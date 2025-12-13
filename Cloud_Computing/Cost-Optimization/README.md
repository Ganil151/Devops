# Cloud Cost Optimization

Comprehensive guide to cloud cost management, optimization strategies, and financial governance.

## Cost Management Fundamentals

### Cost Components
```yaml
Compute Costs:
  - Virtual machines
  - Container services
  - Serverless functions
  - Auto-scaling charges

Storage Costs:
  - Object storage
  - Block storage
  - Database storage
  - Backup storage

Network Costs:
  - Data transfer
  - Load balancers
  - VPN connections
  - CDN usage

Additional Services:
  - Monitoring tools
  - Security services
  - Management tools
  - Support plans
```

### Cost Optimization Principles
```yaml
Right-sizing:
  - Match resources to workload needs
  - Regular capacity reviews
  - Performance monitoring
  - Automated recommendations

Reserved Capacity:
  - Commit to long-term usage
  - Significant cost savings
  - Predictable workloads
  - Strategic planning

Auto-scaling:
  - Dynamic resource allocation
  - Pay for actual usage
  - Handle traffic spikes
  - Reduce idle resources
```

## AWS Cost Optimization

### Reserved Instances and Savings Plans
```bash
# View RI recommendations
aws ce get-reservation-recommendations \
  --service EC2-Instance \
  --lookback-period-in-days 60

# Purchase Reserved Instance
aws ec2 purchase-reserved-instances-offering \
  --reserved-instances-offering-id 12345678-1234-1234-1234-123456789012 \
  --instance-count 2

# Create Savings Plan
aws savingsplans create-savings-plan \
  --savings-plan-type Compute \
  --term-duration-in-years 1 \
  --payment-option NoUpfront \
  --commitment 10.50
```

### Cost Explorer and Budgets
```bash
# Get cost and usage data
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE

# Create budget
aws budgets create-budget \
  --account-id 123456789012 \
  --budget file://budget.json \
  --notifications-with-subscribers file://notifications.json

# Get rightsizing recommendations
aws ce get-rightsizing-recommendation \
  --service EC2-Instance \
  --configuration RecommendationTarget=SAME_INSTANCE_FAMILY
```

### Spot Instances and Auto Scaling
```yaml
# Auto Scaling with Spot Instances
Resources:
  LaunchTemplate:
    Type: AWS::EC2::LaunchTemplate
    Properties:
      LaunchTemplateData:
        ImageId: ami-12345678
        InstanceType: t3.medium
        InstanceMarketOptions:
          MarketType: spot
          SpotOptions:
            MaxPrice: "0.05"
            SpotInstanceType: one-time

  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      MixedInstancesPolicy:
        InstancesDistribution:
          OnDemandPercentage: 20
          SpotAllocationStrategy: diversified
        LaunchTemplate:
          LaunchTemplateSpecification:
            LaunchTemplateId: !Ref LaunchTemplate
            Version: !GetAtt LaunchTemplate.LatestVersionNumber
          Overrides:
            - InstanceType: t3.medium
            - InstanceType: t3.large
            - InstanceType: m5.large
```

## Azure Cost Optimization

### Reserved Instances and Hybrid Benefit
```bash
# View RI recommendations
az consumption reservation recommendation list \
  --resource-type VirtualMachines \
  --scope Subscription

# Purchase Reserved Instance
az reservations reservation-order purchase \
  --reservation-order-id 12345678-1234-1234-1234-123456789012 \
  --sku Standard_D2s_v3

# Enable Azure Hybrid Benefit
az vm update \
  --resource-group myRG \
  --name myVM \
  --license-type Windows_Server
```

### Cost Management and Budgets
```bash
# Create budget
az consumption budget create \
  --budget-name MyBudget \
  --amount 1000 \
  --time-grain Monthly \
  --start-date 2024-01-01 \
  --end-date 2024-12-31

# Get cost analysis
az consumption usage list \
  --start-date 2024-01-01 \
  --end-date 2024-01-31

# Create cost alert
az monitor action-group create \
  --resource-group myRG \
  --name CostAlert \
  --short-name CostAlert
```

### Azure Spot VMs
```bash
# Create Spot VM
az vm create \
  --resource-group myRG \
  --name mySpotVM \
  --image UbuntuLTS \
  --priority Spot \
  --max-price 0.05 \
  --eviction-policy Deallocate
```

## Google Cloud Cost Optimization

### Committed Use Discounts
```bash
# View commitment recommendations
gcloud compute commitments list

# Create commitment
gcloud compute commitments create my-commitment \
  --plan 12-month \
  --resources type=n1-standard-1,count=10 \
  --region us-central1

# View sustained use discounts
gcloud compute instances list \
  --format="table(name,zone,machineType,status,creationTimestamp)"
```

### Preemptible Instances
```bash
# Create preemptible instance
gcloud compute instances create my-preemptible-vm \
  --zone us-central1-a \
  --machine-type n1-standard-1 \
  --preemptible \
  --maintenance-policy TERMINATE

# Create instance template with preemptible VMs
gcloud compute instance-templates create preemptible-template \
  --machine-type n1-standard-1 \
  --preemptible \
  --image-family ubuntu-1804-lts \
  --image-project ubuntu-os-cloud
```

### BigQuery Cost Control
```sql
-- Set query cost controls
SELECT
  project_id,
  user_email,
  job_id,
  total_bytes_processed,
  total_bytes_billed
FROM `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
WHERE creation_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)
  AND total_bytes_billed > 1000000000  -- 1GB threshold
ORDER BY total_bytes_billed DESC;

-- Create cost-controlled dataset
CREATE SCHEMA my_dataset
OPTIONS (
  default_table_expiration_days = 30,
  max_time_travel_hours = 168
);
```

## Multi-Cloud Cost Management

### Cost Comparison Framework
```yaml
Cost Analysis Dimensions:
  Compute:
    - Instance types and pricing
    - Reserved capacity discounts
    - Spot/preemptible pricing
    - Auto-scaling capabilities

  Storage:
    - Storage tiers and pricing
    - Data transfer costs
    - Backup and archival costs
    - Performance requirements

  Network:
    - Bandwidth pricing
    - CDN costs
    - Inter-region transfer
    - Egress charges

  Services:
    - Managed service costs
    - Third-party integrations
    - Support and SLA costs
    - Compliance requirements
```

### Cost Monitoring Tools
```bash
# CloudHealth (Multi-cloud cost management)
curl -X GET "https://chapi.cloudhealthtech.com/v1/aws_accounts" \
  -H "Authorization: Bearer $API_TOKEN"

# Cloudability API
curl -X GET "https://api.cloudability.com/v3/costs" \
  -H "Authorization: Bearer $API_TOKEN" \
  -d "start_date=2024-01-01&end_date=2024-01-31"

# Custom cost tracking script
#!/bin/bash
# multi-cloud-costs.sh

# AWS costs
AWS_COST=$(aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
  --output text)

# Azure costs
AZURE_COST=$(az consumption usage list \
  --start-date 2024-01-01 \
  --end-date 2024-01-31 \
  --query '[].{cost:pretaxCost}' \
  --output tsv | awk '{sum+=$1} END {print sum}')

# GCP costs
GCP_COST=$(gcloud billing accounts list \
  --format="value(name)" | head -1 | \
  xargs -I {} gcloud alpha billing accounts get-billing-info \
  --billing-account={} --format="value(costAmount)")

echo "Total Multi-Cloud Costs:"
echo "AWS: $${AWS_COST}"
echo "Azure: $${AZURE_COST}"
echo "GCP: $${GCP_COST}"
```

## Cost Optimization Strategies

### Resource Right-Sizing
```bash
# AWS EC2 right-sizing analysis
#!/bin/bash
# rightsizing-analysis.sh

# Get instance utilization data
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-31T23:59:59Z \
  --period 3600 \
  --statistics Average

# Analyze and recommend
INSTANCES=$(aws ec2 describe-instances \
  --query 'Reservations[].Instances[].[InstanceId,InstanceType]' \
  --output text)

while read -r instance_id instance_type; do
  # Get average CPU utilization
  avg_cpu=$(aws cloudwatch get-metric-statistics \
    --namespace AWS/EC2 \
    --metric-name CPUUtilization \
    --dimensions Name=InstanceId,Value=$instance_id \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-31T23:59:59Z \
    --period 86400 \
    --statistics Average \
    --query 'Datapoints[].Value' \
    --output text | awk '{sum+=$1; count++} END {print sum/count}')
  
  if (( $(echo "$avg_cpu < 20" | bc -l) )); then
    echo "Instance $instance_id ($instance_type) is underutilized: ${avg_cpu}% CPU"
    echo "Consider downsizing or using Spot instances"
  fi
done <<< "$INSTANCES"
```

### Automated Cost Controls
```python
# Python cost control automation
import boto3
import json
from datetime import datetime, timedelta

def lambda_handler(event, context):
    ce_client = boto3.client('ce')
    ec2_client = boto3.client('ec2')
    
    # Get current month costs
    end_date = datetime.now().strftime('%Y-%m-%d')
    start_date = (datetime.now().replace(day=1)).strftime('%Y-%m-%d')
    
    response = ce_client.get_cost_and_usage(
        TimePeriod={'Start': start_date, 'End': end_date},
        Granularity='MONTHLY',
        Metrics=['BlendedCost']
    )
    
    current_cost = float(response['ResultsByTime'][0]['Total']['BlendedCost']['Amount'])
    budget_threshold = 1000.0  # $1000 budget
    
    if current_cost > budget_threshold * 0.8:  # 80% of budget
        # Stop non-production instances
        instances = ec2_client.describe_instances(
            Filters=[
                {'Name': 'tag:Environment', 'Values': ['dev', 'test']},
                {'Name': 'instance-state-name', 'Values': ['running']}
            ]
        )
        
        instance_ids = []
        for reservation in instances['Reservations']:
            for instance in reservation['Instances']:
                instance_ids.append(instance['InstanceId'])
        
        if instance_ids:
            ec2_client.stop_instances(InstanceIds=instance_ids)
            print(f"Stopped {len(instance_ids)} non-production instances")
    
    return {
        'statusCode': 200,
        'body': json.dumps(f'Current cost: ${current_cost:.2f}')
    }
```

### Cost Allocation and Chargeback
```yaml
Tagging Strategy:
  Required Tags:
    - Environment (prod/staging/dev)
    - Project (project-name)
    - Owner (team-name)
    - CostCenter (department)
    - Application (app-name)

Cost Allocation Rules:
  - Shared services allocation
  - Department chargeback
  - Project cost tracking
  - Resource utilization metrics

Reporting Framework:
  - Monthly cost reports
  - Department dashboards
  - Project cost analysis
  - Trend analysis
```

## Cost Governance

### Financial Operations (FinOps)
```yaml
FinOps Practices:
  Inform:
    - Cost visibility
    - Allocation accuracy
    - Benchmarking
    - Forecasting

  Optimize:
    - Right-sizing
    - Reserved capacity
    - Spot instances
    - Waste elimination

  Operate:
    - Continuous optimization
    - Automation
    - Governance policies
    - Cultural adoption
```

### Cost Policies and Controls
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "ec2:RunInstances"
      ],
      "Resource": "*",
      "Condition": {
        "ForAllValues:StringNotEquals": {
          "ec2:InstanceType": [
            "t3.micro",
            "t3.small",
            "t3.medium"
          ]
        }
      }
    },
    {
      "Effect": "Deny",
      "Action": [
        "rds:CreateDBInstance"
      ],
      "Resource": "*",
      "Condition": {
        "ForAllValues:StringNotEquals": {
          "rds:db-instance-class": [
            "db.t3.micro",
            "db.t3.small"
          ]
        }
      }
    }
  ]
}
```

This comprehensive guide provides strategies and tools for effective cloud cost optimization and financial governance across multiple cloud platforms.