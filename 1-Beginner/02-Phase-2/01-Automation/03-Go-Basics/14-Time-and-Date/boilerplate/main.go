package main

import (
	"fmt"
	"time"
)

// DevOps Context: Scheduling, timeouts, and log timestamps

func main() {
	// Scenario 1: Formatting Timestamps
	now := time.Now()
	fmt.Println("=== Timestamp Formatting ===")
	fmt.Println("Default:   ", now)
	fmt.Println("RFC3339:   ", now.Format(time.RFC3339))
	fmt.Println("Log Format:", now.Format("2006/01/02 15:04:05"))
	fmt.Println("Unix:      ", now.Unix())

	// Scenario 2: Duration and Timeouts
	fmt.Println("\n=== Durations ===")
	start := time.Now()
	
	performTask()
	
	elapsed := time.Since(start)
	fmt.Printf("Task took: %s\n", elapsed)
	
	if elapsed > 100*time.Millisecond {
		fmt.Println("⚠️  Warning: Task is slow")
	}

	// Scenario 3: Date Arithmetic (e.g., Log Retention)
	fmt.Println("\n=== Date Arithmetic ===")
	retentionDays := 30
	cutoffDate := now.AddDate(0, 0, -retentionDays)
	fmt.Printf("Log Cleanup Cutoff: %s\n", cutoffDate.Format("2006-01-02"))
}

func performTask() {
	// Simulate work
	time.Sleep(50 * time.Millisecond)
}
