# Cloud Monitoring

Comprehensive guide to cloud monitoring, observability, and alerting across cloud platforms.

## Monitoring Fundamentals

### Observability Pillars
```yaml
Metrics:
  - Quantitative measurements
  - Time-series data
  - Performance indicators
  - Resource utilization

Logs:
  - Event records
  - Application logs
  - System logs
  - Audit trails

Traces:
  - Request flow tracking
  - Distributed tracing
  - Performance bottlenecks
  - Service dependencies
```

### Key Performance Indicators
```yaml
Infrastructure Metrics:
  - CPU utilization
  - Memory usage
  - Disk I/O
  - Network throughput
  - Storage capacity

Application Metrics:
  - Response time
  - Request rate
  - Error rate
  - Throughput
  - Availability

Business Metrics:
  - User engagement
  - Transaction volume
  - Revenue impact
  - Customer satisfaction
```

## AWS Monitoring

### CloudWatch
```bash
# Create custom metric
aws cloudwatch put-metric-data \
  --namespace "MyApp/Performance" \
  --metric-data MetricName=ResponseTime,Value=250,Unit=Milliseconds

# Create alarm
aws cloudwatch put-metric-alarm \
  --alarm-name "HighCPU" \
  --alarm-description "CPU utilization exceeds 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2

# Create dashboard
aws cloudwatch put-dashboard \
  --dashboard-name "MyAppDashboard" \
  --dashboard-body file://dashboard.json
```

### CloudWatch Logs
```bash
# Create log group
aws logs create-log-group --log-group-name /aws/lambda/my-function

# Create log stream
aws logs create-log-stream \
  --log-group-name /aws/lambda/my-function \
  --log-stream-name 2024/01/01

# Put log events
aws logs put-log-events \
  --log-group-name /aws/lambda/my-function \
  --log-stream-name 2024/01/01 \
  --log-events timestamp=1640995200000,message="Application started"

# Create metric filter
aws logs put-metric-filter \
  --log-group-name /aws/lambda/my-function \
  --filter-name ErrorCount \
  --filter-pattern "ERROR" \
  --metric-transformations \
    metricName=ErrorCount,metricNamespace=MyApp,metricValue=1
```

### X-Ray Distributed Tracing
```python
# Python X-Ray integration
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all

# Patch AWS SDK calls
patch_all()

@xray_recorder.capture('my_function')
def my_function():
    # Your application code
    subsegment = xray_recorder.begin_subsegment('database_query')
    try:
        # Database operation
        result = database.query()
        subsegment.put_metadata('query_result', result)
    except Exception as e:
        subsegment.add_exception(e)
    finally:
        xray_recorder.end_subsegment()
```

## Azure Monitoring

### Azure Monitor
```bash
# Create action group
az monitor action-group create \
  --resource-group myRG \
  --name myActionGroup \
  --short-name myAG

# Create metric alert
az monitor metrics alert create \
  --name "HighCPU" \
  --resource-group myRG \
  --scopes /subscriptions/{subscription-id}/resourceGroups/myRG/providers/Microsoft.Compute/virtualMachines/myVM \
  --condition "avg Percentage CPU > 80" \
  --action myActionGroup

# Create log analytics workspace
az monitor log-analytics workspace create \
  --resource-group myRG \
  --workspace-name myWorkspace
```

### Application Insights
```javascript
// JavaScript Application Insights
import { ApplicationInsights } from '@microsoft/applicationinsights-web'

const appInsights = new ApplicationInsights({
  config: {
    instrumentationKey: 'your-instrumentation-key'
  }
})

appInsights.loadAppInsights()
appInsights.trackPageView()

// Custom telemetry
appInsights.trackEvent({
  name: 'ButtonClick',
  properties: { buttonName: 'submit' }
})

appInsights.trackException({
  exception: new Error('Custom error'),
  severityLevel: SeverityLevel.Error
})
```

### Log Analytics (KQL)
```kusto
// Kusto Query Language examples
// CPU usage over time
Perf
| where ObjectName == "Processor" and CounterName == "% Processor Time"
| summarize avg(CounterValue) by bin(TimeGenerated, 5m)
| render timechart

// Error analysis
AppExceptions
| where TimeGenerated > ago(1d)
| summarize count() by ProblemId, AppRoleName
| order by count_ desc

// Performance trends
AppRequests
| where TimeGenerated > ago(7d)
| summarize avg(DurationMs) by bin(TimeGenerated, 1h), Name
| render timechart
```

## Google Cloud Monitoring

### Cloud Monitoring
```bash
# Create alerting policy
gcloud alpha monitoring policies create \
  --policy-from-file=policy.yaml

# Create notification channel
gcloud alpha monitoring channels create \
  --display-name="Email Notification" \
  --type=email \
  --channel-labels=email_address=admin@example.com

# Create uptime check
gcloud monitoring uptime create \
  --display-name="Website Check" \
  --http-check-path="/" \
  --hostname="example.com"
```

### Cloud Logging
```bash
# Write log entry
gcloud logging write my-log "Application started" \
  --severity=INFO \
  --payload-type=text

# Create log-based metric
gcloud logging metrics create error_count \
  --description="Count of error messages" \
  --log-filter='severity="ERROR"'

# Export logs to BigQuery
gcloud logging sinks create my-sink \
  bigquery.googleapis.com/projects/my-project/datasets/my_dataset \
  --log-filter='resource.type="gce_instance"'
```

### Cloud Trace
```python
# Python Cloud Trace
from google.cloud import trace_v1
import google.cloud.trace_v1.gapic.enums as enums

def trace_function():
    client = trace_v1.TraceServiceClient()
    project_id = "my-project"
    
    # Create trace
    trace = {
        'project_id': project_id,
        'spans': [{
            'span_id': 1,
            'name': 'my-function',
            'start_time': {'seconds': int(time.time())},
            'end_time': {'seconds': int(time.time()) + 1},
            'kind': enums.Span.SpanKind.RPC_SERVER
        }]
    }
    
    client.patch_traces(project_id=project_id, traces={'traces': [trace]})
```

## Third-Party Monitoring Solutions

### Prometheus and Grafana
```yaml
# Prometheus configuration
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
  
  - job_name: 'application'
    static_configs:
      - targets: ['app1:8080', 'app2:8080']
```

```python
# Python Prometheus metrics
from prometheus_client import Counter, Histogram, Gauge, start_http_server
import time

# Define metrics
REQUEST_COUNT = Counter('requests_total', 'Total requests', ['method', 'endpoint'])
REQUEST_LATENCY = Histogram('request_duration_seconds', 'Request latency')
ACTIVE_CONNECTIONS = Gauge('active_connections', 'Active connections')

# Use metrics in application
@REQUEST_LATENCY.time()
def process_request():
    REQUEST_COUNT.labels(method='GET', endpoint='/api').inc()
    # Process request
    time.sleep(0.1)

# Start metrics server
start_http_server(8000)
```

### Datadog
```python
# Datadog Python integration
from datadog import initialize, statsd
import time

# Initialize Datadog
initialize(api_key='your-api-key', app_key='your-app-key')

# Send metrics
statsd.increment('web.requests', tags=['environment:prod'])
statsd.histogram('web.response_time', 0.250, tags=['endpoint:/api'])
statsd.gauge('database.connections', 45)

# Custom metrics with context
with statsd.timed('database.query.duration'):
    # Database query
    time.sleep(0.1)
```

## Alerting and Incident Response

### Alert Configuration
```yaml
Alert Thresholds:
  Critical:
    - Service unavailable (> 5 minutes)
    - Error rate > 5%
    - Response time > 5 seconds
    - Disk usage > 95%
  
  Warning:
    - Error rate > 1%
    - Response time > 2 seconds
    - CPU usage > 80%
    - Memory usage > 85%
  
  Info:
    - Deployment completed
    - Scaling events
    - Configuration changes
```

### Incident Response Workflow
```bash
# Automated incident response
#!/bin/bash
ALERT_TYPE="$1"
SEVERITY="$2"
MESSAGE="$3"

case $SEVERITY in
  "critical")
    # Page on-call engineer
    curl -X POST "https://api.pagerduty.com/incidents" \
      -H "Authorization: Token token=$PD_TOKEN" \
      -d "{\"incident\":{\"type\":\"incident\",\"title\":\"$MESSAGE\"}}"
    
    # Scale up resources
    aws autoscaling set-desired-capacity \
      --auto-scaling-group-name web-asg \
      --desired-capacity 10
    ;;
  "warning")
    # Send Slack notification
    curl -X POST -H 'Content-type: application/json' \
      --data "{\"text\":\"⚠️ Warning: $MESSAGE\"}" \
      $SLACK_WEBHOOK_URL
    ;;
esac
```

## Performance Monitoring

### Application Performance Monitoring (APM)
```yaml
Key Metrics:
  - Apdex score
  - Transaction traces
  - Database query performance
  - External service calls
  - Memory leaks
  - Garbage collection

Tools:
  - New Relic APM
  - AppDynamics
  - Dynatrace
  - Elastic APM
```

### Infrastructure Monitoring
```bash
# System metrics collection
#!/bin/bash
# collect-metrics.sh

# CPU usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)

# Memory usage
MEM_USAGE=$(free | grep Mem | awk '{printf "%.2f", $3/$2 * 100.0}')

# Disk usage
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | cut -d'%' -f1)

# Network connections
CONNECTIONS=$(netstat -an | grep ESTABLISHED | wc -l)

# Send to monitoring system
curl -X POST "http://monitoring-server/metrics" \
  -d "cpu_usage=$CPU_USAGE&mem_usage=$MEM_USAGE&disk_usage=$DISK_USAGE&connections=$CONNECTIONS"
```

This comprehensive guide covers cloud monitoring fundamentals, platform-specific tools, and best practices for observability and incident response.