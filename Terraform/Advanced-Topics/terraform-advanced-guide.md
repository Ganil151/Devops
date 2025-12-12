# Terraform Advanced Topics Guide

## Table of Contents
1. [Advanced Configuration Language](#advanced-configuration-language)
2. [Custom Providers](#custom-providers)
3. [Dynamic Blocks](#dynamic-blocks)
4. [Advanced State Management](#advanced-state-management)
5. [Terraform Cloud Integration](#terraform-cloud-integration)
6. [Multi-Cloud Strategies](#multi-cloud-strategies)
7. [Advanced Testing](#advanced-testing)
8. [Performance Optimization](#performance-optimization)
9. [Security Hardening](#security-hardening)
10. [Enterprise Patterns](#enterprise-patterns)

## Advanced Configuration Language

### Complex Data Structures
```hcl
# Complex variable types
variable "application_config" {
  description = "Complex application configuration"
  type = object({
    name    = string
    version = string
    
    environments = map(object({
      instance_count = number
      instance_type  = string
      
      database = object({
        engine         = string
        engine_version = string
        instance_class = string
        multi_az      = bool
        
        backup_config = object({
          retention_period = number
          backup_window   = string
          maintenance_window = string
        })
      })
      
      monitoring = object({
        enabled = bool
        
        alerts = list(object({
          name      = string
          metric    = string
          threshold = number
          comparison = string
        }))
      })
    }))
    
    features = set(string)
    
    tags = map(string)
  })
  
  validation {
    condition = alltrue([
      for env_name, env_config in var.application_config.environments :
      env_config.instance_count >= 1 && env_config.instance_count <= 10
    ])
    error_message = "Instance count must be between 1 and 10 for all environments."
  }
}

# Advanced locals with complex logic
locals {
  # Flatten nested structures
  environment_instances = flatten([
    for env_name, env_config in var.application_config.environments : [
      for i in range(env_config.instance_count) : {
        environment = env_name
        instance_id = i
        name        = "${var.application_config.name}-${env_name}-${i}"
        type        = env_config.instance_type
      }
    ]
  ])
  
  # Create lookup maps
  instance_lookup = {
    for instance in local.environment_instances :
    instance.name => instance
  }
  
  # Conditional logic with complex expressions
  monitoring_config = {
    for env_name, env_config in var.application_config.environments :
    env_name => env_config.monitoring.enabled ? {
      alerts = {
        for alert in env_config.monitoring.alerts :
        alert.name => {
          metric_name = alert.metric
          threshold   = alert.threshold
          comparison  = alert.comparison
          
          # Dynamic alarm configuration
          alarm_actions = env_name == "prod" ? [
            aws_sns_topic.critical_alerts.arn
          ] : [
            aws_sns_topic.dev_alerts.arn
          ]
        }
      }
    } : {}
  }
}
```

### Advanced Functions and Expressions
```hcl
# Custom validation functions
locals {
  # Validate CIDR blocks
  validate_cidr = {
    for name, cidr in var.subnet_cidrs :
    name => can(cidrhost(cidr, 0))
  }
  
  # Calculate subnet distributions
  subnet_distribution = {
    for i, az in data.aws_availability_zones.available.names :
    az => {
      public_cidr  = cidrsubnet(var.vpc_cidr, 8, i + 1)
      private_cidr = cidrsubnet(var.vpc_cidr, 8, i + 10)
      db_cidr      = cidrsubnet(var.vpc_cidr, 8, i + 20)
    }
  }
  
  # Advanced string manipulation
  resource_names = {
    for service in var.services :
    service => {
      # Normalize service names
      normalized = lower(replace(service, "/[^a-zA-Z0-9]/", "-"))
      
      # Generate resource identifiers
      short_name = substr(local.normalized, 0, 8)
      full_name  = "${var.project_name}-${var.environment}-${local.normalized}"
      
      # DNS-safe names
      dns_name = replace(local.full_name, "_", "-")
    }
  }
}

# Advanced conditional expressions
resource "aws_instance" "conditional" {
  count = var.create_instances ? length(var.instance_configs) : 0
  
  ami           = data.aws_ami.selected.id
  instance_type = var.instance_configs[count.index].type
  
  # Complex conditional logic
  user_data = var.instance_configs[count.index].role == "web" ? templatefile(
    "${path.module}/templates/web-userdata.sh",
    {
      environment = var.environment
      app_config  = jsonencode(var.app_config)
    }
  ) : var.instance_configs[count.index].role == "worker" ? templatefile(
    "${path.module}/templates/worker-userdata.sh",
    {
      queue_url = aws_sqs_queue.main.url
    }
  ) : null
  
  tags = merge(
    local.common_tags,
    var.instance_configs[count.index].tags,
    {
      Name = "${local.name_prefix}-${var.instance_configs[count.index].role}-${count.index + 1}"
      Role = var.instance_configs[count.index].role
    }
  )
}
```

### Template Functions
```hcl
# Advanced templating
resource "aws_launch_template" "web" {
  name_prefix   = "${local.name_prefix}-web-"
  image_id      = data.aws_ami.web.id
  instance_type = var.instance_type
  
  user_data = base64encode(templatefile("${path.module}/templates/web-init.tpl", {
    # Pass complex data structures
    config = {
      environment = var.environment
      region      = data.aws_region.current.name
      
      database = {
        endpoint = aws_db_instance.main.endpoint
        port     = aws_db_instance.main.port
        name     = aws_db_instance.main.db_name
      }
      
      cache = {
        endpoint = aws_elasticache_cluster.main.cache_nodes[0].address
        port     = aws_elasticache_cluster.main.cache_nodes[0].port
      }
      
      features = var.feature_flags
    }
    
    # Pass sensitive data securely
    secrets = {
      db_password_arn = aws_secretsmanager_secret.db_password.arn
      api_key_arn     = aws_secretsmanager_secret.api_key.arn
    }
  }))
}

# Template file: templates/web-init.tpl
%{ for key, value in config.features ~}
export FEATURE_${upper(key)}=${value}
%{ endfor ~}

# Database configuration
export DB_ENDPOINT="${config.database.endpoint}"
export DB_PORT="${config.database.port}"
export DB_NAME="${config.database.name}"

# Retrieve secrets from AWS Secrets Manager
DB_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id "${secrets.db_password_arn}" \
  --query SecretString --output text)

API_KEY=$(aws secretsmanager get-secret-value \
  --secret-id "${secrets.api_key_arn}" \
  --query SecretString --output text)

# Application startup
systemctl enable myapp
systemctl start myapp
```

## Custom Providers

### Provider Development
```go
// Custom provider example
package main

import (
    "context"
    "github.com/hashicorp/terraform-plugin-framework/provider"
    "github.com/hashicorp/terraform-plugin-framework/provider/schema"
    "github.com/hashicorp/terraform-plugin-framework/types"
)

type customProvider struct {
    version string
}

type customProviderModel struct {
    Endpoint types.String `tfsdk:"endpoint"`
    Token    types.String `tfsdk:"token"`
}

func (p *customProvider) Metadata(ctx context.Context, req provider.MetadataRequest, resp *provider.MetadataResponse) {
    resp.TypeName = "custom"
    resp.Version = p.version
}

func (p *customProvider) Schema(ctx context.Context, req provider.SchemaRequest, resp *provider.SchemaResponse) {
    resp.Schema = schema.Schema{
        Attributes: map[string]schema.Attribute{
            "endpoint": schema.StringAttribute{
                MarkdownDescription: "API endpoint URL",
                Optional:            true,
            },
            "token": schema.StringAttribute{
                MarkdownDescription: "API authentication token",
                Optional:            true,
                Sensitive:           true,
            },
        },
    }
}

func (p *customProvider) Configure(ctx context.Context, req provider.ConfigureRequest, resp *provider.ConfigureResponse) {
    var data customProviderModel
    
    resp.Diagnostics.Append(req.Config.Get(ctx, &data)...)
    
    if resp.Diagnostics.HasError() {
        return
    }
    
    // Configure API client
    client := &APIClient{
        Endpoint: data.Endpoint.ValueString(),
        Token:    data.Token.ValueString(),
    }
    
    resp.DataSourceData = client
    resp.ResourceData = client
}
```

### Provider Configuration
```hcl
# Using custom provider
terraform {
  required_providers {
    custom = {
      source  = "company/custom"
      version = "~> 1.0"
    }
  }
}

provider "custom" {
  endpoint = var.custom_api_endpoint
  token    = var.custom_api_token
}

# Custom resource usage
resource "custom_application" "main" {
  name        = var.app_name
  environment = var.environment
  
  configuration = {
    replicas = var.replica_count
    resources = {
      cpu    = var.cpu_limit
      memory = var.memory_limit
    }
  }
  
  lifecycle {
    create_before_destroy = true
  }
}
```

## Dynamic Blocks

### Advanced Dynamic Configurations
```hcl
# Dynamic security group rules
resource "aws_security_group" "dynamic" {
  name_prefix = "${local.name_prefix}-dynamic-"
  vpc_id      = aws_vpc.main.id
  
  # Dynamic ingress rules
  dynamic "ingress" {
    for_each = var.ingress_rules
    
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      
      # Conditional CIDR blocks or security groups
      cidr_blocks = lookup(ingress.value, "cidr_blocks", null)
      security_groups = lookup(ingress.value, "security_groups", null)
      
      # Dynamic nested blocks
      dynamic "prefix_list_ids" {
        for_each = lookup(ingress.value, "prefix_list_ids", [])
        content {
          prefix_list_id = prefix_list_ids.value
        }
      }
    }
  }
  
  # Dynamic egress rules with conditions
  dynamic "egress" {
    for_each = var.enable_egress ? var.egress_rules : []
    
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
  
  tags = local.common_tags
}

# Complex dynamic block with nested structures
resource "aws_launch_template" "dynamic" {
  name_prefix   = "${local.name_prefix}-dynamic-"
  image_id      = data.aws_ami.selected.id
  instance_type = var.instance_type
  
  # Dynamic block devices
  dynamic "block_device_mappings" {
    for_each = var.block_devices
    
    content {
      device_name = block_device_mappings.value.device_name
      
      # Nested dynamic block
      dynamic "ebs" {
        for_each = lookup(block_device_mappings.value, "ebs", null) != null ? [block_device_mappings.value.ebs] : []
        
        content {
          volume_size           = ebs.value.volume_size
          volume_type           = ebs.value.volume_type
          iops                 = lookup(ebs.value, "iops", null)
          throughput           = lookup(ebs.value, "throughput", null)
          encrypted            = lookup(ebs.value, "encrypted", true)
          kms_key_id          = lookup(ebs.value, "kms_key_id", null)
          delete_on_termination = lookup(ebs.value, "delete_on_termination", true)
        }
      }
    }
  }
  
  # Dynamic network interfaces
  dynamic "network_interfaces" {
    for_each = var.network_interfaces
    
    content {
      device_index                = network_interfaces.value.device_index
      associate_public_ip_address = lookup(network_interfaces.value, "associate_public_ip_address", false)
      delete_on_termination       = lookup(network_interfaces.value, "delete_on_termination", true)
      security_groups            = lookup(network_interfaces.value, "security_groups", [])
      subnet_id                  = lookup(network_interfaces.value, "subnet_id", null)
    }
  }
  
  # Dynamic tags
  dynamic "tag_specifications" {
    for_each = var.tag_specifications
    
    content {
      resource_type = tag_specifications.value.resource_type
      tags = merge(
        local.common_tags,
        tag_specifications.value.tags
      )
    }
  }
}
```

### Conditional Dynamic Blocks
```hcl
# Variable definitions for dynamic configuration
variable "monitoring_config" {
  description = "Monitoring configuration"
  type = object({
    enabled = bool
    
    cloudwatch = optional(object({
      enabled = bool
      log_groups = optional(list(object({
        name              = string
        retention_in_days = number
      })), [])
    }))
    
    prometheus = optional(object({
      enabled = bool
      scrape_configs = optional(list(object({
        job_name = string
        targets  = list(string)
      })), [])
    }))
  })
  
  default = {
    enabled = false
  }
}

# Dynamic monitoring resources
resource "aws_cloudwatch_log_group" "dynamic" {
  for_each = {
    for lg in try(var.monitoring_config.cloudwatch.log_groups, []) :
    lg.name => lg
    if try(var.monitoring_config.cloudwatch.enabled, false)
  }
  
  name              = each.value.name
  retention_in_days = each.value.retention_in_days
  
  tags = local.common_tags
}

# Dynamic ALB listener rules
resource "aws_lb_listener_rule" "dynamic" {
  count = length(var.listener_rules)
  
  listener_arn = aws_lb_listener.main.arn
  priority     = var.listener_rules[count.index].priority
  
  # Dynamic actions
  dynamic "action" {
    for_each = var.listener_rules[count.index].actions
    
    content {
      type             = action.value.type
      target_group_arn = lookup(action.value, "target_group_arn", null)
      
      # Conditional redirect action
      dynamic "redirect" {
        for_each = action.value.type == "redirect" ? [action.value.redirect] : []
        
        content {
          port        = lookup(redirect.value, "port", null)
          protocol    = lookup(redirect.value, "protocol", null)
          status_code = redirect.value.status_code
        }
      }
      
      # Conditional fixed response action
      dynamic "fixed_response" {
        for_each = action.value.type == "fixed-response" ? [action.value.fixed_response] : []
        
        content {
          content_type = fixed_response.value.content_type
          message_body = lookup(fixed_response.value, "message_body", null)
          status_code  = fixed_response.value.status_code
        }
      }
    }
  }
  
  # Dynamic conditions
  dynamic "condition" {
    for_each = var.listener_rules[count.index].conditions
    
    content {
      # Path pattern condition
      dynamic "path_pattern" {
        for_each = lookup(condition.value, "path_pattern", null) != null ? [condition.value.path_pattern] : []
        
        content {
          values = path_pattern.value.values
        }
      }
      
      # Host header condition
      dynamic "host_header" {
        for_each = lookup(condition.value, "host_header", null) != null ? [condition.value.host_header] : []
        
        content {
          values = host_header.value.values
        }
      }
    }
  }
}
```

## Advanced State Management

### State Manipulation Patterns
```bash
#!/bin/bash
# advanced-state-operations.sh

# State surgery for complex migrations
perform_state_surgery() {
    local old_resource=$1
    local new_resource=$2
    
    echo "Performing state surgery: $old_resource -> $new_resource"
    
    # Backup current state
    terraform state pull > state-backup-$(date +%Y%m%d-%H%M%S).json
    
    # Remove old resource from state
    terraform state rm "$old_resource"
    
    # Import new resource
    terraform import "$new_resource" $(get_resource_id "$old_resource")
    
    # Verify state consistency
    terraform plan -detailed-exitcode
    
    if [ $? -eq 0 ]; then
        echo "State surgery completed successfully"
    else
        echo "State surgery failed, restoring backup"
        terraform state push state-backup-*.json
        exit 1
    fi
}

# Bulk state operations
bulk_state_operations() {
    local operations_file=$1
    
    while IFS=',' read -r operation resource_old resource_new; do
        case $operation in
            "move")
                terraform state mv "$resource_old" "$resource_new"
                ;;
            "remove")
                terraform state rm "$resource_old"
                ;;
            "import")
                terraform import "$resource_old" "$resource_new"
                ;;
        esac
    done < "$operations_file"
}

# State validation and cleanup
validate_and_cleanup_state() {
    echo "Validating state consistency..."
    
    # Check for orphaned resources
    terraform state list | while read resource; do
        if ! terraform plan -target="$resource" >/dev/null 2>&1; then
            echo "WARNING: Orphaned resource detected: $resource"
        fi
    done
    
    # Refresh state from real infrastructure
    terraform refresh
    
    # Validate configuration
    terraform validate
    
    # Check for drift
    terraform plan -detailed-exitcode
}
```

### Cross-Account State Management
```hcl
# Cross-account state access
data "terraform_remote_state" "shared_services" {
  backend = "s3"
  
  config = {
    bucket   = "shared-services-terraform-state"
    key      = "infrastructure/terraform.tfstate"
    region   = "us-west-2"
    role_arn = "arn:aws:iam::${var.shared_services_account_id}:role/TerraformCrossAccountRole"
  }
}

# Use cross-account resources
resource "aws_route53_record" "app" {
  zone_id = data.terraform_remote_state.shared_services.outputs.public_zone_id
  name    = "${var.app_name}.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# Cross-account IAM role for state access
resource "aws_iam_role" "cross_account_terraform" {
  name = "TerraformCrossAccountRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            for account_id in var.trusted_account_ids :
            "arn:aws:iam::${account_id}:root"
          ]
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })
}
```

## Terraform Cloud Integration

### Workspace Configuration
```hcl
# Terraform Cloud configuration
terraform {
  cloud {
    organization = "my-organization"
    
    workspaces {
      tags = ["production", "infrastructure"]
    }
  }
}

# Workspace-specific variables
variable "workspace_config" {
  description = "Workspace-specific configuration"
  type = map(object({
    instance_type = string
    min_size      = number
    max_size      = number
    
    features = object({
      monitoring = bool
      backup     = bool
      encryption = bool
    })
  }))
  
  default = {
    "prod-infrastructure" = {
      instance_type = "t3.large"
      min_size      = 3
      max_size      = 10
      
      features = {
        monitoring = true
        backup     = true
        encryption = true
      }
    }
    
    "dev-infrastructure" = {
      instance_type = "t3.micro"
      min_size      = 1
      max_size      = 3
      
      features = {
        monitoring = false
        backup     = false
        encryption = false
      }
    }
  }
}

# Use workspace-specific configuration
locals {
  workspace_name = terraform.workspace
  config         = var.workspace_config[local.workspace_name]
}

resource "aws_autoscaling_group" "main" {
  name             = "${local.workspace_name}-asg"
  min_size         = local.config.min_size
  max_size         = local.config.max_size
  desired_capacity = local.config.min_size
  
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
  
  tag {
    key                 = "Workspace"
    value               = local.workspace_name
    propagate_at_launch = true
  }
}
```

### Policy as Code Integration
```hcl
# Sentinel policy example
import "tfplan/v2" as tfplan

# Ensure all S3 buckets have encryption enabled
main = rule {
    all tfplan.resource_changes as _, changes {
        changes.type is "aws_s3_bucket_server_side_encryption_configuration" or
        changes.mode is not "managed" or
        changes.type is not "aws_s3_bucket"
    }
}

# OPA policy example
package terraform.security

import rego.v1

# Deny if EC2 instances don't have required tags
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_instance"
    resource.change.after.tags
    
    required_tags := ["Environment", "Owner", "Project"]
    missing_tags := [tag | tag := required_tags[_]; not resource.change.after.tags[tag]]
    
    count(missing_tags) > 0
    
    msg := sprintf("EC2 instance %s is missing required tags: %v", [
        resource.address,
        missing_tags
    ])
}
```

This advanced guide covers sophisticated Terraform patterns and enterprise-level implementations for complex infrastructure management.