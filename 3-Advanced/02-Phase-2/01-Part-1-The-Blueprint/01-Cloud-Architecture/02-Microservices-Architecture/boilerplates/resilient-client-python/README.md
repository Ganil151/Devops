# Resilient Client - Python Implementation

Production-grade HTTP client with circuit breaker, retries, and timeout handling.

## Features

✅ **Circuit Breaker**: Using `pybreaker` to prevent cascading failures  
✅ **Retry with Exponential Backoff**: Using `tenacity` for robust retry logic  
✅ **Timeout Handling**: Configurable request timeouts  
✅ **Connection Pooling**: Session-based connection reuse  
✅ **Structured Logging**: JSON logging support  

## Installation

```bash
pip install -r requirements.txt
```

### requirements.txt
```
requests>=2.31.0
pybreaker>=1.0.1
tenacity>=8.2.3
```

## Quick Start

```python
from resilient_client import ResilientClient

# Create client instance
client = ResilientClient(
    base_url='http://inventory-service',
    max_retries=3,
    timeout=5.0,
    circuit_breaker=True
)

# Make requests
response = client.get('/api/products/123')
print(response.json())

# POST request
data = {'product_id': '123', 'quantity': 2}
response = client.post('/api/reserve', json=data)
```

## Configuration

```python
class ResilientClient:
    def __init__(
        self,
        base_url: str,
        max_retries: int = 3,
        timeout: float = 5.0,
        circuit_breaker: bool = True,
        
        # Circuit Breaker Settings
        cb_fail_max: int = 5,          # Open after 5 failures
        cb_reset_timeout: int = 30,    # Try Half-Open after 30s
        
        # Retry Settings
        retry_wait_min: float = 0.1,   # Min wait: 100ms
        retry_wait_max: float = 5.0,   # Max wait: 5s
    ):
        ...
```

## Usage Examples

### Basic GET Request

```python
client = ResilientClient(base_url='http://api.example.com')
response = client.get('/users/123')
print(response.json())
```

### POST with Custom Headers

```python
headers = {
    'Authorization': 'Bearer token123',
    'X-Request-ID': 'req-456'
}

response = client.post(
    '/api/orders',
    json={'product_id': 'ABC', 'quantity': 5},
    headers=headers
)
```

### Handle Errors

```python
from resilient_client import CircuitBreakerError, MaxRetriesExceeded

try:
    response = client.get('/api/data')
except CircuitBreakerError:
    # Circuit is open, use fallback
    response = get_cached_data()
except MaxRetriesExceeded:
    # All retries failed
    logger.error("Service unavailable")
    response = None
```

## Architecture

```
┌─────────────────────┐
│   ResilientClient   │
└──────────┬──────────┘
           │
           ▼
┌──────────────────────────┐
│   Circuit Breaker        │
│   (pybreaker)            │
│   States: Closed/Open/   │
│           Half-Open      │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│   Retry Logic            │
│   (tenacity)             │
│   - Exponential Backoff  │
│   - Jitter               │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│   Requests Session       │
│   - Connection Pooling   │
│   - Timeout              │
└──────────────────────────┘
```

## Error Handling

```python
# Custom exceptions
class CircuitBreakerError(Exception):
    """Raised when circuit breaker is open"""
    pass

class MaxRetriesExceeded(Exception):
    """Raised when max retries are exceeded"""
    pass

# Usage
try:
    response = client.get('/api/data')
except CircuitBreakerError:
    logger.warning("Circuit open, using fallback")
    return fallback_data
except MaxRetriesExceeded:
    logger.error("Service unavailable after retries")
    return None
```

## Monitoring

```python
# Get client metrics
metrics = client.get_metrics()

print(f"Total Requests: {metrics['total_requests']}")
print(f"Success Rate: {metrics['success_rate']:.2f}%")
print(f"Circuit Open Count: {metrics['circuit_open_count']}")
print(f"Retry Count: {metrics['retry_count']}")

# Example output:
# Total Requests: 150
# Success Rate: 94.67%
# Circuit Open Count: 2
# Retry Count: 8
```

## Testing

```bash
pytest tests/ -v
```

### Example Test

```python
import pytest
from unittest.mock import Mock, patch
from resilient_client import ResilientClient

def test_successful_request(requests_mock):
    requests_mock.get(
        'http://api.test.com/data',
        json={'status': 'success'}
    )
    
    client = ResilientClient(base_url='http://api.test.com')
    response = client.get('/data')
    
    assert response.json() == {'status': 'success'}

def test_circuit_breaker_opens_after_failures(requests_mock):
    requests_mock.get(
        'http://api.test.com/failing',
        status_code=500
    )
    
    client = ResilientClient(
        base_url='http://api.test.com',
        circuit_breaker=True
    )
    
    # Cause failures to open circuit
    for _ in range(6):
        try:
            client.get('/failing')
        except:
            pass
    
    # Circuit should be open now
    with pytest.raises(CircuitBreakerError):
        client.get('/failing')
```

## Best Practices

### 1. Set Appropriate Timeouts

```python
# For external APIs (higher latency)
external_client = ResilientClient(
    base_url='http://external-api.com',
    timeout=10.0
)

# For internal microservices (low latency)
internal_client = ResilientClient(
    base_url='http://internal-svc',
    timeout=2.0
)
```

### 2. Configure Circuit Breaker Based on SLO

```python
# If service has 99% SLO:
# - Allow 5 failures before opening
# - Reset after 30 seconds
client = ResilientClient(
    base_url='http://critical-service',
    cb_fail_max=5,
    cb_reset_timeout=30
)
```

### 3. Implement Fallback Strategies

```python
def get_user_recommendations(user_id):
    try:
        response = client.get(f'/api/recommendations/{user_id}')
        return response.json()
    except (CircuitBreakerError, MaxRetriesExceeded):
        # Fallback to cached recommendations
        return cache.get(f'recommendations:{user_id}', default=[])
```

### 4. Use Structured Logging

```python
import logging
import json

# Configure JSON logging
logging.basicConfig(
    level=logging.INFO,
    format='%(message)s'
)

logger = logging.getLogger(__name__)

# Log with context
logger.info(json.dumps({
    'event': 'api_request',
    'service': 'inventory-service',
    'endpoint': '/api/reserve',
    'status': 'success',
    'duration_ms': 145
}))
```

## Advanced: Custom Retry Strategy

```python
from tenacity import (
    retry,
    stop_after_attempt,
    wait_exponential,
    retry_if_exception_type
)
import requests

@retry(
    stop=stop_after_attempt(5),
    wait=wait_exponential(multiplier=1, min=1, max=10),
    retry=retry_if_exception_type(requests.exceptions.RequestException)
)
def call_critical_service():
    response = requests.get('http://critical-svc/api/data')
    response.raise_for_status()
    return response.json()
```

## Performance

**Benchmarks** (Python 3.11, AMD Ryzen 9):

```
test_simple_get                    : 0.0234s per request
test_with_circuit_breaker          : 0.0241s per request
test_with_retries (3 attempts)     : 0.0987s per request
```

## Integration with Observability

### OpenTelemetry Integration

```python
from opentelemetry import trace
from opentelemetry.instrumentation.requests import RequestsInstrumentor

# Instrument requests library
RequestsInstrumentor().instrument()

tracer = trace.get_tracer(__name__)

# Requests will automatically create spans
with tracer.start_as_current_span("reserve_inventory"):
    response = client.post('/api/reserve', json=data)
```

### Prometheus Metrics

```python
from prometheus_client import Counter, Histogram

request_counter = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

request_duration = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration'
)

# Track metrics
with request_duration.time():
    response = client.get('/api/data')

request_counter.labels(
    method='GET',
    endpoint='/api/data',
    status=response.status_code
).inc()
```

## Related Files

- [`resilient_client.py`](./resilient_client.py) - Main client implementation
- [`circuit_breaker.py`](./circuit_breaker.py) - Circuit breaker wrapper
- [`examples.py`](./examples.py) - Usage examples
- [`requirements.txt`](./requirements.txt) - Python dependencies

---

**License:** MIT  
**Author:** DevOps Advanced Curriculum
