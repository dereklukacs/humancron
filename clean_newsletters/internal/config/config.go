package config

import (
	"fmt"
	"os"
	"strings"
)

type Config struct {
	OpenRouterAPIKey   string
	GoogleCredentials  string
	SubscribedEmails   []string
	AccountProfile     string
	OpenRouterModel    string
}

func Load() (*Config, error) {
	cfg := &Config{}

	cfg.OpenRouterAPIKey = os.Getenv("OPENROUTER_API_KEY")
	if cfg.OpenRouterAPIKey == "" {
		return nil, fmt.Errorf("OPENROUTER_API_KEY environment variable is required")
	}

	cfg.OpenRouterModel = os.Getenv("OPENROUTER_MODEL")
	if cfg.OpenRouterModel == "" {
		cfg.OpenRouterModel = "meta-llama/llama-3.3-70b-instruct:groq" // Default model with Groq provider
	}

	// Get account profile (defaults to "default")
	cfg.AccountProfile = os.Getenv("GMAIL_ACCOUNT_PROFILE")
	if cfg.AccountProfile == "" {
		cfg.AccountProfile = "default"
	}

	cfg.GoogleCredentials = os.Getenv("GOOGLE_APPLICATION_CREDENTIALS")
	if cfg.GoogleCredentials == "" {
		credentialsPath := fmt.Sprintf("%s/.config/clean_newsletters/%s/credentials.json", os.Getenv("HOME"), cfg.AccountProfile)
		if _, err := os.Stat(credentialsPath); err == nil {
			cfg.GoogleCredentials = credentialsPath
		} else {
			return nil, fmt.Errorf("GOOGLE_APPLICATION_CREDENTIALS environment variable is required or place credentials at %s", credentialsPath)
		}
	}

	subscribedList := os.Getenv("SUBSCRIBED_NEWSLETTERS")
	if subscribedList != "" {
		cfg.SubscribedEmails = strings.Split(subscribedList, ",")
		for i := range cfg.SubscribedEmails {
			cfg.SubscribedEmails[i] = strings.TrimSpace(cfg.SubscribedEmails[i])
		}
	}

	return cfg, nil
}