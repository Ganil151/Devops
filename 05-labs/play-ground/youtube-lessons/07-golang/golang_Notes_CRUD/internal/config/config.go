package config

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	MongoURI   string
	MongoDBName string
	ServerPort  string
	ServerMode  string
	MongoColl string
}

func Load() (*Config, error) {
	if err := godotenv.Load(); err != nil {
		return nil, fmt.Errorf("failed to load .env file: %w", err)
	}

	mongoURI, err := extract("MONGO_URI")
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

	mongoColl, err := extract("MONGO_DB_COLLECTIONS")
	if err != nil {
		return nil, fmt.Errorf("failed to extract MONGO_DB_COLLECTIONS: %w", err)
	}

	return &Config{
		MongoURI:   mongoURI,
		MongoDBName: mongoDBName,
		ServerPort:  serverPort,
		ServerMode:  serverMode,
		MongoColl: mongoColl,
	}, nil
}

// extract Helper 
func extract(key string) (string, error) {
	val := os.Getenv(key)
	if val == "" {
		return "", fmt.Errorf("environment variable not set: %s", key)
	}
	return val, nil
}