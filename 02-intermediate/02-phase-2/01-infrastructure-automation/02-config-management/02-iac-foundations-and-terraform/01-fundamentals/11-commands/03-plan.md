# terraform plan

## 📋 Overview

`terraform plan` creates an execution plan showing what changes Terraform will make to your infrastructure. It's one of the most important commands as it allows you to preview changes **before** applying them, preventing costly mistakes.

---

## 🎯 Purpose

- Preview infrastructure changes before applying
- Identify potential issues early
- Generate saved plans for safe application
- Validate configuration against current state
- Calculate resource dependencies and order

---

## 📝 Basic Syntax

```bash
terraform plan [options]
```

---

## 🚀 Common Usage Examples

### 1. Basic Plan (Interactive)
```bash
terraform plan
```

**Output symbols**:
- `+` = Resource will be created
- `-` = Resource will be destroyed
- `~` = Resource will be modified in-place
- `-/+` = Resource will be destroyed and recreated
- `<=` = Data source will be read

### 2. Save Plan to File
```bash
# Generate and save plan
terraform plan -out=tfplan

# Later, apply the saved plan
terraform apply tfplan
```

### 3. Plan with Variables
```bash
# Single variable
terraform plan -var="instance_type=t3.large"

# Variable file
terraform plan -var-file=production.tfvars

# Multiple variable files
terraform plan \
  -var-file=common.tfvars \
  -var-file=us-east-1.tfvars
```

### 4. Target Specific Resources
```bash
# Plan for single resource
terraform plan -target=aws_instance.web

# Plan for multiple resources
terraform plan \
  -target=aws_instance.web \
  -target=aws_security_group.web_sg
```

### 5. Destroy Plan
```bash
# Preview what destroy would do
terraform plan -destroy
```

### 6. Detailed Exit Code
```bash
terraform plan -detailed-exitcode

# Exit codes:
# 0 = Success, no changes
# 1 = Error
# 2 = Success, changes present
```

---

## ⚙️ Important Flags

| Flag | Description | Use Case |
|------|-------------|----------|
| `-out=<file>` | Save plan to file | Safe, auditable apply |
| `-destroy` | Create destroy plan | Preview destruction |
| `-target=<resource>` | Plan specific resource | Incremental changes |
| `-var="key=value"` | Set variable | Dynamic configuration |
| `-var-file=<file>` | Load variable file | Environment-specific |
| `-refresh=false` | Skip state refresh | Faster planning |
| `-refresh-only` | Only update state | Drift detection |
| `-detailed-exitcode` | Enhanced exit codes | CI/CD automation |
| `-parallelism=<n>` | Concurrent operations | Performance tuning |
| `-no-color` | Disable colors | Log files |
| `-json` | JSON output | Machine parsing |
| `-compact-warnings` | Compact output | Cleaner display |

---

## 📊 Understanding Plan Output

### Example Output
```
Terraform will perform the following actions:

  # aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami                          = "ami-0c55b159cbfafe1f0"
      + instance_type                = "t3.micro"
      + id                           = (known after apply)
      + public_ip                    = (known after apply)
      + subnet_id                    = "subnet-12345"
      
      + tags = {
          + "Name" = "web-server"
        }
    }

  # aws_security_group.web_sg will be modified
  ~ resource "aws_security_group" "web_sg" {
      ~ description = "Old description" -> "New description"
        id          = "sg-12345"
        
      + ingress {
          + from_port = 443
          + to_port   = 443
          + protocol  = "tcp"
        }
    }

Plan: 1 to add, 1 to change, 0 to destroy.
```

### Symbol Legend
| Symbol | Meaning | Example |
|--------|---------|---------|
| **+** | Create | New EC2 instance |
| **-** | Destroy | Remove old database |
| **~** | Update in-place | Change instance tags |
| **-/+** | Replace (destroy + create) | Change instance type |
| **<=** | Read | Data source query |
| **(known after apply)** | Computed value | Resource ID, IP address |

---

## 🛠️ Real-World Scenarios

### Scenario 1: Production Change Review
```bash
# Development environment - test changes
cd environments/dev
terraform plan -var-file=dev.tfvars

# Staging environment - validation
cd ../staging
terraform plan -var-file=staging.tfvars

# Production environment - final review
cd ../prod
terraform plan -var-file=prod.tfvars -out=prod.plan

# Team reviews prod.plan before applying
terraform show prod.plan

# After approval
terraform apply prod.plan
```

### Scenario 2: Infrastructure Drift Detection
```bash
# Check if infrastructure drifted from state
terraform plan -refresh-only

# Example output:
# Note: Objects have changed outside of Terraform
#
# Terraform detected that aws_instance.web was modified outside Terraform:
#   ~ resource "aws_instance" "web" {
#       ~ tags = {
#           + "Owner" = "alice"  # Added manually in console
#         }
#     }
```

### Scenario 3: Incremental Deployment
```bash
# Large infrastructure - deploy in stages

# Stage 1: Network infrastructure
terraform plan \
  -target=module.vpc \
  -target=module.subnets \
  -out=stage1.plan
terraform apply stage1.plan

# Stage 2: Security groups
terraform plan \
  -target=module.security_groups \
  -out=stage2.plan
terraform apply stage2.plan

# Stage 3: Application infrastructure
terraform plan \
  -target=module.ec2 \
  -out=stage3.plan
terraform apply stage3.plan
```

### Scenario 4: CI/CD Integration
```bash
#!/bin/bash
# ci-plan.sh

set -e

# Plan and check for changes
terraform plan -detailed-exitcode -out=tfplan

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  echo "No changes detected"
  exit 0
elif [ $EXIT_CODE -eq 1 ]; then
  echo "Terraform plan failed"
  exit 1
elif [ $EXIT_CODE -eq 2 ]; then
  echo "Changes detected - requiring approval"
  
  # Save plan for human review
  terraform show -json tfplan > plan.json
  
  # Send notification
  ./notify-team.sh "Terraform changes detected - review required"
  
  exit 0
fi
```

---

## ⚠️ Common Errors & Solutions

### Error 1: State Lock
```
Error: Error locking state: Error acquiring the state lock

state blob is already locked
```

**Solution**:
```bash
# Wait for lock to release (another terraform process)
# Or if lock is stale:
terraform force-unlock <LOCK_ID>
```

### Error 2: Provider Not Initialized
```
Error: Could not load plugin

Provider registry.terraform.io/hashicorp/aws is not available
```

**Solution**:
```bash
terraform init
terraform plan
```

### Error 3: Variable Not Set
```
Error: No value for required variable

The root module input variable "instance_type" is not set
```

**Solution**:
```bash
# Option 1: Use -var flag
terraform plan -var="instance_type=t3.micro"

# Option 2: Use tfvars file
terraform plan -var-file=production.tfvars

# Option 3: Set environment variable
export TF_VAR_instance_type="t3.micro"
terraform plan
```

### Error 4: Invalid Resource Reference
```
Error: Reference to undeclared resource

A data resource "aws_ami" "ubuntu" has not been declared in the root module
```

**Solution**:
- Check resource/data source is defined
- Verify spelling and resource type
- Ensure resource is not commented out

---

## 🎓 Best Practices

### 1. Always Plan Before Apply
```bash
# ✅ GOOD: Two-step process
terraform plan -out=tfplan
terraform apply tfplan

# ❌ BAD: Direct apply (skips review)
terraform apply -auto-approve
```

### 2. Use Saved Plans for Production
```bash
# Production workflow
terraform plan -var-file=prod.tfvars -out=prod-$(date +%Y%m%d-%H%M%S).plan

# Review plan
terraform show prod-20260107-143000.plan

# Apply exact plan
terraform apply prod-20260107-143000.plan
```

### 3. Regular Drift Detection
```bash
# Daily cron job to detect drift
#!/bin/bash
# detect-drift.sh

terraform plan -refresh-only -detailed-exitcode

if [ $? -eq 2 ]; then
  echo "ALERT: Infrastructure drift detected!"
  terraform plan -refresh-only > drift-report.txt
  # Send alert to team
fi
```

### 4. Validate Before Planning
```bash
# Pre-plan checks
terraform fmt -check || terraform fmt
terraform validate
terraform plan -out=tfplan
```

### 5. Use Targeted Plans Carefully
```bash
# ⚠️ Targeted plans can miss dependencies
terraform plan -target=aws_instance.web

# Better: Plan all, but note target
terraform plan | grep -A 10 "aws_instance.web"
```

---

## 📊 Plan Analysis Flow

```
terraform plan
    |
    v
Load Configuration
    |
    v
Initialize Providers
    |
    v
Refresh State (unless -refresh=false)
    |
    v
Calculate Dependency Graph
    |
    v
Compare Desired vs Current State
    |
    v
Generate Execution Plan
    |
    v
Display Changes (+, -, ~, -/+)
    |
    v
[Optional] Save Plan to File
    |
    v
Return Exit Code
```

---

## 🔍 Analyzing Plan Output

### Check Resource Counts
```bash
terraform plan | tail -n 3

# Output:
# Plan: 5 to add, 2 to change, 1 to destroy.
```

### Review Specific Resources
```bash
# Plan and filter for specific resource
terraform plan 2>&1 | grep -A 20 "aws_instance.web"
```

### JSON Format for Automation
```bash
terraform plan -json > plan.json

# Parse with jq
cat plan.json | jq '.resource_changes[] | select(.change.actions[] == "create")'
```

---

## 💡 Pro Tips

### 1. Colorized Output in CI
```bash
# Preserve colors in less
terraform plan | less -R

# Or disable colors for logs
terraform plan -no-color > plan.log
```

### 2. Plan with Performance Monitoring
```bash
# Time the plan operation
time terraform plan

# With detailed timing
TF_LOG=DEBUG terraform plan 2>&1 | grep -i "timing"
```

### 3. Compare Plans
```bash
# Save multiple plans
terraform plan -var="env=dev" -out=dev.plan
terraform plan -var="env=prod" -out=prod.plan

# Show both
terraform show dev.plan > dev-plan.txt
terraform show prod.plan > prod-plan.txt
diff dev-plan.txt prod-plan.txt
```

### 4. Plan Approval Workflow
```bash
# Generate plan with metadata
cat > plan-metadata.json <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "author": "$USER",
  "branch": "$(git branch --show-current)",
  "commit": "$(git rev-parse HEAD)"
}
EOF

terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json

# Submit for approval
```

---

## 🔐 Security Considerations

### 1. Plan Contains Sensitive Data
```bash
# Plans may contain secrets
terraform plan -out=tfplan

# ⚠️ Don't commit plan files
echo "*.tfplan" >> .gitignore
echo "*.json" >> .gitignore

# Encrypt plans if storing
gpg -c tfplan
```

### 2. Mask Sensitive Output
```hcl
variable "db_password" {
  type      = string
  sensitive = true  # Won't show in plan output
}

output "connection_string" {
  value     = "postgresql://${var.db_password}@..."
  sensitive = true  # Marked as sensitive
}
```

---

## 📚 Related Commands

- **`terraform apply`** - Execute the plan
- **`terraform show`** - Display saved plan
- **`terraform validate`** - Check configuration before planning
- **`terraform refresh`** - Update state without planning changes

---

## 📖 Summary

**terraform plan**:
- ✅ Previews changes before applying
- ✅ Identifies potential issues
- ✅ Creates safe, auditable plans
- ✅ Enables team review process
- ✅ Prevents accidental destruction

**Always remember**:
1. Plan before every apply
2. Save plans for production
3. Review plans carefully
4. Check for unexpected changes
5. Use in CI/CD for validation

---

**[⬅️ Back to Commands README](readme.md)** | **[Next: terraform apply ➡️](04-apply.md)**
