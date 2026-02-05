# Structs and Methods - DevOps Challenges

## Challenge 1: Docker Container Model
**Scenario**: Model a Docker container with state management.

**Requirements:**
1. Create `Container` struct with: ID, Image, Status, Ports
2. Add methods: `Start()`, `Stop()`, `Restart()`, `GetLogs()`
3. Prevent invalid state transitions (can't stop a stopped container)

**Verification:**
```bash
go run container.go
# Expected: Demonstrates container lifecycle
```

---

## Challenge 2: Deployment Configuration Builder
**Scenario**: Create a builder pattern for deployment configs.

**Requirements:**
1. Create `DeployConfig` struct
2. Add methods: `WithReplicas(int)`, `WithTimeout(duration)`, `WithEnv(map)`
3. Add `Build()` method that validates and returns config

**Verification:**
```bash
go run config-builder.go
# Expected: Creates valid deployment config with method chaining
```

---

## Challenge 3: Load Balancer with Health Tracking
**Scenario**: Model a load balancer that tracks backend health.

**Requirements:**
1. Create `LoadBalancer` struct with slice of `Backend` structs
2. Add method `GetHealthyBackends() []Backend`
3. Add method `RouteRequest() string` (returns healthy backend)

**Verification:**
```bash
go run loadbalancer.go
# Expected: Routes to healthy backends only
```
