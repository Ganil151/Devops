# Serverless Cost Optimization

## Overview

Cost optimization in serverless computing focuses on minimizing execution time, memory usage, and request frequency while maintaining performance and reliability.

## Cost Models

### AWS Lambda Pricing
- **Requests**: $0.20 per 1M requests
- **Duration**: $0.0000166667 per GB-second
- **Free Tier**: 1M requests and 400,000 GB-seconds per month

### Azure Functions Pricing
- **Consumption Plan**: Pay per execution
- **Premium Plan**: Pre-warmed instances
- **Dedicated Plan**: App Service pricing

### Google Cloud Functions Pricing
- **Invocations**: $0.40 per 1M invocations
- **Compute Time**: $0.0000025 per GB-second
- **Networking**: Egress charges apply

## Memory Optimization

### Right-Sizing Memory
```python
# Memory profiling example
import psutil
import time

def lambda_handler(event, context):
    start_memory = psutil.virtual_memory().used
    
    # Your function logic here
    result = process_data(event['data'])
    
    end_memory = psutil.virtual_memory().used
    memory_used = end_memory - start_memory
    
    print(f"Memory used: {memory_used / 1024 / 1024:.2f} MB")
    
    return {
        'statusCode': 200,
        'body': result,
        'memory_used_mb': memory_used / 1024 / 1024
    }
```

### Memory vs Performance Analysis
```bash
# AWS CLI command to test different memory configurations
for memory in 128 256 512 1024 2048; do
  aws lambda update-function-configuration \
    --function-name my-function \
    --memory-size $memory
  
  # Run performance test
  aws lambda invoke \
    --function-name my-function \
    --payload '{"test": "data"}' \
    response.json
  
  # Extract duration and cost metrics
  duration=$(cat response.json | jq '.duration')
  echo "Memory: ${memory}MB, Duration: ${duration}ms"
done
```

## Execution Time Optimization

### Cold Start Reduction
```javascript
// Connection pooling to reduce cold starts
const mysql = require('mysql2/promise');

// Initialize connection pool outside handler
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  connectionLimit: 1
});

exports.handler = async (event) => {
  try {
    // Reuse existing connection
    const connection = await pool.getConnection();
    const [rows] = await connection.execute('SELECT * FROM users WHERE id = ?', [event.userId]);
    connection.release();
    
    return {
      statusCode: 200,
      body: JSON.stringify(rows)
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message })
    };
  }
};
```

### Provisioned Concurrency
```yaml
# serverless.yml with provisioned concurrency
functions:
  myFunction:
    handler: handler.main
    provisionedConcurrency: 5  # Keep 5 instances warm
    reservedConcurrency: 100   # Limit max concurrent executions
```

## Request Optimization

### Batch Processing
```python
# Process multiple records in single invocation
import json

def lambda_handler(event, context):
    # Process SQS batch messages
    results = []
    
    for record in event['Records']:
        try:
            message = json.loads(record['body'])
            result = process_message(message)
            results.append(result)
        except Exception as e:
            # Handle individual message failures
            print(f"Failed to process message: {e}")
    
    return {
        'statusCode': 200,
        'processedCount': len(results)
    }

def process_message(message):
    # Your processing logic here
    return {"processed": True, "id": message.get('id')}
```

### Event Source Optimization
```yaml
# Optimize SQS trigger settings
functions:
  processor:
    handler: handler.process
    events:
      - sqs:
          arn: arn:aws:sqs:region:account:queue-name
          batchSize: 10          # Process up to 10 messages per invocation
          maximumBatchingWindowInSeconds: 5  # Wait up to 5 seconds to fill batch
```

## Caching Strategies

### In-Memory Caching
```javascript
// Cache expensive computations
const cache = new Map();

exports.handler = async (event) => {
  const cacheKey = `result_${event.id}`;
  
  // Check cache first
  if (cache.has(cacheKey)) {
    console.log('Cache hit');
    return {
      statusCode: 200,
      body: JSON.stringify(cache.get(cacheKey))
    };
  }
  
  // Expensive computation
  const result = await expensiveOperation(event.data);
  
  // Cache result (with size limit)
  if (cache.size < 100) {
    cache.set(cacheKey, result);
  }
  
  return {
    statusCode: 200,
    body: JSON.stringify(result)
  };
};
```

### External Caching
```python
# Redis caching example
import redis
import json
import os

redis_client = redis.Redis(
    host=os.environ['REDIS_HOST'],
    port=6379,
    decode_responses=True
)

def lambda_handler(event, context):
    cache_key = f"data:{event['id']}"
    
    # Try cache first
    cached_result = redis_client.get(cache_key)
    if cached_result:
        return {
            'statusCode': 200,
            'body': cached_result,
            'headers': {'X-Cache': 'HIT'}
        }
    
    # Compute result
    result = expensive_computation(event['data'])
    
    # Cache for 1 hour
    redis_client.setex(cache_key, 3600, json.dumps(result))
    
    return {
        'statusCode': 200,
        'body': json.dumps(result),
        'headers': {'X-Cache': 'MISS'}
    }
```

## Architecture Patterns for Cost Optimization

### Event-Driven Processing
```yaml
# Cost-effective event processing
functions:
  # Lightweight trigger function
  trigger:
    handler: trigger.handler
    memorySize: 128
    timeout: 30
    events:
      - s3:
          bucket: my-bucket
          event: s3:ObjectCreated:*
  
  # Heavy processing function
  processor:
    handler: processor.handler
    memorySize: 1024
    timeout: 900
    events:
      - sqs:
          arn: arn:aws:sqs:region:account:processing-queue
```

### Step Functions for Orchestration
```json
{
  "Comment": "Cost-optimized workflow",
  "StartAt": "CheckFileSize",
  "States": {
    "CheckFileSize": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.fileSize",
          "NumericLessThan": 1000000,
          "Next": "ProcessSmallFile"
        }
      ],
      "Default": "ProcessLargeFile"
    },
    "ProcessSmallFile": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:region:account:function:small-processor",
      "End": true
    },
    "ProcessLargeFile": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:region:account:function:large-processor",
      "End": true
    }
  }
}
```

## Monitoring and Alerting

### Cost Monitoring
```python
# CloudWatch custom metrics for cost tracking
import boto3
from datetime import datetime

cloudwatch = boto3.client('cloudwatch')

def lambda_handler(event, context):
    start_time = datetime.now()
    
    # Your function logic
    result = process_data(event)
    
    # Calculate execution cost
    duration_ms = (datetime.now() - start_time).total_seconds() * 1000
    memory_mb = int(context.memory_limit_in_mb)
    gb_seconds = (memory_mb / 1024) * (duration_ms / 1000)
    
    # Estimated cost (AWS Lambda pricing)
    cost = (gb_seconds * 0.0000166667) + (0.0000002)  # Duration + request cost
    
    # Send custom metric
    cloudwatch.put_metric_data(
        Namespace='Lambda/Cost',
        MetricData=[
            {
                'MetricName': 'EstimatedCost',
                'Value': cost,
                'Unit': 'None',
                'Dimensions': [
                    {
                        'Name': 'FunctionName',
                        'Value': context.function_name
                    }
                ]
            }
        ]
    )
    
    return result
```

### Budget Alerts
```yaml
# CloudFormation template for budget alerts
Resources:
  LambdaBudget:
    Type: AWS::Budgets::Budget
    Properties:
      Budget:
        BudgetName: "Lambda-Monthly-Budget"
        BudgetLimit:
          Amount: 100
          Unit: USD
        TimeUnit: MONTHLY
        BudgetType: COST
        CostFilters:
          Service:
            - AWS Lambda
      NotificationsWithSubscribers:
        - Notification:
            NotificationType: ACTUAL
            ComparisonOperator: GREATER_THAN
            Threshold: 80
          Subscribers:
            - SubscriptionType: EMAIL
              Address: admin@company.com
```

## Cost Optimization Tools

### AWS Cost Explorer API
```python
import boto3
from datetime import datetime, timedelta

ce = boto3.client('ce')

def get_lambda_costs():
    end_date = datetime.now().strftime('%Y-%m-%d')
    start_date = (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')
    
    response = ce.get_cost_and_usage(
        TimePeriod={
            'Start': start_date,
            'End': end_date
        },
        Granularity='DAILY',
        Metrics=['BlendedCost'],
        GroupBy=[
            {
                'Type': 'DIMENSION',
                'Key': 'SERVICE'
            }
        ],
        Filter={
            'Dimensions': {
                'Key': 'SERVICE',
                'Values': ['AWS Lambda']
            }
        }
    )
    
    return response['ResultsByTime']
```

### Serverless Framework Cost Plugin
```yaml
# serverless.yml
plugins:
  - serverless-plugin-aws-alerts

custom:
  alerts:
    stages:
      - production
    topics:
      alarm:
        topic: ${self:service}-${opt:stage}-alerts
        notifications:
          - protocol: email
            endpoint: admin@company.com
    alarms:
      - functionErrors
      - functionDuration:
          threshold: 10000  # 10 seconds
      - functionInvocations:
          threshold: 1000
          period: 300
```

## Best Practices

### 1. Function Design
- Keep functions small and focused
- Minimize dependencies
- Use appropriate runtime versions
- Implement proper error handling

### 2. Resource Management
- Right-size memory allocation
- Set appropriate timeouts
- Use reserved concurrency wisely
- Monitor and adjust based on metrics

### 3. Data Transfer Optimization
- Minimize payload sizes
- Use compression when appropriate
- Optimize API responses
- Implement efficient serialization

### 4. Development Practices
- Use local testing to reduce cloud costs
- Implement proper logging levels
- Use environment-specific configurations
- Regular cost reviews and optimization

### 5. Architectural Considerations
- Choose appropriate trigger types
- Implement efficient data processing patterns
- Use managed services when cost-effective
- Consider hybrid architectures for optimization