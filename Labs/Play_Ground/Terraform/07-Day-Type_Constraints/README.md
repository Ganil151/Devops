# Day 7: Terraform Type Constraints

## Overview
This lab demonstrates Terraform's type system and constraints, showing how to use different variable types (string, number, bool, list, map, set, tuple, object) to create robust and type-safe infrastructure configurations.
## 📚 Related Fundamentals
Before starting this lab, review these foundational concepts:
- [Variables and Outputs](../../../../2-Intermediate/02-Phase-2/02-Configuration-Tools/01-Terraform/01-Fundamentals/08-Variables-and-Outputs/Variables%20and%20Outputs.md) - Input variables and output values
- [Configuration Language (HCL)](../../01-Fundamentals/05-Configuration-Language/Configuration%20Language%20(HCL).md) - HCL syntax and expressions
- [Terraform Core Concepts](../../../../2-Intermediate/02-Phase-2/02-Configuration-Tools/01-Terraform/01-Fundamentals/03-Core-Concepts/Terraform%20Core%20Concepts.md) - Understanding Terraform basics
- [Providers](../../../../2-Intermediate/02-Phase-2/02-Configuration-Tools/01-Terraform/01-Fundamentals/06-Providers/Providers.md) - Provider configuration
## Infrastructure Components
This lab creates the following AWS resources:
- **VPC** with DNS support and hostnames enabled
- **Subnet** in us-east-1a with public IP mapping
- **Security Group** with HTTP (port 80) and SSH (port 22) access
- **EC2 Instance** demonstrating all type constraints
- **S3 Bucket** with unique naming using random suffix
- **Random ID** for generating unique resource names
## Step-by-Step IaC Creation Process

### Step 1: Project Structure Setup
```bash
# Navigate to the lab directory
cd /path/to/07-Day-Type_Constraints

# Verify file structure
ls -la
```
Expected files:
- `providers.tf` - Provider configurations
- `variables.tf` - Variable definitions with type constraints
- `locals.tf` - Local values and computed expressions
- `main.tf` - Resource definitions
- `output.tf` - Output value definitions
- `backend.tf` - Remote state configuration
### Step 2: Initialize Terraform
```bash
# Initialize the working directory
terraform init
```
This command:
- Downloads required providers (AWS, Random)
- Initializes the backend (S3 with DynamoDB locking)
- Creates `.terraform` directory and lock file
### Step 3: Validate Configuration
```bash
# Validate syntax and configuration
terraform validate
```
Ensures:
- HCL syntax is correct
- Variable types match usage
- Resource references are valid
- Type constraints are properly defined
### Step 4: Format Code
```bash
# Format Terraform files
terraform fmt
```
Standardizes:
- Indentation and spacing
- Argument alignment
- Code readability
### Step 5: Plan Infrastructure
```bash
# Create execution plan
terraform plan

# Save plan to file (recommended)
terraform plan -out=tfplan
```
The plan shows:
- Resources to be created (6 resources)
- Variable values and type demonstrations
- Output values that will be generated
### Step 6: Apply Configuration
```bash
# Apply the saved plan
terraform apply tfplan

# Or apply with confirmation
terraform apply
```

Creates:
- VPC with CIDR 10.0.0.0/16
- Subnet with CIDR 10.0.1.0/24
- Security group with defined ingress/egress rules
- EC2 instance with specified configuration
- S3 bucket with unique name
- Random ID for unique naming

### Step 7: Verify Outputs
```bash
# View all outputs
terraform output

# View specific output
terraform output instance_ids

# View outputs in JSON format
terraform output -json
```

### Step 8: Inspect State
```bash
# Show current state
terraform show

# List resources in state
terraform state list

# Show specific resource
terraform state show aws_instance.web_server[0]
```

## Type Constraints Demonstrated

### 1. String Type
```hcl
variable "environment" {
  type        = string
  description = "the environment type"
  default     = "dev"
}

variable "instance_type" {
  type        = string
  description = "the ec2 instance type"
  default     = "t2.micro"
}
```
**Usage**: Environment names, instance types, resource descriptions
**Access**: `var.environment`, `var.instance_type`

### 2. Number Type
```hcl
variable "instance_count" {
  type        = number
  description = "the number of ec2 instances to create"
  default     = 1
}

variable "storage_size" {
  type        = number
  description = "the storage size for ec2 instance in GB"
  default     = 8
}
```
**Usage**: Instance counts, storage sizes, port numbers
**Access**: `var.instance_count`, `var.storage_size`

### 3. Bool Type
```hcl
variable "enable_monitoring" {
  type        = bool
  description = "enable detailed monitoring for ec2 instances"
  default     = false
}

variable "associate_public_ip" {
  type        = bool
  description = "associate public ip to ec2 instance"
  default     = true
}
```
**Usage**: Feature flags, enable/disable options
**Access**: `var.enable_monitoring`, `var.associate_public_ip`

### 4. List Type (Allows Duplicates, Maintains Order)
```hcl
variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "list of allowed cidr blocks for security group"
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

variable "allowed_instance_types" {
  type        = list(string)
  description = "list of allowed ec2 instance types"
  default     = ["t2.micro", "t2.small", "t3.micro"]
}
```
**Usage**: Multiple values, ordered collections, allows duplicates
**Access**: `var.allowed_cidr_blocks[0]`, `length(var.allowed_instance_types)`

### 5. Map Type (Key-Value Pairs)
```hcl
variable "instance_tags" {
  type        = map(string)
  description = "tags to apply to the ec2 instances"
  default = {
    "Environment" = "dev"
    "Project"     = "Terraform-Gsmash-Demo"
    "Owner"       = "devops-team"
  }
}

variable "resource_tags" {
  type        = map(string)
  description = "common resource tags"
  default = {
    Project     = "Terraform-Gsmash-Demo"
    Environment = "dev"
    Owner       = "Gsmash"
    ManageBy    = "Terraform"
    LOB         = "Engineering"
  }
}
```
**Usage**: Resource tags, configuration mappings
**Access**: `var.instance_tags["Environment"]`, `keys(var.resource_tags)`

### 6. Set Type (No Duplicates, Order Doesn't Matter)
```hcl
variable "availability_zones" {
  type        = set(string)
  description = "set of availability zones (no duplicates)"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
```
**Usage**: Unique collections, automatically removes duplicates
**Access**: `tolist(var.availability_zones)[0]` (convert to list for indexing)
**Key Difference**: Cannot access by index directly, order not guaranteed

### 7. Tuple Type (Fixed Length, Specific Types)
```hcl
variable "network_config" {
  type        = tuple([string, string, number])
  description = "Network configuration (VPC CIDR, subnet CIDR, port number)"
  default     = ["10.0.0.0/16", "10.0.1.0/24", 80]
}
```
**Usage**: Fixed-length collections with specific types per position
**Access**: `var.network_config[0]` (VPC CIDR), `var.network_config[2]` (port)
**Critical Rules**: Position 0=string, Position 1=string, Position 2=number

### 8. Object Type (Named Attributes with Specific Types)
```hcl
variable "server_config" {
  type = object({
    name           = string
    instance_type  = string
    monitoring     = bool
    storage_gb     = number
    backup_enabled = bool
  })
  description = "Complete server configuration object"
  default = {
    name           = "web-server"
    instance_type  = "t2.micro"
    monitoring     = true
    storage_gb     = 20
    backup_enabled = false
  }
}

variable "vm_config" {
  type = object({
    instance_type = string
    ami_id        = string
    monitoring    = bool
  })
  description = "VM configuration object"
  default = {
    instance_type = "t2.micro"
    ami_id        = "ami-0c55b159cbfafe1f0"
    monitoring    = false
  }
}
```
**Usage**: Complex structured data, self-documenting configuration
**Access**: `var.server_config.name`, `var.vm_config.instance_type`
**Benefits**: Type safety for each attribute, clear structure

## Key Learning Points

### Type Safety Benefits
- **Validation**: Terraform validates types at plan time
- **Documentation**: Types serve as inline documentation
- **Error Prevention**: Catches type mismatches early
- **IDE Support**: Better autocomplete and error detection

### Best Practices
1. **Always specify types** for variables
2. **Use descriptive names** and descriptions
3. **Provide sensible defaults** where appropriate
4. **Use validation blocks** for additional constraints
5. **Choose appropriate types** for your use case

### Type Conversion Functions
- `tostring()` - Convert to string
- `tonumber()` - Convert to number
- `tobool()` - Convert to boolean
- `tolist()` - Convert to list
- `toset()` - Convert to set
- `tomap()` - Convert to map

## Common Patterns

### Conditional Logic with Types
```hcl
# From locals.tf
locals {
  instance_name = "gsmash-${var.environment}-instance"
  vpc_cidr      = element(var.network_config, 0)  # First element (string)
  subnet_cidr   = "${element(var.network_config, 1)}/${element(var.network_config, 2)}"  # Combine elements
}
```

### Type-Safe Resource Configuration
```hcl
# From main.tf - Using different type constraints
resource "aws_instance" "web_server" {
  # String type usage
  ami           = "ami-0e8459476fed2e23b"
  instance_type = var.instance_type
  
  # Number type usage
  count = var.instance_count
  
  # Bool type usage
  monitoring                  = var.enable_monitoring
  associate_public_ip_address = var.associate_public_ip
  
  # Set type usage (convert to list for indexing)
  availability_zone = "us-east-1a"  # Fixed AZ
  
  # Map type usage
  tags = var.instance_tags
  
  # Number type in nested block
  root_block_device {
    volume_size = var.storage_size
    volume_type = "gp3"
  }
}
```

### Security Group with Tuple Type
```hcl
# Using tuple elements for port configuration
resource "aws_security_group" "web_sg" {
  name        = "${var.server_config.name}-sg"  # Object type access
  description = "Security group for web server"
  vpc_id      = aws_vpc.main.id
  
  # HTTP access using tuple type (port from network_config[2])
  ingress {
    from_port   = var.network_config[2]  # Tuple element (number)
    to_port     = var.network_config[2]  # Tuple element (number)
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks  # List type
  }
  
  # Map type for tags
  tags = var.instance_tags
}
```

### Output Demonstrations
```hcl
# From output.tf - Showing type usage in outputs
output "environment_info" {
  description = "Environment information from string type variable"
  value = {
    name         = var.environment
    type         = "string"
    is_staging   = var.environment == "staging"  # String comparison
    display_name = upper(var.environment)        # String function
  }
}

output "network_configuration" {
  description = "Network configuration from tuple type variable"
  value = {
    tuple_value   = var.network_config
    vpc_cidr      = element(var.network_config, 0)  # First element
    subnet_prefix = element(var.network_config, 1)  # Second element
    cidr_bits     = element(var.network_config, 2)  # Third element
    type          = "tuple([string, string, number])"
  }
}
```

## Advanced Type Features

### Variable Validation
```hcl
variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### Optional Object Attributes
```hcl
variable "server_config_optional" {
  type = object({
    name         = string
    instance_type = string
    monitoring   = optional(bool, false)  # Optional with default
    storage_gb   = optional(number)       # Optional without default
  })
  description = "Server configuration with optional attributes"
}
```

### Complex Nested Types
```hcl
variable "complex_config" {
  type = object({
    servers = list(object({
      name = string
      type = string
      tags = map(string)
    }))
    networks = map(object({
      cidr = string
      azs  = set(string)
    }))
  })
  description = "Complex nested configuration"
}
```

## Troubleshooting

### Common Type Errors
1. **Type Mismatch**: Variable type doesn't match usage
   ```
   Error: Invalid value for variable
   The given value is not suitable for the declared variable type.
   ```

2. **Invalid Conversion**: Cannot convert between incompatible types
   ```
   Error: Invalid function argument
   Invalid value for "v" parameter: cannot convert string to number.
   ```

3. **Missing Required Attributes**: Object type missing required fields
   ```
   Error: Missing required argument
   The argument "name" is required, but no definition was found.
   ```

4. **Index Out of Range**: Accessing non-existent list/tuple elements
   ```
   Error: Invalid index
   The given key does not identify an element in this collection value.
   ```

### Debugging Commands
```bash
# Test expressions in console
terraform console
> var.network_config[0]
> length(var.allowed_cidr_blocks)
> keys(var.instance_tags)
> type(var.server_config)
```

### Type Checking Functions
```hcl
# Check if value can be converted
can(tonumber(var.some_string))

# Check if key exists in map
contains(keys(var.instance_tags), "Environment")

# Validate list length
length(var.allowed_cidr_blocks) > 0
```

## Performance Considerations

### Type Choice Impact
- **Lists vs Sets**: Sets are more efficient for membership testing
- **Maps vs Objects**: Objects provide better type safety, maps more flexibility
- **Tuples vs Lists**: Tuples enforce structure, lists allow dynamic sizing

### Memory Usage
- Large maps and lists consume more memory
- Complex nested objects increase processing time
- Consider using data sources for large static datasets

## Cleanup
```bash
# Destroy infrastructure
terraform destroy

# Confirm destruction
# Type 'yes' when prompted
```

## 🔗 Additional Resources

### Command References
- [Init Command](../../../../2-Intermediate/02-Phase-2/02-Configuration-Tools/01-Terraform/01-Fundamentals/02-Commands/01-Init.md) - Initialize working directory
- [Plan Command](../../../../2-Intermediate/02-Phase-2/02-Configuration-Tools/01-Terraform/01-Fundamentals/02-Commands/03-Plan.md) - Create execution plan
- [Apply Command](../../../../2-Intermediate/02-Phase-2/02-Configuration-Tools/01-Terraform/01-Fundamentals/02-Commands/04-Apply.md) - Apply changes
- [Output Command](../../../../2-Intermediate/02-Phase-2/02-Configuration-Tools/01-Terraform/01-Fundamentals/02-Commands/11-Output.md) - View outputs
- [Validate Command](../../../../2-Intermediate/02-Phase-2/02-Configuration-Tools/01-Terraform/01-Fundamentals/02-Commands/02-Validate.md) - Validate configuration
- [Console Command](../../01-Fundamentals/02-Commands/14-Console.md) - Interactive console

### Related Labs
- [Day 5: Project Structure](../../../../README.md) - File organization
- [Day 4: Remote State](../04-Day/README.md) - Backend configuration
- [Day 6: Functions](../../../../README.md) - Built-in functions
- [Day 8: Modules](../../../../README.md) - Module development

### External Documentation
- [Terraform Type Constraints](https://developer.hashicorp.com/terraform/language/expressions/type-constraints)
- [Variable Validation](https://developer.hashicorp.com/terraform/language/values/variables#custom-validation-rules)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [HCL Functions](https://developer.hashicorp.com/terraform/language/functions)