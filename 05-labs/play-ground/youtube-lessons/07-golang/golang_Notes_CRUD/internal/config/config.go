// internal/config/config.go
package config

import (
	"fmt"
	"os"
	"github.com/joho/godotenv"
)

type Config struct {
	MongoURI      string
	MongoDBName   string
	ServerPort    string
	ServerMode    string
	MongoColl     string
}

func Load() (*Config, error) {
	// Silently ignore if .env not found (prod uses env vars)
	_ = godotenv.Load()

	mongoURI, err := extract("MONGO_URI")  // ✅ No spaces
	if err != nil {
		return nil, fmt.Errorf("failed to extract MONGO_URI: %w", err)
	}

	mongoDBName, err := extract("MONGO_DB_NAME")
	if err != nil {
		return nil, fmt.Errorf("failed to extract MONGO_DB_NAME: %w", err)
	}

	serverPort, err := extract("SERVER_PORT")
	if err != nil {
		return nil, fmt.Errorf("failed to extract SERVER_PORT: %w", err)
	}

	serverMode, err := extract("SERVER_MODE")
	if err != nil {
		return nil, fmt.Errorf("failed to extract SERVER_MODE: %w", err)
	}

	mongoColl, err := extract("MONGO_DB_COLLECTION")  // ✅ Singular, matches usage
	if err != nil {
		return nil, fmt.Errorf("failed to extract MONGO_DB_COLLECTION: %w", err)
	}

	return &Config{
		MongoURI:      mongoURI,
		MongoDBName:   mongoDBName,
		ServerPort:    serverPort,
		ServerMode:    serverMode,
		MongoColl:     mongoColl,
	}, nil
}

func extract(key string) (string, error) {
	val := os.Getenv(key)
	if val == "" {
		return "", fmt.Errorf("environment variable not set: %s", key)
	}
	return val, nil
}