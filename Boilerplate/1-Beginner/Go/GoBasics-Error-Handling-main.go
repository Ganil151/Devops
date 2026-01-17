package main

import (
	"errors"
	"fmt"
	"os"
)

// DevOps Context: Proper error handling in deployment automation

var (
	ErrInvalidConfig    = errors.New("invalid configuration")
	ErrConnectionFailed = errors.New("connection failed")
	ErrTimeoutExceeded  = errors.New("timeout exceeded")
)

type DeploymentError struct {
	Stage   string
	Cause   error
	Retryable bool
}

func (e *DeploymentError) Error() string {
	retryMsg := ""
	if e.Retryable {
		retryMsg = " (retryable)"
	}
	return fmt.Sprintf("deployment failed at stage '%s': %v%s", e.Stage, e.Cause, retryMsg)
}

func (e *DeploymentError) Unwrap() error {
	return e.Cause
}

func main() {
	fmt.Println("=== Deployment Error Handling Demo ===\n")
	
	// Attempt deployment
	if err := runDeployment("api-service", "production"); err != nil {
		handleDeploymentError(err)
		os.Exit(1)
	}
	
	fmt.Println("✅ Deployment successful")
}

func runDeployment(app, env string) error {
	// Stage 1: Validate
	if err := validateConfig(app, env); err != nil {
		return &DeploymentError{
			Stage:     "validation",
			Cause:     err,
			Retryable: false,
		}
	}
	
	// Stage 2: Connect
	if err := connectToCluster(env); err != nil {
		return &DeploymentError{
			Stage:     "connection",
			Cause:     err,
			Retryable: true,
		}
	}
	
	// Stage 3: Deploy
	if err := deployApplication(app); err != nil {
		return &DeploymentError{
			Stage:     "deployment",
			Cause:     err,
			Retryable: false,
		}
	}
	
	return nil
}

func validateConfig(app, env string) error {
	if app == "" {
		return fmt.Errorf("%w: app name is required", ErrInvalidConfig)
	}
	if env != "staging" && env != "production" {
		return fmt.Errorf("%w: environment must be staging or production", ErrInvalidConfig)
	}
	fmt.Println("✅ Configuration validated")
	return nil
}

func connectToCluster(env string) error {
	fmt.Printf("Connecting to %s cluster...\n", env)
	// Simulated connection failure
	if env == "production" {
		return fmt.Errorf("%w: unable to reach cluster", ErrConnectionFailed)
	}
	return nil
}

func deployApplication(app string) error {
	fmt.Printf("Deploying %s...\n", app)
	return nil
}

func handleDeploymentError(err error) {
	fmt.Println("\n❌ Deployment Failed")
	fmt.Printf("Error: %v\n", err)
	
	// Type assertion to get detailed error info
	var deployErr *DeploymentError
	if errors.As(err, &deployErr) {
		fmt.Printf("Stage: %s\n", deployErr.Stage)
		fmt.Printf("Retryable: %t\n", deployErr.Retryable)
		
		if deployErr.Retryable {
			fmt.Println("💡 Suggestion: Retry the deployment")
		} else {
			fmt.Println("💡 Suggestion: Fix configuration and retry")
		}
	}
	
	// Check for specific error types
	if errors.Is(err, ErrInvalidConfig) {
		fmt.Println("🔧 Action: Review deployment configuration")
	} else if errors.Is(err, ErrConnectionFailed) {
		fmt.Println("🔧 Action: Check network connectivity")
	}
}
