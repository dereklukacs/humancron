package newsletter

import (
	"context"
	"fmt"
	"log"
	"strings"

	"clean_newsletters/internal/config"
	"clean_newsletters/internal/email"
	"clean_newsletters/internal/llm"
	"clean_newsletters/internal/tracker"
)

const (
	LabelNewsletter   = "Newsletter"
	LabelUnsubscribe = "Unsubscribe"
)

type Processor struct {
	config      *config.Config
	emailClient *email.GmailClient
	llmClient   *llm.OpenRouterClient
	tracker     *tracker.Tracker
}

func NewProcessor(cfg *config.Config, emailClient *email.GmailClient) *Processor {
	llmClient := llm.NewOpenRouterClient(cfg.OpenRouterAPIKey, cfg.OpenRouterModel)

	tracker, err := tracker.NewTracker(cfg.AccountProfile)
	if err != nil {
		log.Fatalf("Failed to create tracker: %v", err)
	}

	return &Processor{
		config:      cfg,
		emailClient: emailClient,
		llmClient:   llmClient,
		tracker:     tracker,
	}
}

func (p *Processor) ProcessInbox(ctx context.Context) error {
	if err := p.emailClient.CreateLabel(ctx, LabelNewsletter); err != nil {
		return fmt.Errorf("failed to create newsletter label: %v", err)
	}

	if err := p.emailClient.CreateLabel(ctx, LabelUnsubscribe); err != nil {
		return fmt.Errorf("failed to create unsubscribe label: %v", err)
	}

	emails, err := p.emailClient.ListInboxEmails(ctx)
	if err != nil {
		return fmt.Errorf("failed to list emails: %v", err)
	}

	fmt.Printf("Found %d emails to process in inbox\n", len(emails))

	for _, email := range emails {
		if err := p.processEmail(ctx, email); err != nil {
			log.Printf("Failed to process email %s: %v", email.ID, err)
			continue
		}
	}

	// Print statistics
	stats := p.tracker.GetStatistics()
	fmt.Printf("\n📊 Newsletter Statistics:\n")
	fmt.Printf("   Total tracked: %d\n", stats["total_emails"])
	fmt.Printf("   Subscribed: %d\n", stats["subscribed_count"])
	fmt.Printf("   Unsubscribed: %d\n", stats["unsubscribed_count"])

	return nil
}

func (p *Processor) processEmail(ctx context.Context, email *email.Email) error {
	isNewsletter, err := p.isNewsletter(ctx, email)
	if err != nil {
		return fmt.Errorf("failed to check if newsletter: %v", err)
	}

	if !isNewsletter {
		fmt.Printf("Email from %s is not a newsletter, skipping\n", email.From)
		return nil
	}

	// Check tracker history first
	status := p.tracker.GetStatus(email.From)
	var isSubscribed bool
	
	switch status {
	case tracker.StatusSubscribed:
		isSubscribed = true
		fmt.Printf("Email from %s is a known subscribed newsletter\n", email.From)
	case tracker.StatusUnsubscribed:
		isSubscribed = false
		fmt.Printf("Email from %s is a known unsubscribed newsletter\n", email.From)
	default:
		// Unknown - use AI to determine
		isSubscribed, err = p.isSubscribedNewsletter(ctx, email)
		if err != nil {
			return fmt.Errorf("failed to check if subscribed: %v", err)
		}
	}

	var label string
	var trackerStatus tracker.EmailStatus
	if isSubscribed {
		label = LabelNewsletter
		trackerStatus = tracker.StatusSubscribed
		if status == tracker.StatusUnknown {
			fmt.Printf("Email from %s is a subscribed newsletter (new)\n", email.From)
		}
	} else {
		label = LabelUnsubscribe
		trackerStatus = tracker.StatusUnsubscribed
		if status == tracker.StatusUnknown {
			fmt.Printf("Email from %s is an unsubscribed newsletter (new)\n", email.From)
		}
	}

	// Record in tracker
	if err := p.tracker.RecordEmail(email.From, trackerStatus); err != nil {
		log.Printf("Failed to record email in tracker: %v", err)
	}

	if err := p.emailClient.ApplyLabel(ctx, email.ID, label); err != nil {
		return fmt.Errorf("failed to apply label: %v", err)
	}

	return nil
}

func (p *Processor) isNewsletter(ctx context.Context, email *email.Email) (bool, error) {
	prompt := fmt.Sprintf(`Analyze the following email and determine if it's a newsletter. 
Consider factors like sender patterns, subject line, content structure, and unsubscribe links.

From: %s
Subject: %s
Body preview: %s

Is this a newsletter? Reply with only YES or NO.`, 
		email.From, 
		email.Subject, 
		truncateString(email.Body, 500))

	response, err := p.llmClient.Complete(ctx, prompt)
	if err != nil {
		return false, err
	}

	response = strings.TrimSpace(strings.ToUpper(response))
	return response == "YES", nil
}

func (p *Processor) isSubscribedNewsletter(ctx context.Context, email *email.Email) (bool, error) {
	// Combine environment variable list with tracker's known subscribed emails
	subscribedList := append(p.config.SubscribedEmails, p.tracker.GetSubscribedEmails()...)
	
	if len(subscribedList) == 0 {
		return false, nil
	}

	prompt := fmt.Sprintf(`Given the following email and list of subscribed newsletter senders, 
determine if this email is from one of the subscribed sources. Consider domain names, 
sender names, and common variations.

Email From: %s
Email Subject: %s

Subscribed Newsletters:
%s

Is this email from a subscribed newsletter source? Reply with only YES or NO.`,
		email.From,
		email.Subject,
		strings.Join(subscribedList, "\n"))

	response, err := p.llmClient.Complete(ctx, prompt)
	if err != nil {
		return false, err
	}

	response = strings.TrimSpace(strings.ToUpper(response))
	return response == "YES", nil
}

func truncateString(s string, maxLen int) string {
	if len(s) <= maxLen {
		return s
	}
	return s[:maxLen] + "..."
}