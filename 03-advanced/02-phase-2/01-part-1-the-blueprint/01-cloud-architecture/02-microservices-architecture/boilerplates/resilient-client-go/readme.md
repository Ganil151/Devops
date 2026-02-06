# Resilient Client - Go Implementation

Production-grade HTTP client with circuit breaker, retries, and timeout handling.

## Features

✅ **Circuit Breaker**: Using `sony/gobreaker` to prevent cascading failures  
✅ **Exponential Backoff**: Configurable retry strategy with jitter  
✅ **Timeout Handling**: Context-based timeouts  
✅ **Request Pooling**: HTTP connection reuse  
✅ **Structured Logging**: Integration-ready logging  

## Installation

```bash
go get github.com/sony/gobreaker
```

## Quick Start

```go
package main

import (
    "context"
    "fmt"
    "time"
    
    "resilient"
)

func main() {
    client := resilient.NewClient(resilient.Config{
        BaseURL:       "http://inventory-service",
        MaxRetries:    3,
        Timeout:       5 * time.Second,
        CircuitBreaker: true,
    })
    
    ctx := context.Background()
    
    payload := map[string]interface{}{
        "product_id": "123",
        "quantity":   2,
    }
    
    response, err := client.Post(ctx, "/api/reserve", payload)
    if err != nil {
        fmt.Printf("Request failed: %v\n", err)
        return
    }
    
    fmt.Printf("Response: %s\n", response)
}
```

## Configuration

```go
type Config struct {
    BaseURL        string        // Base URL of the service
    MaxRetries     int           // Maximum retry attempts (default: 3)
    Timeout        time.Duration // Request timeout (default: 5s)
    CircuitBreaker bool          // Enable circuit breaker (default: true)
    
    // Circuit Breaker Settings
    CBMaxRequests  uint32        // Max requests in Half-Open state (default: 5)
    CBInterval     time.Duration // Reset interval (default: 60s)
    CBTimeout      time.Duration // Time to wait before Half-Open (default: 30s)
    
    // Retry Settings
    BaseDelay      time.Duration // Initial retry delay (default: 100ms)
    MaxDelay       time.Duration // Maximum retry delay (default: 5s)
}
```

## Usage Examples

### Basic GET Request

```go
response, err := client.Get(ctx, "/api/products/123")
```

### POST with Custom Headers

```go
headers := map[string]string{
    "Authorization": "Bearer token123",
    "X-Request-ID":  "req-456",
}

response, err := client.PostWithHeaders(ctx, "/api/orders", payload, headers)
```

### With Custom Context (Deadline)

```go
ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
defer cancel()

response, err := client.Get(ctx, "/api/health")
```

## Architecture

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────┐
│   Circuit Breaker       │
│  (sony/gobreaker)       │
│  States: Closed/Open/   │
│          Half-Open      │
└──────┬──────────────────┘
       │
       ▼
┌─────────────────────────┐
│   Retry Logic           │
│  - Exponential Backoff  │
│  - Jitter               │
│  - Max Attempts         │
└──────┬──────────────────┘
       │
       ▼
┌─────────────────────────┐
│   HTTP Client           │
│  - Connection Pooling   │
│  - Timeout Handling     │
└─────────────────────────┘
```

## Error Handling

The client returns specific error types:

```go
var (
    ErrCircuitOpen     = errors.New("circuit breaker is open")
    ErrMaxRetriesExceeded = errors.New("max retries exceeded")
    ErrTimeout         = errors.New("request timeout")
)

// Usage
response, err := client.Get(ctx, "/api/data")
if err != nil {
    if errors.Is(err, resilient.ErrCircuitOpen) {
        // Handle circuit open (use fallback)
        return getFallbackData()
    }
    // Handle other errors
}
```

## Monitoring

The client exposes metrics:

```go
type Metrics struct {
    TotalRequests      int64
    SuccessfulRequests int64
    FailedRequests     int64
    CircuitOpenCount   int64
    RetryCount         int64
}

metrics := client.GetMetrics()
fmt.Printf("Success Rate: %.2f%%\n", 
    float64(metrics.SuccessfulRequests) / float64(metrics.TotalRequests) * 100)
```

## Testing

```bash
go test -v ./...
```

### Example Test

```go
func TestClientWithMockServer(t *testing.T) {
    server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(http.StatusOK)
        w.Write([]byte(`{"status": "success"}`))
    }))
    defer server.Close()
    
    client := resilient.NewClient(resilient.Config{
        BaseURL: server.URL,
    })
    
    response, err := client.Get(context.Background(), "/test")
    assert.NoError(t, err)
    assert.Contains(t, string(response), "success")
}
```

## Best Practices

1. **Set Appropriate Timeouts**: Don't wait forever
   ```go
   Config{Timeout: 5 * time.Second}  // For external APIs
   Config{Timeout: 1 * time.Second}  // For internal services
   ```

2. **Configure Circuit Breaker Thresholds**: Based on SLOs
   ```go
   // If service has 99% SLO, open circuit at 5% error rate
   CBInterval: 60 * time.Second,
   CBTimeout:  30 * time.Second,
   ```

3. **Use Context Propagation**: For distributed tracing
   ```go
   ctx = opentelemetry.ContextWithSpan(ctx, span)
   client.Get(ctx, "/api/data")
   ```

4. **Implement Fallbacks**: Always have a backup plan
   ```go
   response, err := client.Get(ctx, "/api/recommendations")
   if err != nil {
       return getCachedRecommendations()
   }
   ```

## Advanced: Custom Circuit Breaker Settings

```go
import "github.com/sony/gobreaker"

settings := gobreaker.Settings{
    Name:        "inventory-service",
    MaxRequests: 5,
    Interval:    60 * time.Second,
    Timeout:     30 * time.Second,
    ReadyToTrip: func(counts gobreaker.Counts) bool {
        failureRatio := float64(counts.TotalFailures) / float64(counts.Requests)
        return counts.Requests >= 10 && failureRatio >= 0.5
    },
    OnStateChange: func(name string, from gobreaker.State, to gobreaker.State) {
        log.Printf("Circuit Breaker '%s' changed from %s to %s", name, from, to)
    },
}

client := resilient.NewClientWithCBSettings(config, settings)
```

## Performance

**Benchmarks** (Go 1.21, AMD Ryzen 9):

```
BenchmarkClientGet-16                10000    115234 ns/op
BenchmarkClientWithCircuitBreaker-16  9500    118432 ns/op
BenchmarkClientWithRetries-16         3200    356789 ns/op
```

## Related Files

- [`main.go`](./main.go) - Example usage
- [`client.go`](./client.go) - Main client implementation
- [`circuit_breaker.go`](./circuit-breaker.go) - Circuit breaker wrapper
- [`retry.go`](./retry.go) - Retry logic with exponential backoff

---

**License:** MIT  
**Author:** DevOps Advanced Curriculum
