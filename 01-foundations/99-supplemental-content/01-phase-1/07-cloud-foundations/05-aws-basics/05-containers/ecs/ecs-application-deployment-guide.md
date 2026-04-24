# ECS Application Deployment Guide

## Table of Contents
1. [Deployment Strategies](#deployment-strategies)
2. [Container Image Management](#container-image-management)
3. [Task Definition Patterns](#task-definition-patterns)
4. [Service Deployment](#service-deployment)
5. [Configuration Management](#configuration-management)
6. [Database Integration](#database-integration)
7. [Microservices Architecture](#microservices-architecture)
8. [CI/CD Integration](#cicd-integration)
9. [Monitoring and Health Checks](#monitoring-and-health-checks)
10. [Troubleshooting Deployments](#troubleshooting-deployments)

## Deployment Strategies

### Rolling Deployment
```json
{
  "deploymentConfiguration": {
    "maximumPercent": 200,
    "minimumHealthyPercent": 50,
    "deploymentCircuitBreaker": {
      "enable": true,
      "rollback": true
    }
  },
  "characteristics": {
    "downtime": "Zero downtime",
    "rollback": "Automatic on failure",
    "complexity": "Low",
    "riskLevel": "Low"
  }
}
```

### Blue-Green Deployment with CodeDeploy
```json
{
  "deploymentController": {
    "type": "CODE_DEPLOY"
  },
  "loadBalancers": [
    {
      "targetGroupArn": "arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/blue-tg/1234567890123456",
      "containerName": "web-container",
      "containerPort": 80
    }
  ],
  "codeDeployConfiguration": {
    "applicationName": "ecs-blue-green-app",
    "deploymentGroupName": "ecs-blue-green-dg",
    "deploymentConfigName": "CodeDeployDefault.ECSAllAtOnceBlueGreen",
    "terminationWaitTimeInMinutes": 5,
    "deploymentReadyOption": {
      "actionOnTimeout": "CONTINUE_DEPLOYMENT"
    },
    "blueGreenDeploymentConfiguration": {
      "terminateBlueInstancesOnDeploymentSuccess": {
        "action": "TERMINATE",
        "terminationWaitTimeInMinutes": 5
      },
      "deploymentReadyOption": {
        "actionOnTimeout": "CONTINUE_DEPLOYMENT"
      }
    }
  }
}
```

### Canary Deployment
```hcl
# canary-deployment.tf
resource "aws_ecs_service" "canary_service" {
  name            = "canary-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.canary_task.arn
  desired_count   = 1  # Start with 1 task for canary
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.canary_tg.arn
    container_name   = "web-container"
    container_port   = 80
  }

  tags = {
    Environment = var.environment
    Deployment  = "canary"
  }
}

# Weighted routing for canary
resource "aws_lb_listener_rule" "canary_rule" {
  listener_arn = aws_lb_listener.web_listener.arn
  priority     = 100

  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.production_tg.arn
        weight = 90
      }
      target_group {
        arn    = aws_lb_target_group.canary_tg.arn
        weight = 10
      }
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
```

## Container Image Management

### ECR Repository Setup
```hcl
# ecr-repository.tf
resource "aws_ecr_repository" "app_repo" {
  name                 = "web-application"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ecr_lifecycle_policy" "app_repo_policy" {
  repository = aws_ecr_repository.app_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 production images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["prod"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last 10 development images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["dev"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
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

### Multi-Stage Dockerfile
```dockerfile
# Dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Development dependencies for building
FROM node:18-alpine AS dev-deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

# Build application
FROM dev-deps AS build
WORKDIR /app
COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine AS production
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Copy built application
COPY --from=builder /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/package*.json ./

# Set ownership
RUN chown -R nextjs:nodejs /app
USER nextjs

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

EXPOSE 3000
CMD ["npm", "start"]
```

### Image Build and Push Script
```bash
#!/bin/bash
# build-and-push.sh

set -e

# Configuration
AWS_REGION="us-west-2"
AWS_ACCOUNT_ID="123456789012"
REPOSITORY_NAME="web-application"
IMAGE_TAG="${1:-latest}"
DOCKERFILE_PATH="${2:-.}"

# ECR repository URI
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY_NAME}"

echo "Building and pushing Docker image..."
echo "Repository: ${ECR_URI}"
echo "Tag: ${IMAGE_TAG}"

# Login to ECR
echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URI}

# Build image
echo "Building Docker image..."
docker build -t ${REPOSITORY_NAME}:${IMAGE_TAG} ${DOCKERFILE_PATH}

# Tag image for ECR
docker tag ${REPOSITORY_NAME}:${IMAGE_TAG} ${ECR_URI}:${IMAGE_TAG}

# Push image
echo "Pushing image to ECR..."
docker push ${ECR_URI}:${IMAGE_TAG}

# Scan image for vulnerabilities
echo "Starting vulnerability scan..."
aws ecr start-image-scan --repository-name ${REPOSITORY_NAME} --image-id imageTag=${IMAGE_TAG} --region ${AWS_REGION}

# Wait for scan to complete and get results
echo "Waiting for scan to complete..."
sleep 30

SCAN_RESULTS=$(aws ecr describe-image-scan-findings \
    --repository-name ${REPOSITORY_NAME} \
    --image-id imageTag=${IMAGE_TAG} \
    --region ${AWS_REGION} \
    --query 'imageScanFindings.findingCounts' \
    --output json)

echo "Vulnerability scan results: ${SCAN_RESULTS}"

# Check for critical vulnerabilities
CRITICAL_COUNT=$(echo ${SCAN_RESULTS} | jq -r '.CRITICAL // 0')
if [ "${CRITICAL_COUNT}" -gt 0 ]; then
    echo "ERROR: Found ${CRITICAL_COUNT} critical vulnerabilities"
    exit 1
fi

echo "Image successfully built and pushed: ${ECR_URI}:${IMAGE_TAG}"
```

## Task Definition Patterns

### Web Application Task Definition
```json
{
  "family": "web-application",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::123456789012:role/webAppTaskRole",
  "containerDefinitions": [
    {
      "name": "web-container",
      "image": "123456789012.dkr.ecr.us-west-2.amazonaws.com/web-application:latest",
      "cpu": 512,
      "memory": 1024,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
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
        },
        {
          "name": "LOG_LEVEL",
          "value": "info"
        }
      ],
      "secrets": [
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:secretsmanager:us-west-2:123456789012:secret:prod/database/url"
        },
        {
          "name": "JWT_SECRET",
          "valueFrom": "arn:aws:ssm:us-west-2:123456789012:parameter/prod/jwt/secret"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/web-application",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs",
          "awslogs-create-group": "true"
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
          "softLimit": 65536,
          "hardLimit": 65536
        }
      ]
    }
  ]
}
```

### Background Worker Task Definition
```json
{
  "family": "background-worker",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::123456789012:role/workerTaskRole",
  "containerDefinitions": [
    {
      "name": "worker-container",
      "image": "123456789012.dkr.ecr.us-west-2.amazonaws.com/background-worker:latest",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "environment": [
        {
          "name": "WORKER_TYPE",
          "value": "email-processor"
        },
        {
          "name": "QUEUE_URL",
          "value": "https://sqs.us-west-2.amazonaws.com/123456789012/email-queue"
        }
      ],
      "secrets": [
        {
          "name": "REDIS_URL",
          "valueFrom": "arn:aws:secretsmanager:us-west-2:123456789012:secret:prod/redis/url"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/background-worker",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "worker"
        }
      },
      "stopTimeout": 120
    }
  ]
}
```

### Sidecar Pattern Task Definition
```json
{
  "family": "app-with-sidecar",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::123456789012:role/appTaskRole",
  "volumes": [
    {
      "name": "shared-logs",
      "host": {}
    }
  ],
  "containerDefinitions": [
    {
      "name": "main-app",
      "image": "123456789012.dkr.ecr.us-west-2.amazonaws.com/main-app:latest",
      "cpu": 384,
      "memory": 768,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "mountPoints": [
        {
          "sourceVolume": "shared-logs",
          "containerPath": "/var/log/app",
          "readOnly": false
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/app-with-sidecar",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "main-app"
        }
      }
    },
    {
      "name": "log-shipper",
      "image": "fluent/fluent-bit:latest",
      "cpu": 128,
      "memory": 256,
      "essential": false,
      "mountPoints": [
        {
          "sourceVolume": "shared-logs",
          "containerPath": "/var/log/app",
          "readOnly": true
        }
      ],
      "environment": [
        {
          "name": "FLB_LOG_LEVEL",
          "value": "info"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/app-with-sidecar",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "log-shipper"
        }
      }
    }
  ]
}
```

## Service Deployment

### Production Service Configuration
```hcl
# production-service.tf
resource "aws_ecs_service" "production_service" {
  name            = "production-web-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.web_app.arn
  desired_count   = 3
  launch_type     = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.production_tg.arn
    container_name   = "web-container"
    container_port   = 3000
  }

  # Service discovery
  service_registries {
    registry_arn   = aws_service_discovery_service.web_service.arn
    container_name = "web-container"
  }

  # Deployment configuration
  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 50
    
    deployment_circuit_breaker {
      enable   = true
      rollback = true
    }
  }

  # Health check grace period
  health_check_grace_period_seconds = 300

  # Placement constraints
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone != us-west-2a"
  }

  # Placement strategy
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  # Enable execute command for debugging
  enable_execute_command = true

  depends_on = [
    aws_lb_listener.production_listener,
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy
  ]

  tags = {
    Environment = "production"
    Service     = "web-application"
  }
}
```

### Batch Processing Service
```hcl
# batch-service.tf
resource "aws_ecs_service" "batch_processor" {
  name            = "batch-processor"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.batch_task.arn
  desired_count   = 0  # Scaled by CloudWatch Events
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.batch_tasks.id]
    assign_public_ip = false
  }

  # No load balancer for batch processing
  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 0  # Allow all tasks to be replaced
  }

  tags = {
    Environment = var.environment
    Service     = "batch-processor"
  }
}

# CloudWatch Event Rule for scheduled batch processing
resource "aws_cloudwatch_event_rule" "batch_schedule" {
  name                = "batch-processing-schedule"
  description         = "Trigger batch processing every hour"
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "batch_target" {
  rule      = aws_cloudwatch_event_rule.batch_schedule.name
  target_id = "BatchProcessingTarget"
  arn       = aws_ecs_cluster.main.arn
  role_arn  = aws_iam_role.events_task_execution_role.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.batch_task.arn
    launch_type         = "FARGATE"
    platform_version    = "1.4.0"

    network_configuration {
      subnets          = var.private_subnet_ids
      security_groups  = [aws_security_group.batch_tasks.id]
      assign_public_ip = false
    }
  }
}
```

## Configuration Management

### Environment-Specific Configuration
```hcl
# configuration.tf
# Parameter Store for configuration
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

# Secrets Manager for sensitive data
resource "aws_secretsmanager_secret" "app_secrets" {
  name        = "${var.environment}/app/secrets"
  description = "Application secrets for ${var.environment}"

  tags = {
    Environment = var.environment
    Application = "web-app"
  }
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    database_password = var.database_password
    jwt_secret       = var.jwt_secret
    api_key          = var.api_key
  })
}

# Variables for different environments
variable "app_parameters" {
  description = "Application parameters"
  type        = map(string)
  default = {
    "log_level"        = "info"
    "max_connections"  = "100"
    "cache_ttl"       = "3600"
    "feature_flags"   = "feature1:true,feature2:false"
  }
}
```

### Configuration Injection Pattern
```json
{
  "containerDefinitions": [
    {
      "name": "config-injector",
      "image": "amazon/aws-cli:latest",
      "essential": false,
      "command": [
        "sh",
        "-c",
        "aws ssm get-parameters-by-path --path /ecs/production --recursive --with-decryption --query 'Parameters[*].[Name,Value]' --output text > /shared/config.env"
      ],
      "mountPoints": [
        {
          "sourceVolume": "shared-config",
          "containerPath": "/shared",
          "readOnly": false
        }
      ]
    },
    {
      "name": "main-app",
      "image": "myapp:latest",
      "essential": true,
      "dependsOn": [
        {
          "containerName": "config-injector",
          "condition": "SUCCESS"
        }
      ],
      "mountPoints": [
        {
          "sourceVolume": "shared-config",
          "containerPath": "/config",
          "readOnly": true
        }
      ],
      "command": [
        "sh",
        "-c",
        "source /config/config.env && exec npm start"
      ]
    }
  ],
  "volumes": [
    {
      "name": "shared-config",
      "host": {}
    }
  ]
}
```

## Database Integration

### RDS Integration
```hcl
# database.tf
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name} DB subnet group"
    Environment = var.environment
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-rds-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
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
    Name        = "${var.project_name}-rds-sg"
    Environment = var.environment
  }
}

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}"

  engine         = "postgres"
  engine_version = "14.9"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true

  db_name  = var.database_name
  username = var.database_username
  password = var.database_password

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  skip_final_snapshot = var.environment != "production"
  deletion_protection = var.environment == "production"

  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}

# Store database connection details in Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.environment}/database/credentials"
  description = "Database credentials for ${var.environment}"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    host     = aws_db_instance.main.endpoint
    port     = aws_db_instance.main.port
    dbname   = aws_db_instance.main.db_name
    username = aws_db_instance.main.username
    password = var.database_password
    url      = "postgresql://${aws_db_instance.main.username}:${var.database_password}@${aws_db_instance.main.endpoint}:${aws_db_instance.main.port}/${aws_db_instance.main.db_name}"
  })
}
```

### Database Migration Task
```json
{
  "family": "database-migration",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::123456789012:role/migrationTaskRole",
  "containerDefinitions": [
    {
      "name": "migration-container",
      "image": "migrate/migrate:latest",
      "essential": true,
      "command": [
        "-path",
        "/migrations",
        "-database",
        "$(DATABASE_URL)",
        "up"
      ],
      "secrets": [
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:secretsmanager:us-west-2:123456789012:secret:prod/database/credentials:url::"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/database-migration",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "migration"
        }
      }
    }
  ]
}
```

## Microservices Architecture

### Service Discovery Setup
```hcl
# service-discovery.tf
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${var.environment}.local"
  description = "Private DNS namespace for ${var.environment}"
  vpc         = var.vpc_id

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

resource "aws_service_discovery_service" "api_service" {
  name = "api-service"

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
    Service     = "api-service"
  }
}
```

### API Gateway Service
```json
{
  "family": "api-gateway-service",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::123456789012:role/apiGatewayTaskRole",
  "containerDefinitions": [
    {
      "name": "api-gateway",
      "image": "nginx:alpine",
      "cpu": 512,
      "memory": 1024,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "mountPoints": [
        {
          "sourceVolume": "nginx-config",
          "containerPath": "/etc/nginx/conf.d",
          "readOnly": true
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/api-gateway-service",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "nginx"
        }
      }
    }
  ],
  "volumes": [
    {
      "name": "nginx-config",
      "efsVolumeConfiguration": {
        "fileSystemId": "fs-12345678",
        "rootDirectory": "/nginx-config"
      }
    }
  ]
}
```

### Inter-Service Communication
```nginx
# nginx.conf for API Gateway
upstream user-service {
    server user-service.production.local:3000;
}

upstream order-service {
    server order-service.production.local:3000;
}

upstream payment-service {
    server payment-service.production.local:3000;
}

server {
    listen 80;
    server_name api.example.com;

    # User service routes
    location /api/users {
        proxy_pass http://user-service;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Order service routes
    location /api/orders {
        proxy_pass http://order-service;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Payment service routes
    location /api/payments {
        proxy_pass http://payment-service;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

## CI/CD Integration

### GitHub Actions Workflow
```yaml
# .github/workflows/deploy.yml
name: Deploy to ECS

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  AWS_REGION: us-west-2
  ECR_REPOSITORY: web-application
  ECS_SERVICE: production-web-service
  ECS_CLUSTER: production-cluster
  ECS_TASK_DEFINITION: .aws/task-definition.json

jobs:
  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    environment: production

    steps:
    - name: Checkout
      uses: actions/checkout@v3

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1

    - name: Build, tag, and push image to Amazon ECR
      id: build-image
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        IMAGE_TAG: ${{ github.sha }}
      run: |
        # Build a docker container and push it to ECR
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
        echo "image=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" >> $GITHUB_OUTPUT

    - name: Fill in the new image ID in the Amazon ECS task definition
      id: task-def
      uses: aws-actions/amazon-ecs-render-task-definition@v1
      with:
        task-definition: ${{ env.ECS_TASK_DEFINITION }}
        container-name: web-container
        image: ${{ steps.build-image.outputs.image }}

    - name: Deploy Amazon ECS task definition
      uses: aws-actions/amazon-ecs-deploy-task-definition@v1
      with:
        task-definition: ${{ steps.task-def.outputs.task-definition }}
        service: ${{ env.ECS_SERVICE }}
        cluster: ${{ env.ECS_CLUSTER }}
        wait-for-service-stability: true

    - name: Run database migrations
      if: github.ref == 'refs/heads/main'
      run: |
        aws ecs run-task \
          --cluster ${{ env.ECS_CLUSTER }} \
          --task-definition database-migration \
          --launch-type FARGATE \
          --network-configuration "awsvpcConfiguration={subnets=[subnet-12345678,subnet-87654321],securityGroups=[sg-12345678],assignPublicIp=DISABLED}"
```

### GitLab CI/CD Pipeline
```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - deploy
  - post-deploy

variables:
  AWS_DEFAULT_REGION: us-west-2
  ECR_REPOSITORY: web-application
  ECS_CLUSTER: production-cluster
  ECS_SERVICE: production-web-service

build:
  stage: build
  image: docker:20.10.16
  services:
    - docker:20.10.16-dind
  before_script:
    - apk add --no-cache curl jq python3 py3-pip
    - pip install awscli
    - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $CI_REGISTRY
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  only:
    - main
    - develop

test:
  stage: test
  image: node:18-alpine
  script:
    - npm ci
    - npm run test
    - npm run lint
  coverage: '/Lines\s*:\s*(\d+\.\d+)%/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

deploy:
  stage: deploy
  image: amazon/aws-cli:latest
  before_script:
    - yum install -y jq
  script:
    # Update task definition with new image
    - |
      TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition $ECS_SERVICE --query taskDefinition)
      NEW_TASK_DEFINITION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA" '.containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.placementConstraints) | del(.compatibilities) | del(.registeredAt) | del(.registeredBy)')
      echo $NEW_TASK_DEFINITION > task-definition.json
    
    # Register new task definition
    - aws ecs register-task-definition --cli-input-json file://task-definition.json
    
    # Update service
    - |
      aws ecs update-service \
        --cluster $ECS_CLUSTER \
        --service $ECS_SERVICE \
        --task-definition $ECS_SERVICE
    
    # Wait for deployment to complete
    - |
      aws ecs wait services-stable \
        --cluster $ECS_CLUSTER \
        --services $ECS_SERVICE
  only:
    - main

post-deploy:
  stage: post-deploy
  image: amazon/aws-cli:latest
  script:
    # Run health checks
    - |
      LOAD_BALANCER_DNS=$(aws elbv2 describe-load-balancers --names production-alb --query 'LoadBalancers[0].DNSName' --output text)
      for i in {1..10}; do
        if curl -f http://$LOAD_BALANCER_DNS/health; then
          echo "Health check passed"
          break
        else
          echo "Health check failed, attempt $i/10"
          sleep 30
        fi
      done
    
    # Run smoke tests
    - curl -f http://$LOAD_BALANCER_DNS/api/version
  only:
    - main
```

### Deployment Script
```bash
#!/bin/bash
# deploy.sh

set -e

# Configuration
CLUSTER_NAME="production-cluster"
SERVICE_NAME="production-web-service"
TASK_FAMILY="web-application"
REGION="us-west-2"
IMAGE_URI="${1}"

if [ -z "$IMAGE_URI" ]; then
    echo "Usage: $0 <image-uri>"
    exit 1
fi

echo "Deploying $IMAGE_URI to $SERVICE_NAME in $CLUSTER_NAME"

# Get current task definition
TASK_DEFINITION=$(aws ecs describe-task-definition \
    --task-definition $TASK_FAMILY \
    --region $REGION \
    --query taskDefinition)

# Update image in task definition
NEW_TASK_DEFINITION=$(echo $TASK_DEFINITION | jq \
    --arg IMAGE "$IMAGE_URI" \
    '.containerDefinitions[0].image = $IMAGE | 
     del(.taskDefinitionArn) | 
     del(.revision) | 
     del(.status) | 
     del(.requiresAttributes) | 
     del(.placementConstraints) | 
     del(.compatibilities) | 
     del(.registeredAt) | 
     del(.registeredBy)')

# Register new task definition
echo "Registering new task definition..."
NEW_REVISION=$(echo $NEW_TASK_DEFINITION | aws ecs register-task-definition \
    --cli-input-json file:///dev/stdin \
    --region $REGION \
    --query 'taskDefinition.revision')

echo "New task definition revision: $NEW_REVISION"

# Update service
echo "Updating service..."
aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service $SERVICE_NAME \
    --task-definition $TASK_FAMILY:$NEW_REVISION \
    --region $REGION

# Wait for deployment to complete
echo "Waiting for deployment to complete..."
aws ecs wait services-stable \
    --cluster $CLUSTER_NAME \
    --services $SERVICE_NAME \
    --region $REGION

echo "Deployment completed successfully!"

# Verify deployment
RUNNING_TASKS=$(aws ecs list-tasks \
    --cluster $CLUSTER_NAME \
    --service-name $SERVICE_NAME \
    --desired-status RUNNING \
    --region $REGION \
    --query 'taskArns' \
    --output text | wc -w)

echo "Running tasks: $RUNNING_TASKS"

# Health check
echo "Performing health check..."
LOAD_BALANCER_DNS=$(aws elbv2 describe-load-balancers \
    --names production-alb \
    --region $REGION \
    --query 'LoadBalancers[0].DNSName' \
    --output text)

for i in {1..10}; do
    if curl -f -s http://$LOAD_BALANCER_DNS/health > /dev/null; then
        echo "Health check passed!"
        break
    else
        echo "Health check failed, attempt $i/10"
        if [ $i -eq 10 ]; then
            echo "Health check failed after 10 attempts"
            exit 1
        fi
        sleep 30
    fi
done

echo "Deployment verification completed successfully!"
```

## Monitoring and Health Checks

### Application Health Check Endpoint
```javascript
// health.js - Express.js health check endpoint
const express = require('express');
const app = express();

// Health check dependencies
const checkDatabase = async () => {
  try {
    // Check database connection
    await db.query('SELECT 1');
    return { status: 'healthy', latency: Date.now() - start };
  } catch (error) {
    return { status: 'unhealthy', error: error.message };
  }
};

const checkRedis = async () => {
  try {
    // Check Redis connection
    await redis.ping();
    return { status: 'healthy' };
  } catch (error) {
    return { status: 'unhealthy', error: error.message };
  }
};

// Liveness probe - basic health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: process.env.npm_package_version
  });
});

// Readiness probe - comprehensive health check
app.get('/ready', async (req, res) => {
  const checks = {
    database: await checkDatabase(),
    redis: await checkRedis(),
    memory: {
      used: process.memoryUsage().heapUsed,
      total: process.memoryUsage().heapTotal,
      percentage: (process.memoryUsage().heapUsed / process.memoryUsage().heapTotal) * 100
    }
  };

  const isHealthy = Object.values(checks).every(check => 
    check.status === 'healthy' || check.percentage < 90
  );

  res.status(isHealthy ? 200 : 503).json({
    status: isHealthy ? 'ready' : 'not ready',
    checks,
    timestamp: new Date().toISOString()
  });
});

// Startup probe - check if application is ready to receive traffic
app.get('/startup', (req, res) => {
  // Check if application has completed initialization
  if (app.locals.initialized) {
    res.status(200).json({ status: 'started' });
  } else {
    res.status(503).json({ status: 'starting' });
  }
});

module.exports = app;
```

### CloudWatch Alarms
```hcl
# cloudwatch-alarms.tf
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.service_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ecs cpu utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ServiceName = aws_ecs_service.production_service.name
    ClusterName = aws_ecs_cluster.main.name
  }
}

resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "${var.service_name}-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "This metric monitors ecs memory utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ServiceName = aws_ecs_service.production_service.name
    ClusterName = aws_ecs_cluster.main.name
  }
}

resource "aws_cloudwatch_metric_alarm" "service_count" {
  alarm_name          = "${var.service_name}-low-task-count"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "2"
  alarm_description   = "This metric monitors running task count"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ServiceName = aws_ecs_service.production_service.name
    ClusterName = aws_ecs_cluster.main.name
  }
}
```

## Troubleshooting Deployments

### Deployment Troubleshooting Script
```bash
#!/bin/bash
# troubleshoot-deployment.sh

CLUSTER_NAME="${1:-production-cluster}"
SERVICE_NAME="${2:-production-web-service}"
REGION="${3:-us-west-2}"

echo "=== ECS Deployment Troubleshooting ==="
echo "Cluster: $CLUSTER_NAME"
echo "Service: $SERVICE_NAME"
echo "Region: $REGION"
echo

# 1. Check service status
echo "1. Service Status:"
aws ecs describe-services \
    --cluster $CLUSTER_NAME \
    --services $SERVICE_NAME \
    --region $REGION \
    --query 'services[0].{Status:status,RunningCount:runningCount,PendingCount:pendingCount,DesiredCount:desiredCount}'
echo

# 2. Check recent deployments
echo "2. Recent Deployments:"
aws ecs describe-services \
    --cluster $CLUSTER_NAME \
    --services $SERVICE_NAME \
    --region $REGION \
    --query 'services[0].deployments[*].{Status:status,TaskDefinition:taskDefinition,CreatedAt:createdAt,RunningCount:runningCount}'
echo

# 3. Check service events
echo "3. Service Events (last 10):"
aws ecs describe-services \
    --cluster $CLUSTER_NAME \
    --services $SERVICE_NAME \
    --region $REGION \
    --query 'services[0].events[:10].{CreatedAt:createdAt,Message:message}'
echo

# 4. List tasks
echo "4. Current Tasks:"
TASK_ARNS=$(aws ecs list-tasks \
    --cluster $CLUSTER_NAME \
    --service-name $SERVICE_NAME \
    --region $REGION \
    --query 'taskArns[]' \
    --output text)

if [ ! -z "$TASK_ARNS" ]; then
    aws ecs describe-tasks \
        --cluster $CLUSTER_NAME \
        --tasks $TASK_ARNS \
        --region $REGION \
        --query 'tasks[*].{TaskArn:taskArn,LastStatus:lastStatus,HealthStatus:healthStatus,CreatedAt:createdAt}'
else
    echo "No tasks found"
fi
echo

# 5. Check stopped tasks (for failures)
echo "5. Recent Stopped Tasks:"
STOPPED_TASKS=$(aws ecs list-tasks \
    --cluster $CLUSTER_NAME \
    --service-name $SERVICE_NAME \
    --desired-status STOPPED \
    --region $REGION \
    --query 'taskArns[:5]' \
    --output text)

if [ ! -z "$STOPPED_TASKS" ]; then
    aws ecs describe-tasks \
        --cluster $CLUSTER_NAME \
        --tasks $STOPPED_TASKS \
        --region $REGION \
        --query 'tasks[*].{TaskArn:taskArn,LastStatus:lastStatus,StoppedReason:stoppedReason,StoppedAt:stoppedAt}'
else
    echo "No stopped tasks found"
fi
echo

# 6. Check task definition
echo "6. Current Task Definition:"
TASK_DEF_ARN=$(aws ecs describe-services \
    --cluster $CLUSTER_NAME \
    --services $SERVICE_NAME \
    --region $REGION \
    --query 'services[0].taskDefinition' \
    --output text)

aws ecs describe-task-definition \
    --task-definition $TASK_DEF_ARN \
    --region $REGION \
    --query 'taskDefinition.{Family:family,Revision:revision,Status:status,Cpu:cpu,Memory:memory}'
echo

# 7. Check load balancer health
echo "7. Load Balancer Target Health:"
TARGET_GROUP_ARN=$(aws ecs describe-services \
    --cluster $CLUSTER_NAME \
    --services $SERVICE_NAME \
    --region $REGION \
    --query 'services[0].loadBalancers[0].targetGroupArn' \
    --output text)

if [ "$TARGET_GROUP_ARN" != "None" ] && [ ! -z "$TARGET_GROUP_ARN" ]; then
    aws elbv2 describe-target-health \
        --target-group-arn $TARGET_GROUP_ARN \
        --region $REGION \
        --query 'TargetHealthDescriptions[*].{Target:Target.Id,Health:TargetHealth.State,Reason:TargetHealth.Reason}'
else
    echo "No load balancer configured"
fi
echo

# 8. Check container logs (if tasks exist)
if [ ! -z "$TASK_ARNS" ]; then
    echo "8. Recent Container Logs:"
    TASK_ARN=$(echo $TASK_ARNS | cut -d' ' -f1)
    
    # Get container name from task definition
    CONTAINER_NAME=$(aws ecs describe-task-definition \
        --task-definition $TASK_DEF_ARN \
        --region $REGION \
        --query 'taskDefinition.containerDefinitions[0].name' \
        --output text)
    
    echo "Logs for task: $TASK_ARN, container: $CONTAINER_NAME"
    aws logs get-log-events \
        --log-group-name "/ecs/$SERVICE_NAME" \
        --log-stream-name "ecs/$CONTAINER_NAME/$(basename $TASK_ARN)" \
        --region $REGION \
        --limit 10 \
        --query 'events[*].message' \
        --output text 2>/dev/null || echo "No logs available or log group not found"
fi

echo
echo "=== Troubleshooting Complete ==="
```

### Common Issues and Solutions
```bash
# Common ECS deployment issues and solutions

# Issue 1: Tasks failing to start
# Check: Task definition resource requirements
aws ecs describe-task-definition --task-definition my-app --query 'taskDefinition.{Cpu:cpu,Memory:memory,ContainerDefinitions:containerDefinitions[*].{Name:name,Cpu:cpu,Memory:memory}}'

# Issue 2: Service not reaching steady state
# Check: Health check configuration and target group health
aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:...

# Issue 3: Container exits immediately
# Check: Container logs and exit codes
aws logs get-log-events --log-group-name /ecs/my-app --log-stream-name ecs/container/task-id

# Issue 4: Network connectivity issues
# Check: Security groups and network ACLs
aws ec2 describe-security-groups --group-ids sg-12345678

# Issue 5: Image pull failures
# Check: ECR permissions and image existence
aws ecr describe-images --repository-name my-app --image-ids imageTag=latest

# Issue 6: Resource constraints
# Check: Cluster capacity and resource availability
aws ecs describe-clusters --clusters my-cluster --include STATISTICS

# Issue 7: Service discovery issues
# Check: Cloud Map service registration
aws servicediscovery list-services --filters Name=NAMESPACE_ID,Values=ns-12345678
```

This comprehensive deployment guide covers all aspects of deploying applications to ECS, from basic deployments to complex microservices architectures with full CI/CD integration.