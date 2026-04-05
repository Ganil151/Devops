# Amazon ECS (Elastic Container Service) - Fundamentals Guide

## Table of Contents
1. [What is Amazon ECS](#what-is-amazon-ecs)
2. [ECS Architecture](#ecs-architecture)
3. [Core Components](#core-components)
4. [Launch Types](#launch-types)
5. [Networking Modes](#networking-modes)
6. [Service Discovery](#service-discovery)
7. [Load Balancing](#load-balancing)
8. [Storage Options](#storage-options)
9. [Security Model](#security-model)
10. [DevOps Integration](#devops-integration)

## What is Amazon ECS

Amazon Elastic Container Service (ECS) is a fully managed container orchestration service that makes it easy to deploy, manage, and scale containerized applications using Docker containers.

### Key Benefits
- **Fully Managed**: No control plane to manage
- **AWS Integration**: Native integration with AWS services
- **Flexible**: Support for EC2 and Fargate launch types
- **Scalable**: Auto-scaling capabilities
- **Secure**: IAM integration and VPC networking
- **Cost Effective**: Pay only for resources used

### Use Cases
- **Microservices**: Container-based microservices architecture
- **Batch Processing**: Containerized batch jobs
- **Web Applications**: Scalable web application hosting
- **API Services**: RESTful API backends
- **Data Processing**: ETL and data pipeline workloads

## ECS Architecture

### High-Level Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    AWS Account                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                ECS Control Plane                    │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │   Cluster   │  │   Service   │  │    Task     │ │   │
│  │  │  Manager    │  │  Scheduler  │  │  Placement  │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    VPC Network                      │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │   Subnet    │  │   Subnet    │  │   Subnet    │ │   │
│  │  │    AZ-1     │  │    AZ-2     │  │    AZ-3     │ │   │
│  │  │             │  │             │  │             │ │   │
│  │  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │ │   │
│  │  │ │   EC2   │ │  │ │ Fargate │ │  │ │   EC2   │ │ │   │
│  │  │ │ Instances│ │  │ │  Tasks  │ │  │ │ Instances│ │ │   │
│  │  │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Supporting Services                    │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────────┐ │   │
│  │  │   ALB   │ │   ECR   │ │ CloudMap│ │ CloudWatch  │ │   │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Architecture Components
- **Control Plane**: Managed by AWS (API, Scheduler, Cluster Manager)
- **Data Plane**: EC2 instances or Fargate tasks
- **Networking**: VPC, subnets, security groups
- **Storage**: EBS, EFS, S3 integration
- **Monitoring**: CloudWatch integration

## Core Components

### 1. Cluster
```json
{
  "clusterName": "production-cluster",
  "status": "ACTIVE",
  "runningTasksCount": 25,
  "pendingTasksCount": 0,
  "activeServicesCount": 8,
  "statistics": [
    {
      "name": "runningEC2TasksCount",
      "value": "15"
    },
    {
      "name": "runningFargateTasksCount",
      "value": "10"
    }
  ],
  "capacityProviders": ["FARGATE", "FARGATE_SPOT", "EC2"],
  "defaultCapacityProviderStrategy": [
    {
      "capacityProvider": "FARGATE",
      "weight": 1,
      "base": 2
    }
  ]
}
```

### 2. Task Definition
```json
{
  "family": "web-app",
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
          "awslogs-group": "/ecs/web-app",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "environment": [
        {
          "name": "ENV",
          "value": "production"
        }
      ],
      "secrets": [
        {
          "name": "DB_PASSWORD",
          "valueFrom": "arn:aws:secretsmanager:us-west-2:123456789012:secret:prod/db/password"
        }
      ]
    }
  ]
}
```

### 3. Service
```json
{
  "serviceName": "web-service",
  "cluster": "production-cluster",
  "taskDefinition": "web-app:1",
  "desiredCount": 3,
  "launchType": "FARGATE",
  "networkConfiguration": {
    "awsvpcConfiguration": {
      "subnets": [
        "subnet-12345678",
        "subnet-87654321"
      ],
      "securityGroups": [
        "sg-12345678"
      ],
      "assignPublicIp": "DISABLED"
    }
  },
  "loadBalancers": [
    {
      "targetGroupArn": "arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/web-tg/1234567890123456",
      "containerName": "web-container",
      "containerPort": 80
    }
  ],
  "serviceRegistries": [
    {
      "registryArn": "arn:aws:servicediscovery:us-west-2:123456789012:service/srv-12345678",
      "containerName": "web-container"
    }
  ],
  "deploymentConfiguration": {
    "maximumPercent": 200,
    "minimumHealthyPercent": 50,
    "deploymentCircuitBreaker": {
      "enable": true,
      "rollback": true
    }
  }
}
```

### 4. Task
```json
{
  "taskArn": "arn:aws:ecs:us-west-2:123456789012:task/production-cluster/1234567890abcdef",
  "clusterArn": "arn:aws:ecs:us-west-2:123456789012:cluster/production-cluster",
  "taskDefinitionArn": "arn:aws:ecs:us-west-2:123456789012:task-definition/web-app:1",
  "lastStatus": "RUNNING",
  "desiredStatus": "RUNNING",
  "healthStatus": "HEALTHY",
  "launchType": "FARGATE",
  "platformVersion": "1.4.0",
  "cpu": "256",
  "memory": "512",
  "containers": [
    {
      "containerArn": "arn:aws:ecs:us-west-2:123456789012:container/web-container/1234567890abcdef",
      "name": "web-container",
      "lastStatus": "RUNNING",
      "healthStatus": "HEALTHY",
      "networkBindings": [],
      "networkInterfaces": [
        {
          "attachmentId": "eni-attach-12345678",
          "privateIpv4Address": "10.0.1.100"
        }
      ]
    }
  ]
}
```

## Launch Types

### EC2 Launch Type
```yaml
# EC2 Launch Type Configuration
LaunchType: EC2
Cluster:
  - EC2 instances managed by you
  - ECS agent runs on instances
  - More control over infrastructure
  - Cost optimization with Reserved/Spot instances

Characteristics:
  - Instance management required
  - Persistent storage options
  - Custom AMIs supported
  - SSH access available
  - Lower cost for consistent workloads
```

### Fargate Launch Type
```yaml
# Fargate Launch Type Configuration
LaunchType: FARGATE
Cluster:
  - Serverless compute engine
  - No EC2 instances to manage
  - AWS manages infrastructure
  - Pay per task execution

Characteristics:
  - No instance management
  - Automatic scaling
  - Enhanced security isolation
  - Higher cost per vCPU/GB
  - Ideal for variable workloads
```

### Capacity Providers
```json
{
  "capacityProviders": [
    {
      "name": "FARGATE",
      "status": "ACTIVE"
    },
    {
      "name": "FARGATE_SPOT",
      "status": "ACTIVE"
    },
    {
      "name": "EC2-AutoScaling",
      "status": "ACTIVE",
      "autoScalingGroupProvider": {
        "autoScalingGroupArn": "arn:aws:autoscaling:us-west-2:123456789012:autoScalingGroup:uuid:autoScalingGroupName/ecs-cluster-asg",
        "managedScaling": {
          "status": "ENABLED",
          "targetCapacity": 80,
          "minimumScalingStepSize": 1,
          "maximumScalingStepSize": 10
        },
        "managedTerminationProtection": "ENABLED"
      }
    }
  ],
  "defaultCapacityProviderStrategy": [
    {
      "capacityProvider": "FARGATE",
      "weight": 1,
      "base": 2
    },
    {
      "capacityProvider": "FARGATE_SPOT",
      "weight": 4
    }
  ]
}
```

## Networking Modes

### awsvpc Network Mode
```json
{
  "networkMode": "awsvpc",
  "networkConfiguration": {
    "awsvpcConfiguration": {
      "subnets": ["subnet-12345678", "subnet-87654321"],
      "securityGroups": ["sg-12345678"],
      "assignPublicIp": "DISABLED"
    }
  },
  "benefits": [
    "Each task gets its own ENI",
    "Full VPC networking features",
    "Security groups per task",
    "Network monitoring per task",
    "Required for Fargate"
  ]
}
```

### bridge Network Mode
```json
{
  "networkMode": "bridge",
  "portMappings": [
    {
      "hostPort": 0,
      "containerPort": 80,
      "protocol": "tcp"
    }
  ],
  "characteristics": [
    "Default for EC2 launch type",
    "Dynamic port mapping",
    "Shared host networking",
    "Port conflicts possible",
    "Lower networking overhead"
  ]
}
```

### host Network Mode
```json
{
  "networkMode": "host",
  "characteristics": [
    "Direct host networking",
    "No port mapping needed",
    "Highest network performance",
    "Port conflicts likely",
    "Limited container isolation"
  ]
}
```

## Service Discovery

### AWS Cloud Map Integration
```json
{
  "serviceRegistries": [
    {
      "registryArn": "arn:aws:servicediscovery:us-west-2:123456789012:service/srv-12345678",
      "containerName": "web-container",
      "containerPort": 80
    }
  ],
  "cloudMapService": {
    "name": "web-service",
    "namespace": "production.local",
    "dnsConfig": {
      "dnsRecords": [
        {
          "type": "A",
          "ttl": 60
        }
      ]
    },
    "healthCheckConfig": {
      "type": "HTTP",
      "resourcePath": "/health",
      "failureThreshold": 3
    }
  }
}
```

### Service Connect
```json
{
  "serviceConnectConfiguration": {
    "enabled": true,
    "namespace": "production",
    "services": [
      {
        "portName": "http",
        "discoveryName": "web-service",
        "clientAliases": [
          {
            "port": 80,
            "dnsName": "web-service.production"
          }
        ]
      }
    ]
  }
}
```

## Load Balancing

### Application Load Balancer Integration
```json
{
  "loadBalancers": [
    {
      "targetGroupArn": "arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/web-tg/1234567890123456",
      "containerName": "web-container",
      "containerPort": 80
    }
  ],
  "targetGroup": {
    "name": "web-tg",
    "protocol": "HTTP",
    "port": 80,
    "targetType": "ip",
    "healthCheck": {
      "enabled": true,
      "path": "/health",
      "intervalSeconds": 30,
      "timeoutSeconds": 5,
      "healthyThresholdCount": 2,
      "unhealthyThresholdCount": 3,
      "matcher": {
        "httpCode": "200"
      }
    }
  }
}
```

### Network Load Balancer
```json
{
  "loadBalancers": [
    {
      "targetGroupArn": "arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/tcp-tg/1234567890123456",
      "containerName": "tcp-service",
      "containerPort": 8080
    }
  ],
  "targetGroup": {
    "name": "tcp-tg",
    "protocol": "TCP",
    "port": 8080,
    "targetType": "ip",
    "healthCheck": {
      "enabled": true,
      "protocol": "TCP",
      "intervalSeconds": 30,
      "healthyThresholdCount": 3,
      "unhealthyThresholdCount": 3
    }
  }
}
```

## Storage Options

### EFS Integration
```json
{
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
  "mountPoints": [
    {
      "sourceVolume": "efs-volume",
      "containerPath": "/data",
      "readOnly": false
    }
  ]
}
```

### EBS Volumes (EC2 only)
```json
{
  "volumes": [
    {
      "name": "ebs-volume",
      "dockerVolumeConfiguration": {
        "scope": "shared",
        "autoprovision": true,
        "driver": "rexray/ebs",
        "driverOpts": {
          "volumetype": "gp3",
          "size": "10"
        }
      }
    }
  ]
}
```

### S3 Integration
```json
{
  "environment": [
    {
      "name": "S3_BUCKET",
      "value": "my-app-bucket"
    }
  ],
  "taskRoleArn": "arn:aws:iam::123456789012:role/ecsTaskRole",
  "taskRolePolicy": {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource": "arn:aws:s3:::my-app-bucket/*"
      }
    ]
  }
}
```

## Security Model

### IAM Roles
```json
{
  "executionRole": {
    "roleName": "ecsTaskExecutionRole",
    "description": "Role for ECS task execution",
    "policies": [
      "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    ],
    "customPolicy": {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "secretsmanager:GetSecretValue",
            "ssm:GetParameters",
            "kms:Decrypt"
          ],
          "Resource": "*"
        }
      ]
    }
  },
  "taskRole": {
    "roleName": "ecsTaskRole",
    "description": "Role for application running in task",
    "customPolicy": {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "s3:GetObject",
            "s3:PutObject",
            "dynamodb:GetItem",
            "dynamodb:PutItem"
          ],
          "Resource": "*"
        }
      ]
    }
  }
}
```

### Security Groups
```json
{
  "securityGroups": [
    {
      "groupName": "ecs-web-sg",
      "description": "Security group for web containers",
      "ingressRules": [
        {
          "protocol": "tcp",
          "fromPort": 80,
          "toPort": 80,
          "sourceSecurityGroupId": "sg-alb-12345678"
        },
        {
          "protocol": "tcp",
          "fromPort": 443,
          "toPort": 443,
          "sourceSecurityGroupId": "sg-alb-12345678"
        }
      ],
      "egressRules": [
        {
          "protocol": "-1",
          "fromPort": -1,
          "toPort": -1,
          "cidrBlocks": ["0.0.0.0/0"]
        }
      ]
    }
  ]
}
```

### Secrets Management
```json
{
  "secrets": [
    {
      "name": "DB_PASSWORD",
      "valueFrom": "arn:aws:secretsmanager:us-west-2:123456789012:secret:prod/db/password:password::"
    },
    {
      "name": "API_KEY",
      "valueFrom": "arn:aws:ssm:us-west-2:123456789012:parameter/prod/api/key"
    }
  ],
  "environment": [
    {
      "name": "DB_HOST",
      "value": "prod-db.cluster-xyz.us-west-2.rds.amazonaws.com"
    },
    {
      "name": "DB_NAME",
      "value": "production"
    }
  ]
}
```

## DevOps Integration

### CI/CD Pipeline Integration
```yaml
# GitLab CI/CD Pipeline
stages:
  - build
  - test
  - deploy

variables:
  AWS_DEFAULT_REGION: us-west-2
  ECS_CLUSTER_NAME: production-cluster
  ECS_SERVICE_NAME: web-service

build:
  stage: build
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

deploy:
  stage: deploy
  script:
    - aws ecs update-service 
        --cluster $ECS_CLUSTER_NAME 
        --service $ECS_SERVICE_NAME 
        --force-new-deployment
    - aws ecs wait services-stable 
        --cluster $ECS_CLUSTER_NAME 
        --services $ECS_SERVICE_NAME
  only:
    - main
```

### Infrastructure as Code
```hcl
# Terraform ECS Configuration
resource "aws_ecs_cluster" "main" {
  name = "production-cluster"
  
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight           = 1
    base            = 2
  }
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "web_app" {
  family                   = "web-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
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
          "awslogs-group"         = "/ecs/web-app"
          "awslogs-region"        = "us-west-2"
          "awslogs-stream-prefix" = "ecs"
        }
      }
      
      essential = true
    }
  ])
}

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
  
  depends_on = [aws_lb_listener.web_listener]
}
```

### Auto Scaling
```json
{
  "autoScaling": {
    "targetTrackingScalingPolicies": [
      {
        "targetValue": 70.0,
        "scaleOutCooldown": 300,
        "scaleInCooldown": 300,
        "predefinedMetricSpecification": {
          "predefinedMetricType": "ECSServiceAverageCPUUtilization"
        }
      },
      {
        "targetValue": 80.0,
        "scaleOutCooldown": 300,
        "scaleInCooldown": 300,
        "predefinedMetricSpecification": {
          "predefinedMetricType": "ECSServiceAverageMemoryUtilization"
        }
      }
    ],
    "stepScalingPolicies": [
      {
        "adjustmentType": "ChangeInCapacity",
        "cooldown": 300,
        "stepAdjustments": [
          {
            "metricIntervalLowerBound": 0,
            "scalingAdjustment": 2
          }
        ]
      }
    ]
  }
}
```

## Monitoring and Logging

### CloudWatch Integration
```json
{
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-group": "/ecs/web-app",
      "awslogs-region": "us-west-2",
      "awslogs-stream-prefix": "ecs",
      "awslogs-create-group": "true"
    }
  },
  "containerInsights": {
    "enabled": true,
    "metrics": [
      "CpuUtilized",
      "MemoryUtilized",
      "NetworkRxBytes",
      "NetworkTxBytes",
      "StorageReadBytes",
      "StorageWriteBytes"
    ]
  }
}
```

### Health Checks
```json
{
  "healthCheck": {
    "command": [
      "CMD-SHELL",
      "curl -f http://localhost:80/health || exit 1"
    ],
    "interval": 30,
    "timeout": 5,
    "retries": 3,
    "startPeriod": 60
  }
}
```

## Best Practices

### Task Definition Best Practices
1. **Use specific image tags** instead of `latest`
2. **Set resource limits** for CPU and memory
3. **Implement health checks** for containers
4. **Use secrets management** for sensitive data
5. **Enable logging** with structured logs
6. **Follow least privilege** for IAM roles

### Service Configuration Best Practices
1. **Use multiple AZs** for high availability
2. **Configure deployment circuit breaker** for safety
3. **Set appropriate health check grace period**
4. **Use service discovery** for inter-service communication
5. **Implement proper load balancing**
6. **Monitor service metrics** and set up alerts

### Security Best Practices
1. **Use private subnets** for tasks
2. **Implement security groups** with minimal access
3. **Enable VPC Flow Logs** for network monitoring
4. **Use IAM roles** instead of access keys
5. **Encrypt data** in transit and at rest
6. **Regular security scanning** of container images

### Cost Optimization
1. **Use Fargate Spot** for fault-tolerant workloads
2. **Right-size tasks** based on actual usage
3. **Implement auto-scaling** to match demand
4. **Use reserved capacity** for predictable workloads
5. **Monitor and optimize** resource utilization
6. **Clean up unused resources** regularly

## Comparison with Other Services

### ECS vs EKS
| Feature | ECS | EKS |
|---------|-----|-----|
| Learning Curve | Lower | Higher |
| AWS Integration | Native | Good |
| Kubernetes API | No | Yes |
| Ecosystem | AWS-focused | Kubernetes ecosystem |
| Management Overhead | Lower | Higher |
| Flexibility | Good | Excellent |

### ECS vs Lambda
| Feature | ECS | Lambda |
|---------|-----|-------|
| Runtime | Long-running | Event-driven |
| Scaling | Manual/Auto | Automatic |
| Cost Model | Resource-based | Execution-based |
| Cold Start | No | Yes |
| State Management | Stateful possible | Stateless |
| Execution Time | Unlimited | 15 minutes max |

## Next Steps

1. **Set up your first ECS cluster** - Follow the cluster setup guide
2. **Deploy sample applications** - Practice with different launch types
3. **Implement monitoring** - Set up CloudWatch and logging
4. **Configure CI/CD** - Integrate with your deployment pipeline
5. **Explore advanced features** - Service mesh, batch processing, ML workloads

## Additional Resources

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [ECS Best Practices Guide](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [AWS Copilot CLI](https://aws.github.io/copilot-cli/)
- [ECS CLI](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI.html)
- [Fargate Pricing](https://aws.amazon.com/fargate/pricing/)