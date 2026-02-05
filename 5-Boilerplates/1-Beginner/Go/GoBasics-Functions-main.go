package main

import (
	"fmt"
	"log"
	"os"
	"time"
)

// DevOps Context: Modular deployment functions for reusability

func main() {
	// Simulate deployment workflow
	appName := "api-service"
	environment := "production"
	version := "v1.2.3"

	if err := deploy(appName, environment, version); err != nil {
		log.Fatalf("Deployment failed: %v", err)
	}
}

func deploy(app, env, version string) error {
	fmt.Printf("🚀 Starting deployment: %s to %s (version: %s)\n", app, env, version)
	
	// Step 1: Validate
	if err := validateDeployment(app, env); err != nil {
		return fmt.Errorf("validation failed: %w", err)
	}
	
	// Step 2: Backup
	backupID := createBackup(app, env)
	fmt.Printf("📦 Backup created: %s\n", backupID)
	
	// Step 3: Deploy
	if err := executeDeployment(app, version); err != nil {
		rollback(backupID)
		return fmt.Errorf("deployment failed: %w", err)
	}
	
	// Step 4: Health check
	if !healthCheck(app, env) {
		rollback(backupID)
		return fmt.Errorf("health check failed after deployment")
	}
	
	fmt.Println("✅ Deployment successful")
	return nil
}

func validateDeployment(app, env string) error {
	if app == "" {
		return fmt.Errorf("app name required")
	}
	if env != "staging" && env != "production" {
		return fmt.Errorf("invalid environment: %s", env)
	}
	fmt.Println("✅ Validation passed")
	return nil
}

func createBackup(app, env string) string {
	backupID := fmt.Sprintf("%s-%s-%d", app, env, time.Now().Unix())
	fmt.Printf("Creating backup: %s...\n", backupID)
	time.Sleep(100 * time.Millisecond) // Simulate work
	return backupID
}

func executeDeployment(app, version string) error {
	fmt.Printf("Deploying %s version %s...\n", app, version)
	time.Sleep(200 * time.Millisecond) // Simulate work
	return nil
}

func healthCheck(app, env string) bool {
	fmt.Printf("Running health check for %s in %s...\n", app, env)
	time.Sleep(150 * time.Millisecond) // Simulate check
	return true
}

func rollback(backupID string) {
	fmt.Printf("🔄 Rolling back to backup: %s\n", backupID)
	time.Sleep(100 * time.Millisecond)
	fmt.Println("❌ Rollback complete")
	os.Exit(1)
}
