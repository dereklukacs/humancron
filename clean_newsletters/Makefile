

# Environment variables
export OPENROUTER_API_KEY ?= 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
export OPENROUTER_MODEL ?= meta-llama/llama-3.3-70b-instruct:groq
export GOOGLE_APPLICATION_CREDENTIALS ?= /Users/obsess/codebase/personal-automations/google_oauth_clean_newsletters.json
export GMAIL_ACCOUNT_PROFILE ?= default

build: 
	CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -trimpath \
  	-ldflags="-s -w" -o clean_newsletters .

run: build
	./clean_newsletters

# Run for specific email account profiles
run-personal: build
	GMAIL_ACCOUNT_PROFILE=personal ./clean_newsletters

run-work: build
	GMAIL_ACCOUNT_PROFILE=work ./clean_newsletters

# Run for all configured accounts
run-all: build
	@for profile in default personal work; do \
		echo "Processing account: $$profile"; \
		GMAIL_ACCOUNT_PROFILE=$$profile ./clean_newsletters; \
		echo ""; \
	done

clean:
	rm -f clean_newsletters

test:
	go test ./...

deps:
	go mod download
	go mod tidy
