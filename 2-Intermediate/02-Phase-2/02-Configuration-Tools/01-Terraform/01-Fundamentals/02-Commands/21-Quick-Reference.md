# Terraform Commands Quick Reference & Cheat Sheet

## 🚀 Core Workflow Commands

### 1. terraform init
**Purpose**: Initialize working directory

```bash
# Basic initialization
terraform init

# Upgrade providers to latest versions
terraform init -upgrade

# Reconfigure backend
terraform init -reconfigure

# Migrate state to new backend
terraform init -migrate-state

# Backend configuration file
terraform init -backend-config=backend.hcl
```

**Common Flags**:
- `-upgrade` - Update providers/modules
- `-reconfigure` - Reconfigure backend
- `-backend=false` - Skip backend init
- `-migrate-state` - Migrate state between backends

---

### 2. terraform validate
**Purpose**: Validate configuration syntax

```bash
# Validate configuration
terraform validate

# JSON output
terraform validate -json

# Validate without accessing state
terraform validate -no-color
```

**What it checks**:
- ✅ Syntax errors
- ✅ Reference errors
- ✅ Type mismatches
- ✅ Required arguments
- ❌ Provider credentials (not checked)
- ❌ API availability (not checked)

---

### 3. terraform plan
**Purpose**: Preview infrastructure changes

```bash
# Basic plan
terraform plan

# Save plan to file
terraform plan -out=tfplan

# Plan with variable file
terraform plan -var-file=prod.tfvars

# Plan specific resource
terraform plan -target=aws_instance.web

# Destroy plan
terraform plan -destroy

# Detailed exit codes
terraform plan -detailed-exitcode
# Exit 0: No changes
# Exit 1: Error
# Exit 2: Changes present
```

**Common Flags**:
- `-out=<file>` - Save plan for apply
- `-var="key=value"` - Set variable
- `-var-file=<file>` - Load variables
- `-target=<resource>` - Target specific resource
- `-refresh=false` - Skip state refresh
- `-parallelism=<n>` - Parallel operations (default: 10)

---

### 4. terraform apply
**Purpose**: Create/update infrastructure

```bash
# Interactive apply (prompts for confirmation)
terraform apply

# Apply saved plan
terraform apply tfplan

# Auto-approve (no confirmation)
terraform apply -auto-approve

# Apply with variables
terraform apply -var="instance_type=t3.large"

# Target specific resource
terraform apply -target=aws_instance.web

# Apply with variable file
terraform apply -var-file=prod.tfvars
```

**Common Flags**:
- `-auto-approve` - Skip confirmation
- `-target=<resource>` - Apply specific resource
- `-var="key=value"` - Set variable
- `-parallelism=<n>` - Concurrent operations
- `-lock=false` - Don't lock state (dangerous!)

---

### 5. terraform destroy
**Purpose**: Destroy infrastructure

```bash
# Destroy all resources (with confirmation)
terraform destroy

# Destroy without confirmation
terraform destroy -auto-approve

# Destroy specific resource
terraform destroy -target=aws_instance.web

# Destroy with variable file
terraform destroy -var-file=prod.tfvars
```

⚠️ **Warning**: Use with extreme caution in production!

---

## 🗄️ State Management Commands

### 6. terraform state
**Purpose**: Advanced state management

```bash
# List all resources in state
terraform state list

# Show specific resource
terraform state show aws_instance.web

# Move resource to new address
terraform state mv aws_instance.web aws_instance.app

# Remove resource from state (doesn't destroy)
terraform state rm aws_instance.web

# Pull current state
terraform state pull > backup.tfstate

# Push state (dangerous!)
terraform state push backup.tfstate

# Replace provider for resource
terraform state replace-provider \
  registry.terraform.io/-/aws \
  hashicorp/aws
```

**Subcommands**:
- `list` - List resources
- `show` - Show resource details
- `mv` - Move/rename resource
- `rm` - Remove from state
- `pull` - Download state
- `push` - Upload state
- `replace-provider` - Replace provider

---

### 7. terraform import
**Purpose**: Import existing infrastructure

```bash
# Import AWS EC2 instance
terraform import aws_instance.web i-1234567890abcdef0

# Import with custom state file
terraform import -state=custom.tfstate \
  aws_instance.web \
  i-1234567890abcdef0

# Import with variable
terraform import -var="region=us-west-2" \
  aws_instance.web \
  i-1234567890abcdef0
```

**Workflow**:
1. Write resource block (without computed values)
2. Run `terraform import`
3. Run `terraform plan` to verify
4. Update resource block if needed

---

### 8. terraform taint / terraform untaint
**Purpose**: Mark resource for recreation

```bash
# Mark for recreation
terraform taint aws_instance.web

# Remove taint mark
terraform untaint aws_instance.web
```

**Note**: In Terraform 1.5+, prefer using `terraform apply -replace`:
```bash
terraform apply -replace=aws_instance.web
```

---

## 🎨 Formatting & Documentation

### 9. terraform fmt
**Purpose**: Format Terraform code

```bash
# Format current directory
terraform fmt

# Format and show diff
terraform fmt -diff

# Check if formatting needed (no changes)
terraform fmt -check

# Format recursively
terraform fmt -recursive

# Format specific file
terraform fmt main.tf
```

**Best Practice**: Run before committing
```bash
git add -A
terraform fmt
git add -A
git commit -m "Format Terraform code"
```

---

### 10. terraform show
**Purpose**: Display state or plan

```bash
# Show current state
terraform show

# Show saved plan
terraform show tfplan

# JSON output
terraform show -json

# Show specific resource
terraform state show aws_instance.web
```

---

### 11. terraform output
**Purpose**: Extract output values

```bash
# Show all outputs
terraform output

# Show specific output
terraform output instance_ip

# JSON format
terraform output -json

# Raw value (no quotes)
terraform output -raw private_key
```

**Usage in scripts**:
```bash
# Capture output
IP=$(terraform output -raw instance_ip)
echo "Server IP: $IP"

# Use in another terraform project
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-state"
    key    = "network/terraform.tfstate"
  }
}

resource "aws_instance" "app" {
  subnet_id = data.terraform_remote_state.network.outputs.subnet_id
}
```

---

## 🏢 Workspace Management

### 12. terraform workspace
**Purpose**: Manage workspaces

```bash
# List workspaces
terraform workspace list

# Show current workspace
terraform workspace show

# Create new workspace
terraform workspace new dev

# Select workspace
terraform workspace select prod

# Delete workspace
terraform workspace delete staging
```

**Workspace Usage**:
```hcl
# Reference current workspace
resource "aws_instance" "web" {
  instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.micro"
  
  tags = {
    Environment = terraform.workspace
  }
}
```

---

## 🔧 Advanced Commands

### 13. terraform graph
**Purpose**: Generate dependency graph

```bash
# Generate DOT format graph
terraform graph > graph.dot

# Convert to PNG (requires graphviz)
terraform graph | dot -Tpng > graph.png

# Plan-specific graph
terraform graph -plan=tfplan
```

---

### 14. terraform console
**Purpose**: Interactive REPL for testing

```bash
# Start console
terraform console

# Test expressions
> var.instance_type
"t3.micro"

> aws_instance.web.public_ip
"54.123.45.67"

> length(var.availability_zones)
3

# Use with piped input
echo "var.instance_type" | terraform console
```

**Common uses**:
```terraform
# Test functions
> join(", ", var.availability_zones)
"us-east-1a, us-east-1b, us-east-1c"

# Test conditionals
> var.environment == "prod" ? "t3.large" : "t3.micro"
"t3.micro"

# Access resource attributes
> aws_vpc.main.id
"vpc-1234567890abcdef0"
```

---

### 15. terraform providers
**Purpose**: Show provider requirements

```bash
# List providers
terraform providers

# Show provider configuration
terraform providers schema

# Show providers in JSON
terraform providers schema -json

# Lock providers for current platform
terraform providers lock

# Lock for multiple platforms
terraform providers lock \
  -platform=linux_amd64 \
  -platform=darwin_amd64 \
  -platform=windows_amd64
```

---

### 16. terraform refresh
**Purpose**: Sync state with real infrastructure

```bash
# Refresh state
terraform refresh

# Refresh with variables
terraform refresh -var-file=prod.tfvars

# Refresh specific target
terraform refresh -target=aws_instance.web
```

⚠️ **Deprecated**: Use `terraform apply -refresh-only` instead
```bash
terraform apply -refresh-only
```

---

## 🛠️ Utility Commands

### 17. terraform version
**Purpose**: Show version information

```bash
# Show Terraform version
terraform version

# JSON output
terraform version -json

# Check for updates
terraform version
```

**Example output**:
```
Terraform v1.6.0
on linux_amd64
+ provider registry.terraform.io/hashicorp/aws v5.0.1
+ provider registry.terraform.io/hashicorp/kubernetes v2.20.0
```

---

### 18. terraform get
**Purpose**: Download/update modules

```bash
# Download modules
terraform get

# Update modules
terraform get -update
```

**Note**: Usually not needed as `terraform init` handles this.

---

### 19. terraform login / terraform logout
**Purpose**: Terraform Cloud authentication

```bash
# Login to Terraform Cloud
terraform login

# Login to custom hostname
terraform login app.terraform.io

# Logout
terraform logout

# Logout from specific host
terraform logout app.terraform.io
```

---

### 20. terraform force-unlock
**Purpose**: Manually unlock state

```bash
# Force unlock with lock ID
terraform force-unlock <lock-id>

# Example
terraform force-unlock 1234abcd-56ef-78gh-90ij-1234567890ab
```

⚠️ **Use with extreme caution** - Only when:
- Another process crashed mid-operation
- You're absolutely sure no one else is running Terraform
- You've verified the lock is stale

---

## 📋 Common Workflows

### New Project Setup
```bash
mkdir my-infrastructure
cd my-infrastructure

# Create configuration
cat > main.tf << EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
EOF

# Initialize and apply
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

### Daily Development
```bash
# Format code
terraform fmt

# Validate
terraform validate

# Plan changes
terraform plan -out=tfplan

# Review plan, then apply
terraform apply tfplan
```

### Production Deployment
```bash
# Use specific variable file
terraform init
terraform plan -var-file=prod.tfvars -out=prod.plan

# Review plan carefully
terraform show prod.plan

# Apply (requires approval)
terraform apply prod.plan
```

### State Management
```bash
# Backup state
terraform state pull > backup-$(date +%Y%m%d).tfstate

# List resources
terraform state list

# Remove resource (doesn't destroy)
terraform state rm aws_instance.old_server

# Rename resource
terraform state mv \
  aws_instance.server \
  aws_instance.web_server
```

### Debugging
```bash
# Enable detailed logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Run command
terraform plan

# View logs
cat terraform.log

# Disable logging
unset TF_LOG
unset TF_LOG_PATH
```

---

## 🎯 Command Flags Summary

### Universal Flags
```bash
-chdir=<path>      # Change working directory
-no-color          # Disable colored output
-json              # JSON output (where supported)
-input=false       # Disable prompts
```

### Plan/Apply Flags
```bash
-var="key=value"         # Set variable
-var-file=<file>         # Variable file
-target=<resource>       # Target specific resource
-parallelism=<n>         # Concurrent operations
-refresh=false           # Skip refresh
-lock=false              # Don't lock state
-lock-timeout=<duration> # Lock timeout (default: 0s)
```

### State Flags
```bash
-state=<path>       # Custom state file
-state-out=<path>   # Output state file
-backup=<path>      # Backup file path
-lock=false         # Don't lock
```

---

## 🔍 Exit Codes

| Code | Meaning | Commands |
|------|---------|----------|
| 0 | Success, no changes | plan, apply, destroy |
| 1 | Error occurred | All commands |
| 2 | Success with changes | plan (with -detailed-exitcode) |

---

## 💡 Pro Tips

### 1. Alias Common Commands
```bash
# ~/.bashrc or ~/.zshrc
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfaa='terraform apply -auto-approve'
alias tfd='terraform destroy'
```

### 2. Pre-commit Hooks
```bash
# .git/hooks/pre-commit
#!/bin/bash
terraform fmt -check || {
  echo "Terraform files not formatted. Run 'terraform fmt'"
  exit 1
}
```

### 3. Makefile for Common Tasks
```makefile
.PHONY: init plan apply destroy

init:
	terraform init -upgrade

validate:
	terraform fmt -check
	terraform validate

plan:
	terraform plan -out=tfplan

apply:
	terraform apply tfplan

destroy:
	terraform destroy
```

Usage:
```bash
make init
make validate
make plan
make apply
```

---

## 📚 Command Priority Order

1. **Always First**: `terraform init`
2. **Before Commit**: `terraform fmt`, `terraform validate`
3. **Before Deploy**: `terraform plan`
4. **For Deploy**: `terraform apply`
5. **For Cleanup**: `terraform destroy`
6. **For Debugging**: `terraform console`, `terraform show`, `terraform graph`
7. **For State**: `terraform state`, `terraform import`

---

## 🛡️ Safety Checklist

Before running `terraform apply` in production:
- ✅ Run `terraform fmt -check`
- ✅ Run `terraform validate`
- ✅ Run `terraform plan -out=tfplan`
- ✅ Review plan output carefully
- ✅ Ensure state is backed up
- ✅ Have rollback plan ready
- ✅ Off-peak hours for major changes
- ✅ Team notification sent

---

**[⬅️ Back to Commands README](README.md)**

---

**Last Updated**: 2026-01-07  
**Terraform Version**: 1.6+  
**Maintained by**: DevOps Team
