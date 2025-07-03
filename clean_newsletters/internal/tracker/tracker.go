package tracker

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"
)

type EmailStatus string

const (
	StatusSubscribed   EmailStatus = "subscribed"
	StatusUnsubscribed EmailStatus = "unsubscribed"
	StatusUnknown      EmailStatus = "unknown"
)

type EmailRecord struct {
	Email      string      `json:"email"`
	Domain     string      `json:"domain"`
	Status     EmailStatus `json:"status"`
	FirstSeen  time.Time   `json:"first_seen"`
	LastSeen   time.Time   `json:"last_seen"`
	SeenCount  int         `json:"seen_count"`
	LastAction time.Time   `json:"last_action,omitempty"`
}

type Tracker struct {
	mu       sync.RWMutex
	records  map[string]*EmailRecord
	filePath string
}

func NewTracker(profile string) (*Tracker, error) {
	dir := fmt.Sprintf("%s/.config/clean_newsletters/%s", os.Getenv("HOME"), profile)
	os.MkdirAll(dir, 0700)
	
	filePath := filepath.Join(dir, "newsletter_tracker.json")
	
	t := &Tracker{
		records:  make(map[string]*EmailRecord),
		filePath: filePath,
	}
	
	if err := t.load(); err != nil && !os.IsNotExist(err) {
		return nil, fmt.Errorf("failed to load tracker data: %v", err)
	}
	
	return t, nil
}

func (t *Tracker) load() error {
	data, err := os.ReadFile(t.filePath)
	if err != nil {
		return err
	}
	
	return json.Unmarshal(data, &t.records)
}

func (t *Tracker) save() error {
	data, err := json.MarshalIndent(t.records, "", "  ")
	if err != nil {
		return err
	}
	
	return os.WriteFile(t.filePath, data, 0600)
}

func (t *Tracker) RecordEmail(email string, status EmailStatus) error {
	t.mu.Lock()
	defer t.mu.Unlock()
	
	key := strings.ToLower(email)
	domain := extractDomain(email)
	
	if record, exists := t.records[key]; exists {
		record.LastSeen = time.Now()
		record.SeenCount++
		if record.Status != status {
			record.Status = status
			record.LastAction = time.Now()
		}
	} else {
		t.records[key] = &EmailRecord{
			Email:     email,
			Domain:    domain,
			Status:    status,
			FirstSeen: time.Now(),
			LastSeen:  time.Now(),
			SeenCount: 1,
		}
	}
	
	return t.save()
}

func (t *Tracker) GetStatus(email string) EmailStatus {
	t.mu.RLock()
	defer t.mu.RUnlock()
	
	key := strings.ToLower(email)
	if record, exists := t.records[key]; exists {
		return record.Status
	}
	
	// Check if domain is known
	domain := extractDomain(email)
	for _, record := range t.records {
		if record.Domain == domain && record.Status != StatusUnknown {
			return record.Status
		}
	}
	
	return StatusUnknown
}

func (t *Tracker) GetSubscribedEmails() []string {
	t.mu.RLock()
	defer t.mu.RUnlock()
	
	var subscribed []string
	for _, record := range t.records {
		if record.Status == StatusSubscribed {
			subscribed = append(subscribed, record.Email)
		}
	}
	
	return subscribed
}

func (t *Tracker) GetStatistics() map[string]interface{} {
	t.mu.RLock()
	defer t.mu.RUnlock()
	
	stats := map[string]interface{}{
		"total_emails":      len(t.records),
		"subscribed_count":  0,
		"unsubscribed_count": 0,
		"unknown_count":     0,
	}
	
	for _, record := range t.records {
		switch record.Status {
		case StatusSubscribed:
			stats["subscribed_count"] = stats["subscribed_count"].(int) + 1
		case StatusUnsubscribed:
			stats["unsubscribed_count"] = stats["unsubscribed_count"].(int) + 1
		case StatusUnknown:
			stats["unknown_count"] = stats["unknown_count"].(int) + 1
		}
	}
	
	return stats
}

func extractDomain(email string) string {
	parts := strings.Split(strings.ToLower(email), "@")
	if len(parts) >= 2 {
		return parts[1]
	}
	return ""
}