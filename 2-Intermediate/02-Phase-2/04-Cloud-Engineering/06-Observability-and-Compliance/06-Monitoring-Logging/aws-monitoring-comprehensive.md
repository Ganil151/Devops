# AWS Monitoring and Logging Guide for DevOps Engineers

## Overview

AWS provides comprehensive monitoring and logging services that enable DevOps teams to gain visibility into their infrastructure, applications, and services. This guide covers CloudWatch, CloudTrail, X-Ray, and other monitoring tools essential for maintaining reliable systems.

## CloudWatch - Metrics and Monitoring

### CloudWatch Metrics

```bash
# List available metrics
aws cloudwatch list-metrics --namespace AWS/EC2

# Get metric statistics
aws cloudwatch get-metric-statistics \
    --namespace AWS/EC2 \
    --metric-name CPUUtilization \
    --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
    --statistics Average,Maximum \
    --start-time 2024-01-15T00:00:00Z \
    --end-time 2024-01-15T23:59:59Z \
    --period 3600

# Put custom metric data
aws cloudwatch put-metric-data \
    --namespace DevOps/Application \
    --metric-data MetricName=ActiveUsers,Value=150,Unit=Count,Dimensions=Environment=Production,Application=WebApp

# List metrics with specific dimensions
aws cloudwatch list-metrics \
    --namespace DevOps/Application \
    --dimensions Name=Environment,Value=Production
```

### CloudWatch Alarms

```bash
# Create CPU utilization alarm
aws cloudwatch put-metric-alarm \
    --alarm-name "DevOps-High-CPU-Utilization" \
    --alarm-description "Alarm when CPU exceeds 80%" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
    --evaluation-periods 2 \
    --alarm-actions arn:aws:sns:us-east-1:123456789012:devops-alerts \
    --ok-actions arn:aws:sns:us-east-1:123456789012:devops-alerts \
    --treat-missing-data notBreaching

# Create composite alarm
aws cloudwatch put-composite-alarm \
    --alarm-name "DevOps-System-Health" \
    --alarm-description "Overall system health alarm" \
    --alarm-rule "(ALARM('DevOps-High-CPU-Utilization') OR ALARM('DevOps-High-Memory-Usage'))" \
    --actions-enabled \
    --alarm-actions arn:aws:sns:us-east-1:123456789012:devops-critical-alerts

# Create anomaly detector
aws cloudwatch put-anomaly-detector \
    --namespace AWS/EC2 \
    --metric-name CPUUtilization \
    --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
    --stat Average

# Create anomaly alarm
aws cloudwatch put-metric-alarm \
    --alarm-name "DevOps-CPU-Anomaly" \
    --alarm-description "Alarm for CPU anomaly detection" \
    --actions-enabled \
    --alarm-actions arn:aws:sns:us-east-1:123456789012:devops-alerts \
    --evaluation-periods 2 \
    --datapoints-to-alarm 2 \
    --threshold-metric-id ad1 \
    --comparison-operator LessThanLowerOrGreaterThanUpperThreshold \
    --metrics '[
        {
            "Id": "m1",
            "MetricStat": {
                "Metric": {
                    "Namespace": "AWS/EC2",
                    "MetricName": "CPUUtilization",
                    "Dimensions": [
                        {
                            "Name": "InstanceId",
                            "Value": "i-1234567890abcdef0"
                        }
                    ]
                },
                "Period": 300,
                "Stat": "Average"
            }
        },
        {
            "Id": "ad1",
            "AnomalyDetector": {
                "MetricMathAnomalyDetector": {
                    "MetricDataQueries": [
                        {
                            "Id": "m1",
                            "MetricStat": {
                                "Metric": {
                                    "Namespace": "AWS/EC2",
                                    "MetricName": "CPUUtilization",
                                    "Dimensions": [
                                        {
                                            "Name": "InstanceId",
                                            "Value": "i-1234567890abcdef0"
                                        }
                                    ]
                                },
                                "Period": 300,
                                "Stat": "Average"
                            }
                        }
                    ]
                }
            }
        }
    ]'

# List alarms
aws cloudwatch describe-alarms \
    --state-value ALARM \
    --output table

# Delete alarm
aws cloudwatch delete-alarms \
    --alarm-names "DevOps-High-CPU-Utilization"
```

### CloudWatch Dashboards

```bash
# Create dashboard
aws cloudwatch put-dashboard \
    --dashboard-name "DevOps-Infrastructure-Dashboard" \
    --dashboard-body '{
        "widgets": [
            {
                "type": "metric",
                "x": 0,
                "y": 0,
                "width": 12,
                "height": 6,
                "properties": {
                    "metrics": [
                        ["AWS/EC2", "CPUUtilization", "InstanceId", "i-1234567890abcdef0"],
                        [".", "NetworkIn", ".", "."],
                        [".", "NetworkOut", ".", "."]
                    ],
                    "period": 300,
                    "stat": "Average",
                    "region": "us-east-1",
                    "title": "EC2 Instance Metrics"
                }
            },
            {
                "type": "log",
                "x": 0,
                "y": 6,
                "width": 24,
                "height": 6,
                "properties": {
                    "query": "SOURCE \"/aws/lambda/my-function\" | fields @timestamp, @message | sort @timestamp desc | limit 20",
                    "region": "us-east-1",
                    "title": "Recent Lambda Logs"
                }
            }
        ]
    }'

# List dashboards
aws cloudwatch list-dashboards

# Get dashboard
aws cloudwatch get-dashboard \
    --dashboard-name "DevOps-Infrastructure-Dashboard"

# Delete dashboard
aws cloudwatch delete-dashboards \
    --dashboard-names "DevOps-Infrastructure-Dashboard"
```

## CloudWatch Logs

### Log Groups and Streams

```bash
# Create log group
aws logs create-log-group \
    --log-group-name "/aws/devops/application" \
    --retention-in-days 30 \
    --tags Team=DevOps,Environment=Production

# Create log stream
aws logs create-log-stream \
    --log-group-name "/aws/devops/application" \
    --log-stream-name "application-server-1"

# Put log events
aws logs put-log-events \
    --log-group-name "/aws/devops/application" \
    --log-stream-name "application-server-1" \
    --log-events timestamp=1642694400000,message="Application started successfully" \
                 timestamp=1642694460000,message="Database connection established"

# Get log events
aws logs get-log-events \
    --log-group-name "/aws/devops/application" \
    --log-stream-name "application-server-1" \
    --start-time 1642694400000 \
    --end-time 1642780800000

# Filter log events
aws logs filter-log-events \
    --log-group-name "/aws/devops/application" \
    --filter-pattern "ERROR" \
    --start-time 1642694400000 \
    --end-time 1642780800000

# List log groups
aws logs describe-log-groups \
    --log-group-name-prefix "/aws/devops" \
    --output table

# Delete log group
aws logs delete-log-group \
    --log-group-name "/aws/devops/application"
```

### CloudWatch Logs Insights

```bash
# Start query
aws logs start-query \
    --log-group-name "/aws/devops/application" \
    --start-time 1642694400 \
    --end-time 1642780800 \
    --query-string 'fields @timestamp, @message
    | filter @message like /ERROR/
    | sort @timestamp desc
    | limit 20'

# Get query results
aws logs get-query-results \
    --query-id 12345678-1234-1234-1234-123456789012

# Stop query
aws logs stop-query \
    --query-id 12345678-1234-1234-1234-123456789012

# Advanced query examples
# Error analysis
aws logs start-query \
    --log-group-names "/aws/devops/application" "/aws/devops/database" \
    --start-time 1642694400 \
    --end-time 1642780800 \
    --query-string 'fields @timestamp, @logStream, @message
    | filter @message like /ERROR|FATAL|Exception/
    | stats count() by bin(5m)
    | sort @timestamp desc'

# Performance analysis
aws logs start-query \
    --log-group-name "/aws/lambda/my-function" \
    --start-time 1642694400 \
    --end-time 1642780800 \
    --query-string 'filter @type = "REPORT"
    | fields @requestId, @duration, @billedDuration, @memorySize, @maxMemoryUsed
    | stats avg(@duration), max(@duration), min(@duration) by bin(5m)'

# Custom application metrics
aws logs start-query \
    --log-group-name "/aws/devops/application" \
    --start-time 1642694400 \
    --end-time 1642780800 \
    --query-string 'fields @timestamp, @message
    | parse @message "user_id=* action=* response_time=*" as user_id, action, response_time
    | filter action = "login"
    | stats avg(response_time), count() by bin(1h)'
```

### Log Subscriptions and Filters

```bash
# Create subscription filter to Lambda
aws logs put-subscription-filter \
    --log-group-name "/aws/devops/application" \
    --filter-name "ErrorProcessor" \
    --filter-pattern "ERROR" \
    --destination-arn arn:aws:lambda:us-east-1:123456789012:function:ProcessErrors

# Create subscription filter to Kinesis
aws logs put-subscription-filter \
    --log-group-name "/aws/devops/application" \
    --filter-name "LogStreaming" \
    --filter-pattern "" \
    --destination-arn arn:aws:kinesis:us-east-1:123456789012:stream/log-stream \
    --role-arn arn:aws:iam::123456789012:role/CloudWatchLogsRole

# Create metric filter
aws logs put-metric-filter \
    --log-group-name "/aws/devops/application" \
    --filter-name "ErrorCount" \
    --filter-pattern "ERROR" \
    --metric-transformations \
        metricName=ApplicationErrors,metricNamespace=DevOps/Application,metricValue=1,defaultValue=0

# List subscription filters
aws logs describe-subscription-filters \
    --log-group-name "/aws/devops/application"

# Delete subscription filter
aws logs delete-subscription-filter \
    --log-group-name "/aws/devops/application" \
    --filter-name "ErrorProcessor"
```

## CloudTrail - API Auditing

### CloudTrail Configuration

```bash
# Create CloudTrail
aws cloudtrail create-trail \
    --name DevOps-Audit-Trail \
    --s3-bucket-name devops-cloudtrail-logs \
    --s3-key-prefix cloudtrail-logs \
    --include-global-service-events \
    --is-multi-region-trail \
    --enable-log-file-validation \
    --event-selectors '[
        {
            "ReadWriteType": "All",
            "IncludeManagementEvents": true,
            "DataResources": [
                {
                    "Type": "AWS::S3::Object",
                    "Values": ["arn:aws:s3:::devops-*/*"]
                },
                {
                    "Type": "AWS::Lambda::Function",
                    "Values": ["arn:aws:lambda:*:*:function:devops-*"]
                }
            ]
        }
    ]'

# Start logging
aws cloudtrail start-logging \
    --name DevOps-Audit-Trail

# Get trail status
aws cloudtrail get-trail-status \
    --name DevOps-Audit-Trail

# Update trail
aws cloudtrail update-trail \
    --name DevOps-Audit-Trail \
    --s3-bucket-name devops-cloudtrail-logs-new \
    --include-global-service-events \
    --is-multi-region-trail

# Create advanced event selectors
aws cloudtrail put-event-selectors \
    --trail-name DevOps-Audit-Trail \
    --advanced-event-selectors '[
        {
            "Name": "S3 Data Events",
            "FieldSelectors": [
                {
                    "Field": "eventCategory",
                    "Equals": ["Data"]
                },
                {
                    "Field": "resources.type",
                    "Equals": ["AWS::S3::Object"]
                },
                {
                    "Field": "resources.ARN",
                    "StartsWith": ["arn:aws:s3:::devops-"]
                }
            ]
        },
        {
            "Name": "Lambda Invocations",
            "FieldSelectors": [
                {
                    "Field": "eventCategory",
                    "Equals": ["Data"]
                },
                {
                    "Field": "resources.type",
                    "Equals": ["AWS::Lambda::Function"]
                },
                {
                    "Field": "eventName",
                    "Equals": ["Invoke"]
                }
            ]
        }
    ]'
```

### CloudTrail Event Analysis

```bash
# Lookup events by attribute
aws cloudtrail lookup-events \
    --lookup-attributes AttributeKey=EventName,AttributeValue=CreateUser \
    --start-time 2024-01-01 \
    --end-time 2024-01-31

# Lookup events by user
aws cloudtrail lookup-events \
    --lookup-attributes AttributeKey=Username,AttributeValue=devops-engineer \
    --start-time 2024-01-15 \
    --end-time 2024-01-16

# Lookup events by resource
aws cloudtrail lookup-events \
    --lookup-attributes AttributeKey=ResourceName,AttributeValue=i-1234567890abcdef0 \
    --start-time 2024-01-15 \
    --end-time 2024-01-16

# Complex event analysis with CloudWatch Logs Insights
aws logs start-query \
    --log-group-name "CloudTrail/DevOpsAuditTrail" \
    --start-time 1642694400 \
    --end-time 1642780800 \
    --query-string 'fields @timestamp, eventName, sourceIPAddress, userIdentity.type, userIdentity.userName, errorCode, errorMessage
    | filter eventName like /^(Create|Delete|Modify|Update)/
    | filter errorCode exists
    | stats count() by eventName, errorCode
    | sort count desc'

# Security analysis
aws logs start-query \
    --log-group-name "CloudTrail/DevOpsAuditTrail" \
    --start-time 1642694400 \
    --end-time 1642780800 \
    --query-string 'fields @timestamp, eventName, sourceIPAddress, userIdentity.userName, userAgent
    | filter sourceIPAddress not like /^10\.|^172\.(1[6-9]|2[0-9]|3[01])\.|^192\.168\./
    | filter eventName in ["ConsoleLogin", "AssumeRole", "CreateUser", "DeleteUser"]
    | sort @timestamp desc'
```

## AWS X-Ray - Distributed Tracing

### X-Ray Configuration

```bash
# Enable X-Ray tracing for Lambda function
aws lambda update-function-configuration \
    --function-name devops-processor \
    --tracing-config Mode=Active

# Create X-Ray sampling rule
aws xray create-sampling-rule \
    --sampling-rule '{
        "rule_name": "DevOpsApplicationSampling",
        "priority": 9000,
        "fixed_rate": 0.1,
        "reservoir_size": 1,
        "service_name": "devops-application",
        "service_type": "*",
        "host": "*",
        "method": "*",
        "url_path": "*",
        "version": 1
    }'

# Get sampling rules
aws xray get-sampling-rules

# Update sampling rule
aws xray update-sampling-rule \
    --sampling-rule-update '{
        "rule_name": "DevOpsApplicationSampling",
        "fixed_rate": 0.2,
        "reservoir_size": 2
    }'

# Get service map
aws xray get-service-map \
    --start-time 2024-01-15T00:00:00Z \
    --end-time 2024-01-15T23:59:59Z

# Get trace summaries
aws xray get-trace-summaries \
    --time-range-type TimeRangeByStartTime \
    --start-time 2024-01-15T00:00:00Z \
    --end-time 2024-01-15T23:59:59Z \
    --filter-expression 'service("devops-application") AND error'

# Get specific trace
aws xray batch-get-traces \
    --trace-ids 1-5e1b4151-1234567890abcdef
```

### X-Ray Insights and Analytics

```bash
# Get time series service statistics
aws xray get-time-series-service-statistics \
    --start-time 2024-01-15T00:00:00Z \
    --end-time 2024-01-15T23:59:59Z \
    --group-name "DevOpsApplication" \
    --entity-selector-expression 'service("devops-application")'

# Create group for filtering
aws xray create-group \
    --group-name "DevOpsErrors" \
    --filter-expression 'service("devops-application") AND error'

# Get insights
aws xray get-insight-summaries \
    --start-time 2024-01-15T00:00:00Z \
    --end-time 2024-01-15T23:59:59Z \
    --states Active,Closed

# Get insight events
aws xray get-insight-events \
    --insight-id 12345678-1234-1234-1234-123456789012
```

## Application Performance Monitoring

### CloudWatch Application Insights

```bash
# Create application
aws application-insights create-application \
    --resource-group-name "DevOps-Application-Resources" \
    --ops-center-enabled \
    --cwe-monitor-enabled \
    --ops-item-sns-topic-arn arn:aws:sns:us-east-1:123456789012:devops-alerts

# List applications
aws application-insights list-applications

# Describe application
aws application-insights describe-application \
    --resource-group-name "DevOps-Application-Resources"

# List problems
aws application-insights list-problems \
    --resource-group-name "DevOps-Application-Resources" \
    --start-time 2024-01-15T00:00:00Z \
    --end-time 2024-01-15T23:59:59Z

# Describe problem
aws application-insights describe-problem \
    --problem-id p-1234567890abcdef0
```

### Custom Metrics and Monitoring

```python
# Python example for custom metrics
import boto3
import time
from datetime import datetime

cloudwatch = boto3.client('cloudwatch')

def put_custom_metric(metric_name, value, unit='Count', namespace='DevOps/Application'):
    """Put custom metric to CloudWatch"""
    try:
        response = cloudwatch.put_metric_data(
            Namespace=namespace,
            MetricData=[
                {
                    'MetricName': metric_name,
                    'Value': value,
                    'Unit': unit,
                    'Timestamp': datetime.utcnow(),
                    'Dimensions': [
                        {
                            'Name': 'Environment',
                            'Value': 'Production'
                        },
                        {
                            'Name': 'Application',
                            'Value': 'WebApp'
                        }
                    ]
                }
            ]
        )
        print(f"Metric {metric_name} sent successfully")
        return response
    except Exception as e:
        print(f"Error sending metric: {e}")

# Usage examples
put_custom_metric('ActiveUsers', 150)
put_custom_metric('ResponseTime', 250, 'Milliseconds')
put_custom_metric('ErrorRate', 0.02, 'Percent')
```

### Monitoring Automation Scripts

```bash
#!/bin/bash
# monitoring-setup.sh - Automated monitoring setup

PROJECT_NAME="devops"
ENVIRONMENT="production"
SNS_TOPIC_ARN="arn:aws:sns:us-east-1:123456789012:devops-alerts"

# Create CloudWatch alarms for EC2 instances
create_ec2_alarms() {
    local instance_id=$1
    local instance_name=$2
    
    # CPU Utilization Alarm
    aws cloudwatch put-metric-alarm \
        --alarm-name "${PROJECT_NAME}-${instance_name}-High-CPU" \
        --alarm-description "High CPU utilization for ${instance_name}" \
        --metric-name CPUUtilization \
        --namespace AWS/EC2 \
        --statistic Average \
        --period 300 \
        --threshold 80 \
        --comparison-operator GreaterThanThreshold \
        --dimensions Name=InstanceId,Value=${instance_id} \
        --evaluation-periods 2 \
        --alarm-actions ${SNS_TOPIC_ARN}
    
    # Memory Utilization Alarm (requires CloudWatch agent)
    aws cloudwatch put-metric-alarm \
        --alarm-name "${PROJECT_NAME}-${instance_name}-High-Memory" \
        --alarm-description "High memory utilization for ${instance_name}" \
        --metric-name MemoryUtilization \
        --namespace CWAgent \
        --statistic Average \
        --period 300 \
        --threshold 85 \
        --comparison-operator GreaterThanThreshold \
        --dimensions Name=InstanceId,Value=${instance_id} \
        --evaluation-periods 2 \
        --alarm-actions ${SNS_TOPIC_ARN}
    
    # Disk Space Alarm
    aws cloudwatch put-metric-alarm \
        --alarm-name "${PROJECT_NAME}-${instance_name}-Low-Disk-Space" \
        --alarm-description "Low disk space for ${instance_name}" \
        --metric-name DiskSpaceUtilization \
        --namespace CWAgent \
        --statistic Average \
        --period 300 \
        --threshold 90 \
        --comparison-operator GreaterThanThreshold \
        --dimensions Name=InstanceId,Value=${instance_id},Name=Filesystem,Value=/ \
        --evaluation-periods 1 \
        --alarm-actions ${SNS_TOPIC_ARN}
}

# Create RDS alarms
create_rds_alarms() {
    local db_instance_id=$1
    
    # CPU Utilization
    aws cloudwatch put-metric-alarm \
        --alarm-name "${PROJECT_NAME}-RDS-High-CPU" \
        --alarm-description "High CPU utilization for RDS" \
        --metric-name CPUUtilization \
        --namespace AWS/RDS \
        --statistic Average \
        --period 300 \
        --threshold 80 \
        --comparison-operator GreaterThanThreshold \
        --dimensions Name=DBInstanceIdentifier,Value=${db_instance_id} \
        --evaluation-periods 2 \
        --alarm-actions ${SNS_TOPIC_ARN}
    
    # Database Connections
    aws cloudwatch put-metric-alarm \
        --alarm-name "${PROJECT_NAME}-RDS-High-Connections" \
        --alarm-description "High database connections" \
        --metric-name DatabaseConnections \
        --namespace AWS/RDS \
        --statistic Average \
        --period 300 \
        --threshold 80 \
        --comparison-operator GreaterThanThreshold \
        --dimensions Name=DBInstanceIdentifier,Value=${db_instance_id} \
        --evaluation-periods 2 \
        --alarm-actions ${SNS_TOPIC_ARN}
}

# Create ALB alarms
create_alb_alarms() {
    local load_balancer_name=$1
    
    # Target Response Time
    aws cloudwatch put-metric-alarm \
        --alarm-name "${PROJECT_NAME}-ALB-High-Response-Time" \
        --alarm-description "High response time for ALB" \
        --metric-name TargetResponseTime \
        --namespace AWS/ApplicationELB \
        --statistic Average \
        --period 300 \
        --threshold 1 \
        --comparison-operator GreaterThanThreshold \
        --dimensions Name=LoadBalancer,Value=${load_balancer_name} \
        --evaluation-periods 2 \
        --alarm-actions ${SNS_TOPIC_ARN}
    
    # HTTP 5xx Errors
    aws cloudwatch put-metric-alarm \
        --alarm-name "${PROJECT_NAME}-ALB-High-5xx-Errors" \
        --alarm-description "High 5xx error rate for ALB" \
        --metric-name HTTPCode_Target_5XX_Count \
        --namespace AWS/ApplicationELB \
        --statistic Sum \
        --period 300 \
        --threshold 10 \
        --comparison-operator GreaterThanThreshold \
        --dimensions Name=LoadBalancer,Value=${load_balancer_name} \
        --evaluation-periods 1 \
        --alarm-actions ${SNS_TOPIC_ARN}
}

# Get EC2 instances and create alarms
aws ec2 describe-instances \
    --filters "Name=tag:Environment,Values=${ENVIRONMENT}" "Name=instance-state-name,Values=running" \
    --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`].Value|[0]]' \
    --output text | while read instance_id instance_name; do
    echo "Creating alarms for instance: $instance_id ($instance_name)"
    create_ec2_alarms "$instance_id" "$instance_name"
done

echo "Monitoring setup completed successfully"
```

This comprehensive monitoring and logging guide provides DevOps engineers with the tools and knowledge needed to implement robust observability solutions using AWS native services.