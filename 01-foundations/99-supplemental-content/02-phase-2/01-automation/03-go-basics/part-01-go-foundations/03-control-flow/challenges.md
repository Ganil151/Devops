# Control Flow - DevOps Challenges

## Challenge 1: Deployment Environment Validator
**Scenario**: Validate deployment configuration before executing.

**Requirements:**
1. Check if environment is "dev", "staging", or "prod"
2. For "prod", require additional confirmation flag
3. Exit with appropriate codes: 0 (success), 1 (invalid env), 2 (missing confirmation)

**Verification:**
```bash
go run validator.go prod --confirm
# Expected: ✅ Production deployment authorized
```

---

## Challenge 2: Log Level Router
**Scenario**: Route log messages based on severity level.

**Requirements:**
1. Accept log level (DEBUG, INFO, WARN, ERROR, FATAL)
2. Use switch statement to handle each level
3. For FATAL, print message and exit with code 1

**Verification:**
```bash
go run log-router.go ERROR "Database connection failed"
# Expected: [ERROR] Database connection failed
```

---

## Challenge 3: Multi-Service Status Aggregator
**Scenario**: Check multiple services and determine overall system health.

**Requirements:**
1. Create a function that checks status of 3 services (simulate with variables)
2. Return "healthy" only if ALL are up
3. Return "degraded" if ANY are down
4. Return "critical" if MAJORITY are down

**Verification:**
```bash
go run status-aggregator.go
# Expected: System Status: degraded (2/3 services healthy)
```
