# Advanced Challenges: Self-Healing Orchestration

### Challenge 1: The 10k Concurrent Request Test
**Scenario**: Refactor the `processNextItem` logic to handle 10,000 concurrent resource updates per second without memory leakage.
-   **Requirement**: Implement a dynamic worker pool that scales based on queue depth.
-   **Metric**: No more than 2GB of RAM consumption under peak load.

### Challenge 2: Advanced Circuit Breaker
**Scenario**: Implement a real "Stateful Circuit Breaker" in the `restartPod` function.
-   **Requirement**: If the last 5 `Delete` calls failed, the circuit should "Open," and all subsequent calls should fail fast for the next 60 seconds.
-   **Bonus**: Implement a "Half-Open" state where a single canary request is allowed through after the timeout.

### Challenge 3: Multi-Resource Dependency Graph
**Scenario**: The Healer should not restart Pod A if its dependency, Service B, is currently being updated.
-   **Requirement**: Integrate a second Informer for `Services` and check dependency health before acting on `Pods`.
