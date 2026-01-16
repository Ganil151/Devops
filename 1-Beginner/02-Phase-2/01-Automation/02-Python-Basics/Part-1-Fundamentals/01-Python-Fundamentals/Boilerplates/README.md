# Python Fundamentals - Boilerplate Scripts

## Overview
Essential scripts demonstrating Python's interacting with the system and runtime environment.

## Scripts

### 1. `sys_info.py` - Pre-flight System Checker
**Purpose**: Gather system metadata (OS, CPU, Python version) and validate environment requirements.

**DevOps Use Case**: 
- Running compliance checks before installing software.
- verifying the runtime environment in CI/CD pipelines.

**Run:**
```bash
python sys_info.py
```

**Expected Output:**
```
2024-01-15 10:00:00 - INFO - Starting Pre-flight System Check...
2024-01-15 10:00:00 - INFO - Python Version: 3.10.x ...
System Configuration:
  Os: Windows/Linux
  Cpu_Count: 8
...
```

### 2. `pip_wrapper.py` (Coming Soon)
Demonstrates calling pip programmatically to manage dependencies.
