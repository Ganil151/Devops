# Day 6: Terraform Project Structure - Challenges

## Challenge Overview
These challenges will test your understanding of Terraform project organization, file structure, variables, locals, and outputs. Complete them in order as each builds upon the previous.

---

## 🎯 Challenge 1: File Organization Analysis
**Difficulty**: Beginner  
**Time**: 15 minutes

### Task
Analyze the current project structure and answer these questions:

1. **File Purpose Identification**:
   - List the purpose of each `.tf` file in the project
   - Explain why resources are separated into different files
   - Identify which file would you modify to add a new variable

2. **Dependency Mapping**:
   - Create a diagram showing how files reference each other
   - Identify which resources depend on others
   - Explain the order Terraform processes these files

### Expected Deliverable
Create a markdown document explaining your analysis with a simple dependency diagram.

---

## 🎯 Challenge 2: Variable Validation Enhancement
**Difficulty**: Intermediate  
**Time**: 20 minutes

### Task
Enhance the existing variable definitions with additional validation rules:

1. **Region Validation**:
   - Add validation to `region` variable to only allow US regions
   - Accepted values: `us-east-1`, `us-east-2`, `us-west-1`, `us-west-2`

2. **VPC CIDR Validation**:
   - Enhance the existing CIDR validation
   - Ensure the CIDR block is within private IP ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)

3. **Project Name Validation**:
   - Add validation to ensure project name is lowercase
   - Must be between 3-20 characters
   - Only alphanumeric characters and hyphens allowed

### Expected Deliverable
Updated `variables.tf` file with enhanced validation rules.

---

## 🎯 Challenge 3: Local Values Expansion
**Difficulty**: Intermediate  
**Time**: 25 minutes

### Task
Expand the `locals.tf` file with additional computed values:

1. **Subnet Configuration**:
   ```hcl
   subnet_configs = {
     for i, az in var.availability_zones : az => {
       cidr_block = cidrsubnet(var.vpc_cidr, 8, i)
       az         = az
       name       = "${local.name_prefix}-public-subnet-${i + 1}"
     }
   }
   ```

2. **Resource Naming Standards**:
   ```hcl
   resource_names = {
     vpc                = "${local.name_prefix}-vpc"
     internet_gateway   = "${local.name_prefix}-igw"
     route_table       = "${local.name_prefix}-public-rt"
     security_group    = "${local.name_prefix}-default-sg"
   }
   ```

3. **Environment-Specific Settings**:
   ```hcl
   environment_config = {
     dev = {
       instance_type = "t3.micro"
       min_size     = 1
       max_size     = 2
     }
     staging = {
       instance_type = "t3.small"
       min_size     = 2
       max_size     = 4
     }
     production = {
       instance_type = "t3.medium"
       min_size     = 3
       max_size     = 10
     }
   }
   ```

### Expected Deliverable
Updated `locals.tf` file with the new local values.

---

## 🎯 Challenge 4: Network Infrastructure Expansion
**Difficulty**: Intermediate  
**Time**: 30 minutes

### Task
Enhance the VPC configuration by adding missing networking components:

1. **Internet Gateway**:
   ```hcl
   resource "aws_internet_gateway" "main" {
     vpc_id = aws_vpc.main.id
     tags = merge(local.common_tags, {
       Name = local.resource_names.internet_gateway
     })
   }
   ```

2. **Route Table and Routes**:
   ```hcl
   resource "aws_route_table" "public" {
     vpc_id = aws_vpc.main.id
     
     route {
       cidr_block = "0.0.0.0/0"
       gateway_id = aws_internet_gateway.main.id
     }
     
     tags = merge(local.common_tags, {
       Name = local.resource_names.route_table
       Type = "Public"
     })
   }
   ```

3. **Route Table Associations**:
   ```hcl
   resource "aws_route_table_association" "public" {
     count          = length(aws_subnet.public)
     subnet_id      = aws_subnet.public[count.index].id
     route_table_id = aws_route_table.public.id
   }
   ```

### Expected Deliverable
Updated `vpc.tf` file with complete networking infrastructure.

---

## 🎯 Challenge 5: Security Group Implementation
**Difficulty**: Intermediate  
**Time**: 25 minutes

### Task
Create a new file `security.tf` with security group configurations:

1. **Default Security Group**:
   - Allow HTTP (port 80) from anywhere
   - Allow HTTPS (port 443) from anywhere
   - Allow SSH (port 22) from your IP only
   - Allow all outbound traffic

2. **Database Security Group**:
   - Allow MySQL (port 3306) from web security group only
   - No outbound internet access

3. **Use Dynamic Blocks**:
   ```hcl
   dynamic "ingress" {
     for_each = var.allowed_ports
     content {
       from_port   = ingress.value
       to_port     = ingress.value
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
     }
   }
   ```

### Expected Deliverable
New `security.tf` file with security group resources and corresponding variable definitions.

---

## 🎯 Challenge 6: Output Enhancement
**Difficulty**: Beginner  
**Time**: 15 minutes

### Task
Enhance the `output.tf` file with additional useful outputs:

1. **Network Outputs**:
   - Internet Gateway ID
   - Route Table ID
   - Subnet availability zones mapping

2. **Security Outputs**:
   - Security Group IDs and names
   - Security Group rules summary

3. **Computed Outputs**:
   - Total number of subnets created
   - VPC CIDR host count
   - Resource naming convention examples

### Expected Deliverable
Updated `output.tf` file with comprehensive output values.

---

## 🎯 Challenge 7: Multi-Environment Configuration
**Difficulty**: Advanced  
**Time**: 35 minutes

### Task
Create environment-specific configurations:

1. **Environment-Specific tfvars**:
   - Create `dev.tfvars`, `staging.tfvars`, `prod.tfvars`
   - Each with different configurations (VPC CIDR, instance sizes, etc.)

2. **Conditional Resource Creation**:
   ```hcl
   resource "aws_nat_gateway" "main" {
     count         = var.environment == "production" ? length(aws_subnet.public) : 0
     allocation_id = aws_eip.nat[count.index].id
     subnet_id     = aws_subnet.public[count.index].id
   }
   ```

3. **Environment-Specific Tagging**:
   - Add environment-specific tags
   - Include cost center information
   - Add backup policies based on environment

### Expected Deliverable
Multiple `.tfvars` files and updated resource configurations with conditional logic.

---

## 🎯 Challenge 8: Data Sources Integration
**Difficulty**: Advanced  
**Time**: 30 minutes

### Task
Replace hardcoded values with data sources:

1. **Availability Zones**:
   ```hcl
   data "aws_availability_zones" "available" {
     state = "available"
   }
   ```

2. **AMI Lookup**:
   ```hcl
   data "aws_ami" "amazon_linux" {
     most_recent = true
     owners      = ["amazon"]
     
     filter {
       name   = "name"
       values = ["amzn2-ami-hvm-*-x86_64-gp2"]
     }
   }
   ```

3. **Current Region and Account**:
   ```hcl
   data "aws_region" "current" {}
   data "aws_caller_identity" "current" {}
   ```

### Expected Deliverable
New `data.tf` file with data source definitions and updated resource references.

---

## 🎯 Challenge 9: Validation and Testing
**Difficulty**: Advanced  
**Time**: 25 minutes

### Task
Implement comprehensive validation and testing:

1. **Pre-commit Validation**:
   - Create a script that runs `terraform fmt`, `terraform validate`
   - Check for required tags on all resources
   - Validate naming conventions

2. **Resource Validation**:
   - Ensure all resources have required tags
   - Validate CIDR blocks don't overlap
   - Check security group rules for overly permissive access

3. **Output Testing**:
   - Create a script to test all outputs are accessible
   - Validate output values meet expected formats
   - Test cross-resource references

### Expected Deliverable
Validation scripts and updated configurations with comprehensive checks.

---

## 🎯 Challenge 10: Documentation and Cleanup
**Difficulty**: Intermediate  
**Time**: 20 minutes

### Task
Complete the project with proper documentation:

1. **Auto-Generated Documentation**:
   - Use `terraform-docs` to generate README sections
   - Document all variables, outputs, and resources
   - Include usage examples

2. **Architecture Diagram**:
   - Create a visual representation of the infrastructure
   - Show resource relationships and data flow
   - Include security boundaries

3. **Cleanup and Optimization**:
   - Remove unused variables or locals
   - Optimize resource configurations
   - Ensure consistent formatting

### Expected Deliverable
Complete documentation, architecture diagram, and optimized code.

---

## 🏆 Bonus Challenges

### Bonus 1: Module Conversion
Convert the current configuration into a reusable Terraform module with proper module structure.

### Bonus 2: Remote State Management
Implement proper remote state management with state locking and backup strategies.

### Bonus 3: CI/CD Integration
Create GitHub Actions or similar CI/CD pipeline for automated testing and deployment.

---

## Evaluation Criteria

### Code Quality (40%)
- Proper file organization
- Consistent naming conventions
- Appropriate use of variables and locals
- Code readability and comments

### Functionality (30%)
- Resources deploy successfully
- Outputs provide useful information
- Validation rules work correctly
- Security best practices implemented

### Best Practices (20%)
- Proper tagging strategy
- Environment parameterization
- Resource dependencies handled correctly
- Error handling and validation

### Documentation (10%)
- Clear README updates
- Inline code comments
- Architecture documentation
- Usage examples

---

## Submission Guidelines

1. **Code Submission**: All `.tf` files with your implementations
2. **Documentation**: Updated README.md and any additional docs
3. **Testing**: Evidence of successful `terraform plan` and `terraform apply`
4. **Cleanup**: Proof of successful `terraform destroy`

## Resources for Help

- [Terraform Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Provider Examples](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

Good luck with your challenges! 🚀