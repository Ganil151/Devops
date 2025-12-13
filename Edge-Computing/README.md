# Edge Computing in DevOps

## Overview

Edge Computing brings computation and data storage closer to the sources of data, reducing latency and bandwidth usage while enabling real-time processing and decision-making at the network edge.

## Table of Contents

1. [Edge Computing Fundamentals](#edge-computing-fundamentals)
2. [Container Orchestration at the Edge](#container-orchestration-at-the-edge)
3. [IoT Integration](#iot-integration)
4. [Edge Security](#edge-security)
5. [Monitoring and Observability](#monitoring-and-observability)
6. [CI/CD for Edge](#cicd-for-edge)
7. [Edge Storage Solutions](#edge-storage-solutions)
8. [Network Management](#network-management)
9. [Best Practices](#best-practices)
10. [Tools and Platforms](#tools-and-platforms)

---

## Edge Computing Fundamentals

### What is Edge Computing?

Edge computing is a distributed computing paradigm that brings computation and data storage closer to the location where it is needed, improving response times and saving bandwidth.

### Key Characteristics

- **Low Latency**: Processing happens near data sources
- **Bandwidth Efficiency**: Reduces data transmission to central cloud
- **Real-time Processing**: Enables immediate decision-making
- **Distributed Architecture**: Computation spread across multiple locations
- **Offline Capability**: Can operate without constant cloud connectivity

### Edge vs Cloud vs Fog Computing

| Aspect | Cloud Computing | Fog Computing | Edge Computing |
|--------|----------------|---------------|----------------|
| Location | Centralized data centers | Network edge nodes | Device level |
| Latency | High (100-500ms) | Medium (10-100ms) | Low (<10ms) |
| Processing Power | Very High | Medium | Limited |
| Storage | Unlimited | Limited | Very Limited |
| Connectivity | Always connected | Intermittent | Offline capable |

### Use Cases

1. **Industrial IoT**: Real-time monitoring and control
2. **Autonomous Vehicles**: Immediate decision-making
3. **Smart Cities**: Traffic management and public safety
4. **Healthcare**: Remote patient monitoring
5. **Retail**: Personalized customer experiences
6. **Gaming**: Low-latency gaming experiences
7. **Content Delivery**: Cached content at edge locations

---

## Container Orchestration at the Edge

### Kubernetes at the Edge

```yaml
# edge-cluster-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: edge-cluster-config
  namespace: kube-system
data:
  cluster-type: "edge"
  resource-constraints: "true"
  offline-mode: "enabled"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: edge-application
spec:
  replicas: 1
  selector:
    matchLabels:
      app: edge-app
  template:
    metadata:
      labels:
        app: edge-app
    spec:
      nodeSelector:
        node-type: edge
      containers:
      - name: edge-app
        image: edge-app:latest
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        env:
        - name: EDGE_MODE
          value: "true"
        - name: OFFLINE_CACHE
          value: "enabled"
```

### K3s for Edge Deployment

```bash
# k3s-edge-setup.sh
#!/bin/bash

# Install K3s on edge device
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --disable servicelb" sh -

# Configure for edge environment
cat <<EOF > /etc/rancher/k3s/registries.yaml
mirrors:
  docker.io:
    endpoint:
      - "https://local-registry:5000"
configs:
  "local-registry:5000":
    tls:
      insecure_skip_verify: true
EOF

# Start K3s with edge-specific configuration
systemctl enable k3s
systemctl start k3s

# Install edge-specific components
kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: edge-system
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: edge-agent
  namespace: edge-system
spec:
  selector:
    matchLabels:
      app: edge-agent
  template:
    metadata:
      labels:
        app: edge-agent
    spec:
      hostNetwork: true
      containers:
      - name: edge-agent
        image: edge-agent:latest
        securityContext:
          privileged: true
        volumeMounts:
        - name: host-root
          mountPath: /host
          readOnly: true
      volumes:
      - name: host-root
        hostPath:
          path: /
EOF
```

### MicroK8s Configuration

```python
# microk8s_edge_setup.py
import subprocess
import yaml
import json

class MicroK8sEdgeSetup:
    def __init__(self):
        self.addons = [
            'dns', 'storage', 'registry', 
            'metrics-server', 'prometheus'
        ]
    
    def install_microk8s(self):
        """Install MicroK8s on edge device"""
        commands = [
            "sudo snap install microk8s --classic",
            "sudo usermod -a -G microk8s $USER",
            "sudo chown -f -R $USER ~/.kube"
        ]
        
        for cmd in commands:
            subprocess.run(cmd, shell=True, check=True)
    
    def enable_addons(self):
        """Enable essential addons for edge"""
        for addon in self.addons:
            subprocess.run(f"microk8s enable {addon}", shell=True)
    
    def configure_edge_settings(self):
        """Configure MicroK8s for edge environment"""
        edge_config = {
            'apiVersion': 'v1',
            'kind': 'ConfigMap',
            'metadata': {
                'name': 'edge-config',
                'namespace': 'kube-system'
            },
            'data': {
                'edge-mode': 'true',
                'resource-limit': 'true',
                'offline-capable': 'true'
            }
        }
        
        with open('/tmp/edge-config.yaml', 'w') as f:
            yaml.dump(edge_config, f)
        
        subprocess.run("microk8s kubectl apply -f /tmp/edge-config.yaml", shell=True)
    
    def setup_local_registry(self):
        """Setup local container registry"""
        registry_config = """
apiVersion: apps/v1
kind: Deployment
metadata:
  name: registry
  namespace: container-registry
spec:
  replicas: 1
  selector:
    matchLabels:
      app: registry
  template:
    metadata:
      labels:
        app: registry
    spec:
      containers:
      - name: registry
        image: registry:2
        ports:
        - containerPort: 5000
        volumeMounts:
        - name: registry-storage
          mountPath: /var/lib/registry
      volumes:
      - name: registry-storage
        hostPath:
          path: /opt/registry
---
apiVersion: v1
kind: Service
metadata:
  name: registry-service
  namespace: container-registry
spec:
  selector:
    app: registry
  ports:
  - port: 5000
    targetPort: 5000
  type: NodePort
"""
        
        subprocess.run("microk8s kubectl create namespace container-registry", shell=True)
        
        with open('/tmp/registry.yaml', 'w') as f:
            f.write(registry_config)
        
        subprocess.run("microk8s kubectl apply -f /tmp/registry.yaml", shell=True)
```

---

## IoT Integration

### IoT Device Management

```python
# iot_device_manager.py
import json
import paho.mqtt.client as mqtt
from datetime import datetime
import sqlite3

class IoTDeviceManager:
    def __init__(self, mqtt_broker, db_path="edge_devices.db"):
        self.mqtt_broker = mqtt_broker
        self.db_path = db_path
        self.client = mqtt.Client()
        self.setup_database()
        self.setup_mqtt()
    
    def setup_database(self):
        """Initialize device database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS devices (
                device_id TEXT PRIMARY KEY,
                device_type TEXT,
                location TEXT,
                last_seen TIMESTAMP,
                status TEXT,
                metadata TEXT
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS sensor_data (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                device_id TEXT,
                sensor_type TEXT,
                value REAL,
                timestamp TIMESTAMP,
                FOREIGN KEY (device_id) REFERENCES devices (device_id)
            )
        ''')
        
        conn.commit()
        conn.close()
    
    def setup_mqtt(self):
        """Setup MQTT client for IoT communication"""
        def on_connect(client, userdata, flags, rc):
            print(f"Connected to MQTT broker with result code {rc}")
            client.subscribe("devices/+/data")
            client.subscribe("devices/+/status")
        
        def on_message(client, userdata, msg):
            self.process_device_message(msg.topic, msg.payload.decode())
        
        self.client.on_connect = on_connect
        self.client.on_message = on_message
        self.client.connect(self.mqtt_broker, 1883, 60)
    
    def process_device_message(self, topic, payload):
        """Process incoming IoT device messages"""
        try:
            parts = topic.split('/')
            device_id = parts[1]
            message_type = parts[2]
            
            data = json.loads(payload)
            
            if message_type == "data":
                self.store_sensor_data(device_id, data)
            elif message_type == "status":
                self.update_device_status(device_id, data)
                
        except Exception as e:
            print(f"Error processing message: {e}")
    
    def store_sensor_data(self, device_id, data):
        """Store sensor data in local database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        for sensor_type, value in data.items():
            cursor.execute(
                "INSERT INTO sensor_data (device_id, sensor_type, value, timestamp) VALUES (?, ?, ?, ?)",
                (device_id, sensor_type, value, datetime.now())
            )
        
        conn.commit()
        conn.close()
    
    def update_device_status(self, device_id, status_data):
        """Update device status and metadata"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute(
            "INSERT OR REPLACE INTO devices (device_id, device_type, location, last_seen, status, metadata) VALUES (?, ?, ?, ?, ?, ?)",
            (
                device_id,
                status_data.get('type', 'unknown'),
                status_data.get('location', 'unknown'),
                datetime.now(),
                status_data.get('status', 'online'),
                json.dumps(status_data.get('metadata', {}))
            )
        )
        
        conn.commit()
        conn.close()
    
    def get_device_data(self, device_id, hours=24):
        """Retrieve recent device data"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute(
            "SELECT * FROM sensor_data WHERE device_id = ? AND timestamp > datetime('now', '-{} hours')".format(hours),
            (device_id,)
        )
        
        data = cursor.fetchall()
        conn.close()
        
        return data
    
    def start_monitoring(self):
        """Start IoT device monitoring"""
        self.client.loop_forever()
```

### Edge Analytics

```python
# edge_analytics.py
import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import IsolationForest
import joblib

class EdgeAnalytics:
    def __init__(self):
        self.models = {}
        self.scalers = {}
        self.thresholds = {}
    
    def load_model(self, model_name, model_path):
        """Load pre-trained model for edge inference"""
        self.models[model_name] = joblib.load(model_path)
    
    def real_time_anomaly_detection(self, device_id, sensor_data):
        """Perform real-time anomaly detection"""
        if device_id not in self.models:
            # Initialize anomaly detection model for new device
            self.models[device_id] = IsolationForest(contamination=0.1, random_state=42)
            self.scalers[device_id] = StandardScaler()
            return None
        
        # Prepare data
        data_array = np.array(list(sensor_data.values())).reshape(1, -1)
        
        # Scale data
        scaled_data = self.scalers[device_id].transform(data_array)
        
        # Detect anomaly
        anomaly_score = self.models[device_id].decision_function(scaled_data)[0]
        is_anomaly = self.models[device_id].predict(scaled_data)[0] == -1
        
        return {
            'device_id': device_id,
            'anomaly_detected': is_anomaly,
            'anomaly_score': anomaly_score,
            'timestamp': pd.Timestamp.now(),
            'sensor_data': sensor_data
        }
    
    def predictive_maintenance(self, device_id, historical_data):
        """Predict maintenance needs based on sensor data"""
        if len(historical_data) < 10:
            return None
        
        df = pd.DataFrame(historical_data)
        
        # Calculate trends
        trends = {}
        for column in df.select_dtypes(include=[np.number]).columns:
            if len(df[column]) > 1:
                trend = np.polyfit(range(len(df[column])), df[column], 1)[0]
                trends[column] = trend
        
        # Predict maintenance based on trends
        maintenance_needed = False
        risk_factors = []
        
        for sensor, trend in trends.items():
            if abs(trend) > self.thresholds.get(f"{device_id}_{sensor}", 0.1):
                maintenance_needed = True
                risk_factors.append(f"{sensor}: trend={trend:.4f}")
        
        return {
            'device_id': device_id,
            'maintenance_needed': maintenance_needed,
            'risk_factors': risk_factors,
            'trends': trends,
            'recommendation': self.generate_maintenance_recommendation(risk_factors)
        }
    
    def generate_maintenance_recommendation(self, risk_factors):
        """Generate maintenance recommendations"""
        if not risk_factors:
            return "No maintenance required"
        
        recommendations = []
        for factor in risk_factors:
            if "temperature" in factor.lower():
                recommendations.append("Check cooling system")
            elif "vibration" in factor.lower():
                recommendations.append("Inspect mechanical components")
            elif "pressure" in factor.lower():
                recommendations.append("Check seals and gaskets")
        
        return "; ".join(recommendations) if recommendations else "General inspection recommended"
    
    def edge_ml_inference(self, model_name, input_data):
        """Perform ML inference at the edge"""
        if model_name not in self.models:
            raise ValueError(f"Model {model_name} not loaded")
        
        model = self.models[model_name]
        
        # Prepare input data
        if isinstance(input_data, dict):
            input_array = np.array(list(input_data.values())).reshape(1, -1)
        else:
            input_array = np.array(input_data).reshape(1, -1)
        
        # Make prediction
        prediction = model.predict(input_array)
        
        # Get prediction probability if available
        if hasattr(model, 'predict_proba'):
            probability = model.predict_proba(input_array)
            return {
                'prediction': prediction[0],
                'probability': probability[0].tolist(),
                'confidence': np.max(probability[0])
            }
        else:
            return {
                'prediction': prediction[0],
                'confidence': 1.0
            }
```

---

## Edge Security

### Security Framework

```python
# edge_security.py
import hashlib
import hmac
import jwt
from cryptography.fernet import Fernet
from datetime import datetime, timedelta
import ssl
import socket

class EdgeSecurityManager:
    def __init__(self, secret_key):
        self.secret_key = secret_key
        self.cipher_suite = Fernet(Fernet.generate_key())
        self.device_certificates = {}
        self.access_tokens = {}
    
    def generate_device_certificate(self, device_id):
        """Generate certificate for device authentication"""
        cert_data = {
            'device_id': device_id,
            'issued_at': datetime.now().isoformat(),
            'expires_at': (datetime.now() + timedelta(days=365)).isoformat(),
            'permissions': ['read_sensors', 'write_data']
        }
        
        # Create certificate signature
        cert_string = f"{device_id}:{cert_data['issued_at']}:{cert_data['expires_at']}"
        signature = hmac.new(
            self.secret_key.encode(),
            cert_string.encode(),
            hashlib.sha256
        ).hexdigest()
        
        cert_data['signature'] = signature
        self.device_certificates[device_id] = cert_data
        
        return cert_data
    
    def verify_device_certificate(self, device_id, certificate):
        """Verify device certificate"""
        if device_id not in self.device_certificates:
            return False
        
        stored_cert = self.device_certificates[device_id]
        
        # Check expiration
        expires_at = datetime.fromisoformat(stored_cert['expires_at'])
        if datetime.now() > expires_at:
            return False
        
        # Verify signature
        cert_string = f"{device_id}:{stored_cert['issued_at']}:{stored_cert['expires_at']}"
        expected_signature = hmac.new(
            self.secret_key.encode(),
            cert_string.encode(),
            hashlib.sha256
        ).hexdigest()
        
        return hmac.compare_digest(certificate.get('signature', ''), expected_signature)
    
    def encrypt_data(self, data):
        """Encrypt sensitive data"""
        if isinstance(data, str):
            data = data.encode()
        return self.cipher_suite.encrypt(data)
    
    def decrypt_data(self, encrypted_data):
        """Decrypt sensitive data"""
        return self.cipher_suite.decrypt(encrypted_data)
    
    def create_secure_connection(self, host, port, cert_file=None, key_file=None):
        """Create secure TLS connection"""
        context = ssl.create_default_context(ssl.Purpose.SERVER_AUTH)
        
        if cert_file and key_file:
            context.load_cert_chain(cert_file, key_file)
        
        # Create secure socket
        sock = socket.create_connection((host, port))
        secure_sock = context.wrap_socket(sock, server_hostname=host)
        
        return secure_sock
    
    def generate_access_token(self, device_id, permissions):
        """Generate JWT access token for device"""
        payload = {
            'device_id': device_id,
            'permissions': permissions,
            'iat': datetime.utcnow(),
            'exp': datetime.utcnow() + timedelta(hours=24)
        }
        
        token = jwt.encode(payload, self.secret_key, algorithm='HS256')
        self.access_tokens[device_id] = token
        
        return token
    
    def verify_access_token(self, token):
        """Verify JWT access token"""
        try:
            payload = jwt.decode(token, self.secret_key, algorithms=['HS256'])
            return payload
        except jwt.ExpiredSignatureError:
            return None
        except jwt.InvalidTokenError:
            return None
    
    def secure_device_communication(self, device_id, message):
        """Secure device-to-edge communication"""
        # Add timestamp and device ID
        secure_message = {
            'device_id': device_id,
            'timestamp': datetime.now().isoformat(),
            'message': message
        }
        
        # Create message signature
        message_string = f"{device_id}:{secure_message['timestamp']}:{str(message)}"
        signature = hmac.new(
            self.secret_key.encode(),
            message_string.encode(),
            hashlib.sha256
        ).hexdigest()
        
        secure_message['signature'] = signature
        
        # Encrypt the message
        encrypted_message = self.encrypt_data(str(secure_message))
        
        return encrypted_message
    
    def verify_device_message(self, encrypted_message):
        """Verify and decrypt device message"""
        try:
            # Decrypt message
            decrypted_data = self.decrypt_data(encrypted_message)
            message_data = eval(decrypted_data.decode())
            
            # Verify signature
            message_string = f"{message_data['device_id']}:{message_data['timestamp']}:{str(message_data['message'])}"
            expected_signature = hmac.new(
                self.secret_key.encode(),
                message_string.encode(),
                hashlib.sha256
            ).hexdigest()
            
            if hmac.compare_digest(message_data['signature'], expected_signature):
                return message_data['message']
            else:
                return None
                
        except Exception as e:
            print(f"Message verification failed: {e}")
            return None
```

---

## Monitoring and Observability

### Edge Monitoring System

```python
# edge_monitoring.py
import psutil
import time
import json
from datetime import datetime
import requests
from prometheus_client import CollectorRegistry, Gauge, Counter, push_to_gateway

class EdgeMonitoringSystem:
    def __init__(self, pushgateway_url=None):
        self.pushgateway_url = pushgateway_url
        self.registry = CollectorRegistry()
        self.setup_metrics()
        self.monitoring_data = []
    
    def setup_metrics(self):
        """Setup Prometheus metrics"""
        self.cpu_usage = Gauge('edge_cpu_usage_percent', 'CPU usage percentage', registry=self.registry)
        self.memory_usage = Gauge('edge_memory_usage_percent', 'Memory usage percentage', registry=self.registry)
        self.disk_usage = Gauge('edge_disk_usage_percent', 'Disk usage percentage', registry=self.registry)
        self.network_bytes_sent = Counter('edge_network_bytes_sent_total', 'Network bytes sent', registry=self.registry)
        self.network_bytes_recv = Counter('edge_network_bytes_recv_total', 'Network bytes received', registry=self.registry)
        self.device_count = Gauge('edge_connected_devices_total', 'Number of connected devices', registry=self.registry)
        self.processing_latency = Gauge('edge_processing_latency_seconds', 'Processing latency in seconds', registry=self.registry)
    
    def collect_system_metrics(self):
        """Collect system performance metrics"""
        # CPU usage
        cpu_percent = psutil.cpu_percent(interval=1)
        self.cpu_usage.set(cpu_percent)
        
        # Memory usage
        memory = psutil.virtual_memory()
        memory_percent = memory.percent
        self.memory_usage.set(memory_percent)
        
        # Disk usage
        disk = psutil.disk_usage('/')
        disk_percent = (disk.used / disk.total) * 100
        self.disk_usage.set(disk_percent)
        
        # Network I/O
        network = psutil.net_io_counters()
        self.network_bytes_sent.inc(network.bytes_sent)
        self.network_bytes_recv.inc(network.bytes_recv)
        
        metrics = {
            'timestamp': datetime.now().isoformat(),
            'cpu_percent': cpu_percent,
            'memory_percent': memory_percent,
            'disk_percent': disk_percent,
            'network_bytes_sent': network.bytes_sent,
            'network_bytes_recv': network.bytes_recv
        }
        
        return metrics
    
    def monitor_edge_applications(self):
        """Monitor edge applications and services"""
        app_metrics = {}
        
        # Monitor running processes
        for proc in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_percent']):
            try:
                proc_info = proc.info
                if 'edge' in proc_info['name'].lower():
                    app_metrics[proc_info['name']] = {
                        'pid': proc_info['pid'],
                        'cpu_percent': proc_info['cpu_percent'],
                        'memory_percent': proc_info['memory_percent']
                    }
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                continue
        
        return app_metrics
    
    def check_connectivity(self, endpoints):
        """Check connectivity to cloud and other services"""
        connectivity_status = {}
        
        for name, endpoint in endpoints.items():
            try:
                response = requests.get(endpoint, timeout=5)
                connectivity_status[name] = {
                    'status': 'connected',
                    'response_time': response.elapsed.total_seconds(),
                    'status_code': response.status_code
                }
            except requests.exceptions.RequestException as e:
                connectivity_status[name] = {
                    'status': 'disconnected',
                    'error': str(e)
                }
        
        return connectivity_status
    
    def monitor_device_health(self, device_manager):
        """Monitor connected IoT device health"""
        device_metrics = {
            'total_devices': 0,
            'online_devices': 0,
            'offline_devices': 0,
            'device_status': {}
        }
        
        # Get device status from device manager
        devices = device_manager.get_all_devices()
        
        for device in devices:
            device_metrics['total_devices'] += 1
            
            if device['status'] == 'online':
                device_metrics['online_devices'] += 1
            else:
                device_metrics['offline_devices'] += 1
            
            device_metrics['device_status'][device['device_id']] = {
                'status': device['status'],
                'last_seen': device['last_seen'],
                'location': device['location']
            }
        
        self.device_count.set(device_metrics['total_devices'])
        
        return device_metrics
    
    def generate_health_report(self):
        """Generate comprehensive health report"""
        system_metrics = self.collect_system_metrics()
        app_metrics = self.monitor_edge_applications()
        
        # Check for alerts
        alerts = []
        
        if system_metrics['cpu_percent'] > 80:
            alerts.append({'type': 'high_cpu', 'value': system_metrics['cpu_percent']})
        
        if system_metrics['memory_percent'] > 85:
            alerts.append({'type': 'high_memory', 'value': system_metrics['memory_percent']})
        
        if system_metrics['disk_percent'] > 90:
            alerts.append({'type': 'high_disk', 'value': system_metrics['disk_percent']})
        
        health_report = {
            'timestamp': datetime.now().isoformat(),
            'system_metrics': system_metrics,
            'application_metrics': app_metrics,
            'alerts': alerts,
            'overall_health': 'healthy' if not alerts else 'warning'
        }
        
        return health_report
    
    def push_metrics_to_gateway(self, job_name='edge-node'):
        """Push metrics to Prometheus Pushgateway"""
        if self.pushgateway_url:
            try:
                push_to_gateway(self.pushgateway_url, job=job_name, registry=self.registry)
            except Exception as e:
                print(f"Failed to push metrics: {e}")
    
    def start_monitoring(self, interval=30):
        """Start continuous monitoring"""
        while True:
            try:
                health_report = self.generate_health_report()
                self.monitoring_data.append(health_report)
                
                # Keep only last 100 reports
                if len(self.monitoring_data) > 100:
                    self.monitoring_data.pop(0)
                
                # Push metrics to gateway
                self.push_metrics_to_gateway()
                
                print(f"Health check completed: {health_report['overall_health']}")
                
                time.sleep(interval)
                
            except KeyboardInterrupt:
                print("Monitoring stopped")
                break
            except Exception as e:
                print(f"Monitoring error: {e}")
                time.sleep(interval)
```

---

## CI/CD for Edge

### Edge Deployment Pipeline

```yaml
# .github/workflows/edge-deployment.yml
name: Edge Deployment Pipeline

on:
  push:
    branches: [main]
    paths: ['edge-apps/**']
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: edge-application

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Log in to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: ./edge-apps
          platforms: linux/amd64,linux/arm64,linux/arm/v7
          push: true
          tags: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
      
      - name: Run security scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'

  deploy-to-edge:
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    strategy:
      matrix:
        edge-location: [edge-site-1, edge-site-2, edge-site-3]
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup kubectl
        uses: azure/setup-kubectl@v3
        with:
          version: 'v1.24.0'
      
      - name: Configure kubeconfig for edge site
        run: |
          mkdir -p ~/.kube
          echo "${{ secrets[format('KUBECONFIG_{0}', matrix.edge-location)] }}" | base64 -d > ~/.kube/config
      
      - name: Deploy to edge site
        run: |
          envsubst < k8s/edge-deployment.yaml | kubectl apply -f -
          kubectl rollout status deployment/edge-application -n edge-apps --timeout=300s
        env:
          IMAGE_TAG: ${{ github.sha }}
          EDGE_LOCATION: ${{ matrix.edge-location }}
      
      - name: Run health checks
        run: |
          kubectl wait --for=condition=ready pod -l app=edge-application -n edge-apps --timeout=300s
          kubectl get pods -n edge-apps
      
      - name: Notify deployment status
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: "Edge deployment to ${{ matrix.edge-location }}: ${{ job.status }}"
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### Edge-Specific Deployment Configuration

```python
# edge_deployment_manager.py
import yaml
import subprocess
import json
from pathlib import Path

class EdgeDeploymentManager:
    def __init__(self, config_path="edge-config.yaml"):
        self.config_path = config_path
        self.load_config()
    
    def load_config(self):
        """Load edge deployment configuration"""
        with open(self.config_path, 'r') as f:
            self.config = yaml.safe_load(f)
    
    def generate_edge_manifest(self, app_name, image_tag, edge_location):
        """Generate Kubernetes manifest for edge deployment"""
        manifest = {
            'apiVersion': 'apps/v1',
            'kind': 'Deployment',
            'metadata': {
                'name': f'{app_name}-{edge_location}',
                'namespace': 'edge-apps',
                'labels': {
                    'app': app_name,
                    'edge-location': edge_location
                }
            },
            'spec': {
                'replicas': self.config['edge_sites'][edge_location].get('replicas', 1),
                'selector': {
                    'matchLabels': {
                        'app': app_name,
                        'edge-location': edge_location
                    }
                },
                'template': {
                    'metadata': {
                        'labels': {
                            'app': app_name,
                            'edge-location': edge_location
                        }
                    },
                    'spec': {
                        'nodeSelector': {
                            'edge-location': edge_location
                        },
                        'containers': [{
                            'name': app_name,
                            'image': f'{self.config["registry"]}/{app_name}:{image_tag}',
                            'resources': self.config['edge_sites'][edge_location].get('resources', {
                                'requests': {'memory': '128Mi', 'cpu': '100m'},
                                'limits': {'memory': '256Mi', 'cpu': '200m'}
                            }),
                            'env': [
                                {'name': 'EDGE_LOCATION', 'value': edge_location},
                                {'name': 'EDGE_MODE', 'value': 'true'}
                            ]
                        }]
                    }
                }
            }
        }
        
        return manifest
    
    def deploy_to_edge_site(self, app_name, image_tag, edge_location):
        """Deploy application to specific edge site"""
        # Generate manifest
        manifest = self.generate_edge_manifest(app_name, image_tag, edge_location)
        
        # Write manifest to file
        manifest_file = f'/tmp/{app_name}-{edge_location}.yaml'
        with open(manifest_file, 'w') as f:
            yaml.dump(manifest, f)
        
        # Apply manifest
        try:
            result = subprocess.run(
                ['kubectl', 'apply', '-f', manifest_file],
                capture_output=True,
                text=True,
                check=True
            )
            
            print(f"Deployment successful for {app_name} at {edge_location}")
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"Deployment failed: {e.stderr}")
            return False
    
    def rollback_deployment(self, app_name, edge_location):
        """Rollback deployment to previous version"""
        try:
            result = subprocess.run([
                'kubectl', 'rollout', 'undo',
                f'deployment/{app_name}-{edge_location}',
                '-n', 'edge-apps'
            ], capture_output=True, text=True, check=True)
            
            print(f"Rollback successful for {app_name} at {edge_location}")
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"Rollback failed: {e.stderr}")
            return False
    
    def check_deployment_health(self, app_name, edge_location):
        """Check deployment health status"""
        try:
            # Check deployment status
            result = subprocess.run([
                'kubectl', 'get', 'deployment',
                f'{app_name}-{edge_location}',
                '-n', 'edge-apps',
                '-o', 'json'
            ], capture_output=True, text=True, check=True)
            
            deployment_info = json.loads(result.stdout)
            
            # Check if deployment is ready
            status = deployment_info.get('status', {})
            ready_replicas = status.get('readyReplicas', 0)
            desired_replicas = status.get('replicas', 0)
            
            health_status = {
                'healthy': ready_replicas == desired_replicas,
                'ready_replicas': ready_replicas,
                'desired_replicas': desired_replicas,
                'conditions': status.get('conditions', [])
            }
            
            return health_status
            
        except subprocess.CalledProcessError as e:
            print(f"Health check failed: {e.stderr}")
            return {'healthy': False, 'error': e.stderr}
```

---

## Best Practices

### Edge Computing Best Practices

1. **Resource Optimization**
   - Use lightweight containers and minimal base images
   - Implement efficient resource management
   - Optimize for low-power consumption

2. **Offline Capability**
   - Design for intermittent connectivity
   - Implement local caching and storage
   - Enable autonomous operation

3. **Security First**
   - Implement device authentication
   - Use encrypted communication
   - Regular security updates

4. **Monitoring and Observability**
   - Comprehensive edge monitoring
   - Centralized logging when connected
   - Local alerting capabilities

5. **Scalability**
   - Horizontal scaling across edge locations
   - Automated deployment and updates
   - Load balancing and failover

---

## Tools and Platforms

### Edge Computing Platforms

- **AWS IoT Greengrass**: AWS edge computing platform
- **Azure IoT Edge**: Microsoft edge computing solution
- **Google Cloud IoT Edge**: Google's edge computing platform
- **K3s**: Lightweight Kubernetes for edge
- **MicroK8s**: Canonical's edge Kubernetes
- **OpenShift**: Red Hat's container platform

### Container Orchestration

- **Kubernetes**: Full-featured orchestration
- **Docker Swarm**: Simple container orchestration
- **Nomad**: HashiCorp's workload orchestrator
- **Portainer**: Container management UI

### Monitoring Tools

- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards
- **Telegraf**: Metrics collection agent
- **Fluentd**: Log collection and forwarding

## Conclusion

Edge computing in DevOps requires specialized approaches for deployment, monitoring, and management. Success depends on understanding the unique constraints and opportunities of edge environments while implementing robust, secure, and scalable solutions that can operate effectively in distributed, resource-constrained environments.