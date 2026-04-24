package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"resilient"
)

func main() {
	// Create a resilient client
	client := resilient.NewClient(resilient.Config{
		BaseURL:        "http://localhost:8080",
		MaxRetries:     3,
		Timeout:        5 * time.Second,
		CircuitBreaker: true,
		BaseDelay:      100 * time.Millisecond,
		MaxDelay:       2 * time.Second,
	})

	ctx := context.Background()

	// Example 1: Simple GET request
	fmt.Println("=== Example 1: GET Request ===")
	response, err := client.Get(ctx, "/api/health")
	if err != nil {
		log.Printf("GET request failed: %v", err)
	} else {
		fmt.Printf("Response: %s\n", response)
	}

	// Example 2: POST request with payload
	fmt.Println("\n=== Example 2: POST Request ===")
	orderPayload := map[string]interface{}{
		"product_id": "ABC123",
		"quantity":   5,
		"user_id":    "user-456",
	}

	response, err = client.Post(ctx, "/api/orders", orderPayload)
	if err != nil {
		log.Printf("POST request failed: %v", err)
	} else {
		fmt.Printf("Response: %s\n", response)
	}

	// Example 3: Request with custom headers
	fmt.Println("\n=== Example 3: Request with Headers ===")
	headers := map[string]string{
		"Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
		"X-Request-ID":  "req-789",
		"X-Tenant-ID":   "tenant-001",
	}

	response, err = client.PostWithHeaders(ctx, "/api/payments", map[string]interface{}{
		"amount":   99.99,
		"currency": "USD",
	}, headers)
	if err != nil {
		log.Printf("Request with headers failed: %v", err)
	} else {
		fmt.Printf("Response: %s\n", response)
	}

	// Example 4: Request with timeout context
	fmt.Println("\n=== Example 4: Request with Timeout ===")
	ctxWithTimeout, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	response, err = client.Get(ctxWithTimeout, "/api/slow-endpoint")
	if err != nil {
		log.Printf("Request with timeout failed: %v", err)
	} else {
		fmt.Printf("Response: %s\n", response)
	}

	// Example 5: Display metrics
	fmt.Println("\n=== Client Metrics ===")
	metrics := client.GetMetrics()
	fmt.Printf("Total Requests:      %d\n", metrics.TotalRequests)
	fmt.Printf("Successful Requests: %d\n", metrics.SuccessfulRequests)
	fmt.Printf("Failed Requests:     %d\n", metrics.FailedRequests)
	fmt.Printf("Circuit Open Count:  %d\n", metrics.CircuitOpenCount)
	fmt.Printf("Retry Count:         %d\n", metrics.RetryCount)

	if metrics.TotalRequests > 0 {
		successRate := float64(metrics.SuccessfulRequests) / float64(metrics.TotalRequests) * 100
		fmt.Printf("Success Rate:        %.2f%%\n", successRate)
	}

	// Example 6: Simulating circuit breaker behavior
	fmt.Println("\n=== Example 6: Circuit Breaker Test ===")
	fmt.Println("Sending multiple requests to a failing endpoint...")

	for i := 0; i < 10; i++ {
		_, err := client.Get(ctx, "/api/failing-endpoint")
		if err != nil {
			fmt.Printf("Request %d failed: %v\n", i+1, err)
		}
		time.Sleep(100 * time.Millisecond)
	}

	fmt.Println("\n=== Final Metrics ===")
	finalMetrics := client.GetMetrics()
	fmt.Printf("Total Requests:      %d\n", finalMetrics.TotalRequests)
	fmt.Printf("Successful Requests: %d\n", finalMetrics.SuccessfulRequests)
	fmt.Printf("Failed Requests:     %d\n", finalMetrics.FailedRequests)
	fmt.Printf("Circuit Open Count:  %d\n", finalMetrics.CircuitOpenCount)
	fmt.Printf("Retry Count:         %d\n", finalMetrics.RetryCount)
}

// Example output:
//
// === Example 1: GET Request ===
// Response: {"status": "healthy"}
//
// === Example 2: POST Request ===
// Response: {"order_id": "ORD-123", "status": "created"}
//
// === Example 3: Request with Headers ===
// Response: {"payment_id": "PAY-456", "status": "processed"}
//
// === Example 4: Request with Timeout ===
// Request with timeout failed: context deadline exceeded
//
// === Client Metrics ===
// Total Requests:      4
// Successful Requests: 3
// Failed Requests:     1
// Circuit Open Count:  0
// Retry Count:         2
// Success Rate:        75.00%
