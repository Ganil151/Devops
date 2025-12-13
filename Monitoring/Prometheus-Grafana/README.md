# Prometheus and Grafana Monitoring

Complete guide to Prometheus metrics collection and Grafana visualization.

## Prometheus Setup and Configuration

### Installation and Basic Configuration
```yaml
# docker-compose.yml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./alert_rules.yml:/etc/prometheus/alert_rules.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'

volumes:
  prometheus_data:
```

### Prometheus Configuration
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
      - targets: ['node-exporter:9100']
    scrape_interval: 30s

  - job_name: 'application'
    static_configs:
      - targets: ['app1:8080', 'app2:8080']
    metrics_path: /metrics
    scrape_interval: 15s

  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

### Custom Metrics Implementation
```python
# Python application with Prometheus metrics
from prometheus_client import Counter, Histogram, Gauge, Summary, start_http_server
import time
import random
from flask import Flask, request

app = Flask(__name__)

# Define metrics
REQUEST_COUNT = Counter(
    'app_requests_total', 
    'Total app requests', 
    ['method', 'endpoint', 'http_status']
)

REQUEST_LATENCY = Histogram(
    'app_request_duration_seconds', 
    'Request latency',
    ['method', 'endpoint']
)

ACTIVE_CONNECTIONS = Gauge(
    'app_active_connections', 
    'Number of active connections'
)

PROCESSING_TIME = Summary(
    'app_processing_seconds', 
    'Time spent processing requests'
)

# Middleware for automatic instrumentation
@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    request_latency = time.time() - request.start_time
    
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.endpoint or 'unknown',
        http_status=response.status_code
    ).inc()
    
    REQUEST_LATENCY.labels(
        method=request.method,
        endpoint=request.endpoint or 'unknown'
    ).observe(request_latency)
    
    return response

@app.route('/api/users')
def get_users():
    # Simulate processing time
    with PROCESSING_TIME.time():
        time.sleep(random.uniform(0.1, 0.5))
    
    return {"users": []}

@app.route('/metrics')
def metrics():
    from prometheus_client import generate_latest
    return generate_latest()

if __name__ == '__main__':
    # Start metrics server
    start_http_server(8000)
    app.run(host='0.0.0.0', port=5000)
```

### Node.js Metrics
```javascript
// Node.js application metrics
const express = require('express');
const client = require('prom-client');

const app = express();

// Create a Registry
const register = new client.Registry();

// Add default metrics
client.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route'],
  buckets: [0.1, 0.5, 1, 2, 5],
  registers: [register]
});

const activeConnections = new client.Gauge({
  name: 'active_connections',
  help: 'Number of active connections',
  registers: [register]
});

// Middleware
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    
    httpRequestsTotal
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .inc();
    
    httpRequestDuration
      .labels(req.method, req.route?.path || req.path)
      .observe(duration);
  });
  
  next();
});

// Routes
app.get('/api/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.get('/metrics', (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(register.metrics());
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

## Grafana Setup and Dashboards

### Grafana Configuration
```yaml
# grafana docker-compose service
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_INSTALL_PLUGINS=grafana-piechart-panel
```

### Datasource Provisioning
```yaml
# grafana/provisioning/datasources/prometheus.yml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
```

### Dashboard as Code
```json
{
  "dashboard": {
    "id": null,
    "title": "Application Metrics",
    "tags": ["application", "monitoring"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{route}}"
          }
        ],
        "yAxes": [
          {
            "label": "Requests/sec",
            "min": 0
          }
        ],
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 0
        }
      },
      {
        "id": 2,
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          },
          {
            "expr": "histogram_quantile(0.50, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "50th percentile"
          }
        ],
        "yAxes": [
          {
            "label": "Seconds",
            "min": 0
          }
        ],
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 12,
          "y": 0
        }
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "5s"
  }
}
```

## Advanced Prometheus Features

### Recording Rules
```yaml
# recording_rules.yml
groups:
  - name: application.rules
    interval: 30s
    rules:
      - record: app:request_rate_5m
        expr: rate(http_requests_total[5m])
        labels:
          job: application
      
      - record: app:error_rate_5m
        expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])
        labels:
          job: application
      
      - record: app:response_time_p95_5m
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
        labels:
          job: application
```

### Alert Rules
```yaml
# alert_rules.yml
groups:
  - name: application.alerts
    rules:
      - alert: HighErrorRate
        expr: app:error_rate_5m > 0.05
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value | humanizePercentage }} for {{ $labels.instance }}"
      
      - alert: HighResponseTime
        expr: app:response_time_p95_5m > 1
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "High response time detected"
          description: "95th percentile response time is {{ $value }}s for {{ $labels.instance }}"
      
      - alert: ServiceDown
        expr: up{job="application"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service is down"
          description: "{{ $labels.instance }} has been down for more than 1 minute"
```

### Service Discovery
```yaml
# Kubernetes service discovery
  - job_name: 'kubernetes-services'
    kubernetes_sd_configs:
      - role: service
    relabel_configs:
      - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
        action: replace
        target_label: __scheme__
        regex: (https?)
      - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)

  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        target_label: __address__
        regex: (.+)
        replacement: ${1}:${2}
```

## Grafana Advanced Features

### Templating and Variables
```json
{
  "templating": {
    "list": [
      {
        "name": "instance",
        "type": "query",
        "query": "label_values(up, instance)",
        "refresh": 1,
        "includeAll": true,
        "allValue": ".*"
      },
      {
        "name": "job",
        "type": "query",
        "query": "label_values(up, job)",
        "refresh": 1,
        "includeAll": false
      }
    ]
  }
}
```

### Alerting in Grafana
```json
{
  "alert": {
    "conditions": [
      {
        "evaluator": {
          "params": [0.8],
          "type": "gt"
        },
        "operator": {
          "type": "and"
        },
        "query": {
          "params": ["A", "5m", "now"]
        },
        "reducer": {
          "params": [],
          "type": "avg"
        },
        "type": "query"
      }
    ],
    "executionErrorState": "alerting",
    "for": "5m",
    "frequency": "10s",
    "handler": 1,
    "name": "High CPU Usage",
    "noDataState": "no_data",
    "notifications": []
  }
}
```

### Custom Panels and Plugins
```bash
# Install Grafana plugins
grafana-cli plugins install grafana-piechart-panel
grafana-cli plugins install grafana-worldmap-panel
grafana-cli plugins install grafana-clock-panel

# Custom panel configuration
{
  "type": "piechart",
  "title": "Request Distribution",
  "targets": [
    {
      "expr": "sum by (method) (rate(http_requests_total[5m]))",
      "legendFormat": "{{method}}"
    }
  ],
  "pieType": "pie",
  "strokeWidth": 1,
  "fontSize": "80%"
}
```

## Performance Optimization

### Prometheus Optimization
```yaml
# Prometheus performance tuning
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'production'
    replica: '1'

# Storage optimization
storage:
  tsdb:
    retention.time: 15d
    retention.size: 50GB
    wal-compression: true

# Query optimization
query:
  max-concurrency: 20
  timeout: 2m
  max-samples: 50000000
```

### Grafana Performance
```ini
# grafana.ini performance settings
[database]
max_idle_conn = 2
max_open_conn = 0
conn_max_lifetime = 14400

[session]
provider = memory
provider_config = 
cookie_name = grafana_sess
cookie_secure = false
session_life_time = 86400

[analytics]
reporting_enabled = false
check_for_updates = false

[metrics]
enabled = true
interval_seconds = 10
```

## Monitoring Best Practices

### Metric Design Principles
```bash
# 1. Use appropriate metric types
- Counter: Monotonically increasing values (requests, errors)
- Gauge: Values that can go up and down (memory usage, queue size)
- Histogram: Distribution of values (response times, request sizes)
- Summary: Similar to histogram but with quantiles

# 2. Label best practices
- Keep cardinality low (< 10 values per label)
- Use meaningful label names
- Avoid high-cardinality labels (user IDs, timestamps)
- Use consistent labeling across metrics

# 3. Naming conventions
- Use snake_case for metric names
- Include units in metric names (seconds, bytes, total)
- Use descriptive prefixes (http_, db_, cache_)
```

### Dashboard Design Guidelines
```bash
# 1. Dashboard organization
- Group related metrics together
- Use consistent time ranges
- Implement proper drill-down capabilities
- Include context and documentation

# 2. Visualization best practices
- Choose appropriate chart types
- Use consistent color schemes
- Set meaningful Y-axis ranges
- Include units and legends

# 3. Performance considerations
- Limit number of panels per dashboard
- Use recording rules for complex queries
- Implement proper caching
- Optimize query time ranges
```