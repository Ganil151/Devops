package main

import (
	"fmt"
	"runtime"
)

// DevOps Context: Understanding Go version and build information
// is critical for CI/CD environments and cross-platform deployments.

func main() {
	fmt.Println("=== Go Environment Information ===")
	fmt.Printf("Go Version: %s\n", runtime.Version())
	fmt.Printf("Operating System: %s\n", runtime.GOOS)
	fmt.Printf("Architecture: %s\n", runtime.GOARCH)
	fmt.Printf("CPU Cores: %d\n", runtime.NumCPU())
	
	// Simulate DevOps pre-flight check
	fmt.Println("\n=== Pre-flight Validation ===")
	
	if runtime.NumCPU() < 2 {
		fmt.Println("⚠️  WARNING: Low CPU count detected")
	} else {
		fmt.Println("✅ CPU resources sufficient")
	}
	
	if runtime.GOOS == "linux" {
		fmt.Println("✅ Running on Linux (Production-ready)")
	} else {
		fmt.Printf("ℹ️  Running on %s (Dev environment)\n", runtime.GOOS)
	}
}
