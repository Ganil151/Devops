package main

import (
	"fmt"
	"regexp"
)

// DevOps Context: Validating input formats and extracting data

func main() {
	// Scenario 1: Validating Hostnames
	// Rules: alphanumeric, dots, hyphens
	hostnameRegex := regexp.MustCompile(`^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])(\.[a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])*$`)
	
	hostnames := []string{"api.example.com", "-invalid", "my-server"}
	
	fmt.Println("=== Hostname Validation ===")
	for _, h := range hostnames {
		if hostnameRegex.MatchString(h) {
			fmt.Printf("✅ %s is valid\n", h)
		} else {
			fmt.Printf("❌ %s is invalid\n", h)
		}
	}

	// Scenario 2: Extracting Semantic Versions
	// Extract major.minor.patch
	versionRegex := regexp.MustCompile(`v?(\d+)\.(\d+)\.(\d+)`)
	input := "Release v1.2.3 (stable)"
	
	fmt.Println("\n=== Version Extraction ===")
	matches := versionRegex.FindStringSubmatch(input)
	if len(matches) == 4 {
		fmt.Printf("Full version: %s\n", matches[0])
		fmt.Printf("Major: %s, Minor: %s, Patch: %s\n", matches[1], matches[2], matches[3])
	}

	// Scenario 3: Replacing text
	// Redact IPs
	ipRegex := regexp.MustCompile(`\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b`)
	logEntry := "Connection from 192.168.1.50 to 10.0.0.1 established"
	redacted := ipRegex.ReplaceAllString(logEntry, "[IP]")
	
	fmt.Println("\n=== IP Redaction ===")
	fmt.Println("Original:", logEntry)
	fmt.Println("Redacted:", redacted)
}
