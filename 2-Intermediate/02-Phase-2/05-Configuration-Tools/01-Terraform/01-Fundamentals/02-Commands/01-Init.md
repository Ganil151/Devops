# terraform init

## 📋 Overview

`terraform init` is the **first command** you run when starting with a new or existing Terraform configuration. It initializes the working directory, downloads required providers and modules, and sets up the backend for state management.

---

## 🎯 Purpose

- Download and install provider plugins
- Download and install mo

dules
- Initialize the backend for state storage
- Prepare the working directory for other Terraform commands

---

## 📝 Basic Syntax

```bash
terraform init [options]
```

---

## 🚀 Common Usage Examples

### 1. Basic Initialization
```bash
terraform init
```

### 2. Reinitialize (e.g., after adding new providers)
```bash
terraform init -upgrade
```

### 3. Initialize with Specific Backend Config
```bash
terraform init -backend-config="bucket=my-terraform-state"
```

### 4. Initialize from a Different Directory
```bash
terraform init -chdir=/path/to/terraform/config
```

### 5. Reconfigure Backend
```bash
terraform init -reconfigure
```

### 6. Migrate State to a New Backend
```bash
terraform init -migrate-state
```

---

## ⚙️ Important Flags

| Flag | Description | When to Use |
|------|-------------|-------------|
| `-upgrade` | Upgrade providers/modules to latest allowed versions | After updating version constraints |
| `-reconfigure` | Reconfigure backend, ignoring existing configuration | Changing backend configuration |
| `-migrate-state` | Migrate existing state to new backend | Moving state between backends |
| `-backend=false` | Disable backend initialization | Local state only (not recommended for teams) |
| `-backend-config=<config>` | Provide backend configuration | Dynamic backend configuration |
| `-get=false` | Don't download modules | Modules already downloaded |
| `-plugin-dir=<path>` | Use plugins from specified directory | Custom or air-gapped environments |
| `-lockfile=<mode>` | Set dependency lock file mode (`readonly`) | CI/CD pipelines |

---

## 🔄 Init Workflow

```
terraform init
    |
    ├─> Download Providers (.terraform/providers/)
    |
    ├─> Download Modules (.terraform/modules/)
    |
    ├─> Initialize Backend (backend configuration)
    |
    └─> Create .terraform.lock.hcl (dependency lock file)
```

---

## 📂 What Gets Created

After running `terraform init`, you'll see:

```
project/
├── .terraform/                    # Directory for providers and modules
│   ├── providers/
│   │   └── registry.terraform.io/
│   │       └── hashicorp/
│   │           └── aws/5.0.0/     # Provider version
│   └── modules/
│       └── modules.json           # Module cache
├── .terraform.lock.hcl            # Dependency lock file
├── main.tf
├── variables.tf
└── terraform.tfstate              # (created after apply)
```

---

## 🛠️ Real-World Scenarios

### Scenario 1: First Time Project Setup
```bash
# Clone repository
git clone https://github.com/company/infrastructure.git
cd infrastructure

# Initialize Terraform
terraform init

# Output:
# Initializing the backend...
# Initializing provider plugins...
# - Finding hashicorp/aws versions matching "~> 5.0"...
# - Installing hashicorp/aws v5.0.1...
# - Installed hashicorp/aws v5.0.1
#
# Terraform has been successfully initialized!
```

### Scenario 2: Adding a New Provider
```hcl
# main.tf - Added Kubernetes provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}
```

```bash
# Reinitialize to download new provider
terraform init -upgrade

# Output:
# Initializing provider plugins...
# - Reusing previous version of hashicorp/aws from the dependency lock file
# - Finding hashicorp/kubernetes versions matching "~> 2.20"...
# - Installing hashicorp/kubernetes v2.20.0...
```

### Scenario 3: Backend Migration (Local → S3)
```hcl
# Before: No backend (local state)
# After: S3 backend

terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
```

```bash
# Migrate state from local to S3
terraform init -migrate-state

# Terraform will detect state migration
# Do you want to copy existing state to the new backend?
# Enter a value: yes
#
# Successfully configured the backend "s3"!
```

### Scenario 4: CI/CD Pipeline
```bash
# In CI/CD, use readonly lockfile to ensure reproducibility
terraform init -lockfile=readonly

# If lock file is missing or outdated, this will fail
# Ensures teams commit .terraform.lock.hcl to version control
```

---

## ⚠️ Common Errors & Solutions

### Error 1: Plugin Not Found
```
Error: Failed to install provider

Provider registry.terraform.io/hashicorp/aws could not be found
```

**Solution**:
```bash
# Check internet connectivity
# Verify provider source is correct
# Or download provider manually to .terraform/providers/
```

### Error 2: Backend Configuration Conflict
```
Error: Backend initialization required, please run "terraform init"

Reason: Unsaved changes to backend configuration
```

**Solution**:
```bash
terraform init -reconfigure
```

### Error 3: Lock File Checksum Mismatch
```
Error: Inconsistent dependency lock file

The following dependency selections recorded in the lock file are inconsistent
with the current configuration
```

**Solution**:
```bash
# Update lock file
terraform init -upgrade

# Or if you want to keep current versions
terraform providers lock
```

---

## 🎓 Best Practices

### 1. **Always Commit Lock File**
```bash
git add .terraform.lock.hcl
git commit -m "Update Terraform providers"
```
✅ Ensures team uses same provider versions

### 2. **Use Version Constraints**
```hcl
terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Allows 5.x but not 6.0
    }
  }
}
```

### 3. **Backend Configuration Best Practices**
```bash
# Don't hardcode sensitive values in backend config
# Use backend config files instead

# backend-config.hcl
bucket         = "my-terraform-state"
key            = "prod/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-locks"
```

```bash
terraform init -backend-config=backend-config.hcl
```

### 4. **Automated Init in Scripts**
```bash
#!/bin/bash
# init.sh

set -e

echo "Initializing Terraform..."
terraform init -input=false -upgrade

echo "Validating configuration..."
terraform validate

echo "Ready to plan/apply"
```

---

## 📊 Init Process Flow Diagram

```
START
  |
  v
Check terraform.tf for required_providers
  |
  v
Read .terraform.lock.hcl (if exists)
  |
  v
Download Provider Plugins (to .terraform/providers/)
  |-- Check local cache first
  |-- Download from registry if needed
  |-- Verify signatures
  |
  v
Download Modules (to .terraform/modules/)
  |-- Parse module sources
  |-- Git clone / HTTP download
  |-- Nested module resolution
  |
  v
Initialize Backend
  |-- Parse backend configuration
  |-- Connect to remote backend (S3, etc.)
  |-- Create state location if needed
  |
  v
Update .terraform.lock.hcl
  |
  v
SUCCESS ✅
```

---

## 🔐 Security Considerations

### 1. **Provider Verification**
```bash
# Terraform automatically verifies provider signatures
# Lock file prevents man-in-the-middle attacks
```

### 2. **Backend Credentials**
```bash
# Never commit backend credentials
# Use environment variables or IAM roles

export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."

terraform init
```

### 3. **Network Security**
```bash
# In air-gapped environments, use plugin cache
terraform init -plugin-dir=/path/to/providers
```

---

## 🧪 Testing Init in Different Environments

### Development
```bash
terraform init
```

### Staging
```bash
terraform init -backend-config="key=staging/terraform.tfstate"
```

### Production
```bash
terraform init \
  -backend-config="key=prod/terraform.tfstate" \
  -lockfile=readonly
```

---

## 📚 Related Commands

- **`terraform get`** - Download/update modules only
- **`terraform providers`** - Show provider requirements
- **`terraform version`** - Show Terraform and provider versions

---

## 💡 Pro Tips

1. **Speed up init with plugin cache**:
   ```bash
   # ~/.terraformrc
   plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"
   ```

2. **Skip input prompts in automation**:
   ```bash
   terraform init -input=false
   ```

3. **Force clean re-initialization**:
   ```bash
   rm -rf .terraform .terraform.lock.hcl
   terraform init
   ```

4. **Check what init would do**:
   ```bash
   terraform init -dry-run  # (Not available, but plan first!)
   terraform providers     # See what's required
   ```

---

## 📖 Summary

**terraform init** is your entry point to Terraform. It:
- ✅ Downloads providers and modules
- ✅ Sets up state backend
- ✅ Creates dependency lock file
- ✅ Prepares directory for other commands

Always run `terraform init` when:
- Starting a new project
- Cloning a repository
- Adding/changing providers
- Modifying backend configuration
- Updating module sources

---

**[⬅️ Back to Commands README](README.md)** | **[Next: terraform validate ➡️](02-Validate.md)**
