package resilient

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sync/atomic"
	"time"

	"github.com/sony/gobreaker"
)

// Config holds the configuration for the resilient client
type Config struct {
	BaseURL        string
	MaxRetries     int
	Timeout        time.Duration
	CircuitBreaker bool

	// Circuit Breaker Settings
	CBMaxRequests uint32
	CBInterval    time.Duration
	CBTimeout     time.Duration

	// Retry Settings
	BaseDelay time.Duration
	MaxDelay  time.Duration
}

// Client is a resilient HTTP client with circuit breaker and retry logic
type Client struct {
	config        Config
	httpClient    *http.Client
	circuitBreaker *gobreaker.CircuitBreaker
	metrics       Metrics
}

// Metrics tracks client performance metrics
type Metrics struct {
	TotalRequests      int64
	SuccessfulRequests int64
	FailedRequests     int64
	CircuitOpenCount   int64
	RetryCount         int64
}

// NewClient creates a new resilient HTTP client
func NewClient(config Config) *Client {
	// Set defaults
	if config.MaxRetries == 0 {
		config.MaxRetries = 3
	}
	if config.Timeout == 0 {
		config.Timeout = 5 * time.Second
	}
	if config.BaseDelay == 0 {
		config.BaseDelay = 100 * time.Millisecond
	}
	if config.MaxDelay == 0 {
		config.MaxDelay = 5 * time.Second
	}
	if config.CBMaxRequests == 0 {
		config.CBMaxRequests = 5
	}
	if config.CBInterval == 0 {
		config.CBInterval = 60 * time.Second
	}
	if config.CBTimeout == 0 {
		config.CBTimeout = 30 * time.Second
	}

	client := &Client{
		config: config,
		httpClient: &http.Client{
			Timeout: config.Timeout,
			Transport: &http.Transport{
				MaxIdleConns:        100,
				MaxIdleConnsPerHost: 10,
				IdleConnTimeout:     90 * time.Second,
			},
		},
	}

	if config.CircuitBreaker {
		client.circuitBreaker = gobreaker.NewCircuitBreaker(gobreaker.Settings{
			Name:        "resilient-client",
			MaxRequests: config.CBMaxRequests,
			Interval:    config.CBInterval,
			Timeout:     config.CBTimeout,
			ReadyToTrip: func(counts gobreaker.Counts) bool {
				failureRatio := float64(counts.TotalFailures) / float64(counts.Requests)
				return counts.Requests >= 3 && failureRatio >= 0.6
			},
			OnStateChange: func(name string, from gobreaker.State, to gobreaker.State) {
				fmt.Printf("[Circuit Breaker] State changed from %s to %s\n", from, to)
			},
		})
	}

	return client
}

// Get performs a GET request with retries and circuit breaking
func (c *Client) Get(ctx context.Context, path string) ([]byte, error) {
	return c.doRequest(ctx, "GET", path, nil, nil)
}

// Post performs a POST request with retries and circuit breaking
func (c *Client) Post(ctx context.Context, path string, payload interface{}) ([]byte, error) {
	return c.doRequest(ctx, "POST", path, payload, nil)
}

// PostWithHeaders performs a POST request with custom headers
func (c *Client) PostWithHeaders(ctx context.Context, path string, payload interface{}, headers map[string]string) ([]byte, error) {
	return c.doRequest(ctx, "POST", path, payload, headers)
}

// doRequest executes the HTTP request with retry logic and circuit breaker
func (c *Client) doRequest(ctx context.Context, method, path string, payload interface{}, headers map[string]string) ([]byte, error) {
	atomic.AddInt64(&c.metrics.TotalRequests, 1)

	url := c.config.BaseURL + path

	// Wrap in circuit breaker if enabled
	if c.circuitBreaker != nil {
		result, err := c.circuitBreaker.Execute(func() (interface{}, error) {
			return c.executeWithRetry(ctx, method, url, payload, headers)
		})
		if err != nil {
			atomic.AddInt64(&c.metrics.FailedRequests, 1)
			if err == gobreaker.ErrOpenState {
				atomic.AddInt64(&c.metrics.CircuitOpenCount, 1)
			}
			return nil, err
		}
		atomic.AddInt64(&c.metrics.SuccessfulRequests, 1)
		return result.([]byte), nil
	}

	// Without circuit breaker
	result, err := c.executeWithRetry(ctx, method, url, payload, headers)
	if err != nil {
		atomic.AddInt64(&c.metrics.FailedRequests, 1)
		return nil, err
	}
	atomic.AddInt64(&c.metrics.SuccessfulRequests, 1)
	return result, nil
}

// executeWithRetry executes the request with exponential backoff retries
func (c *Client) executeWithRetry(ctx context.Context, method, url string, payload interface{}, headers map[string]string) ([]byte, error) {
	var lastErr error

	for attempt := 0; attempt <= c.config.MaxRetries; attempt++ {
		if attempt > 0 {
			atomic.AddInt64(&c.metrics.RetryCount, 1)
			delay := calculateBackoff(attempt, c.config.BaseDelay, c.config.MaxDelay)
			fmt.Printf("[Retry] Attempt %d after %v\n", attempt, delay)

			select {
			case <-time.After(delay):
			case <-ctx.Done():
				return nil, ctx.Err()
			}
		}

		resp, err := c.executeRequest(ctx, method, url, payload, headers)
		if err == nil {
			return resp, nil
		}

		lastErr = err

		// Don't retry on context cancellation or 4xx errors
		if ctx.Err() != nil {
			return nil, ctx.Err()
		}
		if !isRetryable(err) {
			return nil, err
		}
	}

	return nil, fmt.Errorf("max retries exceeded: %w", lastErr)
}

// executeRequest performs the actual HTTP request
func (c *Client) executeRequest(ctx context.Context, method, url string, payload interface{}, headers map[string]string) ([]byte, error) {
	var bodyReader io.Reader

	if payload != nil {
		jsonData, err := json.Marshal(payload)
		if err != nil {
			return nil, fmt.Errorf("failed to marshal payload: %w", err)
		}
		bodyReader = bytes.NewReader(jsonData)
	}

	req, err := http.NewRequestWithContext(ctx, method, url, bodyReader)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	// Set headers
	req.Header.Set("Content-Type", "application/json")
	for key, value := range headers {
		req.Header.Set(key, value)
	}

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	if resp.StatusCode >= 400 {
		return nil, fmt.Errorf("HTTP %d: %s", resp.StatusCode, string(body))
	}

	return body, nil
}

// GetMetrics returns current client metrics
func (c *Client) GetMetrics() Metrics {
	return Metrics{
		TotalRequests:      atomic.LoadInt64(&c.metrics.TotalRequests),
		SuccessfulRequests: atomic.LoadInt64(&c.metrics.SuccessfulRequests),
		FailedRequests:     atomic.LoadInt64(&c.metrics.FailedRequests),
		CircuitOpenCount:   atomic.LoadInt64(&c.metrics.CircuitOpenCount),
		RetryCount:         atomic.LoadInt64(&c.metrics.RetryCount),
	}
}

// isRetryable determines if an error is retryable
func isRetryable(err error) bool {
	// Retry on network errors, 5xx errors
	// Don't retry on 4xx (client errors)
	if err == nil {
		return false
	}
	// Add logic to parse HTTP status codes
	return true // Simplified for boilerplate
}
