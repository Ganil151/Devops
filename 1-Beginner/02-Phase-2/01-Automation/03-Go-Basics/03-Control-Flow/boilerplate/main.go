package main

import (
	"fmt"
	"os"
)

// DevOps Context: Health check endpoints and service status validation
// require conditional logic to determine system state.

func main() {
	// Simulated service checks
	diskUsage := 85        // percentage
	memoryAvailable := 2048 // MB
	activeConnections := 150

	fmt.Println("=== Service Health Check ===")

	// Multi-condition health check
	if diskUsage > 90 {
		fmt.Println("❌ CRITICAL: Disk usage above 90%")
		os.Exit(2)
	} else if diskUsage > 80 {
		fmt.Println("⚠️  WARNING: Disk usage above 80%")
	} else {
		fmt.Println("✅ Disk usage normal")
	}

	// Switch-based routing (like HTTP status codes)
	healthStatus := getHealthStatus(diskUsage, memoryAvailable, activeConnections)
	
	switch healthStatus {
	case "healthy":
		fmt.Println("✅ All systems operational")
		os.Exit(0)
	case "degraded":
		fmt.Println("⚠️  System degraded - monitoring required")
		os.Exit(1)
	case "critical":
		fmt.Println("❌ System critical - immediate action required")
		os.Exit(2)
	default:
		fmt.Println("❓ Unknown status")
		os.Exit(3)
	}
}

func getHealthStatus(disk int, memory int, connections int) string {
	if disk > 90 || memory < 1024 || connections > 1000 {
		return "critical"
	}
	if disk > 80 || memory < 2048 || connections > 500 {
		return "degraded"
	}
	return "healthy"
}
