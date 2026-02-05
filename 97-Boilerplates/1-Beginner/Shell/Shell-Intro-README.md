# Boilerplates: Introduction to Shell Scripting

This directory contains production-ready boilerplate scripts demonstrating the fundamentals of shell scripting in DevOps automation.

## Available Boilerplates

### 1. System Health Check
**File**: `boilerplate_startup_health_check.sh`

**Purpose**: Pre-deployment validation script that checks system resources

**DevOps Use Case**: Run before deploying applications to ensure infrastructure has sufficient CPU, memory, and disk space

**Usage**:
```bash
./boilerplate_startup_health_check.sh
```

**Features**:
- CPU usage monitoring
- Memory usage monitoring
- Disk space validation
- Configurable thresholds
- Structured logging

---

### 2. Docker Cleanup Automation
**File**: `boilerplate_docker_cleanup.sh`

**Purpose**: Removes stopped containers, dangling images, and unused volumes

**DevOps Use Case**: CI/CD runner maintenance to prevent disk space exhaustion

**Usage**:
```bash
./boilerplate_docker_cleanup.sh
```

**Cron Schedule** (runs daily at 2 AM):
```bash
0 2 * * * /path/to/boilerplate_docker_cleanup.sh
```

**Features**:
- Automatic cleanup of stopped containers
- Removal of dangling images
- Volume pruning
- Disk space reporting
- Log file output

---

## Quick Start

1. Make scripts executable:
```bash
chmod +x boilerplate_*.sh
```

2. Run any script:
```bash
./boilerplate_startup_health_check.sh
```

3. Review logs and output for results

---

## Learning Objectives

These boilerplates demonstrate:
- ✅ Proper shebang usage (`#!/bin/bash`)
- ✅ Strict error handling (`set -euo pipefail`)
- ✅ Function-based organization
- ✅ Logging best practices
- ✅ Exit code management
- ✅ Real-world DevOps automation patterns

---

## Related Resources

- [Parent Module: Introduction](../../../README.md)
- [Shell Scripting Challenges](../../3-Advanced/01-Self-Healing-Infrastructure/CHALLENGES.md)
