package resilient

import (
	"math"
	"math/rand"
	"time"
)

// calculateBackoff computes the delay for the next retry attempt
// using exponential backoff with jitter
func calculateBackoff(attempt int, baseDelay, maxDelay time.Duration) time.Duration {
	// Exponential backoff formula: baseDelay * 2^attempt
	exponentialDelay := float64(baseDelay) * math.Pow(2, float64(attempt))

	// Cap at max delay
	if exponentialDelay > float64(maxDelay) {
		exponentialDelay = float64(maxDelay)
	}

	// Add jitter (random value between 0.5 and 1.0 of the delay)
	// This prevents thundering herd problem
	jitter := 0.5 + rand.Float64()*0.5
	finalDelay := time.Duration(exponentialDelay * jitter)

	return finalDelay
}

// RetryConfig holds retry-specific configuration
type RetryConfig struct {
	MaxAttempts int
	BaseDelay   time.Duration
	MaxDelay    time.Duration
	Jitter      bool
}

// DefaultRetryConfig returns sensible defaults for retry configuration
func DefaultRetryConfig() RetryConfig {
	return RetryConfig{
		MaxAttempts: 3,
		BaseDelay:   100 * time.Millisecond,
		MaxDelay:    5 * time.Second,
		Jitter:      true,
	}
}

// CalculateRetrySchedule generates a schedule of retry delays
func CalculateRetrySchedule(config RetryConfig) []time.Duration {
	schedule := make([]time.Duration, config.MaxAttempts)

	for i := 0; i < config.MaxAttempts; i++ {
		schedule[i] = calculateBackoff(i, config.BaseDelay, config.MaxDelay)
	}

	return schedule
}

// Example retry schedules for different scenarios:
//
// Fast Internal Service (low latency tolerated):
//   Attempt 1: 50ms
//   Attempt 2: 100ms
//   Attempt 3: 200ms
//
// External API (higher latency acceptable):
//   Attempt 1: 500ms
//   Attempt 2: 1s
//   Attempt 3: 2s
//   Attempt 4: 4s
//   Attempt 5: 5s (capped)
