// internal/db/mongo.go
package db

import (
	"context"
	"fmt"
	"notes-api/internal/config"
	"time"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func Connect(cfg config.Config) (*mongo.Client, *mongo.Database, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)  // ✅ Added *
	defer cancel()
	
	clientOpts := options.Client().ApplyURI(cfg.MongoURI)
	client, err := mongo.Connect(ctx, clientOpts)
	if err != nil {
		return nil, nil, fmt.Errorf("connect to MongoDB failed: %w", err)
	}
	
	if err := client.Ping(ctx, nil); err != nil {
		return nil, nil, fmt.Errorf("ping MongoDB failed: %w", err)
	}
	
	database := client.Database(cfg.MongoDBName)
	return client, database, nil
}

func Disconnect(client *mongo.Client) error {  // ✅ Pointer receiver
	if client == nil {
		return nil
	}
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)  // ✅ Added *
	defer cancel()
	return client.Disconnect(ctx)
}