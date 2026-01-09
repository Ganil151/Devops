# Day 7 Challenges: Terraform Type Constraints

## 🎯 Challenge Overview
These challenges test your understanding of Terraform's type system and constraints. Complete them progressively to master type-safe infrastructure configurations.
## 📋 Prerequisites
- Completed Day 7 main lab
- Understanding of all 8 Terraform types
- AWS CLI configured
- Terraform >= 1.0 installed
---
## Challenge 1: Basic Type Implementation (20 minutes)

### Objective
Create a new Terraform configuration demonstrating all basic types with proper validation.
### Requirements
Create `challenge1.tf` with variables for:
1. **String Type**: Database engine with validation
```hcl
variable "db_engine" {
  type        = string
  description = "Database engine type"
  
  validation {
    condition     = contains(["mysql", "postgres", "mariadb"], var.db_engine)
    error_message = "Database engine must be mysql, postgres, or mariadb."
  }
}
```
2. **Number Type**: Port number with range validation
```hcl
variable "db_port" {
  type        = number
  description = "Database port number"
  
  validation {
    condition     = var.db_port >= 1024 && var.db_port <= 65535
    error_message = "Port must be between 1024 and 65535."
  }
}
```
3. **Bool Type**: Multi-AZ deployment flag
```hcl
variable "multi_az" {
  type        = bool
  description = "Enable Multi-AZ deployment"
  default     = false
}
```
### Tasks
1. Create the variables with validation
2. Add a `terraform.tfvars` file with test values
3. Test validation by providing invalid values
4. Create outputs showing type information
### ✅ Success Criteria
- [ ] All variables validate correctly
- [ ] Invalid values trigger appropriate errors
- [ ] Outputs display type information

---

## Challenge 2: Complex Collection Types (25 minutes)

### Objective
Implement advanced collection types with real-world scenarios.
### Requirements
1. **List Type**: Subnet configurations
```hcl
variable "subnet_configs" {
  type = list(object({
    name              = string
    cidr_block        = string
    availability_zone = string
    public            = bool
  }))
  description = "List of subnet configurations"
  
  validation {
    condition     = length(var.subnet_configs) >= 2
    error_message = "At least 2 subnets are required."
  }
}
```
2. **Map Type**: Environment-specific instance types
```hcl
variable "env_instance_types" {
  type        = map(string)
  description = "Instance types per environment"
  
  validation {
    condition = alltrue([
      for env, type in var.env_instance_types :
      contains(["t2.micro", "t2.small", "t3.micro", "t3.small"], type)
    ])
    error_message = "Instance types must be t2.micro, t2.small, t3.micro, or t3.small."
  }
}
```
3. **Set Type**: Required tags
```hcl
variable "required_tags" {
  type        = set(string)
  description = "Set of required tag keys"
  
  validation {
    condition     = contains(var.required_tags, "Environment")
    error_message = "Environment tag is mandatory."
  }
}
```
### Tasks
1. Create resources using these collection types
2. Implement dynamic blocks based on list configurations
3. Use for_each with map and set types
4. Create comprehensive outputs
### ✅ Success Criteria
- [ ] Dynamic subnets created from list
- [ ] Instance types vary by environment
- [ ] Required tags enforced
- [ ] All validations work correctly
---
## Challenge 3: Advanced Object and Tuple Types (30 minutes)

### Objective
Master complex structured types with nested configurations.
### Requirements
1. **Tuple Type**: Network configuration with strict positioning
```hcl
variable "network_stack" {
  type = tuple([
    string,                    # VPC CIDR
    list(string),             # Subnet CIDRs
    map(number),              # Port mappings
    bool                      # Enable NAT Gateway
  ])
  description = "Complete network stack configuration"
  
  validation {
    condition = can(cidrhost(var.network_stack[0], 0))
    error_message = "First element must be a valid CIDR block."
  }
}
```
2. **Complex Object Type**: Application configuration
```hcl
variable "app_config" {
  type = object({
    name    = string
    version = string
    
    database = object({
      engine      = string
      version     = string
      multi_az    = bool
      backup_days = number
    })
    
    compute = object({
      instance_type = string
      min_size      = number
      max_size      = number
      desired_size  = number
    })
    
    networking = object({
      vpc_cidr     = string
      subnet_cidrs = list(string)
      enable_vpn   = optional(bool, false)
    })
    
    monitoring = optional(object({
      enabled           = bool
      retention_days    = number
      alert_endpoints   = set(string)
    }), {
      enabled           = false
      retention_days    = 7
      alert_endpoints   = []
    })
  })
  description = "Complete application configuration"
}
```
### Tasks
1. Create a complete application stack using the object configuration
2. Use tuple elements for network setup
3. Implement conditional resources based on optional attributes
4. Create nested outputs showing object structure
### ✅ Success Criteria
- [ ] All object attributes used correctly
- [ ] Tuple positioning enforced
- [ ] Optional attributes work as expected
- [ ] Complex nested structure validates
---
## Challenge 4: Type Conversion and Functions (25 minutes)

### Objective
Demonstrate mastery of type conversion functions and type checking.
### Requirements
1. **Type Conversion Challenge**
```hcl
variable "mixed_inputs" {
  type = object({
    string_number    = string    # "123"
    bool_string      = string    # "true"
    list_string      = string    # "item1,item2,item3"
    json_string      = string    # JSON object as string
  })
  description = "Mixed type inputs requiring conversion"
}

locals {
  # Convert and validate types
  converted_number = tonumber(var.mixed_inputs.string_number)
  converted_bool   = tobool(var.mixed_inputs.bool_string)
  converted_list   = split(",", var.mixed_inputs.list_string)
  converted_object = jsondecode(var.mixed_inputs.json_string)
  
  # Type checking
  is_valid_number = can(tonumber(var.mixed_inputs.string_number))
  is_valid_bool   = can(tobool(var.mixed_inputs.bool_string))
  is_valid_json   = can(jsondecode(var.mixed_inputs.json_string))
}
```
2. **Dynamic Type Usage**
```hcl
variable "dynamic_config" {
  type = any
  description = "Dynamic configuration that can be any type"
}

locals {
  # Determine type and handle accordingly
  config_type = type(var.dynamic_config)
  
  # Handle different types
  processed_config = (
    local.config_type == "string" ? { value = var.dynamic_config, type = "string" } :
    local.config_type == "number" ? { value = var.dynamic_config, type = "number" } :
    local.config_type == "bool" ? { value = var.dynamic_config, type = "bool" } :
    local.config_type == "list" ? { value = var.dynamic_config, type = "list", length = length(var.dynamic_config) } :
    local.config_type == "map" ? { value = var.dynamic_config, type = "map", keys = keys(var.dynamic_config) } :
    { value = var.dynamic_config, type = "unknown" }
  )
}
```
### Tasks
1. Create test cases for all type conversions
2. Implement error handling for invalid conversions
3. Create dynamic resource configuration based on type detection
4. Build comprehensive type analysis outputs
### ✅ Success Criteria
- [ ] All type conversions work correctly
- [ ] Invalid conversions handled gracefully
- [ ] Dynamic type detection functional
- [ ] Type analysis outputs comprehensive
---
## Challenge 5: Real-World Application (35 minutes)

### Objective
Build a complete multi-tier application using all type constraints learned.
### Requirements
Create a comprehensive web application infrastructure with:
1. **Application Definition**
```hcl
variable "application" {
  type = object({
    name        = string
    environment = string
    version     = string
    
    # Web tier configuration
    web_tier = object({
      instance_type     = string
      min_instances     = number
      max_instances     = number
      health_check_path = string
      ssl_enabled       = bool
    })
    
    # Database tier configuration
    database = object({
      engine          = string
      instance_class  = string
      allocated_storage = number
      multi_az        = bool
      backup_retention = number
      maintenance_window = string
    })
    
    # Network configuration
    networking = object({
      vpc_cidr           = string
      availability_zones = set(string)
      public_subnets     = list(string)
      private_subnets    = list(string)
      enable_nat_gateway = bool
    })
    
    # Security configuration
    security = object({
      allowed_cidr_blocks = list(string)
      ssl_certificate_arn = optional(string)
      enable_waf          = optional(bool, false)
    })
    
    # Monitoring and logging
    monitoring = optional(object({
      enabled               = bool
      log_retention_days    = number
      alarm_email_endpoints = set(string)
      custom_metrics        = map(string)
    }))
    
    # Feature flags
    features = map(bool)
    
    # Resource tags
    tags = map(string)
  })
  
  validation {
    condition = contains(["dev", "staging", "prod"], var.application.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
  
  validation {
    condition = length(var.application.networking.availability_zones) >= 2
    error_message = "At least 2 availability zones required."
  }
  
  validation {
    condition = var.application.database.backup_retention >= 1 && var.application.database.backup_retention <= 35
    error_message = "Backup retention must be between 1 and 35 days."
  }
}
```
2. **Environment-Specific Configurations**
```hcl
variable "environment_configs" {
  type = map(object({
    instance_type = string
    min_instances = number
    max_instances = number
    db_instance_class = string
    enable_monitoring = bool
  }))
  
  default = {
    dev = {
      instance_type     = "t3.micro"
      min_instances     = 1
      max_instances     = 2
      db_instance_class = "db.t3.micro"
      enable_monitoring = false
    }
    staging = {
      instance_type     = "t3.small"
      min_instances     = 2
      max_instances     = 4
      db_instance_class = "db.t3.small"
      enable_monitoring = true
    }
    prod = {
      instance_type     = "t3.medium"
      min_instances     = 3
      max_instances     = 10
      db_instance_class = "db.t3.medium"
      enable_monitoring = true
    }
  }
}
```
### Tasks
1. Create complete infrastructure using the application object
2. Implement environment-specific resource sizing
3. Use conditional logic for optional features
4. Create comprehensive outputs for all tiers
5. Add proper validation for all inputs
6. Test with different environment configurations
### ✅ Success Criteria
- [ ] Complete multi-tier application deployed
- [ ] All type constraints properly implemented
- [ ] Environment-specific configurations work
- [ ] Optional features toggle correctly
- [ ] All validations pass
- [ ] Comprehensive outputs provided
---
## Challenge 6: Error Handling and Debugging (20 minutes)

### Objective
Master error handling and debugging techniques for type-related issues.
### Requirements
1. **Create Intentional Type Errors**
```hcl
# Create these scenarios and fix them
variable "error_scenarios" {
  type = object({
    # Scenario 1: Type mismatch
    port_number = string  # Should be number
    
    # Scenario 2: Missing required attribute
    incomplete_config = object({
      name = string
      # Missing required 'type' attribute
    })
    
    # Scenario 3: Invalid tuple access
    network_tuple = tuple([string, number])
    # Try to access index 2 (doesn't exist)
    
    # Scenario 4: Set indexing error
    zone_set = set(string)
    # Try to access zone_set[0] directly
  })
}
```
2. **Debugging Toolkit**
```hcl
locals {
  # Type inspection functions
  debug_info = {
    for var_name, var_value in {
      environment = var.environment
      instance_count = var.instance_count
      network_config = var.network_config
      server_config = var.server_config
    } : var_name => {
      type = type(var_value)
      value = var_value
      is_string = can(tostring(var_value))
      is_number = can(tonumber(var_value))
      is_bool = can(tobool(var_value))
    }
  }
}
```
### Tasks
1. Create and document each error scenario
2. Implement debugging outputs
3. Create fixes for each error type
4. Build a troubleshooting guide
5. Test error handling with terraform console
### ✅ Success Criteria
- [ ] All error scenarios documented
- [ ] Debugging toolkit functional
- [ ] Fixes implemented correctly
- [ ] Troubleshooting guide complete
---
## 🏆 Bonus Challenge: Advanced Type System (40 minutes)

### Objective Push the boundaries of Terraform's type system with advanced patterns.

### Requirements
1. **Generic Configuration Pattern**
```hcl
variable "service_configs" {
  type = map(object({
    type = string
    config = any
  }))
  description = "Generic service configurations"
}

locals {
  # Process different service types
  processed_services = {
    for name, service in var.service_configs : name => (
      service.type == "web" ? {
        instance_type = service.config.instance_type
        port = service.config.port
        health_check = service.config.health_check
      } :
      service.type == "database" ? {
        engine = service.config.engine
        size = service.config.size
        backup = service.config.backup
      } :
      service.type == "cache" ? {
        node_type = service.config.node_type
        num_nodes = service.config.num_nodes
      } : {}
    )
  }
}
```
2. **Type-Safe Module Interface**
```hcl
variable "module_inputs" {
  type = object({
    # Required inputs
    name = string
    environment = string
    
    # Optional inputs with defaults
    scaling = optional(object({
      min_size = number
      max_size = number
      desired_size = number
    }), {
      min_size = 1
      max_size = 3
      desired_size = 2
    })
    
    # Conditional inputs
    database = optional(object({
      enabled = bool
      config = optional(object({
        engine = string
        version = string
        instance_class = string
      }))
    }))
    
    # Advanced validation
    custom_config = optional(any)
  })
  
  validation {
    condition = (
      var.module_inputs.database != null && var.module_inputs.database.enabled == true
    ) ? var.module_inputs.database.config != null : true
    error_message = "Database config is required when database is enabled."
  }
}
```
### Tasks
1. Implement the generic service pattern
2. Create type-safe module interfaces
3. Build advanced validation logic
4. Test with complex nested configurations
5. Create documentation for the patterns
### ✅ Success Criteria
- [ ] Generic patterns work with multiple service types
- [ ] Module interfaces are type-safe
- [ ] Advanced validations function correctly
- [ ] Complex configurations handled properly
- [ ] Patterns documented for reuse
---
## 📊 Assessment Rubric

### Basic Level (60% - Challenges 1-2)
- [ ] Understands all 8 basic types
- [ ] Can implement simple validation
- [ ] Creates basic collection types
- [ ] Handles type errors appropriately
### Intermediate Level (80% - Challenges 1-4)
- [ ] Masters complex object and tuple types
- [ ] Implements type conversion correctly
- [ ] Uses optional attributes effectively
- [ ] Debugs type-related issues
### Advanced Level (100% - All Challenges)
- [ ] Builds real-world applications with types
- [ ] Creates advanced type patterns
- [ ] Implements generic configurations
- [ ] Masters error handling and debugging
### Expert Level (Bonus Challenge)
- [ ] Pushes type system boundaries
- [ ] Creates reusable type patterns
- [ ] Implements advanced validation logic
- [ ] Documents patterns for team use
---
## 🔧 Troubleshooting Guide

### Common Issues
1. **Type Mismatch Errors**: Check variable declarations vs usage
2. **Validation Failures**: Review validation conditions and test data
3. **Optional Attribute Issues**: Ensure proper default handling
4. **Conversion Errors**: Use `can()` function to test conversions
### Debugging Commands
```bash
# Test type expressions
terraform console
> type(var.my_variable)
> can(tonumber("123"))
> contains(["a", "b"], "c")

# Validate configuration
terraform validate

# Check plan for type issues
terraform plan
```
---
## ⏱️ Time Allocation
- **Challenge 1**: 20 minutes
- **Challenge 2**: 25 minutes  
- **Challenge 3**: 30 minutes
- **Challenge 4**: 25 minutes
- **Challenge 5**: 35 minutes
- **Challenge 6**: 20 minutes
- **Bonus Challenge**: 40 minutes
- **Total**: 195 minutes (3.25 hours)

Complete challenges progressively to build expertise in Terraform's type system!