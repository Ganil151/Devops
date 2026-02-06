# Boilerplates: Basic Variables

Dynamic configuration and secret management scripts.

## Available Boilerplates

### 1. AWS Credential Loader
**File**: `boilerplate_aws_credential_loader.sh`

**Purpose**: Multi-account AWS credential management

**Usage**:
```bash
./boilerplate_aws_credential_loader.sh production
```

---

### 2. Terraform Variable Injector
**File**: `boilerplate_terraform_var_injector.sh`

**Purpose**: CI/CD Terraform variable export

**Usage**:
```bash
source ./boilerplate_terraform_var_injector.sh production.tfvars
```

---

### 3. Docker Tag Builder
**File**: `boilerplate_docker_tag_builder.sh`

**Purpose**: Generate image tags from Git metadata

**Usage**:
```bash
source ./boilerplate_docker_tag_builder.sh
docker build -t myapp:$DOCKER_TAG_COMMIT .
```

---

## Related Resources

- [Parent Module](../../../readme.md)
