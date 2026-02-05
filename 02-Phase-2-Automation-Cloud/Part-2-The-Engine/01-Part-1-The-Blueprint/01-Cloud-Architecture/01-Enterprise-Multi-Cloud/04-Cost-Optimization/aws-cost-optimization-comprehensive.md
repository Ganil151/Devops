# AWS Cost Optimization Guide

## Table of Contents
1. [Cost Optimization Fundamentals](#cost-optimization-fundamentals)
2. [EC2 Cost Optimization](#ec2-cost-optimization)
3. [ECS/EKS Cost Optimization](#ecseKs-cost-optimization)
4. [Storage Cost Optimization](#storage-cost-optimization)
5. [Database Cost Optimization](#database-cost-optimization)
6. [Networking Cost Optimization](#networking-cost-optimization)
7. [Lambda and Serverless](#lambda-and-serverless)
8. [Monitoring and Analytics](#monitoring-and-analytics)
9. [Cost Management Tools](#cost-management-tools)
10. [Automation and Governance](#automation-and-governance)

## Cost Optimization Fundamentals

### AWS Well-Architected Cost Optimization Pillars
```yaml
Cost Optimization Principles:
  - Right-sizing resources
  - Selecting appropriate pricing models
  - Matching supply with demand
  - Optimizing over time
  - Measuring and monitoring costs
```

### Cost Optimization Framework
```
┌─────────────────────────────────────────────────────────────┐
│                Cost Optimization Framework                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Visibility                        │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │ Cost        │  │ Usage       │  │ Performance │ │   │
│  │  │ Explorer    │  │ Reports     │  │ Metrics     │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                 Right-Sizing                        │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │ Resource    │  │ Performance │  │ Utilization │ │   │
│  │  │ Analysis    │  │ Monitoring  │  │ Tracking    │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │               Pricing Models                        │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │ Reserved    │  │ Spot        │  │ Savings     │ │   │
│  │  │ Instances   │  │ Instances   │  │ Plans       │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                 Automation                          │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │ Auto        │  │ Scheduled   │  │ Policy      │ │   │
│  │  │ Scaling     │  │ Actions     │  │ Enforcement │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## EC2 Cost Optimization

### Instance Right-Sizing
```bash
#!/bin/bash
# ec2-rightsizing-analysis.sh

# Get EC2 instances with utilization data
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name]' --output table

# Get CloudWatch metrics for CPU utilization
get_cpu_utilization() {
    local instance_id=$1
    local days=${2:-7}
    
    aws cloudwatch get-metric-statistics \
        --namespace AWS/EC2 \
        --metric-name CPUUtilization \
        --dimensions Name=InstanceId,Value=$instance_id \
        --start-time $(date -u -d "$days days ago" +%Y-%m-%dT%H:%M:%S) \
        --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
        --period 3600 \
        --statistics Average,Maximum \
        --query 'Datapoints[*].[Timestamp,Average,Maximum]' \
        --output table
}

# Analyze underutilized instances
analyze_underutilized_instances() {
    echo "Analyzing underutilized EC2 instances..."
    
    # Get all running instances
    INSTANCES=$(aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running" \
        --query 'Reservations[].Instances[].InstanceId' \
        --output text)
    
    for instance in $INSTANCES; do
        echo "Analyzing instance: $instance"
        
        # Get average CPU utilization over last 7 days
        AVG_CPU=$(aws cloudwatch get-metric-statistics \
            --namespace AWS/EC2 \
            --metric-name CPUUtilization \
            --dimensions Name=InstanceId,Value=$instance \
            --start-time $(date -u -d "7 days ago" +%Y-%m-%dT%H:%M:%S) \
            --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
            --period 3600 \
            --statistics Average \
            --query 'Datapoints[].Average' \
            --output text | awk '{sum+=$1; count++} END {if(count>0) print sum/count; else print 0}')
        
        if (( $(echo "$AVG_CPU < 10" | bc -l) )); then
            echo "  WARNING: Instance $instance has low CPU utilization: $AVG_CPU%"
            
            # Get instance details
            aws ec2 describe-instances \
                --instance-ids $instance \
                --query 'Reservations[].Instances[].[InstanceType,LaunchTime]' \
                --output table
        fi
    done
}
```

### Reserved Instances Strategy
```hcl
# reserved-instances-analysis.tf
data "aws_ec2_instance_type_offerings" "available" {
  filter {
    name   = "location"
    values = [var.aws_region]
  }
}

# Reserved Instance recommendations
resource "aws_ce_anomaly_detector" "ri_utilization" {
  name         = "ri-utilization-detector"
  monitor_type = "DIMENSIONAL"

  specification {
    dimension_key           = "SERVICE"
    dimension_value_list    = ["Amazon Elastic Compute Cloud - Compute"]
    match_options          = ["EQUALS"]
    metric_name            = "BlendedCost"
  }
}

# Cost and Usage Report for RI analysis
resource "aws_cur_report_definition" "ri_analysis" {
  report_name                = "ri-cost-analysis"
  time_unit                  = "DAILY"
  format                     = "textORcsv"
  compression                = "GZIP"
  additional_schema_elements = ["RESOURCES"]
  s3_bucket                  = aws_s3_bucket.cost_reports.bucket
  s3_region                  = var.aws_region
  additional_artifacts       = ["REDSHIFT", "ATHENA"]
}
```

### Spot Instance Implementation
```yaml
# spot-instance-template.yaml
Resources:
  SpotFleetRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: spotfleet.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole

  SpotFleet:
    Type: AWS::EC2::SpotFleet
    Properties:
      SpotFleetRequestConfig:
        IamFleetRole: !GetAtt SpotFleetRole.Arn
        AllocationStrategy: diversified
        TargetCapacity: 4
        SpotPrice: '0.10'
        LaunchSpecifications:
          - ImageId: ami-0abcdef1234567890
            InstanceType: t3.medium
            KeyName: my-key-pair
            SecurityGroups:
              - GroupId: sg-12345678
            SubnetId: subnet-12345678
            UserData:
              Fn::Base64: !Sub |
                #!/bin/bash
                yum update -y
                # Application setup
          - ImageId: ami-0abcdef1234567890
            InstanceType: t3.large
            KeyName: my-key-pair
            SecurityGroups:
              - GroupId: sg-12345678
            SubnetId: subnet-87654321
```

### Auto Scaling Optimization
```json
{
  "AutoScalingGroupName": "cost-optimized-asg",
  "MinSize": 1,
  "MaxSize": 10,
  "DesiredCapacity": 2,
  "DefaultCooldown": 300,
  "HealthCheckType": "ELB",
  "HealthCheckGracePeriod": 300,
  "MixedInstancesPolicy": {
    "LaunchTemplate": {
      "LaunchTemplateSpecification": {
        "LaunchTemplateName": "cost-optimized-template",
        "Version": "$Latest"
      },
      "Overrides": [
        {
          "InstanceType": "t3.medium",
          "WeightedCapacity": "1"
        },
        {
          "InstanceType": "t3.large",
          "WeightedCapacity": "2"
        },
        {
          "InstanceType": "m5.large",
          "WeightedCapacity": "2"
        }
      ]
    },
    "InstancesDistribution": {
      "OnDemandAllocationStrategy": "prioritized",
      "OnDemandBaseCapacity": 1,
      "OnDemandPercentageAboveBaseCapacity": 25,
      "SpotAllocationStrategy": "capacity-optimized",
      "SpotInstancePools": 3,
      "SpotMaxPrice": "0.10"
    }
  }
}
```

## ECS/EKS Cost Optimization

### Fargate vs EC2 Cost Analysis
```python
# fargate-cost-calculator.py
import json

def calculate_fargate_cost(cpu_units, memory_gb, hours_per_month):
    """Calculate Fargate costs"""
    # Fargate pricing (us-east-1)
    cpu_price_per_hour = 0.04048  # per vCPU
    memory_price_per_hour = 0.004445  # per GB
    
    cpu_cost = (cpu_units / 1024) * cpu_price_per_hour * hours_per_month
    memory_cost = memory_gb * memory_price_per_hour * hours_per_month
    
    return cpu_cost + memory_cost

def calculate_ec2_cost(instance_type, hours_per_month, utilization=0.7):
    """Calculate EC2 costs with utilization factor"""
    # Sample EC2 pricing (us-east-1)
    ec2_pricing = {
        't3.medium': 0.0416,
        't3.large': 0.0832,
        'm5.large': 0.096,
        'm5.xlarge': 0.192
    }
    
    base_cost = ec2_pricing.get(instance_type, 0) * hours_per_month
    return base_cost / utilization  # Account for underutilization

# Example comparison
fargate_cost = calculate_fargate_cost(512, 1, 730)  # 0.5 vCPU, 1GB, full month
ec2_cost = calculate_ec2_cost('t3.medium', 730, 0.3)  # 30% utilization

print(f"Fargate cost: ${fargate_cost:.2f}")
print(f"EC2 cost: ${ec2_cost:.2f}")
print(f"Savings with Fargate: ${ec2_cost - fargate_cost:.2f}")
```

### ECS Spot Integration
```hcl
# ecs-spot-optimization.tf
resource "aws_ecs_capacity_provider" "spot" {
  name = "spot-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.spot_asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 80
    }
  }
}

resource "aws_autoscaling_group" "spot_asg" {
  name                = "ecs-spot-asg"
  vpc_zone_identifier = var.private_subnet_ids
  min_size            = 0
  max_size            = 20
  desired_capacity    = 2

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.ecs_spot.id
        version           = "$Latest"
      }

      override {
        instance_type     = "t3.medium"
        weighted_capacity = "1"
      }
      override {
        instance_type     = "t3.large"
        weighted_capacity = "2"
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 20
      spot_allocation_strategy                 = "capacity-optimized"
    }
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = false
  }
}
```

### EKS Cost Optimization
```yaml
# eks-cost-optimization.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-autoscaler-status
  namespace: kube-system
data:
  nodes.max: "100"
  scale-down-delay-after-add: "10m"
  scale-down-unneeded-time: "10m"
  scale-down-utilization-threshold: "0.5"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
spec:
  template:
    spec:
      containers:
      - image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.0
        name: cluster-autoscaler
        command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=aws
        - --skip-nodes-with-local-storage=false
        - --expander=least-waste
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/production-cluster
        - --balance-similar-node-groups
        - --skip-nodes-with-system-pods=false
        - --scale-down-enabled=true
        - --scale-down-delay-after-add=10m
        - --scale-down-unneeded-time=10m
        - --scale-down-utilization-threshold=0.5
```

## Storage Cost Optimization

### S3 Cost Optimization
```hcl
# s3-cost-optimization.tf
resource "aws_s3_bucket" "optimized_bucket" {
  bucket = "cost-optimized-bucket"
}

resource "aws_s3_bucket_lifecycle_configuration" "cost_optimization" {
  bucket = aws_s3_bucket.optimized_bucket.id

  rule {
    id     = "cost_optimization_rule"
    status = "Enabled"

    # Transition to IA after 30 days
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # Transition to Glacier after 90 days
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # Transition to Deep Archive after 365 days
    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }

    # Delete incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    # Delete old versions
    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    # Transition old versions
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }

  rule {
    id     = "delete_old_logs"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    expiration {
      days = 30
    }
  }
}

# S3 Intelligent Tiering
resource "aws_s3_bucket_intelligent_tiering_configuration" "intelligent_tiering" {
  bucket = aws_s3_bucket.optimized_bucket.id
  name   = "EntireBucket"

  status = "Enabled"

  optional_fields = ["BucketKeyStatus"]
}
```

### EBS Optimization
```bash
#!/bin/bash
# ebs-optimization.sh

# Find unattached EBS volumes
find_unattached_volumes() {
    echo "Finding unattached EBS volumes..."
    aws ec2 describe-volumes \
        --filters Name=status,Values=available \
        --query 'Volumes[*].[VolumeId,Size,VolumeType,CreateTime]' \
        --output table
}

# Find oversized volumes
find_oversized_volumes() {
    echo "Analyzing EBS volume utilization..."
    
    # Get all attached volumes
    VOLUMES=$(aws ec2 describe-volumes \
        --filters Name=status,Values=in-use \
        --query 'Volumes[*].VolumeId' \
        --output text)
    
    for volume in $VOLUMES; do
        # Get volume details
        VOLUME_INFO=$(aws ec2 describe-volumes \
            --volume-ids $volume \
            --query 'Volumes[0].[VolumeId,Size,VolumeType,Attachments[0].InstanceId]' \
            --output text)
        
        echo "Volume: $VOLUME_INFO"
        
        # Note: Actual disk usage requires CloudWatch agent or SSH access
        # This is a placeholder for volume analysis
    done
}

# Optimize EBS volume types
optimize_volume_types() {
    echo "EBS Volume Type Optimization Recommendations:"
    echo "1. gp2 -> gp3: Up to 20% cost savings with same performance"
    echo "2. io1 -> io2: Up to 10% cost savings with better durability"
    echo "3. Consider st1 for throughput-optimized workloads"
    echo "4. Consider sc1 for cold storage workloads"
}

# Snapshot optimization
optimize_snapshots() {
    echo "Optimizing EBS snapshots..."
    
    # Find old snapshots
    aws ec2 describe-snapshots \
        --owner-ids self \
        --query 'Snapshots[?StartTime<=`2023-01-01`].[SnapshotId,StartTime,VolumeSize]' \
        --output table
    
    echo "Consider deleting snapshots older than retention policy"
}
```

### EFS Cost Optimization
```hcl
# efs-cost-optimization.tf
resource "aws_efs_file_system" "cost_optimized" {
  creation_token = "cost-optimized-efs"
  
  # Enable lifecycle management
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  
  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }
  
  # Use provisioned throughput only if needed
  throughput_mode = "bursting"  # vs "provisioned"
  
  # Enable backup
  enable_backup_policy = true
  
  tags = {
    Name = "cost-optimized-efs"
  }
}

# EFS Access Points for better cost control
resource "aws_efs_access_point" "app_access_point" {
  file_system_id = aws_efs_file_system.cost_optimized.id
  
  posix_user {
    gid = 1001
    uid = 1001
  }
  
  root_directory {
    path = "/app"
    creation_info {
      owner_gid   = 1001
      owner_uid   = 1001
      permissions = 755
    }
  }
}
```

## Database Cost Optimization

### RDS Cost Optimization
```hcl
# rds-cost-optimization.tf
resource "aws_db_instance" "cost_optimized" {
  identifier = "cost-optimized-db"
  
  # Right-size instance
  instance_class = "db.t3.micro"  # Burstable performance
  
  # Use gp3 storage
  storage_type          = "gp3"
  allocated_storage     = 20
  max_allocated_storage = 100  # Enable storage autoscaling
  
  # Enable storage encryption
  storage_encrypted = true
  
  # Optimize backup settings
  backup_retention_period = 7
  backup_window          = "03:00-04:00"  # Low traffic window
  
  # Maintenance window
  maintenance_window = "sun:04:00-sun:05:00"
  
  # Multi-AZ only for production
  multi_az = var.environment == "production"
  
  # Performance Insights (free tier)
  performance_insights_enabled = true
  performance_insights_retention_period = 7
  
  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn
  
  # Enable deletion protection for production
  deletion_protection = var.environment == "production"
  
  tags = {
    Environment = var.environment
    CostCenter  = "database"
  }
}

# Read replica for read-heavy workloads
resource "aws_db_instance" "read_replica" {
  count = var.enable_read_replica ? 1 : 0
  
  identifier = "cost-optimized-db-replica"
  
  # Smaller instance for read replica
  instance_class = "db.t3.micro"
  
  # Source database
  replicate_source_db = aws_db_instance.cost_optimized.identifier
  
  # Different AZ for HA
  availability_zone = "us-west-2b"
  
  tags = {
    Environment = var.environment
    Type        = "read-replica"
  }
}
```

### DynamoDB Cost Optimization
```hcl
# dynamodb-cost-optimization.tf
resource "aws_dynamodb_table" "cost_optimized" {
  name           = "cost-optimized-table"
  billing_mode   = "PAY_PER_REQUEST"  # vs PROVISIONED
  hash_key       = "id"
  
  attribute {
    name = "id"
    type = "S"
  }
  
  # Enable point-in-time recovery
  point_in_time_recovery {
    enabled = true
  }
  
  # Server-side encryption
  server_side_encryption {
    enabled = true
  }
  
  # TTL for automatic data expiration
  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }
  
  tags = {
    Environment = var.environment
    CostCenter  = "database"
  }
}

# Global Secondary Index with projection
resource "aws_dynamodb_table" "with_gsi" {
  name           = "table-with-gsi"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  
  attribute {
    name = "id"
    type = "S"
  }
  
  attribute {
    name = "status"
    type = "S"
  }
  
  global_secondary_index {
    name     = "status-index"
    hash_key = "status"
    
    # Project only necessary attributes
    projection_type    = "INCLUDE"
    non_key_attributes = ["created_at", "updated_at"]
  }
}
```

### ElastiCache Optimization
```hcl
# elasticache-optimization.tf
resource "aws_elasticache_replication_group" "cost_optimized" {
  replication_group_id       = "cost-optimized-redis"
  description                = "Cost optimized Redis cluster"
  
  # Right-size nodes
  node_type = "cache.t3.micro"
  
  # Cluster mode for better cost efficiency
  num_cache_clusters = 2
  
  # Use latest engine version
  engine_version = "7.0"
  
  # Optimize backup settings
  snapshot_retention_limit = 3
  snapshot_window         = "03:00-05:00"
  
  # Maintenance window
  maintenance_window = "sun:05:00-sun:07:00"
  
  # Security
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  
  # Subnet group
  subnet_group_name = aws_elasticache_subnet_group.main.name
  
  tags = {
    Environment = var.environment
    CostCenter  = "cache"
  }
}
```

## Networking Cost Optimization

### VPC and Data Transfer Optimization
```hcl
# networking-cost-optimization.tf
# VPC Endpoints to reduce NAT Gateway costs
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id
  
  tags = {
    Name = "s3-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id
  
  tags = {
    Name = "dynamodb-vpc-endpoint"
  }
}

# Interface endpoints for other services
resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
  
  tags = {
    Name = "ec2-vpc-endpoint"
  }
}

# Optimize NAT Gateway usage
resource "aws_nat_gateway" "main" {
  count         = var.single_nat_gateway ? 1 : length(aws_subnet.public)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  
  tags = {
    Name = "nat-gateway-${count.index + 1}"
  }
}
```

### CloudFront Cost Optimization
```hcl
# cloudfront-optimization.tf
resource "aws_cloudfront_distribution" "cost_optimized" {
  origin {
    domain_name = aws_s3_bucket.content.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.content.id}"
    
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }
  
  enabled             = true
  default_root_object = "index.html"
  
  # Use price class to control costs
  price_class = "PriceClass_100"  # US, Canada, Europe only
  
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.content.id}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    
    # Optimize caching
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  
  # Geographic restrictions to control costs
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  
  tags = {
    Environment = var.environment
    CostCenter  = "cdn"
  }
}
```

### Load Balancer Optimization
```bash
#!/bin/bash
# load-balancer-optimization.sh

# Analyze ALB usage and costs
analyze_alb_usage() {
    echo "Analyzing Application Load Balancer usage..."
    
    # Get all ALBs
    aws elbv2 describe-load-balancers \
        --query 'LoadBalancers[*].[LoadBalancerName,LoadBalancerArn,CreatedTime,State.Code]' \
        --output table
    
    # Check for unused ALBs
    aws elbv2 describe-load-balancers \
        --query 'LoadBalancers[?State.Code==`active`]' \
        --output json | jq -r '.[] | select(.LoadBalancerName) | .LoadBalancerArn' | while read alb_arn; do
        
        # Check target groups
        TARGET_GROUPS=$(aws elbv2 describe-target-groups \
            --load-balancer-arn "$alb_arn" \
            --query 'TargetGroups[*].TargetGroupArn' \
            --output text)
        
        if [ -z "$TARGET_GROUPS" ]; then
            echo "WARNING: ALB $alb_arn has no target groups"
        else
            for tg in $TARGET_GROUPS; do
                HEALTHY_TARGETS=$(aws elbv2 describe-target-health \
                    --target-group-arn "$tg" \
                    --query 'TargetHealthDescriptions[?TargetHealth.State==`healthy`]' \
                    --output text | wc -l)
                
                if [ "$HEALTHY_TARGETS" -eq 0 ]; then
                    echo "WARNING: Target group $tg has no healthy targets"
                fi
            done
        fi
    done
}

# Optimize ALB configuration
optimize_alb_config() {
    echo "ALB Optimization Recommendations:"
    echo "1. Use ALB instead of CLB for better cost efficiency"
    echo "2. Consolidate multiple ALBs using host-based routing"
    echo "3. Use path-based routing to reduce ALB count"
    echo "4. Enable access logs only when needed"
    echo "5. Consider NLB for TCP traffic"
}
```

## Lambda and Serverless

### Lambda Cost Optimization
```python
# lambda-cost-optimizer.py
import boto3
import json
from datetime import datetime, timedelta

def analyze_lambda_costs():
    """Analyze Lambda function costs and usage"""
    lambda_client = boto3.client('lambda')
    cloudwatch = boto3.client('cloudwatch')
    
    # Get all Lambda functions
    functions = lambda_client.list_functions()
    
    cost_analysis = []
    
    for function in functions['Functions']:
        function_name = function['FunctionName']
        memory_size = function['MemorySize']
        timeout = function['Timeout']
        
        # Get invocation metrics
        end_time = datetime.utcnow()
        start_time = end_time - timedelta(days=30)
        
        invocations = cloudwatch.get_metric_statistics(
            Namespace='AWS/Lambda',
            MetricName='Invocations',
            Dimensions=[{'Name': 'FunctionName', 'Value': function_name}],
            StartTime=start_time,
            EndTime=end_time,
            Period=86400,
            Statistics=['Sum']
        )
        
        duration = cloudwatch.get_metric_statistics(
            Namespace='AWS/Lambda',
            MetricName='Duration',
            Dimensions=[{'Name': 'FunctionName', 'Value': function_name}],
            StartTime=start_time,
            EndTime=end_time,
            Period=86400,
            Statistics=['Average']
        )
        
        # Calculate costs
        total_invocations = sum([point['Sum'] for point in invocations['Datapoints']])
        avg_duration = sum([point['Average'] for point in duration['Datapoints']]) / len(duration['Datapoints']) if duration['Datapoints'] else 0
        
        # Lambda pricing (us-east-1)
        request_cost = total_invocations * 0.0000002  # $0.20 per 1M requests
        gb_seconds = (memory_size / 1024) * (avg_duration / 1000) * total_invocations
        compute_cost = gb_seconds * 0.0000166667  # $0.0000166667 per GB-second
        
        total_cost = request_cost + compute_cost
        
        cost_analysis.append({
            'function_name': function_name,
            'memory_size': memory_size,
            'timeout': timeout,
            'invocations': total_invocations,
            'avg_duration': avg_duration,
            'estimated_cost': total_cost,
            'optimization_potential': analyze_optimization_potential(memory_size, timeout, avg_duration)
        })
    
    return cost_analysis

def analyze_optimization_potential(memory_size, timeout, avg_duration):
    """Analyze optimization potential for Lambda function"""
    recommendations = []
    
    # Memory optimization
    if avg_duration > 0:
        memory_utilization = (avg_duration / (timeout * 1000)) * 100
        if memory_utilization < 50:
            recommendations.append(f"Consider reducing memory from {memory_size}MB")
    
    # Timeout optimization
    if avg_duration > 0 and timeout > (avg_duration / 1000) * 2:
        recommended_timeout = int((avg_duration / 1000) * 1.5)
        recommendations.append(f"Consider reducing timeout from {timeout}s to {recommended_timeout}s")
    
    return recommendations

# Lambda optimization configurations
lambda_optimizations = {
    "memory_optimization": {
        "description": "Right-size memory allocation",
        "strategies": [
            "Use AWS Lambda Power Tuning tool",
            "Monitor CloudWatch metrics for memory usage",
            "Test different memory configurations",
            "Consider Graviton2 processors for ARM workloads"
        ]
    },
    "cold_start_optimization": {
        "description": "Reduce cold start impact",
        "strategies": [
            "Use provisioned concurrency for critical functions",
            "Minimize deployment package size",
            "Use connection pooling",
            "Implement proper initialization code"
        ]
    },
    "cost_monitoring": {
        "description": "Monitor and alert on costs",
        "strategies": [
            "Set up CloudWatch alarms for cost thresholds",
            "Use AWS Cost Explorer for Lambda costs",
            "Implement cost allocation tags",
            "Regular cost reviews and optimization"
        ]
    }
}
```

### Step Functions Optimization
```json
{
  "Comment": "Cost-optimized Step Functions workflow",
  "StartAt": "OptimizedChoice",
  "States": {
    "OptimizedChoice": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.processingType",
          "StringEquals": "batch",
          "Next": "BatchProcessing"
        },
        {
          "Variable": "$.processingType",
          "StringEquals": "realtime",
          "Next": "RealtimeProcessing"
        }
      ],
      "Default": "DefaultProcessing"
    },
    "BatchProcessing": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "batch-processor",
        "Payload.$": "$"
      },
      "Retry": [
        {
          "ErrorEquals": ["Lambda.ServiceException", "Lambda.AWSLambdaException"],
          "IntervalSeconds": 2,
          "MaxAttempts": 3,
          "BackoffRate": 2.0
        }
      ],
      "End": true
    },
    "RealtimeProcessing": {
      "Type": "Parallel",
      "Branches": [
        {
          "StartAt": "ProcessA",
          "States": {
            "ProcessA": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "Parameters": {
                "FunctionName": "process-a",
                "Payload.$": "$"
              },
              "End": true
            }
          }
        },
        {
          "StartAt": "ProcessB",
          "States": {
            "ProcessB": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "Parameters": {
                "FunctionName": "process-b",
                "Payload.$": "$"
              },
              "End": true
            }
          }
        }
      ],
      "End": true
    },
    "DefaultProcessing": {
      "Type": "Wait",
      "Seconds": 1,
      "Next": "BatchProcessing"
    }
  }
}
```

## Monitoring and Analytics

### Cost Monitoring Setup
```hcl
# cost-monitoring.tf
resource "aws_budgets_budget" "monthly_cost" {
  name         = "monthly-cost-budget"
  budget_type  = "COST"
  limit_amount = "1000"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  
  cost_filters {
    service = ["Amazon Elastic Compute Cloud - Compute"]
  }
  
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }
  
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }
}

resource "aws_budgets_budget" "service_budget" {
  for_each = var.service_budgets
  
  name         = "${each.key}-budget"
  budget_type  = "COST"
  limit_amount = each.value.limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  
  cost_filters {
    service = [each.value.service]
  }
  
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }
}
```

### Cost Anomaly Detection
```hcl
# cost-anomaly-detection.tf
resource "aws_ce_anomaly_detector" "service_anomaly" {
  name         = "service-cost-anomaly"
  monitor_type = "DIMENSIONAL"

  specification {
    dimension_key           = "SERVICE"
    dimension_value_list    = ["Amazon Elastic Compute Cloud - Compute"]
    match_options          = ["EQUALS"]
    metric_name            = "BlendedCost"
  }
}

resource "aws_ce_anomaly_subscription" "anomaly_subscription" {
  name      = "cost-anomaly-subscription"
  frequency = "DAILY"
  
  monitor_arn_list = [
    aws_ce_anomaly_detector.service_anomaly.arn
  ]
  
  subscriber {
    type    = "EMAIL"
    address = var.alert_email
  }
  
  threshold_expression {
    and {
      dimension {
        key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
        values        = ["100"]
        match_options = ["GREATER_THAN_OR_EQUAL"]
      }
    }
  }
}
```

## Cost Management Tools

### AWS Cost Explorer Automation
```python
# cost-explorer-automation.py
import boto3
import json
from datetime import datetime, timedelta

def get_cost_and_usage():
    """Get cost and usage data from AWS Cost Explorer"""
    ce_client = boto3.client('ce')
    
    # Get last 30 days
    end_date = datetime.now().strftime('%Y-%m-%d')
    start_date = (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')
    
    response = ce_client.get_cost_and_usage(
        TimePeriod={
            'Start': start_date,
            'End': end_date
        },
        Granularity='DAILY',
        Metrics=['BlendedCost', 'UsageQuantity'],
        GroupBy=[
            {
                'Type': 'DIMENSION',
                'Key': 'SERVICE'
            }
        ]
    )
    
    return response

def get_rightsizing_recommendations():
    """Get EC2 rightsizing recommendations"""
    ce_client = boto3.client('ce')
    
    response = ce_client.get_rightsizing_recommendation(
        Service='AmazonEC2',
        Configuration={
            'BenefitsConsidered': True,
            'RecommendationTarget': 'SAME_INSTANCE_FAMILY'
        }
    )
    
    return response

def get_savings_plans_recommendations():
    """Get Savings Plans recommendations"""
    ce_client = boto3.client('ce')
    
    response = ce_client.get_savings_plans_purchase_recommendation(
        SavingsPlansType='COMPUTE_SP',
        TermInYears='ONE_YEAR',
        PaymentOption='NO_UPFRONT',
        LookbackPeriodInDays='SIXTY_DAYS'
    )
    
    return response

def generate_cost_report():
    """Generate comprehensive cost report"""
    cost_data = get_cost_and_usage()
    rightsizing = get_rightsizing_recommendations()
    savings_plans = get_savings_plans_recommendations()
    
    report = {
        'timestamp': datetime.now().isoformat(),
        'cost_summary': analyze_cost_trends(cost_data),
        'rightsizing_opportunities': analyze_rightsizing(rightsizing),
        'savings_plans_opportunities': analyze_savings_plans(savings_plans)
    }
    
    return report

def analyze_cost_trends(cost_data):
    """Analyze cost trends from Cost Explorer data"""
    services_cost = {}
    
    for result in cost_data['ResultsByTime']:
        for group in result['Groups']:
            service = group['Keys'][0]
            cost = float(group['Metrics']['BlendedCost']['Amount'])
            
            if service not in services_cost:
                services_cost[service] = []
            services_cost[service].append(cost)
    
    # Calculate trends
    trends = {}
    for service, costs in services_cost.items():
        if len(costs) > 1:
            trend = (costs[-1] - costs[0]) / costs[0] * 100
            trends[service] = {
                'total_cost': sum(costs),
                'trend_percentage': trend,
                'recommendation': 'investigate' if trend > 20 else 'monitor'
            }
    
    return trends
```

### Automated Cost Optimization
```bash
#!/bin/bash
# automated-cost-optimization.sh

# Automated cost optimization script
optimize_costs() {
    echo "Starting automated cost optimization..."
    
    # 1. Stop unused EC2 instances
    stop_unused_instances
    
    # 2. Delete unattached EBS volumes
    cleanup_ebs_volumes
    
    # 3. Optimize S3 storage classes
    optimize_s3_storage
    
    # 4. Clean up old snapshots
    cleanup_old_snapshots
    
    # 5. Optimize RDS instances
    optimize_rds_instances
    
    echo "Cost optimization completed"
}

stop_unused_instances() {
    echo "Checking for unused EC2 instances..."
    
    # Get instances with low CPU utilization (< 5% for 7 days)
    aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running" \
        --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Environment`].Value|[0]]' \
        --output text | while read instance_id environment; do
        
        if [ "$environment" != "production" ]; then
            # Check CPU utilization
            AVG_CPU=$(aws cloudwatch get-metric-statistics \
                --namespace AWS/EC2 \
                --metric-name CPUUtilization \
                --dimensions Name=InstanceId,Value=$instance_id \
                --start-time $(date -u -d "7 days ago" +%Y-%m-%dT%H:%M:%S) \
                --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
                --period 3600 \
                --statistics Average \
                --query 'Datapoints[].Average' \
                --output text | awk '{sum+=$1; count++} END {if(count>0) print sum/count; else print 0}')
            
            if (( $(echo "$AVG_CPU < 5" | bc -l) )); then
                echo "Stopping underutilized instance: $instance_id (CPU: $AVG_CPU%)"
                # aws ec2 stop-instances --instance-ids $instance_id
            fi
        fi
    done
}

cleanup_ebs_volumes() {
    echo "Cleaning up unattached EBS volumes..."
    
    # Find volumes older than 7 days
    aws ec2 describe-volumes \
        --filters Name=status,Values=available \
        --query 'Volumes[?CreateTime<=`2023-01-01`].[VolumeId,CreateTime]' \
        --output text | while read volume_id create_time; do
        
        echo "Found unattached volume: $volume_id (Created: $create_time)"
        # aws ec2 delete-volume --volume-id $volume_id
    done
}

optimize_s3_storage() {
    echo "Optimizing S3 storage classes..."
    
    # This would typically involve analyzing S3 access patterns
    # and applying appropriate lifecycle policies
    aws s3api list-buckets --query 'Buckets[].Name' --output text | while read bucket; do
        echo "Analyzing bucket: $bucket"
        
        # Check if lifecycle policy exists
        LIFECYCLE=$(aws s3api get-bucket-lifecycle-configuration --bucket $bucket 2>/dev/null)
        
        if [ $? -ne 0 ]; then
            echo "  No lifecycle policy found for $bucket"
            # Could automatically apply a default lifecycle policy
        fi
    done
}

cleanup_old_snapshots() {
    echo "Cleaning up old snapshots..."
    
    # Find snapshots older than 30 days
    aws ec2 describe-snapshots \
        --owner-ids self \
        --query 'Snapshots[?StartTime<=`2023-01-01`].[SnapshotId,StartTime,Description]' \
        --output text | while read snapshot_id start_time description; do
        
        echo "Found old snapshot: $snapshot_id (Created: $start_time)"
        # aws ec2 delete-snapshot --snapshot-id $snapshot_id
    done
}

optimize_rds_instances() {
    echo "Optimizing RDS instances..."
    
    # Check for oversized RDS instances
    aws rds describe-db-instances \
        --query 'DBInstances[].[DBInstanceIdentifier,DBInstanceClass,DBInstanceStatus]' \
        --output text | while read db_id instance_class status; do
        
        if [ "$status" = "available" ]; then
            echo "Analyzing RDS instance: $db_id ($instance_class)"
            
            # Get CPU utilization
            AVG_CPU=$(aws cloudwatch get-metric-statistics \
                --namespace AWS/RDS \
                --metric-name CPUUtilization \
                --dimensions Name=DBInstanceIdentifier,Value=$db_id \
                --start-time $(date -u -d "7 days ago" +%Y-%m-%dT%H:%M:%S) \
                --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
                --period 3600 \
                --statistics Average \
                --query 'Datapoints[].Average' \
                --output text | awk '{sum+=$1; count++} END {if(count>0) print sum/count; else print 0}')
            
            if (( $(echo "$AVG_CPU < 20" | bc -l) )); then
                echo "  Low CPU utilization: $AVG_CPU% - Consider downsizing"
            fi
        fi
    done
}

# Schedule this script to run daily
# 0 2 * * * /path/to/automated-cost-optimization.sh
```

## Automation and Governance

### Cost Governance Policies
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyExpensiveInstances",
      "Effect": "Deny",
      "Action": [
        "ec2:RunInstances"
      ],
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "ec2:InstanceType": [
            "x1e.xlarge",
            "x1e.2xlarge",
            "x1e.4xlarge",
            "x1e.8xlarge",
            "x1e.16xlarge",
            "x1e.32xlarge"
          ]
        }
      }
    },
    {
      "Sid": "RequireTagsForResources",
      "Effect": "Deny",
      "Action": [
        "ec2:RunInstances",
        "rds:CreateDBInstance",
        "s3:CreateBucket"
      ],
      "Resource": "*",
      "Condition": {
        "Null": {
          "aws:RequestedRegion": "false"
        },
        "ForAllValues:StringEquals": {
          "aws:TagKeys": [
            "Environment",
            "CostCenter",
            "Owner"
          ]
        }
      }
    },
    {
      "Sid": "RestrictRegions",
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": [
            "us-east-1",
            "us-west-2",
            "eu-west-1"
          ]
        }
      }
    }
  ]
}
```

### Automated Resource Tagging
```hcl
# automated-tagging.tf
resource "aws_config_configuration_recorder" "main" {
  name     = "cost-optimization-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_config_rule" "required_tags" {
  name = "required-tags"

  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }

  input_parameters = jsonencode({
    tag1Key = "Environment"
    tag2Key = "CostCenter"
    tag3Key = "Owner"
  })

  depends_on = [aws_config_configuration_recorder.main]
}

# Lambda function for auto-tagging
resource "aws_lambda_function" "auto_tagger" {
  filename         = "auto_tagger.zip"
  function_name    = "auto-tagger"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 60

  environment {
    variables = {
      DEFAULT_TAGS = jsonencode({
        Environment = "untagged"
        CostCenter  = "unknown"
        Owner       = "system"
      })
    }
  }
}

# EventBridge rule for auto-tagging
resource "aws_cloudwatch_event_rule" "resource_creation" {
  name = "resource-creation-rule"

  event_pattern = jsonencode({
    source      = ["aws.ec2", "aws.rds", "aws.s3"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["ec2.amazonaws.com", "rds.amazonaws.com", "s3.amazonaws.com"]
      eventName   = ["RunInstances", "CreateDBInstance", "CreateBucket"]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.resource_creation.name
  target_id = "AutoTaggerTarget"
  arn       = aws_lambda_function.auto_tagger.arn
}
```

### Cost Optimization Dashboard
```python
# cost-dashboard.py
import boto3
import json
from datetime import datetime, timedelta

class CostOptimizationDashboard:
    def __init__(self):
        self.ce_client = boto3.client('ce')
        self.ec2_client = boto3.client('ec2')
        self.rds_client = boto3.client('rds')
        
    def generate_dashboard_data(self):
        """Generate comprehensive cost optimization dashboard data"""
        return {
            'cost_summary': self.get_cost_summary(),
            'savings_opportunities': self.get_savings_opportunities(),
            'resource_utilization': self.get_resource_utilization(),
            'recommendations': self.get_recommendations(),
            'trends': self.get_cost_trends()
        }
    
    def get_cost_summary(self):
        """Get current month cost summary"""
        start_date = datetime.now().replace(day=1).strftime('%Y-%m-%d')
        end_date = datetime.now().strftime('%Y-%m-%d')
        
        response = self.ce_client.get_cost_and_usage(
            TimePeriod={'Start': start_date, 'End': end_date},
            Granularity='MONTHLY',
            Metrics=['BlendedCost'],
            GroupBy=[{'Type': 'DIMENSION', 'Key': 'SERVICE'}]
        )
        
        return response
    
    def get_savings_opportunities(self):
        """Identify potential savings opportunities"""
        opportunities = []
        
        # Reserved Instance recommendations
        ri_recommendations = self.ce_client.get_reservation_purchase_recommendation(
            Service='AmazonEC2'
        )
        opportunities.append({
            'type': 'Reserved Instances',
            'potential_savings': ri_recommendations.get('Recommendations', [])
        })
        
        # Rightsizing recommendations
        rightsizing = self.ce_client.get_rightsizing_recommendation(
            Service='AmazonEC2'
        )
        opportunities.append({
            'type': 'EC2 Rightsizing',
            'potential_savings': rightsizing.get('RightsizingRecommendations', [])
        })
        
        return opportunities
    
    def get_resource_utilization(self):
        """Get resource utilization metrics"""
        # This would integrate with CloudWatch to get actual utilization
        return {
            'ec2_utilization': self.get_ec2_utilization(),
            'rds_utilization': self.get_rds_utilization(),
            'storage_utilization': self.get_storage_utilization()
        }
    
    def get_recommendations(self):
        """Generate cost optimization recommendations"""
        recommendations = []
        
        # Analyze unattached volumes
        volumes = self.ec2_client.describe_volumes(
            Filters=[{'Name': 'status', 'Values': ['available']}]
        )
        
        if volumes['Volumes']:
            recommendations.append({
                'category': 'Storage',
                'type': 'Unattached EBS Volumes',
                'count': len(volumes['Volumes']),
                'action': 'Delete unused volumes',
                'potential_savings': len(volumes['Volumes']) * 10  # Estimated
            })
        
        return recommendations

# Usage
dashboard = CostOptimizationDashboard()
data = dashboard.generate_dashboard_data()
print(json.dumps(data, indent=2, default=str))
```

This comprehensive cost optimization guide provides strategies and tools for optimizing costs across all major AWS services, with practical implementations and automation scripts for continuous cost management.