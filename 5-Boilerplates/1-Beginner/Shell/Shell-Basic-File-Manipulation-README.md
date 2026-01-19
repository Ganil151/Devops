# Boilerplates: Basic File Manipulation

Production-ready scripts demonstrating file operations for configuration management and IaC workflows.

## Available Boilerplates

### 1. Terraform Backend Setup

**File**: `boilerplate_terraform_backend_setup.sh`

**Purpose**: Creates S3 backend configuration for Terraform state

**DevOps Use Case**: Multi-environment IaC initialization

**Usage**:

```bash
./boilerplate_terraform_backend_setup.sh my-terraform-state-bucket production
```

**Features**:

- S3 backend configuration
- DynamoDB state locking
- Environment-specific state paths
- AWS credential validation

---

### 2. Ansible Inventory Generator

**File**: `boilerplate_ansible_inventory_generator.sh`

**Purpose**: Dynamic inventory from AWS EC2 tags

**DevOps Use Case**: Cloud-native configuration management

**Usage**:

```bash
./boilerplate_ansible_inventory_generator.sh production
```

**Requirements**: AWS CLI, jq

**Features**:

- EC2 tag-based grouping
- Role-based inventory sections
- SSH configuration
- JSON parsing with jq

---

### 3. Docker Compose Templater

**File**: `boilerplate_docker_compose_templater.sh`

**Purpose**: Environment-specific docker-compose generation

**DevOps Use Case**: Multi-environment container deployments

**Usage**:

```bash
./boilerplate_docker_compose_templater.sh
```

**Features**:

- Variable substitution from `.env`
- Template-based generation
- Auto-creates missing templates
- Supports `envsubst`

---

## Quick Start

```bash
chmod +x boilerplate_*.sh

# Terraform backend
./boilerplate_terraform_backend_setup.sh my-bucket dev

# Ansible inventory
./boilerplate_ansible_inventory_generator.sh production

# Docker Compose
./boilerplate_docker_compose_templater.sh
```

---

## Learning Objectives

- ✅ File creation and templating
- ✅ AWS CLI integration
- ✅ JSON parsing with `jq`
- ✅ Environment variable management
- ✅ Configuration file generation

---

## Related Resources

- [Parent Module](../../../README.md)
- [Challenges](../../../1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/01-Introduction/CHALLENGES.md)
