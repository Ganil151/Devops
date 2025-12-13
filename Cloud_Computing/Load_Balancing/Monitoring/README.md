# Load Balancer Monitoring

Complete guide to monitoring load balancers, metrics, alerting, and troubleshooting.

## Key Metrics
```bash
# Performance Metrics
- Request rate (requests/second)
- Response time (latency)
- Throughput (bytes/second)
- Connection count
- Error rates (4xx, 5xx)

# Health Metrics
- Backend server health
- Health check status
- Failover events
- SSL certificate expiry

# Resource Metrics
- CPU utilization
- Memory usage
- Network bandwidth
- Connection pool usage
```

## AWS CloudWatch Monitoring
```bash
# ALB Metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/ApplicationELB \
    --metric-name RequestCount \
    --dimensions Name=LoadBalancer,Value=app/my-load-balancer/50dc6c495c0c9188 \
    --start-time 2023-01-01T00:00:00Z \
    --end-time 2023-01-01T23:59:59Z \
    --period 300 \
    --statistics Sum

# Create CloudWatch Alarm
aws cloudwatch put-metric-alarm \
    --alarm-name "ALB-HighLatency" \
    --alarm-description "ALB high latency alarm" \
    --metric-name TargetResponseTime \
    --namespace AWS/ApplicationELB \
    --statistic Average \
    --period 300 \
    --threshold 1.0 \
    --comparison-operator GreaterThanThreshold
```

## Azure Monitor Integration
```bash
# Application Gateway Metrics
az monitor metrics list \
    --resource /subscriptions/{subscription}/resourceGroups/{rg}/providers/Microsoft.Network/applicationGateways/{name} \
    --metric "RequestCount,ResponseStatus,Throughput"

# Create Alert Rule
az monitor metrics alert create \
    --name "AppGW-HighLatency" \
    --resource-group myResourceGroup \
    --scopes /subscriptions/{subscription}/resourceGroups/{rg}/providers/Microsoft.Network/applicationGateways/{name} \
    --condition "avg ResponseTime > 1000" \
    --description "Application Gateway high response time"
```

## Prometheus Monitoring
```bash
# HAProxy Exporter Configuration
haproxy_exporter:
  image: prom/haproxy-exporter
  ports:
    - "9101:9101"
  command:
    - '--haproxy.scrape-uri=http://haproxy:8404/stats;csv'

# Prometheus Scrape Config
scrape_configs:
  - job_name: 'haproxy'
    static_configs:
      - targets: ['haproxy-exporter:9101']
    scrape_interval: 15s
```

## Grafana Dashboards
```bash
# Load Balancer Dashboard Panels
- Request Rate Timeline
- Response Time Distribution
- Error Rate by Backend
- Backend Health Status
- Connection Pool Usage
- SSL Certificate Expiry
```