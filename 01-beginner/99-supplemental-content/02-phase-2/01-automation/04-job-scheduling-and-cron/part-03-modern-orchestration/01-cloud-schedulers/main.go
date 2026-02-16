package main

import (
	"fmt"
	"time"

	"github.com/robfig/cron/v3"
)

// ---------------------------------------------------------------------
// GO HIGH-PRECISION SCHEDULER BOILERPLATE
// ---------------------------------------------------------------------
// Requirements: go get github.com/robfig/cron/v3
// ---------------------------------------------------------------------

func main() {
	// 1. Initialize cron with second-level precision (standard cron is minute-level)
	c := cron.New(cron.WithSeconds())

	// 2. Add a task that runs every 10 seconds
	_, err := c.AddFunc("*/10 * * * * *", func() {
		timestamp := time.Now().Format("2006-01-02 15:04:05")
		fmt.Printf("[%s] DISPATCH: Monitoring Agent checking system health...\n", timestamp)
	})

	if err != nil {
		fmt.Printf("ERROR: Failed to schedule task: %v\n", err)
		return
	}

	// 3. Add a "Professional Pattern": A task that simulates a long-running job
	// Note: Standard cron doesn't handle overlap; this library runs tasks in goroutines.
	c.AddFunc("@hourly", func() {
		fmt.Println("INFO: Starting heavy database indexing...")
		time.Sleep(5 * time.Minute)
		fmt.Println("SUCCESS: Indexing complete.")
	})

	// 4. Start the scheduler
	fmt.Println(">>> Enterprise Scheduler Engine Initialized")
	fmt.Println(">>> Press Ctrl+C to stop")
	c.Start()

	// 5. Keep the main function alive
	select {}
}
