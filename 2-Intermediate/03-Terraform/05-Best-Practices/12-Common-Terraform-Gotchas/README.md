# Common Terraform Gotchas

Learn from others' mistakes! This guide covers the most common pitfalls, unexpected behaviors, and "gotchas" that trip up even experienced Terraform users.

---

## Table of Contents
1. [State File Gotchas](#state-file-gotchas)
2. [Resource Dependencies](#resource-dependencies)
3. [Variable and Expression Traps](#variable-and-expression-traps)
4. [Provider Quirks](#provider-quirks)
5. [Module Gotchas](#module-gotchas)
6. [Count and For-Each Pitfalls](#count-and-for-each-pitfalls)

---

## State File Gotchas

### Gotcha #1: Editing State File Manually

**The Trap:**
```bash
# Someone opens terraform.tfstate in their editor and "fixes" a value
{
  "resources": [{
    "instances": [{
      "attributes": {
        "id": "i-12345"  # Changed manually!
      }
    }]
  }]
```

**Why It's Bad**: Terraform relies on state file integrity. Manual edits can break the checksums, cause inconsistencies, or lead to resource deletion.



**The Right Way**:
```bash
# Use terraform state commands
terraform state rm aws_instance.broken
terraform import aws_instance.fixed i-12345
```

---

### Gotcha #2: Commit terraform.tfstate to Git

**The Trap**:
```bash
git add terraform.tfstate
git commit -m "saving state"
```

**Problems**:
- State files contain secrets (passwords, keys)
- Merge conflicts are **impossible** to resolve correctly
- Race conditions when team members work simultaneously

**The Right Way**:
```hcl
# Use remote backend
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
    
    dynamodb_table = "terraform-locks"  # State locking
    encrypt        = true
  }
}
```

---

### Gotcha #3: Lost State File = Lost Infrastructure

**The Trap**: Accidentally deleting `terraform.tfstate`

**What Happens**:
- Terraform thinks no resources exist
- Running `terraform apply` tries tocreate everything again
- Results in "AlreadyExists" errors

**The Solution**:
1. **Prevention**: Always use remote backends with versioning
2. **Recovery**: 
   - Restore from S3 versioning
   - Manually import each resource:
   ```bash
   terraform import aws_instance.web i-1234567
   terraform import aws_s3_bucket.data my-bucket-name
   ```

---

## Resource Dependencies

### Gotcha #4: Implicit vs Explicit Dependency Confusion

**The Trap**:
```hcl
resource "aws_instance" "app" {
  ami           = "ami-12345"
  instance_type = "t3.micro"
  # App needs the database, but there's no reference!
}

resource "aws_db_instance" "main" {
  identifier = "mydb"
  # ... config ...
}
```

**What Happens**: Instance might be created before database, causing app startup failure.

**The Fix**:
```hcl
resource "aws_instance" "app" {
  ami           = "ami-12345"
  instance_type = "t3.micro"
  
  # Explicit dependency
  depends_on = [aws_db_instance.main]
  
  # OR use implicit dependency
  user_data = templatefile("init.sh", {
    db_endpoint = aws_db_instance.main.endpoint  # Creates implicit dependency
  })
}
```

---

### Gotcha #5: Circular Dependencies

**The Trap**:
```hcl
resource "aws_security_group" "app" {
  name = "app-sg"
  
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]  # Depends on ALB SG
  }
}

resource "aws_security_group" "alb" {
  name = "alb-sg"
  
  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]  # Depends on App SG!
  }
}
```

**Error**: `Cycle: aws_security_group.app, aws_security_group.alb`

**The Fix**: Use separate security group rules
```hcl
resource "aws_security_group" "app" {
  name = "app-sg"
  # No inline rules
}

resource "aws_security_group" "alb" {
  name = "alb-sg"
  # No inline rules
}

# Separate rules break the cycle
resource "aws_security_group_rule" "app_from_alb" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_to_app" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.app.id
}
```

---

## Variable and Expression Traps

### Gotcha #6: Terraform Variables Are Not Bash Variables

**The Trap**:
```hcl
variable "regions" {
  default = "us-east-1,us-west-2"  # CSV string, VSCODE autocomplete won't work like an array!
}

resource "aws_instance" "web" {
  for_each = var.regions  # ERROR: Must be a map or set, not a string
}
```

**The Fix**:
```hcl
variable "regions" {
  type    = list(string)
  default = ["us-east-1", "us-west-2"]
}

resource "aws_instance" "web" {
  for_each = toset(var.regions)  # Convert list to set
  
  ami           = "ami-12345"
  instance_type = "t3.micro"
}
```

---

### Gotcha #7: Sensitive Variables Still Appear in State

**The Trap**:
```hcl
variable "db_password" {
  type      = string
  sensitive = true
}

resource "aws_db_instance" "main" {
  password = var.db_password  # Marked sensitive
}
```

**Misconception**: "sensitive = true encrypts the value"

**Reality**: The value is **still stored in plain text** in `terraform.tfstate`!

**The Right Approach**:
1. Never commit `.tfstate` files
2. Encrypt state file at rest (S3 encryption)
3. Use IAM roles to limit access
4. For truly sensitive data, use AWS Secrets Manager:
```hcl
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/db/password"
}

resource "aws_db_instance" "main" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

---

### Gotcha #8: String Interpolation in Terraform 0.12+ Changed

**Old Syntax (Terraform < 0.12)**:
```hcl
resource "aws_s3_bucket" "logs" {
  bucket = "${var.project}-logs"  # Required interpolation syntax
}
```

**New Syntax (Terraform >= 0.12)**:
```hcl
resource "aws_s3_bucket" "logs" {
  bucket = "${var.project}-logs"  # Works but generates warning
  # OR
  bucket = "$ {var.project}-logs"  # Cleaner, preferred
}
```

**Gotcha**: Mixing old and new syntax can cause errors with certain functions.

---

## Provider Quirks

### Gotcha #9: AWS Default Tags Don't Override Resource Tags

**The Trap**:
```hcl
provider "aws" {
  default_tags {
    tags = {
      Environment = "Production"
      ManagedBy   = "Terraform"
    }
  }
}

resource "aws_instance" "web" {
  tags = {
    Environment = "Development"  # Trying to override
  }
}
```

**What Happens**: The instance gets **both** tags, resulting in conflicting `Environment` values behavior depends on Terraform version.

**The Fix**: Be explicit and avoid conflicts
```hcl
resource "aws_instance" "web" {
  tags = merge(
    var.common_tags,
    {
      Name = "web-server"
    }
  )
}
```

---

### Gotcha #10: Provider Version Constraints Matter!

**The Trap**:
```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # No version specified!
    }
  }
}
```

**Problem**: Different team members might download different versions, causing inconsistent behavior.

**The Fix**:
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Lock to major version 5
    }
  }
}

# Always commit .terraform.lock.hcl to version control!
```

---

## Module Gotchas

### Gotcha #11: Module Source Must Be Literal String

**The Trap**:
```hcl
variable "module_version" {
  default = "1.0.0"
}

module "network" {
  source = "terraform-aws-modules/vpc/aws?ref=v${var.module_version}"  # ERROR!
}
```

**Error**: `source` argument cannot use variables or expressions.

**The Workaround**: Use separate `terraform.tfvars` files per environment or use Terragrunt.

---

### Gotcha #12: Module Outputs Aren't Available Immediately

**The Trap**:
```hcl
module "vpc" {
  source = "./modules/vpc"
}

resource "aws_instance" "app" {
  subnet_id = module.vpc.subnet_id  # This works
}

output "subnet_check" {
  value = module.vpc.subnet_id == "subnet-12345" ? "match" : "no match"  # Thiscrashes!
}
```

**Error**: `Output refers to sensitive values`

**Fix**: Outputs from modules may not be known until apply.

---

## Count and For-Each Pitfalls

### Gotcha #13: Changing from Count to For-Each (or vice versa)

**The Trap**:
```hcl
# Original code with count
resource "aws_instance" "web" {
  count         = 3
  ami           = "ami-12345"
  instance_type = "t3.micro"
}

# Later, someone changes to for_each
resource "aws_instance" "web" {
  for_each      = toset(["web-1", "web-2", "web-3"])
  ami           = "ami-12345"
  instance_type = "t3.micro"
}
```

**What Happens**: Terraform tries to destroy all 3 instances and recreate them!

**The Fix**: Use `terraform state mv` to preserve resources
```bash
terraform state mv 'aws_instance.web[0]' 'aws_instance.web["web-1"]'
terraform state mv 'aws_instance.web[1]' 'aws_instance.web["web-2"]'
terraform state mv 'aws_instance.web[2]' 'aws_instance.web["web-3"]'
```

---

### Gotcha #14: For-Each with Lists

**The Trap**:
```hcl
variable "instance_names" {
  default = ["web", "api", "db"]
}

resource "aws_instance" "servers" {
  for_each = var.instance_names  # ERROR: Must be a map or set
}
```

**The Fix**:
```hcl
resource "aws_instance" "servers" {
  for_each = toset(var.instance_names)  # Convert list to set
  
  tags = {
    Name = each.key  # "web", "api", or "db"
  }
}
```

---

### Gotcha #15: Count Index Starts at 0

**The Trap**:
```hcl
resource "aws_instance" "web" {
  count = 3
  
  tags = {
    Name = "web-server-${count.index}"  # Results in: web-server-0, web-server-1, web-server-2
  }
}
```

**When You Want 1-Based Indexing**:
```hcl
resource "aws_instance" "web" {
  count = 3
  
  tags = {
    Name = "web-server-${count.index + 1}"  # Results in: web-server-1, web-server-2, web-server-3
  }
}
```

---

## Timing and Lifecycle Gotchas

### Gotcha #16: Depends_on with Modules Doesn't Work as Expected

**The Trap**:
```hcl
module "database" {
  source = "./modules/rds"
}

module "application" {
  source = "./modules/app"
  
  depends_on = [module.database.db_instance]  # ERROR: Can't reference module resource
}
```

**The Fix**: Pass outputs as inputs to create implicit dependency
```hcl
module "database" {
  source = "./modules/rds"
}

module "application" {
  source      = "./modules/app"
  db_endpoint = module.database.endpoint  # Implicit dependency
}
```

---

### Gotcha #17: Replace_triggered_by with Non-Existent Resources

**The Trap**:
```hcl
resource "aws_instance" "app" {
  ami           = "ami-12345"
  instance_type = "t3.micro"
  
  lifecycle {
    replace_triggered_by = [aws_ami.custom.id]  # If AMI doesn't exist yet, error!
  }
}
```

---

## Real-Life Scenarios

### Scenario 1: The Vanishing Security Group

**Problem**: Team deployed an instance, then later added a security group to the code. Running `terraform apply`, the instance was **destroyed and recreated**.

**Root Cause**: Some AWS attributes trigger replacement when changed.

**Prevention**:
```hcl
resource "aws_instance" "web" {
  # ... other config ...
  
  lifecycle {
    ignore_changes = [ami]  # Allow manual AMI updates
  }
}
```

### Scenario 2: The Massive Accidental Destroy

**Problem**: Developer ran `terraform destroy` in production by mistake (thought they were in dev).

**Solution**:
```hcl
# In production workspace/environment
resource "aws_db_instance" "prod" {
  lifecycle {
    prevent_destroy = true
  }
}
```

```bash
# Also, use workspaces
terraform workspace select prod
terraform plan  # Always plan first!
```

### Scenario 3: The "It Worked Yesterday" Mystery

**Problem**: Terraform plan worked yesterday, today it fails with "Invalid instance type".

**Root Cause**: Team didn't lock provider version. AWS provider updated overnight with breaking changes.

**Solution**:
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.1.0"  # Exact version pin
    }
  }
}

# Commit .terraform.lock.hcl
```

---

## Interview Questions

1. **What happens if you manually edit the state file?**
   - *Answer*: State file checksums break, leading to inconsistencies, potential resource destruction, or Apply failures. Always use `terraform state` commands.

2. **Why can't you use variables in module source?**
   - *Answer*: Module sources are resolved during initialization (`terraform init`), before variables are evaluated. They must be literal strings.

3. **What is the difference between `count.index` and `each.key`?**
   - *Answer*: `count.index` is a zero-based integer (0, 1, 2...). `each.key` is the key from a map or set ("web", "api", etc.).

4. **Why does changing from count to for_each destroy resources?**
   - *Answer*: Resource addresses change (from `[0]` to `["name"]`), so Terraform sees them as different resources requiring recreation.

5. **What's wrong with committing terraform.tfstate to Git?**
   - *Answer*: Contains secrets in plain text, causes merge conflicts, enables race conditions in team environments.

6. **How do you create implicit dependencies between modules?**
   - *Answer*: Pass outputs from one module as inputs to another. Terraform automatically detects the dependency.

7. **What does `sensitive = true` actually do?**
   - *Answer*: It hides the value in console output and logs, but does NOT encrypt it in the state file.

8. **How do you recover from a lost state file?**
   - *Answer*: Restore from backup (S3 versioning), or manually import each resource using `terraform import`.

9. **Why use `toset()` with for_each and lists?**
   - *Answer*: `for_each` requires a map or set. `toset()` converts a list into a set, making it compatible.

10. **What is the risk of not locking provider versions?**
    - *Answer*: Different team members download different versions, causing inconsistent behavior and potential breakage from provider updates.

---

## Comprehensive Quiz (22 Questions)

**1. What command should you use to modify state instead of editing manually?**
- A) `vim terraform.tfstate`
- B) `terraform state`
- C) `terraform edit`
- D) Direct JSON modification


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**2. What happens if you commit terraform.tfstate to Git?**
- A) Everything works fine
- B) Merge conflicts and exposed secrets
- C) Faster deployments
- D) Automatic backups


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**3. How do you create an implicit dependency?**
- A) Use `depends_on`
- B) Reference one resource's attribute in another
- C) Place resources in same file
- D) Use `link` meta-argument


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**4. Can you use variables in module source?**
- A) Yes, always
- B) No, source must be literal string
- C) Only with Terraform Cloud
- D) Only for local modules


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**5. What does count.index start at?**
- A) 1
- B) 0
- C) -1
- D) Random


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**6. What breaks when changing from count to for_each?**
- A) Nothing
- B) Resource addresses change, causing recreation
- C) State file corrupts
- D) Provider fails


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**7. Where are sensitive variables stored in plain text?**
- A) Nowhere, they're encrypted
- B) Only in console output
- C) In the state file
- D) In .terraform directory


<details>
<summary>Show Answer</summary>

**Answer: C**

</details>

**8. How do you fix a circular dependency in security groups?**
- A) Can't be fixed
- B) Use separate security group rule resources
- C) Merge the security groups
- D) Use depends_on


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**9. What should you commit to version control?**
- A) terraform.tfstate
- B) .terraform directory
- C) .terraform.lock.hcl
- D) terraform.tfvars with passwords


<details>
<summary>Show Answer</summary>

**Answer: C**

</details>

**10. What does for_each require?**
- A) A list
- B) A map or set
- C) A string
- D) An integer


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**11. How do you prevent accidental resource destruction?**
- A) `protect = true`
- B) `prevent_destroy = true` in lifecycle
- C) `no_delete = true`
- D) `immutable = true`


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**12. What converts a list to a set?**
- A) `tomap()`
- B) `list_to_set()`
- C) `toset()`
- D) `convert()`


<details>
<summary>Show Answer</summary>

**Answer: C**

</details>

**13. When are module sources resolved?**
- A) During plan
- B) During apply
- C) During init
- D) During validation


<details>
<summary>Show Answer</summary>

**Answer: C**

</details>

**14. What does sensitive = true do?**
- A) Encrypts state file
- B) Hides value in console output only
- C) Prevents Git commits
- D) Enables encryption at rest


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**15. How do you lock provider versions?**
- A) In variables.tf
- B) In required_providers block with version constraint
- C) In backend configuration
- D) Can't lock versions


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**16. What is the risk of manual state file edits?**
- A) Faster deployments
- B) Breaks checksums and causes inconsistencies
- C) Improves performance
- D) No risk


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**17. How do you move a resource address in state?**
- A) Manual edit
- B) `terraform state mv`
- C) `terraform move`
- D) `terraform relocate`


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**18. What happens with default_tags and resource tags conflict?**
- A) Resource tags always win
- B) Default tags always win
- C) Results in duplicate or conflicting tags
- D) Terraform errors


<details>
<summary>Show Answer</summary>

**Answer: C**

</details>

**19. How do you recover from lost state file?**
- A) Recreate all resources
- B) Restore from backup or manually import
- C) It's impossible
- D) Use terraform refresh


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**20. What creates implicit dependency between modules?**
- A) depends_on between modules
- B) Passing outputs as inputs
- C) Same file placement
- D) Module naming


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**21. Why might "it worked yesterday" fail today?**
- A) Cloud provider outage
- B) Unlocked provider version updated with breaking changes
- C) State file corruption
- D) Network issues


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**22. What is the proper way to handle secrets?**
- A) Store in tfstate
- B) Commit to Git
- C) Use external secret management (Secrets Manager, Vault)
- D) Hard-code in .tf files


<details>
<summary>Show Answer</summary>

**Answer: C**

</details>

---

## Summary of Key Gotchas

| Gotcha | Impact | Prevention |
|--------|--------|------------|
| Manual state edits | High | Use `terraform state` commands |
| Committing state to Git | High | Use remote backend |
| Unlocked provider versions | Medium | Lock versions in `required_providers` |
| Count ↔ For_each changes | High | Use `terraform state mv` |
| Circular dependencies | Medium | Use separate rule resources |
| Module source with variables | Low | Use literal strings only |
| Sensitive in state | High | Use external secret management |
| Default tag conflicts | Low | Be explicit with merge() |

**Remember**: Most gotchas can be avoided by following Terraform best practices and understanding the tool's behavior before making changes!
