# Working with JSON - DevOps Challenges

## Challenge 1: Docker Inspect Parser
**Scenario**: Parse output from `docker inspect` command.

**Requirements:**
1. Parse JSON with container info (ID, State, Config, NetworkSettings)
2. Extract: Container status, IP address, exposed ports
3. Print formatted summary

**Verification:**
```bash
go run docker-parser.go container.json
# Expected: Shows container details in readable format
```

---

## Challenge 2: Kubernetes Manifest Generator
**Scenario**: Generate K8s Deployment manifest from struct.

**Requirements:**
1. Create structs for Deployment, PodSpec, Container
2. Build deployment config programmatically
3. Marshal to JSON with proper indentation

**Verification:**
```bash
go run k8s-generator.go
# Expected: Outputs valid Kubernetes Deployment JSON
```

---

## Challenge 3: API Response Validator
**Scenario**: Validate API responses match expected schema.

**Requirements:**
1. Parse API response JSON
2. Check required fields exist
3. Validate field types
4. Return list of validation errors

**Verification:**
```bash
go run api-validator.go response.json
# Expected: Lists any schema violations
```
