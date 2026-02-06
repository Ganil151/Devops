# Boilerplates: Hidden Files

Scripts for managing hidden configuration files (.env, .ssh/config) critical to DevOps workflows.

## Available Boilerplates

### 1. Environment File Manager
**File**: `boilerplate_env_file_manager.sh`

**Purpose**: Safely creates and validates .env files

**DevOps Use Case**: Secret management and configuration validation

**Usage**:
```bash
./boilerplate_env_file_manager.sh
```

**Features**:
- Template generation
- Required variable validation
- Git safety checks (.gitignore)
- Prevents committing secrets

---

### 2. SSH Config Builder
**File**: `boilerplate_ssh_config_builder.sh`

**Purpose**: Generates ~/.ssh/config for multi-environment access

**DevOps Use Case**: Managing bastion hosts and jump servers

**Usage**:
```bash
./boilerplate_ssh_config_builder.sh
```

**Features**:
- Automatic config backup
- Jump host configuration
- Default settings
- Permission hardening

---

## Quick Start

```bash
chmod +x boilerplate_*.sh

# Create and validate .env
./boilerplate_env_file_manager.sh

# Generate SSH config
./boilerplate_ssh_config_builder.sh

# Test SSH connection
ssh dev-bastion
```

---

## Learning Objectives

- ✅ Hidden file management
- ✅ Secret safety practices
- ✅ SSH configuration
- ✅ Jump host patterns
- ✅ Git security

---

## Related Resources

- [Parent Module](../../../readme.md)
- [Challenges](../../03-advanced/01-self-healing-infrastructure/challenges.md)
