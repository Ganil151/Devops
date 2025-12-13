# Serverless Monitoring and Observability

## Overview

Monitoring and observability in serverless environments require specialized approaches due to the ephemeral nature of functions, distributed architecture, and event-driven patterns.

## Three Pillars of Observability

### 1. Metrics
Quantitative measurements of system behavior
- Function invocations and duration
- Error rates and success rates
- Memory and CPU utilization
- Cold start frequency

### 2. Logs
Detailed records of system events
- Function execution logs
- Application-specific logs
- Error and exception logs
- Audit and security logs

### 3. Traces
Request flow through distributed systems
- End-to-end request tracking
- Service dependency mapping
- Performance bottleneck identification
- Error propagation analysis

## AWS CloudWatch Monitoring

### Basic Metrics Collection
```javascript
// Custom metrics with CloudWatch
const AWS = require('aws-sdk');
const cloudwatch = new AWS.CloudWatch();

exports.handler = async (event) => {
  const startTime = Date.now();
  
  try {
    // Your business logic
    const result = await processData(event);
    
    // Record success metric
    await recordMetric('ProcessingSuccess', 1);
    
    return {
      statusCode: 200,
      body: JSON.stringify(result)
    };
  } catch (error) {
    // Record error metric
    await recordMetric('ProcessingError', 1);
    
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message })
    };
  } finally {
    // Record duration metric
    const duration = Date.now() - startTime;
    await recordMetric('ProcessingDuration', duration, 'Milliseconds');
  }
};

async function recordMetric(metricName, value, unit = 'Count') {
  try {
    await cloudwatch.putMetricData({
      Namespace: 'MyApp/Lambda',
      MetricData: [{
        MetricName: metricName,
        Value: value,
        Unit: unit,
        Dimensions: [
          {
            Name: 'FunctionName',
            Value: process.env.AWS_LAMBDA_FUNCTION_NAME
          }
        ]
      }]
    }).promise();
  } catch (error) {
    console.error('Failed to record metric:', error);
  }
}
```

### CloudWatch Alarms
```yaml
# serverless.yml with CloudWatch alarms
resources:
  Resources:
    ErrorRateAlarm:
      Type: AWS::CloudWatch::Alarm
      Properties:
        AlarmName: ${self:service}-${opt:stage}-error-rate
        AlarmDescription: High error rate detected
        MetricName: Errors
        Namespace: AWS/Lambda
        Statistic: Sum
        Period: 300
        EvaluationPeriods: 2
        Threshold: 5
        ComparisonOperator: GreaterThanThreshold
        Dimensions:
          - Name: FunctionName
            Value: ${self:service}-${opt:stage}-myFunction
        AlarmActions:
          - !Ref ErrorNotificationTopic

    DurationAlarm:
      Type: AWS::CloudWatch::Alarm
      Properties:
        AlarmName: ${self:service}-${opt:stage}-duration
        AlarmDescription: Function duration too high
        MetricName: Duration
        Namespace: AWS/Lambda
        Statistic: Average
        Period: 300
        EvaluationPeriods: 2
        Threshold: 10000
        ComparisonOperator: GreaterThanThreshold
        Dimensions:
          - Name: FunctionName
            Value: ${self:service}-${opt:stage}-myFunction

    ErrorNotificationTopic:
      Type: AWS::SNS::Topic
      Properties:
        TopicName: ${self:service}-${opt:stage}-alerts
        Subscription:
          - Protocol: email
            Endpoint: admin@company.com
```

## Structured Logging

### JSON Logging Format
```python
import json
import logging
import uuid
from datetime import datetime

class StructuredLogger:
    def __init__(self, service_name, version="1.0"):
        self.service_name = service_name
        self.version = version
        
    def log(self, level, message, **kwargs):
        log_entry = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "level": level,
            "service": self.service_name,
            "version": self.version,
            "message": message,
            "correlation_id": kwargs.get("correlation_id"),
            "request_id": kwargs.get("request_id"),
            "user_id": kwargs.get("user_id"),
            "function_name": kwargs.get("function_name"),
            "cold_start": kwargs.get("cold_start", False),
            "duration_ms": kwargs.get("duration_ms"),
            "memory_used_mb": kwargs.get("memory_used_mb"),
            "error": kwargs.get("error"),
            "stack_trace": kwargs.get("stack_trace"),
            "custom_fields": {k: v for k, v in kwargs.items() 
                            if k not in ["correlation_id", "request_id", "user_id", 
                                       "function_name", "cold_start", "duration_ms", 
                                       "memory_used_mb", "error", "stack_trace"]}
        }
        
        print(json.dumps(log_entry, default=str))

# Usage
logger = StructuredLogger("order-service")

def lambda_handler(event, context):
    correlation_id = event.get("headers", {}).get("X-Correlation-ID", str(uuid.uuid4()))
    start_time = datetime.now()
    
    logger.log("INFO", "Function started", 
               correlation_id=correlation_id,
               function_name=context.function_name,
               cold_start=is_cold_start())
    
    try:
        result = process_order(event)
        
        duration = (datetime.now() - start_time).total_seconds() * 1000
        logger.log("INFO", "Function completed successfully",
                   correlation_id=correlation_id,
                   duration_ms=duration,
                   order_id=result.get("order_id"))
        
        return result
    except Exception as e:
        duration = (datetime.now() - start_time).total_seconds() * 1000
        logger.log("ERROR", "Function failed",
                   correlation_id=correlation_id,
                   duration_ms=duration,
                   error=str(e),
                   stack_trace=traceback.format_exc())
        raise
```

### Log Aggregation with CloudWatch Insights
```sql
-- CloudWatch Insights queries

-- Find all errors in the last hour
fields @timestamp, @message, error, stack_trace
| filter level = "ERROR"
| sort @timestamp desc
| limit 100

-- Analyze function performance
fields @timestamp, duration_ms, memory_used_mb, cold_start
| filter @type = "REPORT"
| stats avg(duration_ms), max(duration_ms), count(cold_start) by bin(5m)

-- Track correlation IDs across services
fields @timestamp, @message, correlation_id, service
| filter correlation_id = "your-correlation-id"
| sort @timestamp asc

-- Monitor error rates by service
fields @timestamp, service, level
| filter level = "ERROR"
| stats count() by service, bin(5m)
```

## Distributed Tracing

### AWS X-Ray Implementation
```javascript
// X-Ray tracing setup
const AWSXRay = require('aws-xray-sdk-core');
const AWS = AWSXRay.captureAWS(require('aws-sdk'));
const https = AWSXRay.captureHTTPs(require('https'));

exports.handler = async (event) => {
  const segment = AWSXRay.getSegment();
  
  // Add annotations (indexed for filtering)
  segment.addAnnotation('userId', event.userId);
  segment.addAnnotation('orderType', event.orderType);
  
  // Add metadata (not indexed, for detailed info)
  segment.addMetadata('requestData', event);
  
  try {
    // Database operation with subsegment
    const dbSubsegment = segment.addNewSubsegment('database-query');
    dbSubsegment.addAnnotation('table', 'orders');
    
    const order = await getOrder(event.orderId);
    dbSubsegment.close();
    
    // External API call with subsegment
    const apiSubsegment = segment.addNewSubsegment('payment-api');
    apiSubsegment.addAnnotation('endpoint', '/payments');
    
    const paymentResult = await callPaymentAPI(order);
    apiSubsegment.addAnnotation('paymentStatus', paymentResult.status);
    apiSubsegment.close();
    
    return {
      statusCode: 200,
      body: JSON.stringify(paymentResult)
    };
  } catch (error) {
    segment.addError(error);
    throw error;
  }
};

async function getOrder(orderId) {
  const dynamodb = new AWS.DynamoDB.DocumentClient();
  
  const result = await dynamodb.get({
    TableName: 'orders',
    Key: { orderId }
  }).promise();
  
  return result.Item;
}

async function callPaymentAPI(order) {
  const https = require('https');
  
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({
      amount: order.amount,
      currency: order.currency
    });
    
    const options = {
      hostname: 'api.payment-provider.com',
      port: 443,
      path: '/payments',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };
    
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => resolve(JSON.parse(data)));
    });
    
    req.on('error', reject);
    req.write(postData);
    req.end();
  });
}
```

### Custom Tracing with Correlation IDs
```python
import uuid
import json
import time
from functools import wraps

def trace_function(func):
    @wraps(func)
    def wrapper(event, context):
        # Extract or generate correlation ID
        correlation_id = event.get('headers', {}).get('X-Correlation-ID', str(uuid.uuid4()))
        
        # Create trace context
        trace_context = {
            'correlation_id': correlation_id,
            'function_name': context.function_name,
            'request_id': context.aws_request_id,
            'start_time': time.time()
        }
        
        # Add trace context to event
        event['trace_context'] = trace_context
        
        try:
            result = func(event, context)
            
            # Log successful completion
            duration = (time.time() - trace_context['start_time']) * 1000
            print(json.dumps({
                'event': 'function_completed',
                'correlation_id': correlation_id,
                'function_name': context.function_name,
                'duration_ms': duration,
                'status': 'success'
            }))
            
            return result
        except Exception as e:
            # Log error
            duration = (time.time() - trace_context['start_time']) * 1000
            print(json.dumps({
                'event': 'function_failed',
                'correlation_id': correlation_id,
                'function_name': context.function_name,
                'duration_ms': duration,
                'status': 'error',
                'error': str(e)
            }))
            raise
    
    return wrapper

@trace_function
def lambda_handler(event, context):
    correlation_id = event['trace_context']['correlation_id']
    
    # Pass correlation ID to downstream services
    headers = {
        'X-Correlation-ID': correlation_id,
        'Content-Type': 'application/json'
    }
    
    # Your function logic here
    return process_request(event, headers)
```

## Application Performance Monitoring (APM)

### Datadog Integration
```javascript
// Datadog APM for serverless
const tracer = require('dd-trace').init({
  service: 'my-serverless-app',
  env: process.env.STAGE,
  version: process.env.VERSION
});

exports.handler = tracer.wrap('lambda', async (event) => {
  const span = tracer.scope().active();
  
  // Add custom tags
  span.setTag('user.id', event.userId);
  span.setTag('order.type', event.orderType);
  
  try {
    const result = await processOrder(event);
    
    span.setTag('order.status', 'completed');
    span.setTag('order.id', result.orderId);
    
    return {
      statusCode: 200,
      body: JSON.stringify(result)
    };
  } catch (error) {
    span.setTag('error', true);
    span.setTag('error.message', error.message);
    throw error;
  }
});

async function processOrder(event) {
  return tracer.trace('process.order', async (span) => {
    span.setTag('order.items.count', event.items.length);
    
    // Database operation
    const order = await tracer.trace('db.query', async () => {
      return await saveOrder(event);
    });
    
    // External API call
    const payment = await tracer.trace('payment.process', async () => {
      return await processPayment(order);
    });
    
    return { orderId: order.id, paymentId: payment.id };
  });
}
```

### New Relic Monitoring
```python
import newrelic.agent

@newrelic.agent.lambda_handler()
def lambda_handler(event, context):
    # Add custom attributes
    newrelic.agent.add_custom_attribute('user_id', event.get('userId'))
    newrelic.agent.add_custom_attribute('order_type', event.get('orderType'))
    
    try:
        with newrelic.agent.FunctionTrace('process_order'):
            result = process_order(event)
        
        newrelic.agent.add_custom_attribute('order_status', 'completed')
        return result
    except Exception as e:
        newrelic.agent.record_exception()
        raise

@newrelic.agent.function_trace()
def process_order(event):
    # Database operation
    with newrelic.agent.DatabaseTrace('SELECT', 'orders'):
        order = get_order_from_db(event['orderId'])
    
    # External service call
    with newrelic.agent.ExternalTrace('payment-service', 'http://payment-api.com'):
        payment_result = call_payment_service(order)
    
    return {
        'orderId': order['id'],
        'status': 'processed'
    }
```

## Health Checks and Synthetic Monitoring

### Health Check Endpoints
```javascript
// Health check function
exports.healthCheck = async (event) => {
  const checks = [];
  
  try {
    // Database connectivity check
    const dbCheck = await checkDatabase();
    checks.push({
      name: 'database',
      status: dbCheck.status,
      responseTime: dbCheck.responseTime
    });
    
    // External API check
    const apiCheck = await checkExternalAPI();
    checks.push({
      name: 'payment-api',
      status: apiCheck.status,
      responseTime: apiCheck.responseTime
    });
    
    // Memory usage check
    const memoryUsage = process.memoryUsage();
    checks.push({
      name: 'memory',
      status: memoryUsage.heapUsed < 100 * 1024 * 1024 ? 'healthy' : 'warning',
      heapUsed: memoryUsage.heapUsed,
      heapTotal: memoryUsage.heapTotal
    });
    
    const overallStatus = checks.every(check => check.status === 'healthy') ? 'healthy' : 'unhealthy';
    
    return {
      statusCode: overallStatus === 'healthy' ? 200 : 503,
      body: JSON.stringify({
        status: overallStatus,
        timestamp: new Date().toISOString(),
        checks: checks
      })
    };
  } catch (error) {
    return {
      statusCode: 503,
      body: JSON.stringify({
        status: 'unhealthy',
        error: error.message,
        timestamp: new Date().toISOString()
      })
    };
  }
};

async function checkDatabase() {
  const start = Date.now();
  try {
    const AWS = require('aws-sdk');
    const dynamodb = new AWS.DynamoDB();
    
    await dynamodb.describeTable({ TableName: 'health-check' }).promise();
    
    return {
      status: 'healthy',
      responseTime: Date.now() - start
    };
  } catch (error) {
    return {
      status: 'unhealthy',
      responseTime: Date.now() - start,
      error: error.message
    };
  }
}
```

### Synthetic Monitoring
```yaml
# CloudWatch Synthetics canary
Resources:
  APICanary:
    Type: AWS::Synthetics::Canary
    Properties:
      Name: api-health-check
      Code:
        Handler: pageLoadBlueprint.handler
        Script: |
          const synthetics = require('Synthetics');
          const log = require('SyntheticsLogger');
          
          const checkAPI = async function () {
            const response = await synthetics.executeStep('checkAPI', async function () {
              const requestOptions = {
                hostname: 'api.myapp.com',
                method: 'GET',
                path: '/health',
                port: 443,
                protocol: 'https:'
              };
              
              return await synthetics.makeRequest(requestOptions);
            });
            
            if (response.statusCode !== 200) {
              throw new Error(`API health check failed with status ${response.statusCode}`);
            }
            
            const body = JSON.parse(response.body);
            if (body.status !== 'healthy') {
              throw new Error(`API reported unhealthy status: ${body.status}`);
            }
          };
          
          exports.handler = async () => {
            return await synthetics.executeStep('canary', checkAPI);
          };
      ExecutionRoleArn: !GetAtt CanaryExecutionRole.Arn
      RuntimeVersion: syn-nodejs-puppeteer-3.8
      Schedule:
        Expression: rate(5 minutes)
      FailureRetentionPeriod: 30
      SuccessRetentionPeriod: 30
```

## Dashboards and Visualization

### CloudWatch Dashboard
```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/Lambda", "Invocations", "FunctionName", "my-function"],
          [".", "Errors", ".", "."],
          [".", "Duration", ".", "."]
        ],
        "period": 300,
        "stat": "Sum",
        "region": "us-east-1",
        "title": "Lambda Metrics"
      }
    },
    {
      "type": "log",
      "properties": {
        "query": "SOURCE '/aws/lambda/my-function'\n| fields @timestamp, @message\n| filter @message like /ERROR/\n| sort @timestamp desc\n| limit 20",
        "region": "us-east-1",
        "title": "Recent Errors"
      }
    }
  ]
}
```

### Grafana Dashboard
```yaml
# Grafana dashboard configuration
dashboard:
  title: "Serverless Application Monitoring"
  panels:
    - title: "Function Invocations"
      type: "graph"
      targets:
        - expr: 'aws_lambda_invocations_sum{function_name="my-function"}'
          legendFormat: "Invocations"
    
    - title: "Error Rate"
      type: "singlestat"
      targets:
        - expr: 'rate(aws_lambda_errors_sum{function_name="my-function"}[5m]) / rate(aws_lambda_invocations_sum{function_name="my-function"}[5m]) * 100'
          legendFormat: "Error Rate %"
    
    - title: "Cold Starts"
      type: "graph"
      targets:
        - expr: 'aws_lambda_cold_starts_sum{function_name="my-function"}'
          legendFormat: "Cold Starts"
```

## Best Practices

### 1. Monitoring Strategy
- Define SLIs (Service Level Indicators)
- Set appropriate SLOs (Service Level Objectives)
- Implement error budgets
- Monitor business metrics alongside technical metrics

### 2. Alerting
- Alert on symptoms, not causes
- Use multiple severity levels
- Implement alert fatigue prevention
- Include runbooks in alerts

### 3. Logging
- Use structured logging (JSON format)
- Include correlation IDs
- Log at appropriate levels
- Avoid logging sensitive data

### 4. Tracing
- Trace critical user journeys
- Include business context in traces
- Monitor trace sampling rates
- Use trace data for optimization

### 5. Performance Monitoring
- Monitor cold start frequency
- Track function duration trends
- Monitor memory utilization
- Analyze cost vs performance trade-offs