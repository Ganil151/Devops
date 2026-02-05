package main

import (
	"fmt"
	"log"
	"os"
	"strconv"
)

// DevOps Context: 12-factor app configuration via environment variables

type AppConfig struct {
	Port        int
	DatabaseURL string
	LogLevel    string
	Debug       bool
	MaxWorkers  int
}

func main() {
	config := loadConfig()
	
	fmt.Println("=== Application Configuration ===")
	fmt.Printf("Port: %d\n", config.Port)
	fmt.Printf("Database: %s\n", maskSensitive(config.DatabaseURL))
	fmt.Printf("Log Level: %s\n", config.LogLevel)
	fmt.Printf("Debug Mode: %t\n", config.Debug)
	fmt.Printf("Max Workers: %d\n", config.MaxWorkers)
	
	// Validate configuration
	if err := validateConfig(config); err != nil {
		log.Fatalf("Invalid configuration: %v", err)
	}
	
	fmt.Println("\n✅ Configuration loaded and validated")
}

func loadConfig() AppConfig {
	return AppConfig{
		Port:        getEnvAsInt("PORT", 8080),
		DatabaseURL: getEnv("DATABASE_URL", "postgres://localhost:5432/myapp"),
		LogLevel:    getEnv("LOG_LEVEL", "info"),
		Debug:       getEnvAsBool("DEBUG", false),
		MaxWorkers:  getEnvAsInt("MAX_WORKERS", 10),
	}
}

func getEnv(key, defaultVal string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return defaultVal
}

func getEnvAsInt(key string, defaultVal int) int {
	if valStr := os.Getenv(key); valStr != "" {
		if val, err := strconv.Atoi(valStr); err == nil {
			return val
		}
		log.Printf("Warning: Invalid integer for %s, using default", key)
	}
	return defaultVal
}

func getEnvAsBool(key string, defaultVal bool) bool {
	if valStr := os.Getenv(key); valStr != "" {
		if val, err := strconv.ParseBool(valStr); err == nil {
			return val
		}
		log.Printf("Warning: Invalid boolean for %s, using default", key)
	}
	return defaultVal
}

func validateConfig(cfg AppConfig) error {
	if cfg.Port < 1 || cfg.Port > 65535 {
		return fmt.Errorf("invalid port: %d", cfg.Port)
	}
	if cfg.MaxWorkers < 1 {
		return fmt.Errorf("max workers must be positive")
	}
	return nil
}

func maskSensitive(s string) string {
	if len(s) > 20 {
		return s[:10] + "..." + s[len(s)-5:]
	}
	return "***"
}
