# Production Scenario: Enterprise Self-Healing Operator

## Overview
This boilerplate demonstrates a custom Kubernetes Controller designed for **Complex Systems Orchestration**. Unlike basic tutorials, this implementation focuses on high-concurrency, rate-limiting, and graceful degradation.

### Real-World Use Case
Imagine a production environment where high-traffic microservices occasionally enter a `CrashLoopBackOff` state due to transient resource exhaustion. This operator monitors these services and applies a "Healer" logic that:
1.  **Detects Failures**: Uses `client-go` informers to monitor pod status in real-time.
2.  **Circuit Breaking**: Prevents mass-deletion of pods if the failure rate exceeds a specific threshold (e.g., more than 20% of the namespace is down).
3.  **Rate Limiting**: Uses a `workqueue` to ensure that healing actions do not overwhelm the K8s API server.

## "What happens if the API rate limit is reached?"
The script implements a `RateLimitingInterface`. If the Kubernetes API server returns a 429 (Too Many Requests) or if the controller itself detects high latency, the `handleErr` function uses an exponential backoff strategy.
-   **Immediate Failure**: If the API is completely unreachable, the controller enters a "Degraded Mode" where it stops all mutations and only logs events until connectivity is restored.
-   **Graceful Shutdown**: The controller listens for `SIGTERM`/`SIGINT` to ensure that the work queue is drained and workers finish their current tasks before exiting, preventing orphaned state in the cluster.

## Key Features
-   **Worker Pool Pattern**: Scalable background workers to handle massive resource updates.
-   **Shared Informers**: Optimized resource caching to minimize API traffic.
-   **Circuit Breaker Logic**: (Simulated) prevents cascading failures.
