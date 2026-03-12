# ECS Security and Networking Guide

## Table of Contents
1. [Security Architecture](#security-architecture)
2. [IAM Roles and Policies](#iam-roles-and-policies)
3. [Network Security](#network-security)
4. [Container Security](#container-security)
5. [Secrets Management](#secrets-management)
6. [Image Security](#image-security)
7. [Compliance and Auditing](#compliance-and-auditing)
8. [Network Configuration](#network-configuration)
9. [Service Mesh Integration](#service-mesh-integration)
10. [Security Monitoring](#security-monitoring)

## Security Architecture

### ECS Security Model
```
┌─────────────────────────────────────────────────────────────┐
│                    AWS Account Boundary                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                 ECS Control Plane                   │   │
│  │              (AWS Managed)                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│                    ┌─────────────┐                         │
│                    │   AWS IAM   │                         │
│                    │ Integration │                         │
│                    └─────────────┘                         │
│                           │                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    VPC Network                      │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │   Private   │  │   Private   │  │   Private   │ │   │
│  │  │   Subnet    │  │   Subnet    │  │   Subnet    │ │   │
│  │  │             │  │             │  │             │ │   │
│  │  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │ │   │
│  │  │ │   ECS   │ │  │ │   ECS   │ │  │ │   ECS   │ │ │   │
│  │  │ │  Tasks  │ │  │ │  Tasks  │ │  │ │  Tasks  │ │ │   │
│  │  │ │   +SG   │ │  │ │   +SG   │ │  │ │   +SG   │ │ │   │
│  │  │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Security Services                      │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────────┐ │   │
│  │  │   WAF   │ │ Secrets │ │   KMS   │ │ CloudTrail  │ │   │
│  │  │         │ │ Manager │ │         │ │             │ │   │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Security Layers
1. **Account Level**: AWS Organizations, SCPs, IAM
2. **Network Level**: VPC, Security Groups, NACLs
3. **Container Level**: Task roles, resource limits
4. **Application Level**: Secrets, encryption, authentication
5. **Monitoring Level**: CloudTrail, GuardDuty, Security Hub

## IAM Roles and Policies

### Task Execution Role
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

```hcl
# iam-execution-role.tf
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Attach AWS managed policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom policy for additional permissions
resource "aws_iam_role_policy" "ecs_task_execution_custom_policy" {
  name = "${var.project_name}-execution-custom-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParametersByPath",
          "kms:Decrypt"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.environment}/*",
          "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/*",
          "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:key/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/*"
      }
    ]
  })
}
```

### Task Role (Application Permissions)
```hcl
# iam-task-role.tf
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Application-specific permissions
resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "${var.project_name}-task-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.app_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          "${aws_dynamodb_table.app_table.arn}",
          "${aws_dynamodb_table.app_table.arn}/index/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [
          "${aws_sqs_queue.app_queue.arn}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = [
          "${aws_sns_topic.app_notifications.arn}"
        ]
      }
    ]
  })
}

# Enable ECS Exec for debugging
resource "aws_iam_role_policy" "ecs_exec_policy" {
  name = "${var.project_name}-ecs-exec-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}
```

### Service-Linked Roles
```hcl
# service-linked-roles.tf
# ECS Service-Linked Role (automatically created)
data "aws_iam_role" "ecs_service_role" {
  name = "AWSServiceRoleForECS"
}

# Auto Scaling Service-Linked Role
resource "aws_iam_service_linked_role" "ecs_autoscaling" {
  aws_service_name = "ecs.application-autoscaling.amazonaws.com"
  description      = "Service-linked role for ECS Application Auto Scaling"
}

# Load Balancer Controller Role (if using ALB)
resource "aws_iam_role" "alb_controller_role" {
  name = "${var.project_name}-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_controller_policy" {
  role       = aws_iam_role.alb_controller_role.name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}
```

## Network Security

### VPC Configuration
```hcl
# vpc-security.tf
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# Private subnets for ECS tasks
resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "${var.project_name}-private-${count.index + 1}"
    Environment = var.environment
    Type        = "private"
  }
}

# Public subnets for load balancers
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index + 10)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-${count.index + 1}"
    Environment = var.environment
    Type        = "public"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# NAT Gateways
resource "aws_eip" "nat" {
  count  = length(aws_subnet.public)
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-nat-eip-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "main" {
  count         = length(aws_subnet.public)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name        = "${var.project_name}-nat-${count.index + 1}"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.main]
}
```

### Security Groups
```hcl
# security-groups.tf
# ALB Security Group
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-alb-"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-alb-sg"
    Environment = var.environment
  }
}

# ECS Tasks Security Group
resource "aws_security_group" "ecs_tasks" {
  name_prefix = "${var.project_name}-ecs-tasks-"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Custom port from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Allow inter-service communication
  ingress {
    description = "Inter-service communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-ecs-tasks-sg"
    Environment = var.environment
  }
}

# Database Security Group
resource "aws_security_group" "database" {
  name_prefix = "${var.project_name}-db-"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  ingress {
    description     = "MySQL from ECS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-db-sg"
    Environment = var.environment
  }
}

# Redis/ElastiCache Security Group
resource "aws_security_group" "redis" {
  name_prefix = "${var.project_name}-redis-"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Redis from ECS"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  tags = {
    Name        = "${var.project_name}-redis-sg"
    Environment = var.environment
  }
}
```

### Network ACLs
```hcl
# network-acls.tf
resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id

  # Allow inbound traffic from VPC
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  # Allow inbound HTTPS from internet (for outbound responses)
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Allow inbound HTTP from internet (for outbound responses)
  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # Allow ephemeral ports for return traffic
  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Allow all outbound traffic
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name        = "${var.project_name}-private-nacl"
    Environment = var.environment
  }
}

resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.public[*].id

  # Allow all inbound traffic (will be filtered by security groups)
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  # Allow all outbound traffic
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name        = "${var.project_name}-public-nacl"
    Environment = var.environment
  }
}
```

## Container Security

### Secure Task Definition
```json
{
  "family": "secure-web-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::123456789012:role/secureTaskRole",
  "containerDefinitions": [
    {
      "name": "web-container",
      "image": "123456789012.dkr.ecr.us-west-2.amazonaws.com/secure-web-app:latest",
      "cpu": 512,
      "memory": 1024,
      "essential": true,
      "readonlyRootFilesystem": true,
      "user": "1000:1000",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "mountPoints": [
        {
          "sourceVolume": "tmp-volume",
          "containerPath": "/tmp",
          "readOnly": false
        },
        {
          "sourceVolume": "app-cache",
          "containerPath": "/app/cache",
          "readOnly": false
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        },
        {
          "name": "PORT",
          "value": "3000"
        }
      ],
      "secrets": [
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:secretsmanager:us-west-2:123456789012:secret:prod/database/url"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/secure-web-app",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost:3000/health || exit 1"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      },
      "ulimits": [
        {
          "name": "nofile",
          "softLimit": 1024,
          "hardLimit": 1024
        }
      ],
      "linuxParameters": {
        "capabilities": {
          "drop": ["ALL"]
        },
        "initProcessEnabled": true
      }
    }
  ],
  "volumes": [
    {
      "name": "tmp-volume",
      "host": {}
    },
    {
      "name": "app-cache",
      "host": {}
    }
  ]
}
```

### Container Security Best Practices
```dockerfile
# Secure Dockerfile
FROM node:18-alpine AS base

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Set working directory
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copy application code
COPY --chown=nextjs:nodejs . .

# Remove unnecessary packages
RUN apk del --purge \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

# Set security headers
ENV NODE_OPTIONS="--max-old-space-size=512"

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start application
CMD ["npm", "start"]
```

### Runtime Security Configuration
```hcl
# runtime-security.tf
resource "aws_ecs_task_definition" "secure_task" {
  family                   = "secure-web-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "web-container"
      image = "${aws_ecr_repository.app_repo.repository_url}:latest"
      
      # Security configurations
      readonlyRootFilesystem = true
      user                  = "1000:1000"
      
      # Resource limits
      cpu    = 512
      memory = 1024
      
      # Linux parameters for additional security
      linuxParameters = {
        capabilities = {
          drop = ["ALL"]
        }
        initProcessEnabled = true
      }
      
      # Mount points for writable directories
      mountPoints = [
        {
          sourceVolume  = "tmp-volume"
          containerPath = "/tmp"
          readOnly      = false
        }
      ]
      
      # Port mappings
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      
      # Environment variables (non-sensitive)
      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        }
      ]
      
      # Secrets from AWS Secrets Manager
      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = aws_secretsmanager_secret.db_credentials.arn
        }
      ]
      
      # Logging configuration
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      
      # Health check
      healthCheck = {
        command = [
          "CMD-SHELL",
          "curl -f http://localhost:3000/health || exit 1"
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
      
      essential = true
    }
  ])

  # Volumes for writable directories
  volume {
    name = "tmp-volume"
  }

  tags = {
    Environment = var.environment
    Security    = "hardened"
  }
}
```

## Secrets Management

### AWS Secrets Manager Integration
```hcl
# secrets-manager.tf
resource "aws_secretsmanager_secret" "app_secrets" {
  name        = "${var.environment}/app/secrets"
  description = "Application secrets for ${var.environment}"
  
  kms_key_id = aws_kms_key.secrets_key.arn

  tags = {
    Environment = var.environment
    Application = "web-app"
  }
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    database_url    = "postgresql://user:${random_password.db_password.result}@${aws_db_instance.main.endpoint}:5432/myapp"
    jwt_secret      = random_password.jwt_secret.result
    api_key         = random_password.api_key.result
    encryption_key  = random_password.encryption_key.result
  })
}

# KMS key for encryption
resource "aws_kms_key" "secrets_key" {
  description             = "KMS key for secrets encryption"
  deletion_window_in_days = 7

  tags = {
    Environment = var.environment
    Purpose     = "secrets-encryption"
  }
}

resource "aws_kms_alias" "secrets_key_alias" {
  name          = "alias/${var.project_name}-secrets-${var.environment}"
  target_key_id = aws_kms_key.secrets_key.key_id
}

# Random passwords
resource "random_password" "db_password" {
  length  = 32
  special = true
}

resource "random_password" "jwt_secret" {
  length  = 64
  special = false
}

resource "random_password" "api_key" {
  length  = 32
  special = false
}

resource "random_password" "encryption_key" {
  length  = 32
  special = false
}
```

### Parameter Store Configuration
```hcl
# parameter-store.tf
resource "aws_ssm_parameter" "app_config" {
  for_each = var.app_parameters

  name  = "/ecs/${var.environment}/${each.key}"
  type  = "String"
  value = each.value

  tags = {
    Environment = var.environment
    Application = "web-app"
  }
}

resource "aws_ssm_parameter" "secure_config" {
  for_each = var.secure_parameters

  name   = "/ecs/${var.environment}/secure/${each.key}"
  type   = "SecureString"
  value  = each.value
  key_id = aws_kms_key.secrets_key.arn

  tags = {
    Environment = var.environment
    Application = "web-app"
    Type        = "secure"
  }
}

variable "app_parameters" {
  description = "Non-sensitive application parameters"
  type        = map(string)
  default = {
    "log_level"       = "info"
    "max_connections" = "100"
    "cache_ttl"      = "3600"
    "api_version"    = "v1"
  }
}

variable "secure_parameters" {
  description = "Sensitive application parameters"
  type        = map(string)
  sensitive   = true
  default = {
    "oauth_client_secret" = "secure-oauth-secret"
    "webhook_secret"      = "secure-webhook-secret"
  }
}
```

### Secrets Rotation
```hcl
# secrets-rotation.tf
resource "aws_secretsmanager_secret_rotation" "db_rotation" {
  secret_id           = aws_secretsmanager_secret.db_credentials.id
  rotation_lambda_arn = aws_lambda_function.rotation_lambda.arn

  rotation_rules {
    automatically_after_days = 30
  }

  depends_on = [aws_secretsmanager_secret_version.db_credentials]
}

# Lambda function for rotation
resource "aws_lambda_function" "rotation_lambda" {
  filename         = "rotation_lambda.zip"
  function_name    = "${var.project_name}-secrets-rotation"
  role            = aws_iam_role.rotation_lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.rotation_lambda_zip.output_base64sha256
  runtime         = "python3.9"
  timeout         = 30

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda_rotation.id]
  }

  environment {
    variables = {
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${var.aws_region}.amazonaws.com"
    }
  }
}
```

## Image Security

### ECR Security Configuration
```hcl
# ecr-security.tf
resource "aws_ecr_repository" "app_repo" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key        = aws_kms_key.ecr_key.arn
  }

  tags = {
    Environment = var.environment
    Security    = "enabled"
  }
}

# KMS key for ECR encryption
resource "aws_kms_key" "ecr_key" {
  description             = "KMS key for ECR encryption"
  deletion_window_in_days = 7

  tags = {
    Environment = var.environment
    Purpose     = "ecr-encryption"
  }
}

# Repository policy for access control
resource "aws_ecr_repository_policy" "app_repo_policy" {
  repository = aws_ecr_repository.app_repo.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPull"
        Effect = "Allow"
        Principal = {
          AWS = [
            aws_iam_role.ecs_task_execution_role.arn,
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      },
      {
        Sid    = "AllowPush"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}

# Lifecycle policy to manage image retention
resource "aws_ecr_lifecycle_policy" "app_repo_lifecycle" {
  repository = aws_ecr_repository.app_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 production images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["prod", "production"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last 5 staging images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["staging", "stage"]
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 3
        description  = "Delete untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
```

### Image Vulnerability Scanning
```bash
#!/bin/bash
# image-security-scan.sh

set -e

REPOSITORY_NAME="${1}"
IMAGE_TAG="${2}"
REGION="${3:-us-west-2}"
SEVERITY_THRESHOLD="${4:-HIGH}"

if [ -z "$REPOSITORY_NAME" ] || [ -z "$IMAGE_TAG" ]; then
    echo "Usage: $0 <repository-name> <image-tag> [region] [severity-threshold]"
    exit 1
fi

echo "Scanning image: $REPOSITORY_NAME:$IMAGE_TAG"

# Start image scan
aws ecr start-image-scan \
    --repository-name "$REPOSITORY_NAME" \
    --image-id imageTag="$IMAGE_TAG" \
    --region "$REGION"

# Wait for scan to complete
echo "Waiting for scan to complete..."
while true; do
    SCAN_STATUS=$(aws ecr describe-image-scan-findings \
        --repository-name "$REPOSITORY_NAME" \
        --image-id imageTag="$IMAGE_TAG" \
        --region "$REGION" \
        --query 'imageScanStatus.status' \
        --output text 2>/dev/null || echo "IN_PROGRESS")
    
    if [ "$SCAN_STATUS" = "COMPLETE" ]; then
        break
    elif [ "$SCAN_STATUS" = "FAILED" ]; then
        echo "Scan failed"
        exit 1
    fi
    
    sleep 10
done

# Get scan results
SCAN_RESULTS=$(aws ecr describe-image-scan-findings \
    --repository-name "$REPOSITORY_NAME" \
    --image-id imageTag="$IMAGE_TAG" \
    --region "$REGION")

# Extract vulnerability counts
CRITICAL_COUNT=$(echo "$SCAN_RESULTS" | jq -r '.imageScanFindings.findingCounts.CRITICAL // 0')
HIGH_COUNT=$(echo "$SCAN_RESULTS" | jq -r '.imageScanFindings.findingCounts.HIGH // 0')
MEDIUM_COUNT=$(echo "$SCAN_RESULTS" | jq -r '.imageScanFindings.findingCounts.MEDIUM // 0')
LOW_COUNT=$(echo "$SCAN_RESULTS" | jq -r '.imageScanFindings.findingCounts.LOW // 0')

echo "Vulnerability Scan Results:"
echo "  Critical: $CRITICAL_COUNT"
echo "  High: $HIGH_COUNT"
echo "  Medium: $MEDIUM_COUNT"
echo "  Low: $LOW_COUNT"

# Check against threshold
case "$SEVERITY_THRESHOLD" in
    "CRITICAL")
        if [ "$CRITICAL_COUNT" -gt 0 ]; then
            echo "FAIL: Found $CRITICAL_COUNT critical vulnerabilities"
            exit 1
        fi
        ;;
    "HIGH")
        if [ "$CRITICAL_COUNT" -gt 0 ] || [ "$HIGH_COUNT" -gt 0 ]; then
            echo "FAIL: Found critical or high severity vulnerabilities"
            exit 1
        fi
        ;;
    "MEDIUM")
        if [ "$CRITICAL_COUNT" -gt 0 ] || [ "$HIGH_COUNT" -gt 0 ] || [ "$MEDIUM_COUNT" -gt 0 ]; then
            echo "FAIL: Found medium or higher severity vulnerabilities"
            exit 1
        fi
        ;;
esac

echo "PASS: Image meets security requirements"

# Generate detailed report
echo "$SCAN_RESULTS" | jq '.imageScanFindings.findings[] | {name: .name, severity: .severity, description: .description}' > "scan-report-$REPOSITORY_NAME-$IMAGE_TAG.json"
echo "Detailed report saved to: scan-report-$REPOSITORY_NAME-$IMAGE_TAG.json"
```

## Compliance and Auditing

### CloudTrail Configuration
```hcl
# cloudtrail.tf
resource "aws_cloudtrail" "main" {
  name           = "${var.project_name}-cloudtrail"
  s3_bucket_name = aws_s3_bucket.cloudtrail_logs.bucket

  event_selector {
    read_write_type                 = "All"
    include_management_events       = true
    exclude_management_event_sources = []

    data_resource {
      type   = "AWS::ECS::Cluster"
      values = ["${aws_ecs_cluster.main.arn}/*"]
    }

    data_resource {
      type   = "AWS::ECS::Service"
      values = ["arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:service/*"]
    }

    data_resource {
      type   = "AWS::ECS::Task"
      values = ["arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:task/*"]
    }
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail_logs_policy]

  tags = {
    Environment = var.environment
    Purpose     = "audit-logging"
  }
}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "${var.project_name}-cloudtrail-logs-${random_string.bucket_suffix.result}"
  force_destroy = false

  tags = {
    Environment = var.environment
    Purpose     = "audit-logs"
  }
}

resource "aws_s3_bucket_encryption" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.cloudtrail_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### AWS Config Rules
```hcl
# config-rules.tf
resource "aws_config_configuration_recorder" "main" {
  name     = "${var.project_name}-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "main" {
  name           = "${var.project_name}-config-delivery"
  s3_bucket_name = aws_s3_bucket.config_logs.bucket
}

# Config rules for ECS compliance
resource "aws_config_config_rule" "ecs_task_definition_memory_hard_limit" {
  name = "ecs-task-definition-memory-hard-limit"

  source {
    owner             = "AWS"
    source_identifier = "ECS_TASK_DEFINITION_MEMORY_HARD_LIMIT"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "ecs_task_definition_user_for_host_mode_check" {
  name = "ecs-task-definition-user-for-host-mode-check"

  source {
    owner             = "AWS"
    source_identifier = "ECS_TASK_DEFINITION_USER_FOR_HOST_MODE_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "ecs_task_definition_pid_mode_check" {
  name = "ecs-task-definition-pid-mode-check"

  source {
    owner             = "AWS"
    source_identifier = "ECS_TASK_DEFINITION_PID_MODE_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.main]
}
```

### Security Hub Integration
```hcl
# security-hub.tf
resource "aws_securityhub_account" "main" {
  enable_default_standards = true
}

# Enable AWS Foundational Security Standard
resource "aws_securityhub_standards_subscription" "aws_foundational" {
  standards_arn = "arn:aws:securityhub:::ruleset/finding-format/aws-foundational-security-standard/v/1.0.0"
  depends_on    = [aws_securityhub_account.main]
}

# Enable CIS AWS Foundations Benchmark
resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:::ruleset/finding-format/cis-aws-foundations-benchmark/v/1.2.0"
  depends_on    = [aws_securityhub_account.main]
}

# Custom insight for ECS security findings
resource "aws_securityhub_insight" "ecs_security" {
  filters {
    product_name {
      comparison = "EQUALS"
      value      = "Security Hub"
    }
    
    resource_type {
      comparison = "EQUALS"
      value      = "AwsEcsTaskDefinition"
    }
    
    compliance_status {
      comparison = "EQUALS"
      value      = "FAILED"
    }
  }

  group_by_attribute = "ResourceId"
  name              = "ECS Security Findings"
}
```

## Network Configuration

### Service Discovery
```hcl
# service-discovery.tf
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${var.environment}.local"
  description = "Private DNS namespace for ${var.environment}"
  vpc         = aws_vpc.main.id

  tags = {
    Environment = var.environment
  }
}

resource "aws_service_discovery_service" "web_service" {
  name = "web-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 60
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_grace_period_seconds = 30

  tags = {
    Environment = var.environment
    Service     = "web-service"
  }
}
```

### VPC Endpoints
```hcl
# vpc-endpoints.tf
# ECR VPC Endpoints
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-ecr-dkr-endpoint"
    Environment = var.environment
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-ecr-api-endpoint"
    Environment = var.environment
  }
}

# S3 VPC Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id

  tags = {
    Name        = "${var.project_name}-s3-endpoint"
    Environment = var.environment
  }
}

# CloudWatch Logs VPC Endpoint
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-logs-endpoint"
    Environment = var.environment
  }
}

# Security group for VPC endpoints
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.project_name}-vpc-endpoints-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  tags = {
    Name        = "${var.project_name}-vpc-endpoints-sg"
    Environment = var.environment
  }
}
```

## Service Mesh Integration

### AWS App Mesh Configuration
```hcl
# app-mesh.tf
resource "aws_appmesh_mesh" "main" {
  name = "${var.project_name}-mesh"

  spec {
    egress_filter {
      type = "ALLOW_ALL"
    }
  }

  tags = {
    Environment = var.environment
  }
}

# Virtual gateway for ingress
resource "aws_appmesh_virtual_gateway" "main" {
  name      = "main-gateway"
  mesh_name = aws_appmesh_mesh.main.name

  spec {
    listener {
      port_mapping {
        port     = 80
        protocol = "http"
      }
    }
  }

  tags = {
    Environment = var.environment
  }
}

# Virtual service
resource "aws_appmesh_virtual_service" "web_service" {
  name      = "web-service.${var.environment}.local"
  mesh_name = aws_appmesh_mesh.main.name

  spec {
    provider {
      virtual_router {
        virtual_router_name = aws_appmesh_virtual_router.web_service.name
      }
    }
  }

  tags = {
    Environment = var.environment
  }
}

# Virtual router
resource "aws_appmesh_virtual_router" "web_service" {
  name      = "web-service-router"
  mesh_name = aws_appmesh_mesh.main.name

  spec {
    listener {
      port_mapping {
        port     = 3000
        protocol = "http"
      }
    }
  }

  tags = {
    Environment = var.environment
  }
}

# Virtual node
resource "aws_appmesh_virtual_node" "web_service" {
  name      = "web-service-node"
  mesh_name = aws_appmesh_mesh.main.name

  spec {
    listener {
      port_mapping {
        port     = 3000
        protocol = "http"
      }

      health_check {
        healthy_threshold   = 2
        interval_millis     = 5000
        path                = "/health"
        port                = 3000
        protocol            = "http"
        timeout_millis      = 2000
        unhealthy_threshold = 3
      }
    }

    service_discovery {
      aws_cloud_map {
        namespace_name = aws_service_discovery_private_dns_namespace.main.name
        service_name   = aws_service_discovery_service.web_service.name
      }
    }
  }

  tags = {
    Environment = var.environment
  }
}
```

## Security Monitoring

### GuardDuty Integration
```hcl
# guardduty.tf
resource "aws_guardduty_detector" "main" {
  enable = true

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }

  tags = {
    Environment = var.environment
  }
}

# GuardDuty findings filter
resource "aws_guardduty_filter" "ecs_findings" {
  name        = "ecs-security-findings"
  action      = "ARCHIVE"
  detector_id = aws_guardduty_detector.main.id
  rank        = 1

  finding_criteria {
    criterion {
      field  = "service.resourceRole"
      equals = ["TARGET"]
    }

    criterion {
      field  = "resource.resourceType"
      equals = ["ECSCluster"]
    }

    criterion {
      field                 = "severity"
      greater_than_or_equal = "4.0"
    }
  }
}
```

### CloudWatch Security Monitoring
```hcl
# security-monitoring.tf
resource "aws_cloudwatch_log_metric_filter" "failed_logins" {
  name           = "failed-login-attempts"
  log_group_name = aws_cloudwatch_log_group.app_logs.name
  pattern        = "[timestamp, request_id, level=\"ERROR\", message=\"Authentication failed\"]"

  metric_transformation {
    name      = "FailedLoginAttempts"
    namespace = "Security/Authentication"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "failed_login_alarm" {
  alarm_name          = "high-failed-login-attempts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FailedLoginAttempts"
  namespace           = "Security/Authentication"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors failed login attempts"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]

  tags = {
    Environment = var.environment
    Type        = "security"
  }
}

# SNS topic for security alerts
resource "aws_sns_topic" "security_alerts" {
  name = "${var.project_name}-security-alerts"

  tags = {
    Environment = var.environment
    Purpose     = "security-notifications"
  }
}
```

### Security Automation
```bash
#!/bin/bash
# security-audit.sh

set -e

CLUSTER_NAME="${1:-production-cluster}"
REGION="${2:-us-west-2}"

echo "=== ECS Security Audit ==="
echo "Cluster: $CLUSTER_NAME"
echo "Region: $REGION"
echo

# 1. Check task definitions for security best practices
echo "1. Checking task definitions for security issues..."

TASK_DEFINITIONS=$(aws ecs list-task-definitions --status ACTIVE --region $REGION --query 'taskDefinitionArns[]' --output text)

for task_def in $TASK_DEFINITIONS; do
    echo "Checking: $task_def"
    
    # Check for privileged containers
    PRIVILEGED=$(aws ecs describe-task-definition --task-definition $task_def --region $REGION --query 'taskDefinition.containerDefinitions[?privileged==`true`].name' --output text)
    if [ ! -z "$PRIVILEGED" ]; then
        echo "  WARNING: Privileged containers found: $PRIVILEGED"
    fi
    
    # Check for root user
    ROOT_USER=$(aws ecs describe-task-definition --task-definition $task_def --region $REGION --query 'taskDefinition.containerDefinitions[?user==`0` || user==`root`].name' --output text)
    if [ ! -z "$ROOT_USER" ]; then
        echo "  WARNING: Containers running as root: $ROOT_USER"
    fi
    
    # Check for read-only root filesystem
    RW_ROOT=$(aws ecs describe-task-definition --task-definition $task_def --region $REGION --query 'taskDefinition.containerDefinitions[?readonlyRootFilesystem!=`true`].name' --output text)
    if [ ! -z "$RW_ROOT" ]; then
        echo "  INFO: Containers with writable root filesystem: $RW_ROOT"
    fi
done

# 2. Check for exposed services
echo
echo "2. Checking for exposed services..."

SERVICES=$(aws ecs list-services --cluster $CLUSTER_NAME --region $REGION --query 'serviceArns[]' --output text)

for service in $SERVICES; do
    SERVICE_NAME=$(basename $service)
    
    # Check if service has load balancer
    LB_CONFIG=$(aws ecs describe-services --cluster $CLUSTER_NAME --services $service --region $REGION --query 'services[0].loadBalancers' --output text)
    if [ "$LB_CONFIG" != "None" ] && [ ! -z "$LB_CONFIG" ]; then
        echo "  Service $SERVICE_NAME is exposed via load balancer"
        
        # Get target group ARN
        TG_ARN=$(aws ecs describe-services --cluster $CLUSTER_NAME --services $service --region $REGION --query 'services[0].loadBalancers[0].targetGroupArn' --output text)
        
        if [ "$TG_ARN" != "None" ]; then
            # Check target group health
            UNHEALTHY_TARGETS=$(aws elbv2 describe-target-health --target-group-arn $TG_ARN --region $REGION --query 'TargetHealthDescriptions[?TargetHealth.State!=`healthy`].Target.Id' --output text)
            if [ ! -z "$UNHEALTHY_TARGETS" ]; then
                echo "    WARNING: Unhealthy targets: $UNHEALTHY_TARGETS"
            fi
        fi
    fi
done

# 3. Check security groups
echo
echo "3. Checking security groups..."

# Get security groups used by ECS tasks
SG_IDS=$(aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICES --region $REGION --query 'services[].networkConfiguration.awsvpcConfiguration.securityGroups[]' --output text | sort -u)

for sg_id in $SG_IDS; do
    echo "Checking security group: $sg_id"
    
    # Check for overly permissive rules
    OPEN_RULES=$(aws ec2 describe-security-groups --group-ids $sg_id --region $REGION --query 'SecurityGroups[0].IpPermissions[?IpRanges[?CidrIp==`0.0.0.0/0`]]' --output text)
    if [ ! -z "$OPEN_RULES" ]; then
        echo "  WARNING: Security group has rules open to 0.0.0.0/0"
    fi
done

# 4. Check for secrets in environment variables
echo
echo "4. Checking for potential secrets in environment variables..."

for task_def in $TASK_DEFINITIONS; do
    ENV_VARS=$(aws ecs describe-task-definition --task-definition $task_def --region $REGION --query 'taskDefinition.containerDefinitions[].environment[?contains(name, `PASSWORD`) || contains(name, `SECRET`) || contains(name, `KEY`)].name' --output text)
    if [ ! -z "$ENV_VARS" ]; then
        echo "  WARNING: Potential secrets in environment variables for $task_def: $ENV_VARS"
    fi
done

echo
echo "=== Security Audit Complete ==="
```

This comprehensive security and networking guide provides the foundation for securing ECS deployments with defense-in-depth strategies, proper IAM configurations, network isolation, and continuous monitoring.