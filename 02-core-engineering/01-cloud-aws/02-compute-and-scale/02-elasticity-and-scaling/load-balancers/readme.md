# Cloud Load Balancing

Comprehensive guide to load balancing concepts, types, and implementation across cloud platforms.

## Load Balancing Fundamentals

### What is Load Balancing?
Load balancing distributes incoming network traffic across multiple servers to ensure no single server becomes overwhelmed, improving application performance, availability, and scalability.

### Key Benefits
- **High Availability**: Eliminates single points of failure
- **Scalability**: Handles increased traffic by distributing load
- **Performance**: Reduces response times and latency
- **Reliability**: Provides fault tolerance and redundancy
- **Resource Optimization**: Maximizes server utilization

## Load Balancer Types

### By OSI Layer

#### Layer 4 (Transport Layer)
```bash
# Network Load Balancers
- TCP/UDP traffic distribution
- IP and port-based routing
- High performance, low latency
- Protocol-agnostic
```

#### Layer 7 (Application Layer)
```bash
# Application Load Balancers
- HTTP/HTTPS traffic distribution
- Content-based routing
- SSL termination
- Advanced routing rules
```

### By Deployment Model

#### Hardware Load Balancers
- Physical appliances (F5, Citrix NetScaler)
- High performance and reliability
- Expensive and less flexible

#### Software Load Balancers
- Virtual appliances or software solutions
- Cost-effective and flexible
- Examples: HAProxy, NGINX, Apache HTTP Server

#### Cloud Load Balancers
- Managed services by cloud providers
- Auto-scaling and high availability
- Pay-as-you-use pricing model

## Cloud Provider Load Balancers

### AWS Load Balancers

#### Application Load Balancer (ALB)
```yaml
# Layer 7 HTTP/HTTPS load balancer
Features:
  - Content-based routing
  - Host-based routing
  - Path-based routing
  - WebSocket support
  - HTTP/2 support
  - SSL termination

Use Cases:
  - Web applications
  - Microservices
  - Container-based applications
```

#### Network Load Balancer (NLB)
```yaml
# Layer 4 TCP/UDP load balancer
Features:
  - Ultra-high performance
  - Static IP addresses
  - Preserve source IP
  - Low latency
  - Millions of requests per second

Use Cases:
  - Gaming applications
  - IoT applications
  - Real-time communications
```

#### Gateway Load Balancer (GWLB)
```yaml
# Layer 3 Gateway load balancer
Features:
  - Third-party virtual appliances
  - Transparent network gateway
  - GENEVE protocol
  - Centralized deployment

Use Cases:
  - Firewalls
  - Intrusion detection systems
  - Deep packet inspection
```

### Google Cloud Load Balancers

#### Global External Application Load Balancer
```yaml
# Global HTTP(S) load balancer
Features:
  - Anycast IP addresses
  - Global load distribution
  - CDN integration
  - SSL termination
  - URL-based routing

Implementation:
  - Google Front End (GFE)
  - Envoy-based proxy
```

#### Regional External Application Load Balancer
```yaml
# Regional HTTP(S) load balancer
Features:
  - Regional deployment
  - Envoy-based
  - Advanced traffic management
  - WebSocket support

Use Cases:
  - Regional applications
  - Compliance requirements
```

#### Network Load Balancers
```yaml
# TCP/UDP load balancers
Types:
  - Proxy Network Load Balancer
  - Passthrough Network Load Balancer

Features:
  - High performance
  - Regional or global deployment
  - Direct server return (DSR)
```

### Azure Load Balancers

#### Azure Load Balancer
```yaml
# Layer 4 load balancer
Features:
  - TCP/UDP traffic
  - Internal and external
  - High availability
  - Health probes
  - Outbound connectivity

SKUs:
  - Basic: Simple scenarios
  - Standard: Production workloads
```

#### Azure Application Gateway
```yaml
# Layer 7 load balancer
Features:
  - HTTP/HTTPS traffic
  - SSL termination
  - Web Application Firewall (WAF)
  - URL-based routing
  - Multi-site hosting

Use Cases:
  - Web applications
  - API gateways
  - Microservices
```

## Load Balancing Algorithms

### Round Robin
```bash
# Distributes requests sequentially
Server1 -> Server2 -> Server3 -> Server1...

Pros: Simple, equal distribution
Cons: Doesn't consider server capacity
```

### Weighted Round Robin
```bash
# Assigns weights based on server capacity
Server1 (weight: 3) -> Server2 (weight: 1) -> Server3 (weight: 2)

Pros: Considers server differences
Cons: Static weight assignment
```

### Least Connections
```bash
# Routes to server with fewest active connections
Current connections:
Server1: 10 connections
Server2: 5 connections  <- Next request goes here
Server3: 8 connections

Pros: Dynamic load consideration
Cons: May not reflect actual server load
```

### IP Hash
```bash
# Routes based on client IP hash
hash(client_ip) % number_of_servers = target_server

Pros: Session persistence
Cons: Uneven distribution possible
```

### Geographic/Latency-based
```bash
# Routes based on client location or latency
Client in US East -> US East servers
Client in Europe -> European servers

Pros: Reduced latency
Cons: Complex implementation
```

## Health Checks and Monitoring

### Health Check Types
```yaml
HTTP Health Checks:
  - GET /health endpoint
  - Expected status code: 200
  - Response time threshold
  - Custom headers

TCP Health Checks:
  - Port connectivity test
  - Connection establishment
  - Socket-level validation

Custom Health Checks:
  - Application-specific logic
  - Database connectivity
  - External service dependencies
```

### Monitoring Metrics
```bash
# Key performance indicators
- Request rate (requests/second)
- Response time (latency)
- Error rate (4xx/5xx responses)
- Active connections
- Server utilization
- Health check status
```

## SSL/TLS Termination

### SSL Termination Options
```yaml
SSL Termination at Load Balancer:
  Pros:
    - Offloads SSL processing from servers
    - Centralized certificate management
    - Better performance
  Cons:
    - Unencrypted traffic to backend
    - Single point of certificate failure

SSL Pass-through:
  Pros:
    - End-to-end encryption
    - Server-level certificate control
  Cons:
    - Higher server CPU usage
    - No content inspection

SSL Bridging:
  Pros:
    - Content inspection possible
    - Flexible certificate management
  Cons:
    - Higher load balancer CPU usage
    - Complex configuration
```

## Best Practices

### Design Principles
```yaml
High Availability:
  - Multi-AZ deployment
  - Health check configuration
  - Automatic failover
  - Redundant load balancers

Security:
  - SSL/TLS encryption
  - Security groups/firewalls
  - DDoS protection
  - Access logging

Performance:
  - Appropriate algorithm selection
  - Connection pooling
  - Caching strategies
  - CDN integration

Monitoring:
  - Real-time metrics
  - Alerting thresholds
  - Log analysis
  - Performance baselines
```

### Configuration Examples

#### AWS ALB with Auto Scaling
```yaml
# Application Load Balancer configuration
Resources:
  ApplicationLoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Type: application
      Scheme: internet-facing
      SecurityGroups:
        - !Ref ALBSecurityGroup
      Subnets:
        - !Ref PublicSubnet1
        - !Ref PublicSubnet2
  
  TargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      Port: 80
      Protocol: HTTP
      VpcId: !Ref VPC
      HealthCheckPath: /health
      HealthCheckProtocol: HTTP
      HealthCheckIntervalSeconds: 30
      HealthyThresholdCount: 2
      UnhealthyThresholdCount: 3
```

This comprehensive guide covers cloud load balancing concepts, implementations, and best practices across major cloud platforms.

---
## 🧭 Additional Modules
- [Algorithms](algorithms/readme.md)
- [AWS](aws/readme.md)
- [Azure](azure/readme.md)
- [Best Practices](best-practices/readme.md)
- [Configuration](configuration/readme.md)
- [GCP](gcp/readme.md)
- [Monitoring](monitoring/readme.md)
