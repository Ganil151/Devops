# Variables and Types - Boilerplate Scripts

## Overview
Type-safe configuration parsing for DevOps applications.

## Scripts

### 1. `main.go` - Config Parser with Type Safety
**Purpose**: Parse environment variables with proper type conversion and validation.

**DevOps Use Case**: Reading configuration from environment variables in containerized applications (Docker, Kubernetes) where config is injected as env vars.

**Run:**
```bash
# With defaults
go run main.go

# With custom environment
SERVER_HOST=api.example.com SERVER_PORT=9000 DEBUG=true go run main.go
```

**Expected Output:**
```
=== Server Configuration ===
Host: api.example.com (type: string)
Port: 9000 (type: int)
Timeout: 30s (type: time.Duration)
Debug Mode: true (type: bool)
Max Retries: 3 (type: int)

=== Type Safety Check ===
✅ Port number is valid
```

## Key Concepts
- Type conversion from string environment variables
- Default value handling
- Type safety validation at runtime
- Error handling for invalid conversions
