package main

import (
	"fmt"
	"testing"
)

// DevOps Context: Unit testing infrastructure code to prevent regressions

// Function to test: Calculate resource requirements
func CalculateResources(replicas int, cpuPerPod int) int {
	if replicas < 0 {
		return 0
	}
	return replicas * cpuPerPod
}

// Function to test: Validate environment name
func ValidateEnv(env string) bool {
	allowed := []string{"dev", "staging", "prod"}
	for _, a := range allowed {
		if env == a {
			return true
		}
	}
	return false
}

// This is a "test" file in the boilerplate package to demonstrate
// But usually tests live in _test.go files
func main() {
	// Manual test runner simulation
	fmt.Println("=== Running Tests ===")
	
	// Test 1
	got := CalculateResources(5, 100)
	want := 500
	if got != want {
		fmt.Printf("❌ CalculateResources(5, 100) = %d; want %d\n", got, want)
	} else {
		fmt.Println("✅ CalculateResources passed")
	}
	
	// Test 2
	if !ValidateEnv("prod") {
		fmt.Println("❌ ValidateEnv('prod') failed")
	} else {
		fmt.Println("✅ ValidateEnv passed")
	}
}

// NOTE: in real Go projects, use 'go test ./...'
