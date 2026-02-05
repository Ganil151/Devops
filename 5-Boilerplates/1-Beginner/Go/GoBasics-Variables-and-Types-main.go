package main

import (
	"fmt"
	"os"
	"strconv"
	"time"
)

// DevOps Context: Type-safe configuration parsing is essential
// for reading environment variables and config files without runtime errors.

type ServerConfig struct {
	Host         string
	Port         int
	Timeout      time.Duration
	EnableDebug  bool
	MaxRetries   int
}

func main() {
	// Reading environment variables with type conversion
	config := ServerConfig{
		Host:        getEnv("SERVER_HOST", "localhost"),
		Port:        getEnvAsInt("SERVER_PORT", 8080),
		Timeout:     getEnvAsDuration("SERVER_TIMEOUT", 30*time.Second),
		EnableDebug: getEnvAsBool("DEBUG", false),
		MaxRetries:  getEnvAsInt("MAX_RETRIES", 3),
	}

	fmt.Println("=== Server Configuration ===")
	fmt.Printf("Host: %s (type: %T)\n", config.Host, config.Host)
	fmt.Printf("Port: %d (type: %T)\n", config.Port, config.Port)
	fmt.Printf("Timeout: %s (type: %T)\n", config.Timeout, config.Timeout)
	fmt.Printf("Debug Mode: %t (type: %T)\n", config.EnableDebug, config.EnableDebug)
	fmt.Printf("Max Retries: %d (type: %T)\n", config.MaxRetries, config.MaxRetries)

	// Type safety validation
	fmt.Println("\n=== Type Safety Check ===")
	if config.Port > 0 && config.Port <= 65535 {
		fmt.Println("✅ Port number is valid")
	} else {
		fmt.Println("❌ Invalid port number")
		os.Exit(1)
	}
}

// Helper functions for type-safe env parsing
func getEnv(key, defaultVal string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultVal
}

func getEnvAsInt(key string, defaultVal int) int {
	if valueStr := os.Getenv(key); valueStr != "" {
		if value, err := strconv.Atoi(valueStr); err == nil {
			return value
		}
		fmt.Fprintf(os.Stderr, "Warning: Invalid integer for %s, using default\n", key)
	}
	return defaultVal
}

func getEnvAsDuration(key string, defaultVal time.Duration) time.Duration {
	if valueStr := os.Getenv(key); valueStr != "" {
		if value, err := time.ParseDuration(valueStr); err == nil {
			return value
		}
		fmt.Fprintf(os.Stderr, "Warning: Invalid duration for %s, using default\n", key)
	}
	return defaultVal
}

func getEnvAsBool(key string, defaultVal bool) bool {
	if valueStr := os.Getenv(key); valueStr != "" {
		if value, err := strconv.ParseBool(valueStr); err == nil {
			return value
		}
		fmt.Fprintf(os.Stderr, "Warning: Invalid boolean for %s, using default\n", key)
	}
	return defaultVal
}
