# Newsletter Cleaner

A Go tool that automatically identifies and labels newsletters in your Gmail inbox using AI.

## Prerequisites

1. **OpenRouter API Key**: Get one from [openrouter.ai](https://openrouter.ai)
2. **Google OAuth2 Credentials**: 
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Create a new project or select existing
   - Enable Gmail API
   - Create OAuth 2.0 credentials (Desktop application type)
   - Download the credentials JSON

## Setup

1. Set environment variables:
```bash
export OPENROUTER_API_KEY="your-openrouter-api-key"
export OPENROUTER_MODEL="openai/gpt-3.5-turbo"  # Optional, defaults to gpt-3.5-turbo
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/credentials.json"
# Optional: List subscribed newsletters (comma-separated)
export SUBSCRIBED_NEWSLETTERS="noreply@medium.com,newsletter@example.com"
```

2. Build the tool:
```bash
make build
```

## Usage

### Single Account
Run the tool:
```bash
./clean_newsletters
```

### Multiple Accounts
Use account profiles to manage multiple Gmail accounts:

```bash
# Run for personal account
GMAIL_ACCOUNT_PROFILE=personal ./clean_newsletters

# Run for work account  
GMAIL_ACCOUNT_PROFILE=work ./clean_newsletters

# Or use the convenience commands
make run-personal
make run-work

# Process all accounts at once
make run-all
```

Each account profile stores its credentials and OAuth tokens separately in:
- `~/.config/clean_newsletters/{profile}/credentials.json`
- `~/.config/clean_newsletters/{profile}/token.json`

On first run for each profile, you'll be prompted to authenticate with Gmail.

## How it Works

1. Fetches ALL emails from your inbox (both read and unread)
2. Uses AI to identify newsletters
3. Checks if newsletters are from subscribed sources using:
   - Environment variable list (SUBSCRIBED_NEWSLETTERS)
   - Historical tracking data (learns from previous runs)
4. Applies labels:
   - `Newsletter`: For subscribed newsletters
   - `Unsubscribe`: For unwanted newsletters
5. Saves decisions to track subscribed/unsubscribed status

Note: Emails remain unread and in your inbox - only labels are added.

## Tracking System

The tool maintains a persistent database of newsletter decisions:
- Tracks which emails are subscribed vs unsubscribed
- Learns from previous runs to avoid re-checking known senders
- Stores data in `~/.config/clean_newsletters/{profile}/newsletter_tracker.json`
- Shows statistics after each run

The tracking system means:
- First time seeing an email: Uses AI to determine status
- Subsequent times: Uses saved decision (much faster)
- Reduces API calls to OpenAI over time

## Configuration

- **OPENROUTER_API_KEY**: Required for AI newsletter detection via OpenRouter
- **OPENROUTER_MODEL**: Model to use (e.g., "openai/gpt-3.5-turbo", "anthropic/claude-3-haiku")
- **GOOGLE_APPLICATION_CREDENTIALS**: Path to OAuth2 credentials JSON
- **SUBSCRIBED_NEWSLETTERS**: Comma-separated list of email addresses you want to keep

The tool stores OAuth tokens in `~/.config/clean_newsletters/token.json` for future use.

### Available OpenRouter Models
Some popular options:
- `meta-llama/llama-3.3-70b-instruct:groq` (default, using Groq provider for speed)
- `openai/gpt-3.5-turbo` (fast and cheap)
- `openai/gpt-4-turbo`
- `anthropic/claude-3-haiku` (very fast)
- `anthropic/claude-3-sonnet`
- `google/gemini-flash-1.5`

You can specify a provider by appending `:provider` to the model name (e.g., `:groq`, `:together`, `:deepinfra`).

See [OpenRouter models](https://openrouter.ai/models) for full list and pricing.