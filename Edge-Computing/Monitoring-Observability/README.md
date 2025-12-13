# Edge Monitoring and Observability

## Overview
Monitoring and observability at the edge requires lightweight, distributed solutions that can operate with limited resources and intermittent connectivity while providing comprehensive insights into system health and performance.

## Edge Monitoring Challenges
- **Resource Constraints**: Limited CPU, memory, and storage on edge devices
- **Network Limitations**: Intermittent connectivity and bandwidth constraints
- **Geographic Distribution**: Devices spread across multiple locations
- **Scale**: Large numbers of edge devices to monitor
- **Heterogeneous Infrastructure**: Different hardware and software configurations

## Lightweight Monitoring Stack

### Prometheus Edge Configuration
```yaml
# prometheus-edge-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-edge-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 30s
      evaluation_interval: 30s
      external_labels:
        edge_location: 'edge-site-1'
        cluster: 'edge-cluster'
    
    rule_files:
      - "edge_rules.yml"
    
    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']
      
      - job_name: 'node-exporter'
        static_configs:
          - targets: ['node-exporter:9100']
      
      - job_name: 'cadvisor'
        static_configs:
          - targets: ['cadvisor:8080']
      
      - job_name: 'edge-applications'
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
    
    remote_write:
      - url: "https://central-prometheus.company.com/api/v1/write"
        queue_config:
          max_samples_per_send: 1000
          max_shards: 10
          capacity: 10000
        write_relabel_configs:
          - source_labels: [__name__]
            regex: 'up|node_.*|container_.*'
            action: keep

  edge_rules.yml: |
    groups:
      - name: edge.rules
        rules:
          - alert: EdgeNodeDown
            expr: up{job="node-exporter"} == 0
            for: 1m
            labels:
              severity: critical
            annotations:
              summary: "Edge node is down"
              description: "Edge node {{ $labels.instance }} has been down for more than 1 minute"
          
          - alert: EdgeHighCPUUsage
            expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
            for: 5m
            labels:
              severity: warning
            annotations:
              summary: "High CPU usage on edge node"
              description: "CPU usage is above 80% on {{ $labels.instance }}"
          
          - alert: EdgeHighMemoryUsage
            expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 85
            for: 5m
            labels:
              severity: warning
            annotations:
              summary: "High memory usage on edge node"
              description: "Memory usage is above 85% on {{ $labels.instance }}"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus-edge
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus-edge
  template:
    metadata:
      labels:
        app: prometheus-edge
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:v2.40.0
        args:
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus/'
          - '--web.console.libraries=/etc/prometheus/console_libraries'
          - '--web.console.templates=/etc/prometheus/consoles'
          - '--storage.tsdb.retention.time=7d'
          - '--storage.tsdb.retention.size=5GB'
          - '--web.enable-lifecycle'
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: prometheus-config
          mountPath: /etc/prometheus/
        - name: prometheus-storage
          mountPath: /prometheus/
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
      volumes:
      - name: prometheus-config
        configMap:
          name: prometheus-edge-config
      - name: prometheus-storage
        persistentVolumeClaim:
          claimName: prometheus-edge-pvc
```

### Grafana Edge Dashboard
```yaml
# grafana-edge-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana-edge
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana-edge
  template:
    metadata:
      labels:
        app: grafana-edge
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:9.3.0
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: "admin123"
        - name: GF_INSTALL_PLUGINS
          value: "grafana-piechart-panel"
        volumeMounts:
        - name: grafana-storage
          mountPath: /var/lib/grafana
        - name: grafana-config
          mountPath: /etc/grafana/provisioning
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "250m"
      volumes:
      - name: grafana-storage
        persistentVolumeClaim:
          claimName: grafana-edge-pvc
      - name: grafana-config
        configMap:
          name: grafana-edge-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-edge-config
data:
  datasources.yml: |
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        access: proxy
        url: http://prometheus-edge:9090
        isDefault: true
  
  dashboards.yml: |
    apiVersion: 1
    providers:
      - name: 'default'
        orgId: 1
        folder: ''
        type: file
        disableDeletion: false
        updateIntervalSeconds: 10
        options:
          path: /var/lib/grafana/dashboards
```

## Distributed Logging

### Fluent Bit Edge Configuration
```yaml
# fluent-bit-edge-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
data:
  fluent-bit.conf: |
    [SERVICE]
        Flush         5
        Log_Level     info
        Daemon        off
        Parsers_File  parsers.conf
        HTTP_Server   On
        HTTP_Listen   0.0.0.0
        HTTP_Port     2020
        storage.path  /var/log/flb-storage/
        storage.sync  normal
        storage.checksum off
        storage.backlog.mem_limit 50M

    [INPUT]
        Name              tail
        Path              /var/log/containers/*.log
        Parser            docker
        Tag               kube.*
        Refresh_Interval  5
        Mem_Buf_Limit     50MB
        Skip_Long_Lines   On
        storage.type      filesystem

    [INPUT]
        Name            systemd
        Tag             host.*
        Systemd_Filter  _SYSTEMD_UNIT=docker.service
        Systemd_Filter  _SYSTEMD_UNIT=kubelet.service

    [FILTER]
        Name                kubernetes
        Match               kube.*
        Kube_URL            https://kubernetes.default.svc:443
        Kube_CA_File        /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        Kube_Token_File     /var/run/secrets/kubernetes.io/serviceaccount/token
        Kube_Tag_Prefix     kube.var.log.containers.
        Merge_Log           On
        Keep_Log            Off
        K8S-Logging.Parser  On
        K8S-Logging.Exclude On

    [FILTER]
        Name    grep
        Match   *
        Exclude log level=debug

    [OUTPUT]
        Name            forward
        Match           *
        Host            central-fluentd.company.com
        Port            24224
        storage.total_limit_size 100M

    [OUTPUT]
        Name            file
        Match           *
        Path            /var/log/edge-logs/
        Format          json_lines
        storage.total_limit_size 500M

  parsers.conf: |
    [PARSER]
        Name   docker
        Format json
        Time_Key time
        Time_Format %Y-%m-%dT%H:%M:%S.%L
        Time_Keep On

    [PARSER]
        Name        syslog
        Format      regex
        Regex       ^\<(?<pri>[0-9]+)\>(?<time>[^ ]* {1,2}[^ ]* [^ ]*) (?<host>[^ ]*) (?<ident>[a-zA-Z0-9_\/\.\-]*)(?:\[(?<pid>[0-9]+)\])?(?:[^\:]*\:)? *(?<message>.*)$
        Time_Key    time
        Time_Format %b %d %H:%M:%S
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluent-bit-edge
spec:
  selector:
    matchLabels:
      name: fluent-bit-edge
  template:
    metadata:
      labels:
        name: fluent-bit-edge
    spec:
      serviceAccountName: fluent-bit
      tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      containers:
      - name: fluent-bit
        image: fluent/fluent-bit:2.0
        imagePullPolicy: Always
        ports:
          - containerPort: 2020
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: fluent-bit-config
          mountPath: /fluent-bit/etc/
        - name: edge-logs-storage
          mountPath: /var/log/edge-logs/
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
      terminationGracePeriodSeconds: 10
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      - name: fluent-bit-config
        configMap:
          name: fluent-bit-config
      - name: edge-logs-storage
        hostPath:
          path: /opt/edge-logs
```

## Application Performance Monitoring

### OpenTelemetry Edge Collector
```yaml
# otel-collector-edge.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: otel-collector-config
data:
  otel-collector-config.yaml: |
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
      
      prometheus:
        config:
          scrape_configs:
            - job_name: 'edge-apps'
              static_configs:
                - targets: ['localhost:8080']
      
      jaeger:
        protocols:
          grpc:
            endpoint: 0.0.0.0:14250
          thrift_http:
            endpoint: 0.0.0.0:14268

    processors:
      batch:
        timeout: 1s
        send_batch_size: 1024
      
      memory_limiter:
        limit_mib: 256
      
      resource:
        attributes:
          - key: edge.location
            value: "edge-site-1"
            action: insert

    exporters:
      otlp:
        endpoint: "https://central-otel.company.com:4317"
        tls:
          insecure: false
      
      prometheus:
        endpoint: "0.0.0.0:8889"
      
      jaeger:
        endpoint: "jaeger-collector.company.com:14250"
        tls:
          insecure: false

    service:
      pipelines:
        traces:
          receivers: [otlp, jaeger]
          processors: [memory_limiter, batch, resource]
          exporters: [otlp, jaeger]
        
        metrics:
          receivers: [otlp, prometheus]
          processors: [memory_limiter, batch, resource]
          exporters: [otlp, prometheus]
        
        logs:
          receivers: [otlp]
          processors: [memory_limiter, batch, resource]
          exporters: [otlp]
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: otel-collector-edge
spec:
  replicas: 1
  selector:
    matchLabels:
      app: otel-collector-edge
  template:
    metadata:
      labels:
        app: otel-collector-edge
    spec:
      containers:
      - name: otel-collector
        image: otel/opentelemetry-collector-contrib:0.70.0
        command:
          - "/otelcol-contrib"
          - "--config=/conf/otel-collector-config.yaml"
        volumeMounts:
        - name: otel-collector-config-vol
          mountPath: /conf
        ports:
        - containerPort: 4317   # OTLP gRPC receiver
        - containerPort: 4318   # OTLP HTTP receiver
        - containerPort: 8889   # Prometheus metrics
        - containerPort: 14250  # Jaeger gRPC
        - containerPort: 14268  # Jaeger HTTP
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
      volumes:
      - name: otel-collector-config-vol
        configMap:
          name: otel-collector-config
          items:
            - key: otel-collector-config.yaml
              path: otel-collector-config.yaml
```

## Edge Monitoring Agent

### Custom Edge Monitoring Agent
```python
# edge_monitor_agent.py
import asyncio
import aiohttp
import psutil
import json
import time
import logging
from typing import Dict, List, Optional
from dataclasses import dataclass, asdict

@dataclass
class EdgeMetrics:
    timestamp: float
    node_id: str
    location: str
    cpu_percent: float
    memory_percent: float
    disk_percent: float
    network_bytes_sent: int
    network_bytes_recv: int
    temperature: Optional[float]
    uptime: float
    running_containers: int
    application_health: Dict[str, bool]

class EdgeMonitorAgent:
    def __init__(self, node_id: str, location: str, central_endpoint: str):
        self.node_id = node_id
        self.location = location
        self.central_endpoint = central_endpoint
        self.logger = logging.getLogger(__name__)
        self.metrics_buffer = []
        self.max_buffer_size = 100
    
    async def collect_system_metrics(self) -> EdgeMetrics:
        """Collect system-level metrics"""
        # CPU usage
        cpu_percent = psutil.cpu_percent(interval=1)
        
        # Memory usage
        memory = psutil.virtual_memory()
        memory_percent = memory.percent
        
        # Disk usage
        disk = psutil.disk_usage('/')
        disk_percent = (disk.used / disk.total) * 100
        
        # Network statistics
        network = psutil.net_io_counters()
        
        # System uptime
        uptime = time.time() - psutil.boot_time()
        
        # Container count (if Docker is available)
        running_containers = await self.get_container_count()
        
        # Application health checks
        app_health = await self.check_application_health()
        
        # Temperature (if available)
        temperature = await self.get_temperature()
        
        return EdgeMetrics(
            timestamp=time.time(),
            node_id=self.node_id,
            location=self.location,
            cpu_percent=cpu_percent,
            memory_percent=memory_percent,
            disk_percent=disk_percent,
            network_bytes_sent=network.bytes_sent,
            network_bytes_recv=network.bytes_recv,
            temperature=temperature,
            uptime=uptime,
            running_containers=running_containers,
            application_health=app_health
        )
    
    async def get_container_count(self) -> int:
        """Get number of running containers"""
        try:
            import docker
            client = docker.from_env()
            containers = client.containers.list()
            return len(containers)
        except Exception:
            return 0
    
    async def check_application_health(self) -> Dict[str, bool]:
        """Check health of edge applications"""
        health_checks = {
            'web_app': 'http://localhost:8080/health',
            'api_service': 'http://localhost:8081/health',
            'data_processor': 'http://localhost:8082/health'
        }
        
        health_status = {}
        
        async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=5)) as session:
            for app_name, health_url in health_checks.items():
                try:
                    async with session.get(health_url) as response:
                        health_status[app_name] = response.status == 200
                except Exception:
                    health_status[app_name] = False
        
        return health_status
    
    async def get_temperature(self) -> Optional[float]:
        """Get system temperature if available"""
        try:
            temps = psutil.sensors_temperatures()
            if temps:
                # Get CPU temperature
                for name, entries in temps.items():
                    if 'cpu' in name.lower() or 'core' in name.lower():
                        return entries[0].current if entries else None
        except Exception:
            pass
        return None
    
    async def send_metrics_to_central(self, metrics: EdgeMetrics) -> bool:
        """Send metrics to central monitoring system"""
        try:
            async with aiohttp.ClientSession() as session:
                payload = asdict(metrics)
                async with session.post(
                    f"{self.central_endpoint}/api/v1/metrics",
                    json=payload,
                    timeout=aiohttp.ClientTimeout(total=10)
                ) as response:
                    return response.status == 200
        except Exception as e:
            self.logger.error(f"Failed to send metrics: {e}")
            return False
    
    async def buffer_metrics(self, metrics: EdgeMetrics):
        """Buffer metrics for later transmission"""
        self.metrics_buffer.append(asdict(metrics))
        
        # Keep buffer size manageable
        if len(self.metrics_buffer) > self.max_buffer_size:
            self.metrics_buffer = self.metrics_buffer[-self.max_buffer_size:]
    
    async def flush_buffered_metrics(self) -> bool:
        """Send all buffered metrics to central system"""
        if not self.metrics_buffer:
            return True
        
        try:
            async with aiohttp.ClientSession() as session:
                async with session.post(
                    f"{self.central_endpoint}/api/v1/metrics/batch",
                    json={"metrics": self.metrics_buffer},
                    timeout=aiohttp.ClientTimeout(total=30)
                ) as response:
                    if response.status == 200:
                        self.metrics_buffer.clear()
                        return True
                    return False
        except Exception as e:
            self.logger.error(f"Failed to flush buffered metrics: {e}")
            return False
    
    async def run_monitoring_loop(self, interval: int = 30):
        """Main monitoring loop"""
        self.logger.info(f"Starting edge monitoring agent for node {self.node_id}")
        
        while True:
            try:
                # Collect metrics
                metrics = await self.collect_system_metrics()
                
                # Try to send to central system
                if await self.send_metrics_to_central(metrics):
                    self.logger.debug("Metrics sent successfully")
                    
                    # If we have buffered metrics, try to flush them
                    if self.metrics_buffer:
                        await self.flush_buffered_metrics()
                else:
                    # Buffer metrics if central system is unreachable
                    await self.buffer_metrics(metrics)
                    self.logger.warning("Central system unreachable, buffering metrics")
                
            except Exception as e:
                self.logger.error(f"Error in monitoring loop: {e}")
            
            await asyncio.sleep(interval)

# Usage example
async def main():
    agent = EdgeMonitorAgent(
        node_id="edge-node-001",
        location="factory-floor-1",
        central_endpoint="https://monitoring.company.com"
    )
    
    await agent.run_monitoring_loop(interval=30)

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    asyncio.run(main())
```

## Alerting and Notification

### AlertManager Edge Configuration
```yaml
# alertmanager-edge-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
data:
  alertmanager.yml: |
    global:
      smtp_smarthost: 'smtp.company.com:587'
      smtp_from: 'edge-alerts@company.com'
    
    route:
      group_by: ['alertname', 'edge_location']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h
      receiver: 'edge-team'
      routes:
      - match:
          severity: critical
        receiver: 'critical-alerts'
      - match:
          alertname: EdgeNodeDown
        receiver: 'node-down-alerts'
    
    receivers:
    - name: 'edge-team'
      email_configs:
      - to: 'edge-team@company.com'
        subject: 'Edge Alert: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          Location: {{ .Labels.edge_location }}
          Severity: {{ .Labels.severity }}
          {{ end }}
    
    - name: 'critical-alerts'
      email_configs:
      - to: 'oncall@company.com'
        subject: 'CRITICAL Edge Alert: {{ .GroupLabels.alertname }}'
      webhook_configs:
      - url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
        send_resolved: true
    
    - name: 'node-down-alerts'
      webhook_configs:
      - url: 'https://api.pagerduty.com/integration/YOUR_INTEGRATION_KEY/enqueue'
        send_resolved: true

    inhibit_rules:
    - source_match:
        severity: 'critical'
      target_match:
        severity: 'warning'
      equal: ['alertname', 'edge_location']
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: alertmanager-edge
spec:
  replicas: 1
  selector:
    matchLabels:
      app: alertmanager-edge
  template:
    metadata:
      labels:
        app: alertmanager-edge
    spec:
      containers:
      - name: alertmanager
        image: prom/alertmanager:v0.25.0
        args:
          - '--config.file=/etc/alertmanager/alertmanager.yml'
          - '--storage.path=/alertmanager'
          - '--web.external-url=http://alertmanager-edge:9093'
        ports:
        - containerPort: 9093
        volumeMounts:
        - name: alertmanager-config
          mountPath: /etc/alertmanager
        - name: alertmanager-storage
          mountPath: /alertmanager
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
      volumes:
      - name: alertmanager-config
        configMap:
          name: alertmanager-config
      - name: alertmanager-storage
        emptyDir: {}
```

## Best Practices

### 1. Resource Optimization
- Use lightweight monitoring tools
- Implement efficient data collection intervals
- Optimize metric retention policies
- Use compression for data transmission

### 2. Network Efficiency
- Batch metric transmission
- Implement local buffering for offline scenarios
- Use efficient serialization formats
- Compress telemetry data

### 3. Alerting Strategy
- Define appropriate alert thresholds for edge environments
- Implement alert aggregation and deduplication
- Use multiple notification channels
- Plan for network partition scenarios

### 4. Data Management
- Implement data retention policies
- Use local storage for critical metrics
- Plan for data synchronization with central systems
- Implement data compression and archival

### 5. Security and Privacy
- Encrypt telemetry data in transit
- Implement authentication for monitoring endpoints
- Audit monitoring access
- Ensure compliance with data privacy regulations