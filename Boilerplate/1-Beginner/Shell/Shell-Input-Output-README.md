# Boilerplates: Input-Output

Stream processing, pipes, and redirection for DevOps automation.

## Available Boilerplates

### 1. Log Processor
**File**: `boilerplate_log_processor.sh`

**Purpose**: Real-time log stream filtering

**Usage**:
```bash
tail -f app.log | ./boilerplate_log_processor.sh
```

---

### 2. Terraform Output Parser
**File**: `boilerplate_terraform_output_parser.sh`

**Purpose**: Extract and export Terraform outputs

**Usage**:
```bash
./boilerplate_terraform_output_parser.sh
source terraform_outputs.env
```

---

### 3. Ansible Vault Manager
**File**: `boilerplate_ansible_vault_manager.sh`

**Purpose**: Secret encryption and rotation

**Usage**:
```bash
source ./boilerplate_ansible_vault_manager.sh
encrypt_secret "my-password"
```

---

## Related Resources

- [Parent Module](../../../README.md)
