# ECS Cluster Setup and Management Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Cluster Creation Methods](#cluster-creation-methods)
3. [EC2 Launch Type Setup](#ec2-launch-type-setup)
4. [Fargate Launch Type Setup](#fargate-launch-type-setup)
5. [Capacity Providers](#capacity-providers)
6. [Task Definitions](#task-definitions)
7. [Service Configuration](#service-configuration)
8. [Load Balancer Integration](#load-balancer-integration)
9. [Auto Scaling Setup](#auto-scaling-setup)
10. [Cluster Management](#cluster-management)

## Prerequisites

### Required Tools
```bash
# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install ECS CLI (optional)
sudo curl -Lo /usr/local/bin/ecs-cli https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest
sudo chmod +x /usr/local/bin/ecs-cli

# Install AWS Copilot (recommended)
curl -Lo copilot https://github.com/aws/copilot-cli/releases/latest/download/copilot-linux
chmod +x copilot && sudo mv copilot /usr/local/bin

# Verify installations
aws --version
ecs-cli --version
copilot --version
```

### AWS Configuration
```bash
# Configure AWS credentials
aws configure
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region name: us-west-2
# Default output format: json

# Verify configuration
aws sts get-caller-identity
```

### IAM Permissions Required
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*",
        "ec2:*",
        "iam:*",
        "elasticloadbalancing:*",
        "autoscaling:*",
        "cloudformation:*",
        "logs:*",
        "servicediscovery:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Cluster Creation Methods

### Method 1: AWS CLI
```bash
# Create ECS cluster
aws ecs create-cluster \
    --cluster-name production-cluster \
    --capacity-providers FARGATE FARGATE_SPOT EC2 \
    --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1,base=2 \
    --settings name=containerInsights,value=enabled \
    --tags key=Environment,value=production key=Project,value=web-platform

# Verify cluster creation
aws ecs describe-clusters --clusters production-cluster
```

### Method 2: AWS Copilot
```bash
# Initialize new application
copilot app init web-platform

# Create environment
copilot env init --name production
copilot env deploy --name production

# Create service
copilot svc init --name web-service --svc-type "Backend Service"
copilot svc deploy --name web-service --env production
```

### Method 3: Terraform
```hcl
# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  capacity_providers = ["FARGATE", "FARGATE_SPOT", "EC2"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight           = 1
    base            = 2
  }

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight           = 4
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
    Project     = var.project_name
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.cluster_name}"
  retention_in_days = 30

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
```

### Method 4: CloudFormation
```yaml
# ecs-cluster.yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'ECS Cluster with Fargate and EC2 capacity providers'

Parameters:
  ClusterName:
    Type: String
    Default: production-cluster
  Environment:
    Type: String
    Default: production

Resources:
  ECSCluster:
    Type: AWS::ECS::Cluster
    Properties:
      ClusterName: !Ref ClusterName
      CapacityProviders:
        - FARGATE
        - FARGATE_SPOT
        - EC2
      DefaultCapacityProviderStrategy:
        - CapacityProvider: FARGATE
          Weight: 1
          Base: 2
        - CapacityProvider: FARGATE_SPOT
          Weight: 4
      ClusterSettings:
        - Name: containerInsights
          Value: enabled
      Tags:
        - Key: Environment
          Value: !Ref Environment
        - Key: Name
          Value: !Ref ClusterName

  LogGroup:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: !Sub '/ecs/${ClusterName}'
      RetentionInDays: 30

Outputs:
  ClusterArn:
    Description: ECS Cluster ARN
    Value: !GetAtt ECSCluster.Arn
    Export:
      Name: !Sub '${AWS::StackName}-ClusterArn'
```

## EC2 Launch Type Setup

### Auto Scaling Group Configuration
```hcl
# ec2-capacity-provider.tf
# Launch Template
resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "${var.cluster_name}-lt"
  image_id      = data.aws_ami.ecs_optimized.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ecs_nodes.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name = var.cluster_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-instance"
      Environment = var.environment
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "ecs_asg" {
  name                = "${var.cluster_name}-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = []
  health_check_type   = "EC2"
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  protect_from_scale_in = true

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = false
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg"
    propagate_at_launch = false
  }
}

# Capacity Provider
resource "aws_ecs_capacity_provider" "ec2_capacity_provider" {
  name = "${var.cluster_name}-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 80
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 10
    }
  }

  tags = {
    Environment = var.environment
  }
}
```

### User Data Script
```bash
#!/bin/bash
# user_data.sh
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_SPOT_INSTANCE_DRAINING=true >> /etc/ecs/ecs.config

# Install CloudWatch agent
yum update -y
yum install -y amazon-cloudwatch-agent

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
  "metrics": {
    "namespace": "CWAgent",
    "metrics_collected": {
      "cpu": {
        "measurement": ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": ["used_percent"],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

# Start ECS agent
start ecs
```

### IAM Roles for EC2
```hcl
# iam-roles.tf
# ECS Instance Role
resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.cluster_name}-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ssm_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.cluster_name}-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}
```

## Fargate Launch Type Setup

### Basic Fargate Task Definition
```json
{
  "family": "web-app-fargate",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::123456789012:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "web-container",
      "image": "nginx:latest",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/web-app-fargate",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost/ || exit 1"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      }
    }
  ]
}
```

### Fargate Service with Terraform
```hcl
# fargate-service.tf
resource "aws_ecs_task_definition" "fargate_task" {
  family                   = "web-app-fargate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "web-container"
      image = "nginx:latest"
      
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      
      healthCheck = {
        command = [
          "CMD-SHELL",
          "curl -f http://localhost/ || exit 1"
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
      
      essential = true
    }
  ])

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ecs_service" "fargate_service" {
  name            = "web-service-fargate"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.fargate_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "web-container"
    container_port   = 80
  }

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 50
    
    deployment_circuit_breaker {
      enable   = true
      rollback = true
    }
  }

  depends_on = [aws_lb_listener.app_listener]

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
```

## Capacity Providers

### Mixed Capacity Provider Strategy
```hcl
# capacity-providers.tf
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT", aws_ecs_capacity_provider.ec2_capacity_provider.name]

  default_capacity_provider_strategy {
    base              = 2
    weight            = 1
    capacity_provider = "FARGATE"
  }

  default_capacity_provider_strategy {
    base              = 0
    weight            = 4
    capacity_provider = "FARGATE_SPOT"
  }

  default_capacity_provider_strategy {
    base              = 0
    weight            = 2
    capacity_provider = aws_ecs_capacity_provider.ec2_capacity_provider.name
  }
}
```

### Service-Level Capacity Provider Strategy
```json
{
  "serviceName": "mixed-capacity-service",
  "cluster": "production-cluster",
  "taskDefinition": "web-app:1",
  "desiredCount": 10,
  "capacityProviderStrategy": [
    {
      "capacityProvider": "FARGATE",
      "weight": 1,
      "base": 2
    },
    {
      "capacityProvider": "FARGATE_SPOT",
      "weight": 4,
      "base": 0
    },
    {
      "capacityProvider": "EC2",
      "weight": 2,
      "base": 0
    }
  ],
  "networkConfiguration": {
    "awsvpcConfiguration": {
      "subnets": ["subnet-12345678", "subnet-87654321"],
      "securityGroups": ["sg-12345678"],
      "assignPublicIp": "DISABLED"
    }
  }
}
```

## Task Definitions

### Multi-Container Task Definition
```json
{
  "family": "multi-container-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::123456789012:role/ecsTaskRole",
  "volumes": [
    {
      "name": "shared-volume",
      "host": {}
    }
  ],
  "containerDefinitions": [
    {
      "name": "web-server",
      "image": "nginx:latest",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "mountPoints": [
        {
          "sourceVolume": "shared-volume",
          "containerPath": "/usr/share/nginx/html",
          "readOnly": true
        }
      ],
      "dependsOn": [
        {
          "containerName": "app-container",
          "condition": "SUCCESS"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/multi-container-app",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "nginx"
        }
      }
    },
    {
      "name": "app-container",
      "image": "myapp:latest",
      "cpu": 256,
      "memory": 512,
      "essential": false,
      "mountPoints": [
        {
          "sourceVolume": "shared-volume",
          "containerPath": "/app/static",
          "readOnly": false
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        }
      ],
      "secrets": [
        {
          "name": "DB_PASSWORD",
          "valueFrom": "arn:aws:secretsmanager:us-west-2:123456789012:secret:prod/db/password"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/multi-container-app",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "app"
        }
      }
    }
  ]
}
```

### Task Definition with EFS Volume
```json
{
  "family": "efs-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::123456789012:role/ecsTaskRole",
  "volumes": [
    {
      "name": "efs-volume",
      "efsVolumeConfiguration": {
        "fileSystemId": "fs-12345678",
        "rootDirectory": "/app/data",
        "transitEncryption": "ENABLED",
        "transitEncryptionPort": 2049,
        "authorizationConfig": {
          "accessPointId": "fsap-12345678",
          "iam": "ENABLED"
        }
      }
    }
  ],
  "containerDefinitions": [
    {
      "name": "data-processor",
      "image": "myapp:latest",
      "essential": true,
      "mountPoints": [
        {
          "sourceVolume": "efs-volume",
          "containerPath": "/data",
          "readOnly": false
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/efs-task",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

## Service Configuration

### Service with Rolling Deployment
```hcl
# service-configuration.tf
resource "aws_ecs_service" "web_service" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.web_app.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web_tg.arn
    container_name   = "web-container"
    container_port   = 80
  }

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 50
    
    deployment_circuit_breaker {
      enable   = true
      rollback = true
    }
  }

  # Service discovery
  service_registries {
    registry_arn   = aws_service_discovery_service.web_service.arn
    container_name = "web-container"
  }

  # Placement constraints
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.instance-type =~ t3.*"
  }

  # Placement strategy
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  depends_on = [aws_lb_listener.web_listener]

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
```

### Blue-Green Deployment Service
```json
{
  "serviceName": "blue-green-service",
  "cluster": "production-cluster",
  "taskDefinition": "web-app:1",
  "desiredCount": 3,
  "launchType": "FARGATE",
  "deploymentController": {
    "type": "CODE_DEPLOY"
  },
  "networkConfiguration": {
    "awsvpcConfiguration": {
      "subnets": ["subnet-12345678", "subnet-87654321"],
      "securityGroups": ["sg-12345678"],
      "assignPublicIp": "DISABLED"
    }
  },
  "loadBalancers": [
    {
      "targetGroupArn": "arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/blue-tg/1234567890123456",
      "containerName": "web-container",
      "containerPort": 80
    }
  ]
}
```

## Load Balancer Integration

### Application Load Balancer Setup
```hcl
# load-balancer.tf
resource "aws_lb" "main" {
  name               = "${var.cluster_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_lb_target_group" "web_tg" {
  name        = "${var.cluster_name}-web-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# HTTPS Listener with SSL Certificate
resource "aws_lb_listener" "web_https_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
```

### Network Load Balancer for TCP Services
```hcl
# network-load-balancer.tf
resource "aws_lb" "tcp_nlb" {
  name               = "${var.cluster_name}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_lb_target_group" "tcp_tg" {
  name        = "${var.cluster_name}-tcp-tg"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    port                = "traffic-port"
    protocol            = "TCP"
    timeout             = 10
    unhealthy_threshold = 3
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_lb_listener" "tcp_listener" {
  load_balancer_arn = aws_lb.tcp_nlb.arn
  port              = "8080"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tcp_tg.arn
  }
}
```

## Auto Scaling Setup

### Service Auto Scaling
```hcl
# auto-scaling.tf
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.web_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU-based scaling policy
resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  name               = "${var.cluster_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_out_cooldown = 300
    scale_in_cooldown  = 300
  }
}

# Memory-based scaling policy
resource "aws_appautoscaling_policy" "ecs_memory_policy" {
  name               = "${var.cluster_name}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 80.0
    scale_out_cooldown = 300
    scale_in_cooldown  = 300
  }
}

# Custom metric scaling (ALB request count)
resource "aws_appautoscaling_policy" "ecs_request_policy" {
  name               = "${var.cluster_name}-request-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.main.arn_suffix}/${aws_lb_target_group.web_tg.arn_suffix}"
    }
    target_value       = 1000.0
    scale_out_cooldown = 300
    scale_in_cooldown  = 300
  }
}
```

### Scheduled Scaling
```hcl
# scheduled-scaling.tf
resource "aws_appautoscaling_scheduled_action" "scale_up_morning" {
  name               = "${var.cluster_name}-scale-up-morning"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  schedule           = "cron(0 8 * * MON-FRI)"

  scalable_target_action {
    min_capacity = 5
    max_capacity = 15
  }
}

resource "aws_appautoscaling_scheduled_action" "scale_down_evening" {
  name               = "${var.cluster_name}-scale-down-evening"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  schedule           = "cron(0 18 * * MON-FRI)"

  scalable_target_action {
    min_capacity = 2
    max_capacity = 10
  }
}
```

## Cluster Management

### Monitoring and Logging Setup
```hcl
# monitoring.tf
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.cluster_name}"
  retention_in_days = 30

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "ecs_dashboard" {
  dashboard_name = "${var.cluster_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", aws_ecs_service.web_service.name, "ClusterName", aws_ecs_cluster.main.name],
            [".", "MemoryUtilization", ".", ".", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ECS Service Metrics"
          period  = 300
        }
      }
    ]
  })
}
```

### Cluster Maintenance Commands
```bash
#!/bin/bash
# cluster-maintenance.sh

CLUSTER_NAME="production-cluster"
REGION="us-west-2"

# Check cluster status
echo "=== Cluster Status ==="
aws ecs describe-clusters --clusters $CLUSTER_NAME --region $REGION

# List services
echo "=== Services ==="
aws ecs list-services --cluster $CLUSTER_NAME --region $REGION

# Check service health
echo "=== Service Health ==="
aws ecs describe-services --cluster $CLUSTER_NAME --services $(aws ecs list-services --cluster $CLUSTER_NAME --query 'serviceArns[]' --output text --region $REGION) --region $REGION

# List running tasks
echo "=== Running Tasks ==="
aws ecs list-tasks --cluster $CLUSTER_NAME --region $REGION

# Check container instances (EC2 launch type)
echo "=== Container Instances ==="
aws ecs list-container-instances --cluster $CLUSTER_NAME --region $REGION

# Update service (force new deployment)
update_service() {
    local service_name=$1
    echo "Updating service: $service_name"
    aws ecs update-service \
        --cluster $CLUSTER_NAME \
        --service $service_name \
        --force-new-deployment \
        --region $REGION
}

# Scale service
scale_service() {
    local service_name=$1
    local desired_count=$2
    echo "Scaling service $service_name to $desired_count tasks"
    aws ecs update-service \
        --cluster $CLUSTER_NAME \
        --service $service_name \
        --desired-count $desired_count \
        --region $REGION
}

# Drain container instance
drain_instance() {
    local instance_arn=$1
    echo "Draining instance: $instance_arn"
    aws ecs update-container-instances-state \
        --cluster $CLUSTER_NAME \
        --container-instances $instance_arn \
        --status DRAINING \
        --region $REGION
}

# Usage examples:
# update_service "web-service"
# scale_service "web-service" 5
# drain_instance "arn:aws:ecs:us-west-2:123456789012:container-instance/12345678-1234-1234-1234-123456789012"
```

### Cleanup and Resource Management
```bash
#!/bin/bash
# cleanup-resources.sh

CLUSTER_NAME="production-cluster"
REGION="us-west-2"

# Stop all services
echo "Stopping all services..."
SERVICES=$(aws ecs list-services --cluster $CLUSTER_NAME --query 'serviceArns[]' --output text --region $REGION)
for service in $SERVICES; do
    echo "Stopping service: $service"
    aws ecs update-service --cluster $CLUSTER_NAME --service $service --desired-count 0 --region $REGION
done

# Wait for services to stop
echo "Waiting for services to stop..."
aws ecs wait services-stable --cluster $CLUSTER_NAME --services $SERVICES --region $REGION

# Delete services
echo "Deleting services..."
for service in $SERVICES; do
    echo "Deleting service: $service"
    aws ecs delete-service --cluster $CLUSTER_NAME --service $service --region $REGION
done

# Deregister task definitions
echo "Deregistering task definitions..."
TASK_DEFINITIONS=$(aws ecs list-task-definitions --status ACTIVE --query 'taskDefinitionArns[]' --output text --region $REGION)
for task_def in $TASK_DEFINITIONS; do
    echo "Deregistering task definition: $task_def"
    aws ecs deregister-task-definition --task-definition $task_def --region $REGION
done

# Delete cluster
echo "Deleting cluster..."
aws ecs delete-cluster --cluster $CLUSTER_NAME --region $REGION

echo "Cleanup complete!"
```

## Best Practices

### Security Best Practices
1. **Use IAM roles** for task and execution roles
2. **Enable VPC mode** for network isolation
3. **Use private subnets** for tasks
4. **Implement security groups** with minimal access
5. **Enable logging** for all containers
6. **Use secrets management** for sensitive data

### Performance Best Practices
1. **Right-size tasks** based on actual usage
2. **Use health checks** for reliable deployments
3. **Implement auto-scaling** for variable workloads
4. **Use placement strategies** for optimal distribution
5. **Monitor resource utilization** continuously
6. **Optimize container images** for faster startup

### Cost Optimization
1. **Use Fargate Spot** for fault-tolerant workloads
2. **Implement capacity providers** for mixed strategies
3. **Right-size resources** to avoid over-provisioning
4. **Use scheduled scaling** for predictable patterns
5. **Monitor costs** with AWS Cost Explorer
6. **Clean up unused resources** regularly

This comprehensive setup guide provides everything needed to create and manage ECS clusters effectively in production environments.