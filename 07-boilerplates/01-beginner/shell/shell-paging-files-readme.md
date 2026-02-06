# Boilerplates: Paging Files

Safe viewing scripts for large outputs in DevOps workflows.

## Available Boilerplates

### 1. Kubectl Log Viewer
**File**: `boilerplate_kubectl_log_viewer.sh`

**Purpose**: View Kubernetes pod logs with paging

**Usage**:
```bash
./boilerplate_kubectl_log_viewer.sh my-pod production
```

---

### 2. Terraform Plan Reviewer
**File**: `boilerplate_terraform_plan_reviewer.sh`

**Purpose**: Safe review of IaC changes

**Usage**:
```bash
./boilerplate_terraform_plan_reviewer.sh
```

---

## Quick Start

```bash
chmod+x boilerplate_*.sh
./boilerplate_kubectl_log_viewer.sh my-app default
```

---

## Related Resources

- [Parent Module](../../../readme.md)
- [Challenges](../../03-advanced/01-self-healing-infrastructure/challenges.md)
