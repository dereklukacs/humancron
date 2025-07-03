package main

import (
	"context"
	"fmt"
	"log"

	"clean_newsletters/internal/auth"
	"clean_newsletters/internal/config"
	"clean_newsletters/internal/email"
	"clean_newsletters/internal/newsletter"
)

func main() {
	ctx := context.Background()

	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	authClient, err := auth.NewGmailAuth(ctx, cfg)
	if err != nil {
		log.Fatalf("Failed to authenticate with Gmail: %v", err)
	}

	emailClient := email.NewGmailClient(authClient)
	newsletterProcessor := newsletter.NewProcessor(cfg, emailClient)

	if err := newsletterProcessor.ProcessInbox(ctx); err != nil {
		log.Fatalf("Failed to process inbox: %v", err)
	}

	fmt.Println("Newsletter processing completed successfully")
}