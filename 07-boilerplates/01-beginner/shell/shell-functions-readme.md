# Boilerplates: Functions

Modular, reusable automation functions.

## Available Boilerplates

### 1. DevOps Function Library
**File**: `boilerplate_devops_library.sh`

**Purpose**: Reusable functions for common DevOps tasks

**Usage**:
```bash
source ./boilerplate_devops_library.sh
check_terraform_drift
docker_health_check myapp
```

**Functions**:
- `check_terraform_drift`
- `deploy_ansible_playbook <playbook> [inventory]`
- `docker_health_check <container>`
- `wait_for_k8s_deployment <deployment> [namespace]`

---

### 2. Logging Framework
**File**: `boilerplate_logging_framework.sh`

**Purpose**: Structured logging with severity levels

**Usage**:
```bash
source ./boilerplate_logging_framework.sh
log_info "Deployment started"
log_error "Deployment failed"
```

---

## Related Resources

- [Parent Module](../../../readme.md)
