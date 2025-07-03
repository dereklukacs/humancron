package auth

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/exec"
	"runtime"
	"time"

	"clean_newsletters/internal/config"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"google.golang.org/api/gmail/v1"
	"google.golang.org/api/option"
)

type GmailAuth struct {
	Service *gmail.Service
}

func NewGmailAuth(ctx context.Context, cfg *config.Config) (*GmailAuth, error) {
	b, err := ioutil.ReadFile(cfg.GoogleCredentials)
	if err != nil {
		return nil, fmt.Errorf("unable to read client secret file: %v\n\nPlease ensure you have downloaded your OAuth2 credentials from Google Cloud Console and saved them to %s", err, cfg.GoogleCredentials)
	}

	config, err := google.ConfigFromJSON(b, gmail.GmailModifyScope, gmail.GmailLabelsScope)
	if err != nil {
		return nil, fmt.Errorf("unable to parse client secret file to config: %v", err)
	}

	client := getClient(config, cfg.AccountProfile)
	srv, err := gmail.NewService(ctx, option.WithHTTPClient(client))
	if err != nil {
		return nil, fmt.Errorf("unable to create Gmail service: %v\n\nPlease check your internet connection and try again", err)
	}

	return &GmailAuth{
		Service: srv,
	}, nil
}

func getClient(config *oauth2.Config, profile string) *http.Client {
	tokFile := fmt.Sprintf("%s/.config/clean_newsletters/%s/token.json", os.Getenv("HOME"), profile)
	tok, err := tokenFromFile(tokFile)
	if err != nil {
		tok = getTokenFromWeb(config)
		saveToken(tokFile, tok, profile)
	}
	return config.Client(context.Background(), tok)
}

func getTokenFromWeb(config *oauth2.Config) *oauth2.Token {
	// Start local server to receive the auth code
	codeChan := make(chan string, 1)
	server := &http.Server{Addr: ":8080"}
	
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		code := r.URL.Query().Get("code")
		if code != "" {
			fmt.Fprintf(w, `<html><body>
				<h1 style="color: green;">✅ Authentication Successful!</h1>
				<p>You can close this window and return to the terminal.</p>
				<script>window.setTimeout(function(){window.close();}, 2000);</script>
			</body></html>`)
			codeChan <- code
		} else {
			fmt.Fprintf(w, `<html><body>
				<h1 style="color: red;">❌ Authentication Failed</h1>
				<p>No authorization code received. Please try again.</p>
			</body></html>`)
		}
	})
	
	// Start server in background
	go func() {
		if err := server.ListenAndServe(); err != http.ErrServerClosed {
			log.Printf("Local server error: %v", err)
		}
	}()
	
	// Update redirect URI to use our local server
	config.RedirectURL = "http://localhost:8080"
	authURL := config.AuthCodeURL("state-token", oauth2.AccessTypeOffline)
	
	fmt.Printf("\n🔐 Gmail Authentication Required\n")
	fmt.Printf("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
	fmt.Printf("Opening browser for authentication...\n")
	fmt.Printf("(A local server is running on port 8080 to receive the auth code)\n\n")
	
	// Try to open the browser automatically
	if err := openBrowser(authURL); err != nil {
		fmt.Printf("Could not open browser automatically.\n")
		fmt.Printf("Please visit this URL manually:\n\n")
		fmt.Printf("%s\n\n", authURL)
	}
	
	// Wait for the authorization code
	fmt.Printf("Waiting for authorization...\n")
	
	var authCode string
	select {
	case authCode = <-codeChan:
		fmt.Printf("Authorization code received!\n")
	case <-time.After(5 * time.Minute):
		server.Shutdown(context.Background())
		log.Fatal("Authentication timeout - no code received within 5 minutes")
	}
	
	// Shutdown the server
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	server.Shutdown(ctx)
	
	tok, err := config.Exchange(context.TODO(), authCode)
	if err != nil {
		log.Fatalf("Unable to retrieve token: %v\n\nError details: %v", err, err)
	}
	
	fmt.Printf("\n✅ Authentication successful! Token saved for future use.\n")
	fmt.Printf("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n")
	
	return tok
}

func openBrowser(url string) error {
	var cmd string
	var args []string

	switch runtime.GOOS {
	case "darwin":
		cmd = "open"
		args = []string{url}
	case "linux":
		cmd = "xdg-open"
		args = []string{url}
	case "windows":
		cmd = "cmd"
		args = []string{"/c", "start", url}
	default:
		return fmt.Errorf("unsupported platform")
	}

	return exec.Command(cmd, args...).Start()
}

func tokenFromFile(file string) (*oauth2.Token, error) {
	f, err := os.Open(file)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	tok := &oauth2.Token{}
	err = json.NewDecoder(f).Decode(tok)
	return tok, err
}

func saveToken(path string, token *oauth2.Token, profile string) {
	dir := fmt.Sprintf("%s/.config/clean_newsletters/%s", os.Getenv("HOME"), profile)
	os.MkdirAll(dir, 0700)
	
	f, err := os.OpenFile(path, os.O_RDWR|os.O_CREATE|os.O_TRUNC, 0600)
	if err != nil {
		log.Printf("Unable to cache oauth token: %v", err)
		return
	}
	defer f.Close()
	json.NewEncoder(f).Encode(token)
}