# Network Performance Optimization for DevOps

Advanced network performance analysis, optimization techniques, and capacity planning for high-performance applications. This section covers latency optimization, bandwidth management, and quality of service implementation.

## 🎯 Learning Objectives

- Master network performance analysis and monitoring
- Implement advanced optimization techniques
- Design Quality of Service (QoS) policies
- Optimize application-level network performance
- Plan network capacity and scaling strategies

## 📊 Network Performance Analysis

### Performance Metrics and KPIs

**Key Performance Indicators:**
```
┌─────────────────────────────────────────┐
│           Network KPIs                  │
├─────────────────────────────────────────┤
│ Latency (RTT)        │ < 10ms (LAN)     │
│                      │ < 100ms (WAN)    │
├─────────────────────────────────────────┤
│ Throughput           │ 95% of capacity  │
├─────────────────────────────────────────┤
│ Packet Loss          │ < 0.1%           │
├─────────────────────────────────────────┤
│ Jitter               │ < 5ms            │
├─────────────────────────────────────────┤
│ Availability         │ 99.99%           │
└─────────────────────────────────────────┘
```

### Advanced Monitoring Setup

**Prometheus Network Monitoring:**
```yaml
# prometheus-network.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-network-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    rule_files:
      - "network_rules.yml"
    
    scrape_configs:
    # SNMP monitoring for network devices
    - job_name: 'snmp-devices'
      static_configs:
        - targets:
          - router1:161
          - switch1:161
          - firewall1:161
      metrics_path: /snmp
      params:
        module: [if_mib]
      relabel_configs:
        - source_labels: [__address__]
          target_label: __param_target
        - source_labels: [__param_target]
          target_label: instance
        - target_label: __address__
          replacement: snmp-exporter:9116
    
    # Network latency monitoring
    - job_name: 'blackbox-network'
      metrics_path: /probe
      params:
        module: [icmp]
      static_configs:
        - targets:
          - 8.8.8.8
          - 1.1.1.1
          - internal-service.example.com
      relabel_configs:
        - source_labels: [__address__]
          target_label: __param_target
        - source_labels: [__param_target]
          target_label: instance
        - target_label: __address__
          replacement: blackbox-exporter:9115
    
    # Application performance monitoring
    - job_name: 'application-metrics'
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

  network_rules.yml: |
    groups:
    - name: network_performance
      rules:
      - alert: HighNetworkLatency
        expr: probe_duration_seconds > 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High network latency detected"
          description: "Network latency to {{ $labels.instance }} is {{ $value }}s"
      
      - alert: PacketLoss
        expr: (probe_success == 0) * 100 > 1
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Packet loss detected"
          description: "Packet loss to {{ $labels.instance }} detected"
      
      - alert: HighBandwidthUtilization
        expr: (rate(ifInOctets[5m]) * 8) / ifSpeed > 0.8
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High bandwidth utilization"
          description: "Interface {{ $labels.ifDescr }} utilization is {{ $value }}%"
```

### Network Performance Testing Tools

**Comprehensive Performance Test Script:**
```python
#!/usr/bin/env python3
# scripts/network_performance_test.py
import subprocess
import json
import time
import statistics
from concurrent.futures import ThreadPoolExecutor
import argparse

class NetworkPerformanceTester:
    def __init__(self):
        self.results = {}
    
    def test_latency(self, target, count=100):
        """Test network latency using ping"""
        try:
            result = subprocess.run([
                'ping', '-c', str(count), '-i', '0.1', target
            ], capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                # Parse ping output
                lines = result.stdout.split('\n')
                times = []
                
                for line in lines:
                    if 'time=' in line:
                        time_str = line.split('time=')[1].split(' ')[0]
                        times.append(float(time_str))
                
                if times:
                    return {
                        'target': target,
                        'min_latency': min(times),
                        'max_latency': max(times),
                        'avg_latency': statistics.mean(times),
                        'median_latency': statistics.median(times),
                        'std_dev': statistics.stdev(times) if len(times) > 1 else 0,
                        'packet_loss': 0,  # Calculate from ping output
                        'jitter': max(times) - min(times)
                    }
            
            return {'target': target, 'error': 'Ping failed'}
            
        except subprocess.TimeoutExpired:
            return {'target': target, 'error': 'Timeout'}
        except Exception as e:
            return {'target': target, 'error': str(e)}
    
    def test_bandwidth(self, server, port=5201, duration=30):
        """Test bandwidth using iperf3"""
        try:
            # Run iperf3 client
            result = subprocess.run([
                'iperf3', '-c', server, '-p', str(port), 
                '-t', str(duration), '-J'
            ], capture_output=True, text=True, timeout=duration + 10)
            
            if result.returncode == 0:
                data = json.loads(result.stdout)
                
                return {
                    'server': server,
                    'bandwidth_mbps': data['end']['sum_received']['bits_per_second'] / 1000000,
                    'retransmits': data['end']['sum_sent']['retransmits'],
                    'cpu_utilization': data['end']['cpu_utilization_percent'],
                    'duration': data['end']['sum_received']['seconds']
                }
            
            return {'server': server, 'error': 'iperf3 failed'}
            
        except subprocess.TimeoutExpired:
            return {'server': server, 'error': 'Timeout'}
        except Exception as e:
            return {'server': server, 'error': str(e)}
    
    def test_tcp_throughput(self, target, port, data_size_mb=100):
        """Test TCP throughput"""
        try:
            # Create test data
            test_data = b'0' * (1024 * 1024)  # 1MB chunks
            
            start_time = time.time()
            
            # Simulate data transfer (simplified)
            import socket
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(30)
            sock.connect((target, port))
            
            bytes_sent = 0
            for _ in range(data_size_mb):
                sock.send(test_data)
                bytes_sent += len(test_data)
            
            sock.close()
            end_time = time.time()
            
            duration = end_time - start_time
            throughput_mbps = (bytes_sent * 8) / (duration * 1000000)
            
            return {
                'target': target,
                'port': port,
                'throughput_mbps': throughput_mbps,
                'duration': duration,
                'bytes_transferred': bytes_sent
            }
            
        except Exception as e:
            return {'target': target, 'error': str(e)}
    
    def test_dns_performance(self, nameserver, domain, query_type='A', count=100):
        """Test DNS resolution performance"""
        try:
            times = []
            
            for _ in range(count):
                start_time = time.time()
                
                result = subprocess.run([
                    'dig', f'@{nameserver}', domain, query_type, '+short'
                ], capture_output=True, text=True, timeout=5)
                
                end_time = time.time()
                
                if result.returncode == 0:
                    times.append((end_time - start_time) * 1000)  # Convert to ms
            
            if times:
                return {
                    'nameserver': nameserver,
                    'domain': domain,
                    'query_type': query_type,
                    'min_time_ms': min(times),
                    'max_time_ms': max(times),
                    'avg_time_ms': statistics.mean(times),
                    'median_time_ms': statistics.median(times),
                    'success_rate': len(times) / count * 100
                }
            
            return {'nameserver': nameserver, 'error': 'All queries failed'}
            
        except Exception as e:
            return {'nameserver': nameserver, 'error': str(e)}
    
    def run_comprehensive_test(self, config):
        """Run comprehensive network performance tests"""
        results = {
            'timestamp': time.time(),
            'latency_tests': [],
            'bandwidth_tests': [],
            'dns_tests': [],
            'summary': {}
        }
        
        # Latency tests
        if 'latency_targets' in config:
            print("Running latency tests...")
            with ThreadPoolExecutor(max_workers=5) as executor:
                latency_futures = [
                    executor.submit(self.test_latency, target)
                    for target in config['latency_targets']
                ]
                
                for future in latency_futures:
                    result = future.result()
                    results['latency_tests'].append(result)
        
        # Bandwidth tests
        if 'bandwidth_servers' in config:
            print("Running bandwidth tests...")
            for server in config['bandwidth_servers']:
                result = self.test_bandwidth(server['host'], server.get('port', 5201))
                results['bandwidth_tests'].append(result)
        
        # DNS tests
        if 'dns_tests' in config:
            print("Running DNS performance tests...")
            for dns_test in config['dns_tests']:
                result = self.test_dns_performance(
                    dns_test['nameserver'],
                    dns_test['domain'],
                    dns_test.get('type', 'A')
                )
                results['dns_tests'].append(result)
        
        # Calculate summary statistics
        results['summary'] = self.calculate_summary(results)
        
        return results
    
    def calculate_summary(self, results):
        """Calculate summary statistics"""
        summary = {}
        
        # Latency summary
        latency_values = [
            test['avg_latency'] for test in results['latency_tests']
            if 'avg_latency' in test
        ]
        
        if latency_values:
            summary['avg_latency_ms'] = statistics.mean(latency_values)
            summary['max_latency_ms'] = max(latency_values)
            summary['min_latency_ms'] = min(latency_values)
        
        # Bandwidth summary
        bandwidth_values = [
            test['bandwidth_mbps'] for test in results['bandwidth_tests']
            if 'bandwidth_mbps' in test
        ]
        
        if bandwidth_values:
            summary['total_bandwidth_mbps'] = sum(bandwidth_values)
            summary['avg_bandwidth_mbps'] = statistics.mean(bandwidth_values)
        
        # DNS summary
        dns_times = [
            test['avg_time_ms'] for test in results['dns_tests']
            if 'avg_time_ms' in test
        ]
        
        if dns_times:
            summary['avg_dns_time_ms'] = statistics.mean(dns_times)
        
        return summary
    
    def generate_report(self, results):
        """Generate performance report"""
        print("\n" + "="*60)
        print("NETWORK PERFORMANCE TEST REPORT")
        print("="*60)
        
        summary = results['summary']
        
        if 'avg_latency_ms' in summary:
            print(f"Average Latency: {summary['avg_latency_ms']:.2f} ms")
            print(f"Min/Max Latency: {summary['min_latency_ms']:.2f}/{summary['max_latency_ms']:.2f} ms")
        
        if 'total_bandwidth_mbps' in summary:
            print(f"Total Bandwidth: {summary['total_bandwidth_mbps']:.2f} Mbps")
            print(f"Average Bandwidth: {summary['avg_bandwidth_mbps']:.2f} Mbps")
        
        if 'avg_dns_time_ms' in summary:
            print(f"Average DNS Resolution: {summary['avg_dns_time_ms']:.2f} ms")
        
        # Detailed results
        print("\nDETAILED RESULTS:")
        print("-" * 40)
        
        for test in results['latency_tests']:
            if 'error' not in test:
                print(f"Latency to {test['target']}: {test['avg_latency']:.2f} ms (jitter: {test['jitter']:.2f} ms)")
        
        for test in results['bandwidth_tests']:
            if 'error' not in test:
                print(f"Bandwidth to {test['server']}: {test['bandwidth_mbps']:.2f} Mbps")
        
        return results

# Configuration example
test_config = {
    'latency_targets': [
        '8.8.8.8',
        '1.1.1.1',
        'google.com',
        'internal-service.example.com'
    ],
    'bandwidth_servers': [
        {'host': 'iperf.example.com', 'port': 5201}
    ],
    'dns_tests': [
        {'nameserver': '8.8.8.8', 'domain': 'google.com'},
        {'nameserver': '1.1.1.1', 'domain': 'cloudflare.com'}
    ]
}

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Network performance testing')
    parser.add_argument('--config', help='Test configuration file')
    parser.add_argument('--output', help='Output file for results')
    args = parser.parse_args()
    
    tester = NetworkPerformanceTester()
    
    if args.config:
        with open(args.config, 'r') as f:
            config = json.load(f)
    else:
        config = test_config
    
    results = tester.run_comprehensive_test(config)
    tester.generate_report(results)
    
    if args.output:
        with open(args.output, 'w') as f:
            json.dump(results, f, indent=2)
```

## ⚡ Latency Optimization Techniques

### TCP Optimization

**Advanced TCP Tuning:**
```bash
#!/bin/bash
# scripts/tcp_optimization.sh

# TCP congestion control algorithms
echo "Available congestion control algorithms:"
cat /proc/sys/net/ipv4/tcp_available_congestion_control

# Set BBR congestion control (recommended for high-bandwidth networks)
echo 'net.core.default_qdisc = fq' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control = bbr' >> /etc/sysctl.conf

# TCP buffer sizes
echo 'net.core.rmem_default = 262144' >> /etc/sysctl.conf
echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf
echo 'net.core.wmem_default = 262144' >> /etc/sysctl.conf
echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf

# TCP window scaling
echo 'net.ipv4.tcp_rmem = 4096 65536 16777216' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_wmem = 4096 65536 16777216' >> /etc/sysctl.conf

# TCP timestamps and SACK
echo 'net.ipv4.tcp_timestamps = 1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_sack = 1' >> /etc/sysctl.conf

# TCP fast open
echo 'net.ipv4.tcp_fastopen = 3' >> /etc/sysctl.conf

# Reduce TIME_WAIT sockets
echo 'net.ipv4.tcp_tw_reuse = 1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_fin_timeout = 30' >> /etc/sysctl.conf

# Network device queue optimization
echo 'net.core.netdev_max_backlog = 5000' >> /etc/sysctl.conf
echo 'net.core.netdev_budget = 600' >> /etc/sysctl.conf

# Apply settings
sysctl -p

echo "TCP optimization applied. Reboot recommended for full effect."
```

### Application-Level Optimization

**HTTP/2 and HTTP/3 Configuration:**
```nginx
# nginx-http2.conf
server {
    listen 443 ssl http2;
    server_name example.com;
    
    # SSL configuration
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
    
    # HTTP/2 push
    http2_push_preload on;
    
    # Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript 
               application/javascript application/xml+rss 
               application/json image/svg+xml;
    
    # Brotli compression (if available)
    brotli on;
    brotli_comp_level 6;
    brotli_types text/plain text/css application/json 
                 application/javascript text/xml 
                 application/xml application/xml+rss 
                 text/javascript;
    
    # Connection optimization
    keepalive_timeout 65;
    keepalive_requests 1000;
    
    # Buffer optimization
    client_body_buffer_size 128k;
    client_max_body_size 10m;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 4k;
    output_buffers 1 32k;
    postpone_output 1460;
    
    location / {
        proxy_pass http://backend;
        
        # Proxy optimization
        proxy_buffering on;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
        
        # Connection reuse
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        
        # Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Static file optimization
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|pdf|txt)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary Accept-Encoding;
        
        # Enable sendfile
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
    }
}
```

### CDN and Edge Optimization

**CloudFlare Optimization Rules:**
```javascript
// cloudflare-worker.js
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  const url = new URL(request.url)
  
  // Cache static assets aggressively
  if (url.pathname.match(/\.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2)$/)) {
    const cache = caches.default
    const cacheKey = new Request(url.toString(), request)
    
    let response = await cache.match(cacheKey)
    
    if (!response) {
      response = await fetch(request)
      
      // Cache for 1 year
      const headers = new Headers(response.headers)
      headers.set('Cache-Control', 'public, max-age=31536000, immutable')
      headers.set('Vary', 'Accept-Encoding')
      
      response = new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers: headers
      })
      
      event.waitUntil(cache.put(cacheKey, response.clone()))
    }
    
    return response
  }
  
  // API requests optimization
  if (url.pathname.startsWith('/api/')) {
    const response = await fetch(request)
    
    // Add performance headers
    const headers = new Headers(response.headers)
    headers.set('X-Edge-Cache', 'MISS')
    headers.set('X-Response-Time', Date.now())
    
    return new Response(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers: headers
    })
  }
  
  return fetch(request)
}
```

## 🎛️ Quality of Service (QoS) Implementation

### Traffic Classification and Marking

**Cisco QoS Configuration:**
```bash
# QoS class maps
class-map match-all VOICE
 match dscp ef

class-map match-all VIDEO
 match dscp af41 af42 af43

class-map match-all CRITICAL_DATA
 match dscp af31 af32 af33

class-map match-all BULK_DATA
 match dscp af11 af12 af13

# Policy map
policy-map WAN_QOS
 class VOICE
  priority percent 20
  set dscp ef
 
 class VIDEO
  bandwidth percent 30
  set dscp af41
 
 class CRITICAL_DATA
  bandwidth percent 25
  set dscp af31
  random-detect dscp-based
 
 class BULK_DATA
  bandwidth percent 15
  set dscp af11
  random-detect dscp-based
 
 class class-default
  bandwidth percent 10
  random-detect

# Apply to interface
interface gigabitethernet0/0
 service-policy output WAN_QOS
 
# Traffic shaping
interface gigabitethernet0/1
 traffic-shape rate 100000000
 service-policy output WAN_QOS
```

### Linux Traffic Control (tc)

**Advanced Traffic Shaping:**
```bash
#!/bin/bash
# scripts/qos_setup.sh

INTERFACE="eth0"
TOTAL_BW="1000mbit"

# Clear existing rules
tc qdisc del dev $INTERFACE root 2>/dev/null

# Create root qdisc
tc qdisc add dev $INTERFACE root handle 1: htb default 99

# Create main class
tc class add dev $INTERFACE parent 1: classid 1:1 htb rate $TOTAL_BW

# High priority class (VoIP, real-time)
tc class add dev $INTERFACE parent 1:1 classid 1:10 htb rate 200mbit ceil 400mbit prio 1
tc qdisc add dev $INTERFACE parent 1:10 handle 10: sfq perturb 10

# Medium priority class (interactive)
tc class add dev $INTERFACE parent 1:1 classid 1:20 htb rate 300mbit ceil 600mbit prio 2
tc qdisc add dev $INTERFACE parent 1:20 handle 20: sfq perturb 10

# Low priority class (bulk data)
tc class add dev $INTERFACE parent 1:1 classid 1:30 htb rate 200mbit ceil 400mbit prio 3
tc qdisc add dev $INTERFACE parent 1:30 handle 30: sfq perturb 10

# Default class
tc class add dev $INTERFACE parent 1:1 classid 1:99 htb rate 100mbit ceil 200mbit prio 4
tc qdisc add dev $INTERFACE parent 1:99 handle 99: sfq perturb 10

# Traffic classification filters
# VoIP traffic (SIP, RTP)
tc filter add dev $INTERFACE parent 1: protocol ip prio 1 u32 \
    match ip dport 5060 0xffff flowid 1:10
tc filter add dev $INTERFACE parent 1: protocol ip prio 1 u32 \
    match ip dport 10000 0xf000 flowid 1:10

# HTTP/HTTPS traffic
tc filter add dev $INTERFACE parent 1: protocol ip prio 2 u32 \
    match ip dport 80 0xffff flowid 1:20
tc filter add dev $INTERFACE parent 1: protocol ip prio 2 u32 \
    match ip dport 443 0xffff flowid 1:20

# SSH traffic
tc filter add dev $INTERFACE parent 1: protocol ip prio 2 u32 \
    match ip dport 22 0xffff flowid 1:20

# FTP/SFTP (bulk data)
tc filter add dev $INTERFACE parent 1: protocol ip prio 3 u32 \
    match ip dport 21 0xffff flowid 1:30
tc filter add dev $INTERFACE parent 1: protocol ip prio 3 u32 \
    match ip dport 990 0xffff flowid 1:30

echo "QoS configuration applied to $INTERFACE"

# Show configuration
tc -s qdisc show dev $INTERFACE
tc -s class show dev $INTERFACE
```

### Kubernetes Network QoS

**Pod QoS Classes:**
```yaml
# high-priority-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: high-priority-app
  annotations:
    kubernetes.io/ingress-bandwidth: "100M"
    kubernetes.io/egress-bandwidth: "100M"
spec:
  priorityClassName: high-priority
  containers:
  - name: app
    image: myapp:latest
    resources:
      requests:
        memory: "1Gi"
        cpu: "500m"
      limits:
        memory: "2Gi"
        cpu: "1000m"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000
globalDefault: false
description: "High priority class for critical applications"
---
# Network policy for QoS
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: qos-policy
spec:
  podSelector:
    matchLabels:
      priority: high
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from: []
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to: []
```

## 📈 Capacity Planning and Scaling

### Network Capacity Analysis

**Capacity Planning Script:**
```python
#!/usr/bin/env python3
# scripts/capacity_planning.py
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import matplotlib.pyplot as plt
import seaborn as sns

class NetworkCapacityPlanner:
    def __init__(self):
        self.utilization_data = []
        self.growth_rate = 0.15  # 15% annual growth
    
    def load_utilization_data(self, csv_file):
        """Load network utilization data from CSV"""
        self.df = pd.read_csv(csv_file)
        self.df['timestamp'] = pd.to_datetime(self.df['timestamp'])
        self.df.set_index('timestamp', inplace=True)
        
        return self.df
    
    def analyze_trends(self, interface_name, days=30):
        """Analyze utilization trends for an interface"""
        # Filter data for specific interface
        interface_data = self.df[self.df['interface'] == interface_name]
        
        # Calculate daily statistics
        daily_stats = interface_data.resample('D').agg({
            'utilization_percent': ['mean', 'max', 'std'],
            'bytes_in': 'sum',
            'bytes_out': 'sum'
        })
        
        # Calculate growth rate
        if len(daily_stats) > 7:
            recent_avg = daily_stats['utilization_percent']['mean'].tail(7).mean()
            older_avg = daily_stats['utilization_percent']['mean'].head(7).mean()
            
            if older_avg > 0:
                growth_rate = (recent_avg - older_avg) / older_avg
            else:
                growth_rate = 0
        else:
            growth_rate = 0
        
        return {
            'interface': interface_name,
            'avg_utilization': daily_stats['utilization_percent']['mean'].mean(),
            'max_utilization': daily_stats['utilization_percent']['max'].max(),
            'growth_rate': growth_rate,
            'daily_stats': daily_stats
        }
    
    def predict_capacity_needs(self, current_utilization, current_bandwidth_mbps, 
                             months_ahead=12, target_utilization=0.8):
        """Predict when capacity upgrade will be needed"""
        
        monthly_growth = (1 + self.growth_rate) ** (1/12) - 1
        
        predictions = []
        util = current_utilization
        
        for month in range(months_ahead):
            util *= (1 + monthly_growth)
            
            predictions.append({
                'month': month + 1,
                'predicted_utilization': util,
                'bandwidth_needed_mbps': current_bandwidth_mbps * (util / current_utilization),
                'upgrade_needed': util > target_utilization
            })
        
        # Find when upgrade is needed
        upgrade_month = None
        for pred in predictions:
            if pred['upgrade_needed']:
                upgrade_month = pred['month']
                break
        
        return {
            'predictions': predictions,
            'upgrade_needed_in_months': upgrade_month,
            'recommended_bandwidth_mbps': predictions[-1]['bandwidth_needed_mbps'] * 1.2  # 20% buffer
        }
    
    def generate_capacity_report(self, interfaces):
        """Generate comprehensive capacity planning report"""
        report = {
            'timestamp': datetime.now().isoformat(),
            'interfaces': {},
            'summary': {
                'total_interfaces': len(interfaces),
                'high_utilization_count': 0,
                'upgrade_needed_count': 0
            }
        }
        
        for interface in interfaces:
            analysis = self.analyze_trends(interface)
            prediction = self.predict_capacity_needs(
                analysis['avg_utilization'] / 100,
                1000,  # Assume 1Gbps interface
                12
            )
            
            report['interfaces'][interface] = {
                'analysis': analysis,
                'prediction': prediction
            }
            
            # Update summary
            if analysis['max_utilization'] > 80:
                report['summary']['high_utilization_count'] += 1
            
            if prediction['upgrade_needed_in_months']:
                report['summary']['upgrade_needed_count'] += 1
        
        return report
    
    def visualize_trends(self, interface_name, save_path=None):
        """Create visualization of utilization trends"""
        interface_data = self.df[self.df['interface'] == interface_name]
        
        fig, axes = plt.subplots(2, 2, figsize=(15, 10))
        fig.suptitle(f'Network Utilization Analysis - {interface_name}')
        
        # Utilization over time
        axes[0, 0].plot(interface_data.index, interface_data['utilization_percent'])
        axes[0, 0].set_title('Utilization Over Time')
        axes[0, 0].set_ylabel('Utilization %')
        axes[0, 0].axhline(y=80, color='r', linestyle='--', label='80% threshold')
        axes[0, 0].legend()
        
        # Daily utilization distribution
        daily_util = interface_data.resample('D')['utilization_percent'].mean()
        axes[0, 1].hist(daily_util, bins=20, alpha=0.7)
        axes[0, 1].set_title('Daily Utilization Distribution')
        axes[0, 1].set_xlabel('Utilization %')
        axes[0, 1].set_ylabel('Frequency')
        
        # Hourly patterns
        hourly_avg = interface_data.groupby(interface_data.index.hour)['utilization_percent'].mean()
        axes[1, 0].bar(hourly_avg.index, hourly_avg.values)
        axes[1, 0].set_title('Average Utilization by Hour')
        axes[1, 0].set_xlabel('Hour of Day')
        axes[1, 0].set_ylabel('Utilization %')
        
        # Weekly patterns
        weekly_avg = interface_data.groupby(interface_data.index.dayofweek)['utilization_percent'].mean()
        days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        axes[1, 1].bar(days, weekly_avg.values)
        axes[1, 1].set_title('Average Utilization by Day of Week')
        axes[1, 1].set_ylabel('Utilization %')
        
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
        
        plt.show()

# Usage example
if __name__ == '__main__':
    planner = NetworkCapacityPlanner()
    
    # Load sample data (would be from monitoring system)
    sample_data = pd.DataFrame({
        'timestamp': pd.date_range('2023-01-01', periods=1000, freq='H'),
        'interface': ['eth0'] * 1000,
        'utilization_percent': np.random.normal(45, 15, 1000),
        'bytes_in': np.random.normal(1000000, 200000, 1000),
        'bytes_out': np.random.normal(800000, 150000, 1000)
    })
    
    sample_data.to_csv('sample_utilization.csv', index=False)
    
    # Analyze capacity
    planner.load_utilization_data('sample_utilization.csv')
    report = planner.generate_capacity_report(['eth0'])
    
    print("Capacity Planning Report:")
    print(f"Interface: eth0")
    print(f"Average Utilization: {report['interfaces']['eth0']['analysis']['avg_utilization']:.1f}%")
    print(f"Max Utilization: {report['interfaces']['eth0']['analysis']['max_utilization']:.1f}%")
    
    upgrade_months = report['interfaces']['eth0']['prediction']['upgrade_needed_in_months']
    if upgrade_months:
        print(f"Upgrade needed in: {upgrade_months} months")
    else:
        print("No upgrade needed in next 12 months")
```

## ✅ Knowledge Check

- [ ] Implement comprehensive network monitoring
- [ ] Optimize TCP and application-level performance
- [ ] Configure Quality of Service (QoS) policies
- [ ] Design traffic shaping and prioritization
- [ ] Perform network capacity planning
- [ ] Optimize CDN and edge performance
- [ ] Implement automated performance testing

## 🔗 Next Steps

- [Network Automation](readme.md) - Automated performance optimization
- [Service Mesh](readme.md) - Service-level performance optimization
- [Cloud Networking](readme.md) - Cloud performance optimization

---

*Network performance optimization is crucial for delivering excellent user experiences. Master these techniques to build high-performance, scalable network infrastructures.*