# Error Handling - DevOps Challenges

## Challenge 1: Retry with Exponential Backoff
**Scenario**: Implement robust retry logic for API calls.

**Requirements:**
1. Create `RetryableError` type
2. Implement exponential backoff (1s, 2s, 4s, 8s)
3. Log each retry attempt
4. Return original error after max retries

**Verification:**
```bash
go run retry-backoff.go
# Expected: Shows increasing delays between retries
```

---

## Challenge 2: Error Aggregation for Parallel Tasks
**Scenario**: Run multiple health checks in parallel and aggregate errors.

**Requirements:**
1. Check 5 services concurrently
2. Collect all errors (don't stop on first)
3. Return custom `MultiError` type with all failures

**Verification:**
```bash
go run parallel-checks.go
# Expected: Reports all failed services, not just first
```

---

## Challenge 3: Circuit Breaker Pattern
**Scenario**: Prevent cascading failures with circuit breaker.

**Requirements:**
1. Create `CircuitBreaker` type with states: Closed, Open, HalfOpen
2. Open after 3 consecutive failures
3. Attempt recovery after timeout

**Verification:**
```bash
go run circuit-breaker.go
# Expected: Shows state transitions: Closed → Open → HalfOpen → Closed
```

---

## Challenge 4 (Advanced): Error Context Enrichment
**Scenario**: Add context to errors as they propagate up the call stack.

**Requirements:**
1. Wrap errors with additional context at each layer
2. Preserve original error for `errors.Is()` checks
3. Create readable error chain for debugging

**Verification:**
```bash
go run error-context.go
# Expected: Shows full error chain with context from each layer
```
