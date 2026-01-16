# Go Fundamentals - Boilerplate Scripts

## Overview
These boilerplates demonstrate core Go program structure and environment introspection for DevOps workflows.

## Scripts

### 1. `main.go` - Environment Information Tool
**Purpose**: Display Go runtime information and perform system checks.

**DevOps Use Case**: Pre-flight validation in CI/CD pipelines to ensure build environments meet minimum requirements.

**Run:**
```bash
go run main.go
```

**Expected Output:**
```
=== Go Environment Information ===
Go Version: go1.21.x
Operating System: linux
Architecture: amd64
CPU Cores: 8

=== Pre-flight Validation ===
✅ CPU resources sufficient
✅ Running on Linux (Production-ready)
```

## Build for Production
```bash
# Build static binary
go build -o env-check main.go

# Cross-compile for Linux
GOOS=linux GOARCH=amd64 go build -o env-check-linux main.go
```
