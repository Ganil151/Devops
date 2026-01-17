package main

import (
	"fmt"
	"strings"
	"unicode"
)

// DevOps Context: String processing for log analysis and config generation

func main() {
	// Scenario 1: Log format parsing
	logLine := "[INFO] 2024-01-15 10:30:00 - Service started successfully"
	
	fmt.Println("=== Log Analysis ===")
	if strings.Contains(logLine, "[INFO]") {
		fmt.Println("Type: Information Log")
	}
	
	parts := strings.Split(logLine, " - ")
	if len(parts) >= 2 {
		timestamp := strings.TrimPrefix(parts[0], "[INFO] ")
		message := parts[1]
		fmt.Printf("Time: %s\nMessage: %s\n", timestamp, message)
	}

	// Scenario 2: Config generation from template
	template := "server_name: {{HOST}}; port: {{PORT}}; env: {{ENV}}"
	config := replacePlaceholders(template, map[string]string{
		"HOST": "api-01",
		"PORT": "8080",
		"ENV":  "production",
	})
	
	fmt.Println("\n=== Config Generation ===")
	fmt.Println("Template:", template)
	fmt.Println("Result:  ", config)

	// Scenario 3: Sanitization
	dirtyInput := "  db-user-name  "
	cleanInput := sanitizeInput(dirtyInput)
	fmt.Println("\n=== Input Sanitization ===")
	fmt.Printf("Original: '%s'\n", dirtyInput)
	fmt.Printf("Cleaned:  '%s'\n", cleanInput)
}

func replacePlaceholders(tmpl string, values map[string]string) string {
	result := tmpl
	for key, val := range values {
		placeholder := fmt.Sprintf("{{%s}}", key)
		result = strings.ReplaceAll(result, placeholder, val)
	}
	return result
}

func sanitizeInput(s string) string {
	// Remove whitespace
	s = strings.TrimSpace(s)
	// Normalize to lowercase
	s = strings.ToLower(s)
	// Remove non-alphanumeric chars (simple version)
	return strings.Map(func(r rune) rune {
		if unicode.IsLetter(r) || unicode.IsNumber(r) || r == '-' {
			return r
		}
		return -1
	}, s)
}
