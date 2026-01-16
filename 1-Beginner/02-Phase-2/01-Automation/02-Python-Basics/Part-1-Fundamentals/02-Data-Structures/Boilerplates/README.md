# Data Structures - Boilerplate Scripts

## Overview
Scripts demonstrating efficient manipulation of Lists, Dictionaries, and Sets for DevOps data processing.

## Scripts

### 1. `inventory_manager.py` - Server Inventory Processor
**Purpose**: Filter, transform, and aggregate data from a mock server inventory.

**DevOps Use Case**: 
- Generating dynamic Ansible inventories.
- Filtering cloud resources by tags.
- Parsing API responses from AWS/Azure/GCP.

**Run:**
```bash
python inventory_manager.py
```

**Expected Output:**
```
INFO: Full Inventory: ...
INFO: Filtering Active Web Servers...
Active Web IPs: ['10.0.1.10', '10.0.1.11']
...
```
