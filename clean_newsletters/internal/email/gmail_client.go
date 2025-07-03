package email

import (
	"context"
	"fmt"
	"strings"

	"clean_newsletters/internal/auth"
	"google.golang.org/api/gmail/v1"
)

type GmailClient struct {
	auth *auth.GmailAuth
}

type Email struct {
	ID      string
	From    string
	Subject string
	Body    string
}

func NewGmailClient(auth *auth.GmailAuth) *GmailClient {
	return &GmailClient{
		auth: auth,
	}
}

func (g *GmailClient) ListInboxEmails(ctx context.Context) ([]*Email, error) {
	user := "me"
	
	r, err := g.auth.Service.Users.Messages.List(user).Q("in:inbox").Do()
	if err != nil {
		return nil, fmt.Errorf("unable to retrieve messages: %v", err)
	}

	var emails []*Email
	for _, m := range r.Messages {
		msg, err := g.auth.Service.Users.Messages.Get(user, m.Id).Do()
		if err != nil {
			continue
		}

		email := &Email{
			ID: m.Id,
		}

		for _, header := range msg.Payload.Headers {
			switch header.Name {
			case "From":
				email.From = header.Value
			case "Subject":
				email.Subject = header.Value
			}
		}

		email.Body = extractBody(msg.Payload)
		emails = append(emails, email)
	}

	return emails, nil
}

func (g *GmailClient) CreateLabel(ctx context.Context, name string) error {
	user := "me"
	
	labels, err := g.auth.Service.Users.Labels.List(user).Do()
	if err != nil {
		return fmt.Errorf("unable to list labels: %v", err)
	}

	for _, label := range labels.Labels {
		if label.Name == name {
			return nil
		}
	}

	label := &gmail.Label{
		Name:                name,
		MessageListVisibility: "show",
		LabelListVisibility:  "labelShow",
	}

	_, err = g.auth.Service.Users.Labels.Create(user, label).Do()
	if err != nil {
		return fmt.Errorf("unable to create label: %v", err)
	}

	return nil
}

func (g *GmailClient) ApplyLabel(ctx context.Context, messageID, labelName string) error {
	user := "me"
	
	labels, err := g.auth.Service.Users.Labels.List(user).Do()
	if err != nil {
		return fmt.Errorf("unable to list labels: %v", err)
	}

	var labelID string
	for _, label := range labels.Labels {
		if label.Name == labelName {
			labelID = label.Id
			break
		}
	}

	if labelID == "" {
		return fmt.Errorf("label %s not found", labelName)
	}

	modifyRequest := &gmail.ModifyMessageRequest{
		AddLabelIds: []string{labelID},
	}

	_, err = g.auth.Service.Users.Messages.Modify(user, messageID, modifyRequest).Do()
	if err != nil {
		return fmt.Errorf("unable to apply label: %v", err)
	}

	return nil
}


func extractBody(payload *gmail.MessagePart) string {
	var body string
	
	if payload.Body != nil && payload.Body.Data != "" {
		body = payload.Body.Data
	}

	for _, part := range payload.Parts {
		if part.MimeType == "text/plain" && part.Body != nil && part.Body.Data != "" {
			body = part.Body.Data
			break
		}
		if strings.HasPrefix(part.MimeType, "multipart") {
			body = extractBody(part)
			if body != "" {
				break
			}
		}
	}

	return body
}