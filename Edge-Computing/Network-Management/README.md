# Edge Network Management

## Overview
Network management at the edge involves orchestrating connectivity, bandwidth optimization, security, and service discovery across distributed edge infrastructure with varying network conditions and constraints.

## Edge Network Challenges
- **Intermittent Connectivity**: Unreliable network connections
- **Bandwidth Limitations**: Limited and variable bandwidth
- **Latency Sensitivity**: Ultra-low latency requirements
- **Network Segmentation**: Isolated network domains
- **Dynamic Topology**: Changing network configurations
- **Security Boundaries**: Multiple trust zones

## Software-Defined Networking (SDN)

### Open vSwitch (OVS) Configuration
```bash
#!/bin/bash
# ovs-edge-setup.sh

# Install Open vSwitch
apt-get update
apt-get install -y openvswitch-switch openvswitch-common

# Create edge bridge
ovs-vsctl add-br edge-br0

# Configure bridge with controller
ovs-vsctl set-controller edge-br0 tcp:controller.company.com:6653

# Add physical interfaces to bridge
ovs-vsctl add-port edge-br0 eth0
ovs-vsctl add-port edge-br0 eth1

# Configure VLAN tagging for network segmentation
ovs-vsctl add-port edge-br0 vlan100 tag=100 -- set interface vlan100 type=internal
ovs-vsctl add-port edge-br0 vlan200 tag=200 -- set interface vlan200 type=internal

# Set up flow rules for traffic steering
ovs-ofctl add-flow edge-br0 "priority=100,in_port=1,dl_vlan=100,actions=output:2"
ovs-ofctl add-flow edge-br0 "priority=100,in_port=2,dl_vlan=200,actions=output:1"

# Configure QoS for bandwidth management
ovs-vsctl set port eth0 qos=@newqos -- \
  --id=@newqos create qos type=linux-htb other-config:max-rate=1000000000 \
  queues=0=@q0,1=@q1 -- \
  --id=@q0 create queue other-config:min-rate=100000000 other-config:max-rate=500000000 -- \
  --id=@q1 create queue other-config:min-rate=50000000 other-config:max-rate=200000000

echo "OVS edge configuration completed"
```

### Calico Edge Networking
```yaml
# calico-edge-config.yaml
apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
  name: edge-pool
spec:
  cidr: 192.168.100.0/24
  ipipMode: Always
  natOutgoing: true
  nodeSelector: edge-location == "site-1"
---
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: edge-network-policy
  namespace: edge-apps
spec:
  selector: app == "edge-service"
  types:
  - Ingress
  - Egress
  ingress:
  - action: Allow
    protocol: TCP
    source:
      selector: role == "frontend"
    destination:
      ports:
      - 8080
  egress:
  - action: Allow
    protocol: TCP
    destination:
      selector: role == "database"
      ports:
      - 5432
  - action: Allow
    protocol: UDP
    destination:
      nets:
      - 8.8.8.8/32
      ports:
      - 53
---
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: edge-security-policy
spec:
  selector: edge-location == "site-1"
  types:
  - Ingress
  - Egress
  ingress:
  - action: Deny
    protocol: TCP
    source:
      nets:
      - 0.0.0.0/0
    destination:
      ports:
      - 22
      - 3389
  egress:
  - action: Allow
    destination:
      selector: role == "central-services"
```

## Service Mesh for Edge

### Istio Edge Configuration
```yaml
# istio-edge-gateway.yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: edge-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "edge-api.company.com"
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: edge-tls-secret
    hosts:
    - "edge-api.company.com"
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: edge-services
  namespace: edge-apps
spec:
  hosts:
  - "edge-api.company.com"
  gateways:
  - istio-system/edge-gateway
  http:
  - match:
    - uri:
        prefix: /api/v1/
    route:
    - destination:
        host: edge-api-service
        port:
          number: 8080
    fault:
      delay:
        percentage:
          value: 0.1
        fixedDelay: 5s
    retries:
      attempts: 3
      perTryTimeout: 2s
  - match:
    - uri:
        prefix: /health
    route:
    - destination:
        host: edge-health-service
        port:
          number: 8081
---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: edge-api-destination
  namespace: edge-apps
spec:
  host: edge-api-service
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 50
        maxRequestsPerConnection: 10
    loadBalancer:
      simple: LEAST_CONN
    outlierDetection:
      consecutiveErrors: 3
      interval: 30s
      baseEjectionTime: 30s
      maxEjectionPercent: 50
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
```

### Linkerd Edge Service Mesh
```yaml
# linkerd-edge-config.yaml
apiVersion: linkerd.io/v1alpha2
kind: ServiceProfile
metadata:
  name: edge-api-service
  namespace: edge-apps
spec:
  routes:
  - name: api_routes
    condition:
      method: GET
      pathRegex: /api/v1/.*
    responseClasses:
    - condition:
        status:
          min: 200
          max: 299
      isFailure: false
    - condition:
        status:
          min: 500
          max: 599
      isFailure: true
    timeout: 30s
    retryBudget:
      retryRatio: 0.2
      minRetriesPerSecond: 10
      ttl: 10s
---
apiVersion: policy.linkerd.io/v1beta1
kind: Server
metadata:
  name: edge-api-server
  namespace: edge-apps
spec:
  podSelector:
    matchLabels:
      app: edge-api
  port: 8080
  proxyProtocol: HTTP/2
---
apiVersion: policy.linkerd.io/v1beta1
kind: ServerAuthorization
metadata:
  name: edge-api-auth
  namespace: edge-apps
spec:
  server:
    name: edge-api-server
  client:
    meshTLS:
      serviceAccounts:
      - name: edge-frontend
        namespace: edge-apps
      - name: edge-gateway
        namespace: edge-apps
```

## Network Optimization

### Traffic Shaping and QoS
```python
# network_qos_manager.py
import subprocess
import json
import logging
from typing import Dict, List, Optional
from dataclasses import dataclass

@dataclass
class QoSRule:
    interface: str
    class_id: str
    rate: str
    ceil: str
    priority: int
    protocol: Optional[str] = None
    port: Optional[int] = None

class NetworkQoSManager:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.interfaces = self._get_network_interfaces()
    
    def _get_network_interfaces(self) -> List[str]:
        """Get list of network interfaces"""
        try:
            result = subprocess.run(['ip', 'link', 'show'], 
                                  capture_output=True, text=True)
            interfaces = []
            for line in result.stdout.split('\n'):
                if ': ' in line and 'state UP' in line:
                    interface = line.split(':')[1].strip().split('@')[0]
                    if interface not in ['lo']:
                        interfaces.append(interface)
            return interfaces
        except Exception as e:
            self.logger.error(f"Failed to get network interfaces: {e}")
            return []
    
    def setup_htb_qdisc(self, interface: str, root_rate: str = "1gbit"):
        """Set up HTB (Hierarchical Token Bucket) queueing discipline"""
        commands = [
            # Remove existing qdisc
            f"tc qdisc del dev {interface} root 2>/dev/null || true",
            
            # Add HTB root qdisc
            f"tc qdisc add dev {interface} root handle 1: htb default 30",
            
            # Add root class
            f"tc class add dev {interface} parent 1: classid 1:1 htb rate {root_rate}",
            
            # Add default class
            f"tc class add dev {interface} parent 1:1 classid 1:30 htb rate 100mbit ceil {root_rate} prio 3"
        ]
        
        for cmd in commands:
            try:
                subprocess.run(cmd, shell=True, check=True)
                self.logger.info(f"Executed: {cmd}")
            except subprocess.CalledProcessError as e:
                self.logger.error(f"Failed to execute: {cmd}, error: {e}")
    
    def add_qos_class(self, rule: QoSRule):
        """Add QoS class for traffic shaping"""
        # Add traffic class
        class_cmd = (f"tc class add dev {rule.interface} parent 1:1 "
                    f"classid 1:{rule.class_id} htb rate {rule.rate} "
                    f"ceil {rule.ceil} prio {rule.priority}")
        
        # Add SFQ qdisc to the class for fairness
        sfq_cmd = (f"tc qdisc add dev {rule.interface} parent 1:{rule.class_id} "
                  f"handle {rule.class_id}: sfq perturb 10")
        
        try:
            subprocess.run(class_cmd, shell=True, check=True)
            subprocess.run(sfq_cmd, shell=True, check=True)
            self.logger.info(f"Added QoS class {rule.class_id} on {rule.interface}")
        except subprocess.CalledProcessError as e:
            self.logger.error(f"Failed to add QoS class: {e}")
    
    def add_traffic_filter(self, rule: QoSRule):
        """Add traffic filter to classify packets"""
        if rule.protocol and rule.port:
            filter_cmd = (f"tc filter add dev {rule.interface} protocol ip parent 1:0 "
                         f"prio {rule.priority} u32 match ip protocol {rule.protocol} 0xff "
                         f"match ip dport {rule.port} 0xffff flowid 1:{rule.class_id}")
        else:
            # Default filter for unclassified traffic
            filter_cmd = (f"tc filter add dev {rule.interface} protocol ip parent 1:0 "
                         f"prio {rule.priority} u32 match u32 0 0 flowid 1:{rule.class_id}")
        
        try:
            subprocess.run(filter_cmd, shell=True, check=True)
            self.logger.info(f"Added traffic filter for class {rule.class_id}")
        except subprocess.CalledProcessError as e:
            self.logger.error(f"Failed to add traffic filter: {e}")
    
    def setup_edge_qos_policy(self, interface: str):
        """Set up comprehensive QoS policy for edge computing"""
        # Initialize HTB
        self.setup_htb_qdisc(interface)
        
        # Define QoS classes for different traffic types
        qos_rules = [
            # Critical control traffic (highest priority)
            QoSRule(interface, "10", "50mbit", "100mbit", 1, "tcp", 22),
            
            # Real-time applications (high priority)
            QoSRule(interface, "20", "200mbit", "400mbit", 2, "udp", 5060),
            
            # Business applications (medium priority)
            QoSRule(interface, "21", "300mbit", "600mbit", 2, "tcp", 80),
            QoSRule(interface, "22", "300mbit", "600mbit", 2, "tcp", 443),
            
            # Bulk data transfer (lower priority)
            QoSRule(interface, "40", "100mbit", "800mbit", 4, "tcp", 21),
            QoSRule(interface, "41", "100mbit", "800mbit", 4, "tcp", 22),
        ]
        
        # Apply QoS rules
        for rule in qos_rules:
            self.add_qos_class(rule)
            self.add_traffic_filter(rule)
    
    def get_qos_stats(self, interface: str) -> Dict:
        """Get QoS statistics for interface"""
        try:
            result = subprocess.run(['tc', '-s', 'class', 'show', 'dev', interface],
                                  capture_output=True, text=True)
            return {"interface": interface, "stats": result.stdout}
        except Exception as e:
            self.logger.error(f"Failed to get QoS stats: {e}")
            return {}
    
    def reset_qos(self, interface: str):
        """Reset QoS configuration on interface"""
        try:
            subprocess.run(f"tc qdisc del dev {interface} root", 
                          shell=True, check=True)
            self.logger.info(f"Reset QoS on {interface}")
        except subprocess.CalledProcessError:
            self.logger.info(f"No QoS configuration to reset on {interface}")

# Usage example
def setup_edge_networking():
    qos_manager = NetworkQoSManager()
    
    # Set up QoS on all available interfaces
    for interface in qos_manager.interfaces:
        qos_manager.setup_edge_qos_policy(interface)
        
        # Display stats
        stats = qos_manager.get_qos_stats(interface)
        print(f"QoS Stats for {interface}:")
        print(stats.get('stats', 'No stats available'))

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    setup_edge_networking()
```

## Load Balancing and Service Discovery

### HAProxy Edge Configuration
```bash
# haproxy-edge.cfg
global
    daemon
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    
    # SSL/TLS configuration
    ssl-default-bind-ciphers ECDHE+AESGCM:ECDHE+CHACHA20:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
    ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms
    option httplog
    option dontlognull
    option http-server-close
    option forwardfor except 127.0.0.0/8
    option redispatch
    retries 3
    
    # Health check configuration
    option httpchk GET /health
    http-check expect status 200

# Statistics interface
stats enable
stats uri /haproxy-stats
stats refresh 30s
stats admin if TRUE

# Frontend for edge services
frontend edge_frontend
    bind *:80
    bind *:443 ssl crt /etc/ssl/certs/edge.pem
    
    # Redirect HTTP to HTTPS
    redirect scheme https if !{ ssl_fc }
    
    # ACLs for routing
    acl is_api path_beg /api/
    acl is_websocket hdr(Upgrade) -i websocket
    acl is_health path /health
    
    # Route to appropriate backends
    use_backend api_backend if is_api
    use_backend websocket_backend if is_websocket
    use_backend health_backend if is_health
    default_backend web_backend

# Backend for API services
backend api_backend
    balance roundrobin
    option httpchk GET /api/health
    
    # Edge API servers
    server api1 192.168.1.10:8080 check inter 5s fall 3 rise 2
    server api2 192.168.1.11:8080 check inter 5s fall 3 rise 2
    server api3 192.168.1.12:8080 check inter 5s fall 3 rise 2 backup

# Backend for WebSocket connections
backend websocket_backend
    balance source
    option httpchk GET /ws/health
    
    # WebSocket servers
    server ws1 192.168.1.20:8081 check inter 10s
    server ws2 192.168.1.21:8081 check inter 10s

# Backend for web services
backend web_backend
    balance leastconn
    option httpchk GET /
    
    # Web servers
    server web1 192.168.1.30:80 check
    server web2 192.168.1.31:80 check

# Backend for health checks
backend health_backend
    balance roundrobin
    
    # Health check endpoint
    server health localhost:8090 check
```

### Consul Service Discovery
```python
# consul_service_discovery.py
import consul
import json
import time
import logging
from typing import Dict, List, Optional
from dataclasses import dataclass

@dataclass
class ServiceInstance:
    id: str
    name: str
    address: str
    port: int
    tags: List[str]
    health_check: Optional[str] = None

class ConsulServiceDiscovery:
    def __init__(self, consul_host: str = 'localhost', consul_port: int = 8500):
        self.consul = consul.Consul(host=consul_host, port=consul_port)
        self.logger = logging.getLogger(__name__)
    
    def register_service(self, service: ServiceInstance) -> bool:
        """Register a service with Consul"""
        try:
            check = None
            if service.health_check:
                check = consul.Check.http(service.health_check, interval="10s")
            
            self.consul.agent.service.register(
                name=service.name,
                service_id=service.id,
                address=service.address,
                port=service.port,
                tags=service.tags,
                check=check
            )
            
            self.logger.info(f"Registered service {service.name} with ID {service.id}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to register service {service.name}: {e}")
            return False
    
    def deregister_service(self, service_id: str) -> bool:
        """Deregister a service from Consul"""
        try:
            self.consul.agent.service.deregister(service_id)
            self.logger.info(f"Deregistered service with ID {service_id}")
            return True
        except Exception as e:
            self.logger.error(f"Failed to deregister service {service_id}: {e}")
            return False
    
    def discover_services(self, service_name: str, tag: Optional[str] = None) -> List[Dict]:
        """Discover healthy services by name and optional tag"""
        try:
            if tag:
                _, services = self.consul.health.service(service_name, tag=tag, passing=True)
            else:
                _, services = self.consul.health.service(service_name, passing=True)
            
            discovered_services = []
            for service in services:
                service_info = service['Service']
                discovered_services.append({
                    'id': service_info['ID'],
                    'name': service_info['Service'],
                    'address': service_info['Address'],
                    'port': service_info['Port'],
                    'tags': service_info['Tags']
                })
            
            return discovered_services
            
        except Exception as e:
            self.logger.error(f"Failed to discover services for {service_name}: {e}")
            return []
    
    def watch_service_changes(self, service_name: str, callback):
        """Watch for service changes and call callback function"""
        index = None
        
        while True:
            try:
                index, services = self.consul.health.service(
                    service_name, 
                    index=index, 
                    wait='30s'
                )
                
                # Process service changes
                healthy_services = [s for s in services if s['Checks'][0]['Status'] == 'passing']
                callback(service_name, healthy_services)
                
            except Exception as e:
                self.logger.error(f"Error watching service {service_name}: {e}")
                time.sleep(5)
    
    def get_service_health(self, service_name: str) -> Dict:
        """Get health status of all instances of a service"""
        try:
            _, services = self.consul.health.service(service_name)
            
            health_status = {
                'service_name': service_name,
                'total_instances': len(services),
                'healthy_instances': 0,
                'unhealthy_instances': 0,
                'instances': []
            }
            
            for service in services:
                checks = service['Checks']
                is_healthy = all(check['Status'] == 'passing' for check in checks)
                
                if is_healthy:
                    health_status['healthy_instances'] += 1
                else:
                    health_status['unhealthy_instances'] += 1
                
                health_status['instances'].append({
                    'id': service['Service']['ID'],
                    'address': service['Service']['Address'],
                    'port': service['Service']['Port'],
                    'healthy': is_healthy,
                    'checks': [{'name': c['Name'], 'status': c['Status']} for c in checks]
                })
            
            return health_status
            
        except Exception as e:
            self.logger.error(f"Failed to get health status for {service_name}: {e}")
            return {}

# Example usage for edge services
def setup_edge_service_discovery():
    consul_sd = ConsulServiceDiscovery()
    
    # Register edge services
    edge_services = [
        ServiceInstance(
            id="edge-api-1",
            name="edge-api",
            address="192.168.1.10",
            port=8080,
            tags=["api", "edge", "v1"],
            health_check="http://192.168.1.10:8080/health"
        ),
        ServiceInstance(
            id="edge-data-processor-1",
            name="edge-data-processor",
            address="192.168.1.20",
            port=8081,
            tags=["processor", "edge", "iot"],
            health_check="http://192.168.1.20:8081/health"
        )
    ]
    
    for service in edge_services:
        consul_sd.register_service(service)
    
    # Discover services
    api_services = consul_sd.discover_services("edge-api")
    print(f"Discovered API services: {json.dumps(api_services, indent=2)}")
    
    # Get health status
    health = consul_sd.get_service_health("edge-api")
    print(f"API service health: {json.dumps(health, indent=2)}")

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    setup_edge_service_discovery()
```

## Network Security

### IPTables Edge Firewall
```bash
#!/bin/bash
# edge-firewall-setup.sh

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established and related connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow SSH (restrict to management network)
iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/8 -j ACCEPT

# Allow HTTP/HTTPS for edge services
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow Kubernetes API server
iptables -A INPUT -p tcp --dport 6443 -s 192.168.0.0/16 -j ACCEPT

# Allow kubelet API
iptables -A INPUT -p tcp --dport 10250 -s 192.168.0.0/16 -j ACCEPT

# Allow NodePort services
iptables -A INPUT -p tcp --dport 30000:32767 -j ACCEPT

# Allow ICMP (ping)
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# Allow DNS
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -j ACCEPT

# Allow NTP
iptables -A INPUT -p udp --dport 123 -j ACCEPT

# Log dropped packets
iptables -A INPUT -j LOG --log-prefix "DROPPED INPUT: "
iptables -A FORWARD -j LOG --log-prefix "DROPPED FORWARD: "

# Rate limiting for SSH
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 -j DROP

# Save rules
iptables-save > /etc/iptables/rules.v4

echo "Edge firewall configuration completed"
```

## Best Practices

### 1. Network Architecture
- Design for network partitions and intermittent connectivity
- Implement redundant network paths
- Use network segmentation for security
- Plan for bandwidth optimization

### 2. Service Discovery
- Use distributed service discovery mechanisms
- Implement health checking and automatic failover
- Cache service information locally
- Plan for service mesh integration

### 3. Traffic Management
- Implement QoS policies for critical traffic
- Use traffic shaping to manage bandwidth
- Implement load balancing for high availability
- Monitor network performance metrics

### 4. Security
- Implement network segmentation and micro-segmentation
- Use encrypted communication channels
- Implement proper firewall rules
- Monitor network traffic for anomalies

### 5. Monitoring and Troubleshooting
- Implement comprehensive network monitoring
- Use network performance metrics
- Set up alerting for network issues
- Plan for network troubleshooting procedures