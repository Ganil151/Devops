# Error Handling - Boilerplate Scripts

## Overview
Demonstrates `try-except-finally` blocks and custom exceptions for robust scripts.

## Scripts

### 1. `api_retry.py`
**Purpose**: A resilient function that retries operations on failure with backoff.

**DevOps Use Case**: 
- Waiting for a database to become available.
- Retrying flaky API calls to Cloud Providers.

**Run:**
```bash
python api_retry.py
```
