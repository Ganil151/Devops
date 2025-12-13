# DevOps Monitoring

Complete guide to monitoring strategies, tools, and implementation in DevOps environments.

## Monitoring Fundamentals

### Three Pillars of Observability
```bash
# Metrics - Numerical data over time
- System performance metrics
- Application metrics
- Business metrics
- Infrastructure metrics

# Logs - Event records with timestamps
- Application logs
- System logs
- Security logs
- Audit logs

# Traces - Request flow through distributed systems
- Distributed tracing
- Service dependencies
- Performance bottlenecks
- Error propagation
```

### Monitoring Types
```bash
# Infrastructure Monitoring
- CPU, Memory, Disk, Network utilization
- Server health and availability
- Container and orchestration metrics
- Cloud resource monitoring

# Application Performance Monitoring (APM)
- Response times and throughput
- Error rates and exceptions
- Database performance
- User experience metrics

# Business Monitoring
- Key performance indicators (KPIs)
- Revenue and conversion metrics
- User engagement metrics
- Service level objectives (SLOs)

# Security Monitoring
- Security events and incidents
- Compliance monitoring
- Threat detection
- Vulnerability assessments
```

## Prometheus and Grafana Stack

### Prometheus Setup
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

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
    metrics_path: /metrics
    scrape_interval: 30s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

### Grafana Dashboard Configuration
```json
{
  "dashboard": {
    "title": "System Overview",
    "panels": [
      {
        "title": "CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "100 - (avg(irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "legendFormat": "CPU Usage %"
          }
        ]
      },
      {
        "title": "Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100",
            "legendFormat": "Memory Usage %"
          }
        ]
      }
    ]
  }
}
```

### Custom Metrics with Prometheus Client
```python
# Python application metrics
from prometheus_client import Counter, Histogram, Gauge, start_http_server
import time
import random

# Define metrics
REQUEST_COUNT = Counter('app_requests_total', 'Total requests', ['method', 'endpoint'])
REQUEST_LATENCY = Histogram('app_request_duration_seconds', 'Request latency')
ACTIVE_USERS = Gauge('app_active_users', 'Number of active users')

# Instrument your application
@REQUEST_LATENCY.time()
def process_request(method, endpoint):
    REQUEST_COUNT.labels(method=method, endpoint=endpoint).inc()
    # Simulate processing time
    time.sleep(random.uniform(0.1, 0.5))
    return "Response"

# Update gauge metrics
def update_active_users():
    ACTIVE_USERS.set(random.randint(100, 1000))

# Start metrics server
if __name__ == '__main__':
    start_http_server(8000)
    while True:
        process_request('GET', '/api/users')
        update_active_users()
        time.sleep(1)
```

## ELK Stack (Elasticsearch, Logstash, Kibana)

### Logstash Configuration
```ruby
# logstash.conf
input {
  beats {
    port => 5044
  }
  
  file {
    path => "/var/log/application/*.log"
    start_position => "beginning"
    tags => ["application"]
  }
}

filter {
  if "application" in [tags] {
    grok {
      match => { 
        "message" => "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:level} %{GREEDYDATA:message}" 
      }
    }
    
    date {
      match => [ "timestamp", "ISO8601" ]
    }
    
    if [level] == "ERROR" {
      mutate {
        add_tag => ["error"]
      }
    }
  }
  
  # Parse JSON logs
  if [fields][log_type] == "json" {
    json {
      source => "message"
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "logs-%{+YYYY.MM.dd}"
  }
  
  if "error" in [tags] {
    email {
      to => "alerts@company.com"
      subject => "Application Error Detected"
      body => "Error: %{message}"
    }
  }
}
```

### Filebeat Configuration
```yaml
# filebeat.yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/nginx/*.log
  fields:
    log_type: nginx
  fields_under_root: true

- type: log
  enabled: true
  paths:
    - /var/log/application/*.log
  fields:
    log_type: application
  fields_under_root: true
  multiline.pattern: '^\d{4}-\d{2}-\d{2}'
  multiline.negate: true
  multiline.match: after

output.logstash:
  hosts: ["logstash:5044"]

processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
```

### Kibana Dashboard
```json
{
  "version": "7.15.0",
  "objects": [
    {
      "id": "application-logs-dashboard",
      "type": "dashboard",
      "attributes": {
        "title": "Application Logs Dashboard",
        "panelsJSON": "[{\"version\":\"7.15.0\",\"gridData\":{\"x\":0,\"y\":0,\"w\":24,\"h\":15},\"panelIndex\":\"1\",\"embeddableConfig\":{},\"panelRefName\":\"panel_1\"}]"
      }
    }
  ]
}
```

## Application Performance Monitoring (APM)

### New Relic Integration
```javascript
// Node.js APM setup
require('newrelic');

const express = require('express');
const app = express();

// Custom metrics
const newrelic = require('newrelic');

app.get('/api/users', (req, res) => {
  // Record custom metric
  newrelic.recordMetric('Custom/API/Users/RequestCount', 1);
  
  // Add custom attributes
  newrelic.addCustomAttribute('userId', req.user?.id);
  newrelic.addCustomAttribute('userType', req.user?.type);
  
  // Simulate processing
  setTimeout(() => {
    res.json({ users: [] });
  }, Math.random() * 100);
});

// Error tracking
app.use((err, req, res, next) => {
  newrelic.noticeError(err);
  res.status(500).json({ error: 'Internal Server Error' });
});
```

### Datadog APM
```python
# Python APM with Datadog
from ddtrace import tracer
from ddtrace.contrib.flask import TraceMiddleware
from flask import Flask

app = Flask(__name__)
TraceMiddleware(app, tracer, service="my-app")

@app.route('/api/data')
def get_data():
    # Custom span
    with tracer.trace("database.query", service="postgres") as span:
        span.set_tag("query.type", "SELECT")
        span.set_tag("db.statement", "SELECT * FROM users")
        
        # Simulate database query
        import time
        time.sleep(0.1)
        
        return {"data": "example"}

# Custom metrics
from datadog import statsd

@app.route('/api/process')
def process_data():
    # Increment counter
    statsd.increment('api.requests', tags=['endpoint:process'])
    
    # Record timing
    with statsd.timed('api.process.duration'):
        # Process data
        time.sleep(0.2)
    
    return {"status": "processed"}
```

### OpenTelemetry Implementation
```go
// Go application with OpenTelemetry
package main

import (
    "context"
    "log"
    "net/http"
    
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/attribute"
    "go.opentelemetry.io/otel/exporters/jaeger"
    "go.opentelemetry.io/otel/sdk/trace"
)

func initTracer() {
    exporter, err := jaeger.New(jaeger.WithCollectorEndpoint(jaeger.WithEndpoint("http://jaeger:14268/api/traces")))
    if err != nil {
        log.Fatal(err)
    }
    
    tp := trace.NewTracerProvider(
        trace.WithBatcher(exporter),
        trace.WithResource(resource.NewWithAttributes(
            semconv.SchemaURL,
            semconv.ServiceNameKey.String("my-service"),
        )),
    )
    
    otel.SetTracerProvider(tp)
}

func handler(w http.ResponseWriter, r *http.Request) {
    tracer := otel.Tracer("my-service")
    ctx, span := tracer.Start(r.Context(), "handle-request")
    defer span.End()
    
    // Add attributes
    span.SetAttributes(
        attribute.String("http.method", r.Method),
        attribute.String("http.url", r.URL.String()),
    )
    
    // Simulate work
    processData(ctx)
    
    w.WriteHeader(http.StatusOK)
}

func processData(ctx context.Context) {
    tracer := otel.Tracer("my-service")
    _, span := tracer.Start(ctx, "process-data")
    defer span.End()
    
    // Simulate processing
    time.Sleep(100 * time.Millisecond)
}
```

## Infrastructure Monitoring

### Node Exporter Setup
```bash
# Install Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz
sudo cp node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/

# Systemd service
sudo tee /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
```

### Container Monitoring
```yaml
# Docker Compose monitoring stack
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro

volumes:
  prometheus_data:
  grafana_data:
```

### Kubernetes Monitoring
```yaml
# Kubernetes monitoring with Prometheus Operator
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: app-monitor
  labels:
    app: my-app
spec:
  selector:
    matchLabels:
      app: my-app
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics

---
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: app-alerts
spec:
  groups:
  - name: app.rules
    rules:
    - alert: HighErrorRate
      expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High error rate detected"
        description: "Error rate is {{ $value }} errors per second"
```

## Alerting and Incident Management

### Alertmanager Configuration
```yaml
# alertmanager.yml
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@company.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'
  routes:
  - match:
      severity: critical
    receiver: 'critical-alerts'
  - match:
      severity: warning
    receiver: 'warning-alerts'

receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://webhook-server:5001/'

- name: 'critical-alerts'
  email_configs:
  - to: 'oncall@company.com'
    subject: 'CRITICAL: {{ .GroupLabels.alertname }}'
    body: |
      {{ range .Alerts }}
      Alert: {{ .Annotations.summary }}
      Description: {{ .Annotations.description }}
      {{ end }}
  slack_configs:
  - api_url: 'https://hooks.slack.com/services/...'
    channel: '#alerts'
    title: 'Critical Alert'
    text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'

- name: 'warning-alerts'
  email_configs:
  - to: 'team@company.com'
    subject: 'WARNING: {{ .GroupLabels.alertname }}'
```

### PagerDuty Integration
```python
# PagerDuty webhook handler
from flask import Flask, request, jsonify
import requests
import json

app = Flask(__name__)

PAGERDUTY_INTEGRATION_KEY = "your-integration-key"

@app.route('/webhook', methods=['POST'])
def handle_alert():
    alert_data = request.json
    
    for alert in alert_data.get('alerts', []):
        if alert['status'] == 'firing' and alert['labels'].get('severity') == 'critical':
            create_pagerduty_incident(alert)
        elif alert['status'] == 'resolved':
            resolve_pagerduty_incident(alert)
    
    return jsonify({'status': 'ok'})

def create_pagerduty_incident(alert):
    payload = {
        "routing_key": PAGERDUTY_INTEGRATION_KEY,
        "event_action": "trigger",
        "dedup_key": alert['fingerprint'],
        "payload": {
            "summary": alert['annotations']['summary'],
            "source": alert['labels']['instance'],
            "severity": "critical",
            "custom_details": alert['annotations']
        }
    }
    
    response = requests.post(
        'https://events.pagerduty.com/v2/enqueue',
        json=payload,
        headers={'Content-Type': 'application/json'}
    )
    
    return response.status_code == 202

def resolve_pagerduty_incident(alert):
    payload = {
        "routing_key": PAGERDUTY_INTEGRATION_KEY,
        "event_action": "resolve",
        "dedup_key": alert['fingerprint']
    }
    
    requests.post(
        'https://events.pagerduty.com/v2/enqueue',
        json=payload,
        headers={'Content-Type': 'application/json'}
    )
```

## Cloud Monitoring

### AWS CloudWatch
```bash
# CloudWatch custom metrics
aws cloudwatch put-metric-data \
  --namespace "MyApp/Performance" \
  --metric-data MetricName=ResponseTime,Value=0.5,Unit=Seconds,Dimensions=Environment=Production

# CloudWatch Logs Insights queries
aws logs start-query \
  --log-group-name "/aws/lambda/my-function" \
  --start-time 1640995200 \
  --end-time 1641081600 \
  --query-string 'fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc'

# CloudWatch Alarms
aws cloudwatch put-metric-alarm \
  --alarm-name "HighCPUUtilization" \
  --alarm-description "Alarm when CPU exceeds 70%" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 70 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2
```

### Azure Monitor
```bash
# Azure Monitor metrics
az monitor metrics list \
  --resource /subscriptions/{subscription}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines/{vm} \
  --metric "Percentage CPU"

# Log Analytics queries
az monitor log-analytics query \
  --workspace {workspace-id} \
  --analytics-query "Heartbeat | where TimeGenerated > ago(1h) | summarize count() by Computer"

# Action Groups
az monitor action-group create \
  --resource-group myResourceGroup \
  --name myActionGroup \
  --short-name myAG \
  --email-receivers name=admin email=admin@company.com
```

### Google Cloud Monitoring
```bash
# Cloud Monitoring custom metrics
gcloud logging metrics create my_error_metric \
  --description="Count of error log entries" \
  --log-filter='severity="ERROR"'

# Alerting policies
gcloud alpha monitoring policies create \
  --policy-from-file=alert-policy.yaml

# Uptime checks
gcloud monitoring uptime create \
  --display-name="Website Uptime Check" \
  --http-check-path="/" \
  --hostname="example.com"
```

## Monitoring Best Practices

### SLI/SLO Implementation
```yaml
# Service Level Indicators and Objectives
apiVersion: sloth.slok.dev/v1
kind: PrometheusServiceLevel
metadata:
  name: api-availability
spec:
  service: "api-service"
  labels:
    team: "platform"
  slis:
    - name: "requests-availability"
      objective: 99.9
      description: "API requests availability"
      sli:
        events:
          error_query: sum(rate(http_requests_total{job="api",code=~"5.."}[5m]))
          total_query: sum(rate(http_requests_total{job="api"}[5m]))
      alerting:
        name: APIHighErrorRate
        labels:
          severity: critical
        annotations:
          summary: "API error rate is too high"
```

### Monitoring as Code
```python
# Terraform monitoring configuration
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "MyApp-Dashboard"

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
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.main.arn_suffix],
            [".", "TargetResponseTime", ".", "."],
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-west-2"
          title   = "Load Balancer Metrics"
          period  = 300
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_instance.web.id
  }
}
```