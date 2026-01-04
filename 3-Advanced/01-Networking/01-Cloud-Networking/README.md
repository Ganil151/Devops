# Cloud Networking for DevOps

Multi-cloud and hybrid networking architectures for modern cloud-native applications. This section covers AWS, Azure, GCP networking services, interconnectivity solutions, and global network optimization.

## 🎯 Learning Objectives

- Master cloud networking services across major providers
- Design multi-cloud and hybrid architectures
- Implement cloud interconnectivity solutions
- Optimize global network performance
- Secure cloud network communications

## ☁️ AWS Networking Services

### Virtual Private Cloud (VPC)

**VPC Architecture:**
```
┌─────────────────────────────────────────┐
│              AWS VPC                    │
│  CIDR: 10.0.0.0/16                     │
│                                         │
│  ┌─────────────┐    ┌─────────────┐     │
│  │Public Subnet│    │Private Subnet│    │
│  │10.0.1.0/24  │    │10.0.2.0/24   │    │
│  │             │    │              │    │
│  │[NAT Gateway]│    │[App Servers] │    │
│  │[Bastion]    │    │[Databases]   │    │
│  └─────────────┘    └─────────────┘     │
│         │                   │           │
│  ┌─────────────┐    ┌─────────────┐     │
│  │Internet GW  │    │  VPC Endpoint│    │
│  └─────────────┘    └─────────────┘     │
└─────────────────────────────────────────┘
```

**Terraform VPC Configuration:**
```hcl
# vpc.tf
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "main-vpc"
    Environment = "production"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "main-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  count = length(var.availability_zones)
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "public-subnet-${count.index + 1}"
    Type = "public"
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  count = length(var.availability_zones)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "private-subnet-${count.index + 1}"
    Type = "private"
  }
}

# NAT Gateway
resource "aws_eip" "nat" {
  count  = length(aws_subnet.public)
  domain = "vpc"
  
  tags = {
    Name = "nat-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "main" {
  count = length(aws_subnet.public)
  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  
  tags = {
    Name = "nat-gateway-${count.index + 1}"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table" "private" {
  count  = length(aws_nat_gateway.main)
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }
  
  tags = {
    Name = "private-rt-${count.index + 1}"
  }
}
```

### AWS Transit Gateway

**Multi-VPC Connectivity:**
```hcl
# transit-gateway.tf
resource "aws_ec2_transit_gateway" "main" {
  description                     = "Main Transit Gateway"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  
  tags = {
    Name = "main-tgw"
  }
}

# VPC Attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachments" {
  count = length(var.vpc_ids)
  
  subnet_ids         = var.subnet_ids[count.index]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = var.vpc_ids[count.index]
  
  tags = {
    Name = "tgw-attachment-${count.index + 1}"
  }
}

# Route Table
resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  
  tags = {
    Name = "main-tgw-rt"
  }
}

# Routes
resource "aws_ec2_transit_gateway_route" "vpc_routes" {
  count = length(var.vpc_cidrs)
  
  destination_cidr_block         = var.vpc_cidrs[count.index]
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_attachments[count.index].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}
```

### AWS Direct Connect

**Hybrid Connectivity:**
```hcl
# direct-connect.tf
resource "aws_dx_connection" "main" {
  name      = "main-dx-connection"
  bandwidth = "1Gbps"
  location  = "EqDC2"
  
  tags = {
    Name = "main-dx"
  }
}

resource "aws_dx_virtual_interface" "private" {
  connection_id = aws_dx_connection.main.id
  
  name           = "private-vif"
  vlan           = 100
  address_family = "ipv4"
  bgp_asn        = 65000
  
  route_filter_prefixes = [
    "10.0.0.0/16",
    "172.16.0.0/12"
  ]
  
  tags = {
    Name = "private-vif"
  }
}

# Direct Connect Gateway
resource "aws_dx_gateway" "main" {
  name            = "main-dx-gateway"
  amazon_side_asn = "64512"
}

resource "aws_dx_gateway_association" "main" {
  dx_gateway_id         = aws_dx_gateway.main.id
  associated_gateway_id = aws_ec2_transit_gateway.main.id
}
```

## 🔷 Azure Networking Services

### Virtual Network (VNet)

**Azure VNet Configuration:**
```hcl
# azure-vnet.tf
resource "azurerm_resource_group" "main" {
  name     = "networking-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "main" {
  name                = "main-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  tags = {
    Environment = "production"
  }
}

# Subnets
resource "azurerm_subnet" "web" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "data" {
  name                 = "data-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Network Security Groups
resource "azurerm_network_security_group" "web" {
  name                = "web-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
```

### Azure Virtual WAN

**Global Network Architecture:**
```hcl
# virtual-wan.tf
resource "azurerm_virtual_wan" "main" {
  name                = "main-vwan"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  
  type = "Standard"
  
  tags = {
    Environment = "production"
  }
}

resource "azurerm_virtual_hub" "east_us" {
  name                = "eastus-hub"
  resource_group_name = azurerm_resource_group.main.name
  location            = "East US"
  virtual_wan_id      = azurerm_virtual_wan.main.id
  address_prefix      = "10.1.0.0/24"
}

resource "azurerm_virtual_hub" "west_us" {
  name                = "westus-hub"
  resource_group_name = azurerm_resource_group.main.name
  location            = "West US"
  virtual_wan_id      = azurerm_virtual_wan.main.id
  address_prefix      = "10.2.0.0/24"
}

# VNet Connections
resource "azurerm_virtual_hub_connection" "east_connection" {
  name                      = "east-vnet-connection"
  virtual_hub_id            = azurerm_virtual_hub.east_us.id
  remote_virtual_network_id = azurerm_virtual_network.east_vnet.id
}
```

## 🌐 Google Cloud Platform Networking

### VPC and Subnets

**GCP VPC Configuration:**
```hcl
# gcp-vpc.tf
resource "google_compute_network" "main" {
  name                    = "main-vpc"
  auto_create_subnetworks = false
  routing_mode           = "GLOBAL"
}

resource "google_compute_subnetwork" "web" {
  name          = "web-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.main.id
  
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/16"
  }
}

resource "google_compute_subnetwork" "app" {
  name          = "app-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = "us-central1"
  network       = google_compute_network.main.id
}

# Firewall Rules
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.main.name
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.main.name
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = ["10.0.0.0/8"]
}
```

### Cloud Interconnect

**Dedicated Interconnect:**
```hcl
# interconnect.tf
resource "google_compute_interconnect_attachment" "main" {
  name                     = "main-interconnect"
  edge_availability_domain = "AVAILABILITY_DOMAIN_1"
  type                     = "DEDICATED"
  router                   = google_compute_router.main.id
  region                   = "us-central1"
  
  vlan_tag8021q = 100
}

resource "google_compute_router" "main" {
  name    = "main-router"
  region  = "us-central1"
  network = google_compute_network.main.id
  
  bgp {
    asn = 64514
  }
}

resource "google_compute_router_interface" "main" {
  name       = "main-interface"
  router     = google_compute_router.main.name
  region     = "us-central1"
  ip_range   = "169.254.1.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.main.name
}
```

## 🌍 Multi-Cloud Networking

### Cross-Cloud VPN

**AWS to Azure VPN:**
```hcl
# aws-azure-vpn.tf

# AWS Side
resource "aws_vpn_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "main-vpn-gateway"
  }
}

resource "aws_customer_gateway" "azure" {
  bgp_asn    = 65000
  ip_address = azurerm_public_ip.vpn_gateway.ip_address
  type       = "ipsec.1"
  
  tags = {
    Name = "azure-customer-gateway"
  }
}

resource "aws_vpn_connection" "azure" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.azure.id
  type                = "ipsec.1"
  static_routes_only  = true
  
  tags = {
    Name = "aws-azure-vpn"
  }
}

# Azure Side
resource "azurerm_public_ip" "vpn_gateway" {
  name                = "vpn-gateway-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "main" {
  name                = "main-vpn-gateway"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  type     = "Vpn"
  vpn_type = "RouteBased"
  
  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"
  
  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }
}
```

### Service Mesh Across Clouds

**Istio Multi-Cloud Setup:**
```yaml
# istio-multicloud.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: control-plane
spec:
  values:
    pilot:
      env:
        EXTERNAL_ISTIOD: true
    global:
      meshID: mesh1
      multiCluster:
        clusterName: aws-cluster
      network: aws-network
---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: cross-network-gateway
  namespace: istio-system
spec:
  selector:
    istio: eastwestgateway
  servers:
  - port:
      number: 15443
      name: tls
      protocol: TLS
    tls:
      mode: ISTIO_MUTUAL
    hosts:
    - "*.local"
---
apiVersion: v1
kind: Service
metadata:
  name: cross-cloud-service
  annotations:
    networking.istio.io/exportTo: "*"
spec:
  ports:
  - port: 80
    name: http
  selector:
    app: web-app
```

## 🚀 Global Network Optimization

### Content Delivery Networks (CDN)

**CloudFlare CDN Configuration:**
```yaml
# cloudflare-cdn.tf
resource "cloudflare_zone" "main" {
  zone = "example.com"
  plan = "pro"
}

resource "cloudflare_record" "www" {
  zone_id = cloudflare_zone.main.id
  name    = "www"
  value   = aws_lb.main.dns_name
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_page_rule" "cache_everything" {
  zone_id  = cloudflare_zone.main.id
  target   = "www.example.com/static/*"
  priority = 1
  
  actions {
    cache_level = "cache_everything"
    edge_cache_ttl = 86400
  }
}

resource "cloudflare_load_balancer" "main" {
  zone_id = cloudflare_zone.main.id
  name    = "main-lb"
  
  fallback_pool_id = cloudflare_load_balancer_pool.aws.id
  default_pool_ids = [
    cloudflare_load_balancer_pool.aws.id,
    cloudflare_load_balancer_pool.azure.id
  ]
  
  description = "Multi-cloud load balancer"
  proxied     = true
}

resource "cloudflare_load_balancer_pool" "aws" {
  name = "aws-pool"
  
  origins {
    name    = "aws-origin"
    address = aws_lb.main.dns_name
    enabled = true
  }
  
  description = "AWS origin pool"
  enabled     = true
}
```

### Global Load Balancing

**AWS Global Accelerator:**
```hcl
# global-accelerator.tf
resource "aws_globalaccelerator_accelerator" "main" {
  name            = "main-accelerator"
  ip_address_type = "IPV4"
  enabled         = true
  
  attributes {
    flow_logs_enabled   = true
    flow_logs_s3_bucket = aws_s3_bucket.flow_logs.bucket
    flow_logs_s3_prefix = "flow-logs/"
  }
}

resource "aws_globalaccelerator_listener" "main" {
  accelerator_arn = aws_globalaccelerator_accelerator.main.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"
  
  port_range {
    from_port = 80
    to_port   = 80
  }
  
  port_range {
    from_port = 443
    to_port   = 443
  }
}

resource "aws_globalaccelerator_endpoint_group" "us_east" {
  listener_arn = aws_globalaccelerator_listener.main.id
  
  endpoint_configuration {
    endpoint_id = aws_lb.us_east.arn
    weight      = 100
  }
  
  health_check_grace_period_seconds = 30
  health_check_interval_seconds     = 30
  health_check_path                 = "/health"
  health_check_protocol             = "HTTP"
  health_check_port                 = 80
  threshold_count                   = 3
  traffic_dial_percentage           = 100
}
```

## 🔒 Cloud Network Security

### Zero Trust Architecture

**AWS Zero Trust Implementation:**
```hcl
# zero-trust.tf
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-west-2.s3"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::secure-bucket/*"
        ]
        Condition = {
          StringEquals = {
            "aws:PrincipalTag/Department" = "Engineering"
          }
        }
      }
    ]
  })
}

# Private DNS
resource "aws_route53_resolver_endpoint" "inbound" {
  name      = "inbound-resolver"
  direction = "INBOUND"
  
  security_group_ids = [aws_security_group.resolver.id]
  
  ip_address {
    subnet_id = aws_subnet.private[0].id
  }
  
  ip_address {
    subnet_id = aws_subnet.private[1].id
  }
}

# Network ACLs for micro-segmentation
resource "aws_network_acl" "web_tier" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.web[*].id
  
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.2.0/24"  # App tier only
    from_port  = 8080
    to_port    = 8080
  }
}
```

## 📊 Network Monitoring and Observability

### Multi-Cloud Monitoring

**Prometheus Multi-Cloud Setup:**
```yaml
# prometheus-multicloud.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    
    scrape_configs:
    # AWS CloudWatch metrics
    - job_name: 'aws-cloudwatch'
      ec2_sd_configs:
      - region: us-west-2
        port: 9100
      relabel_configs:
      - source_labels: [__meta_ec2_tag_Environment]
        target_label: environment
    
    # Azure Monitor metrics
    - job_name: 'azure-monitor'
      azure_sd_configs:
      - subscription_id: "subscription-id"
        resource_group: "monitoring-rg"
        port: 9100
    
    # GCP Monitoring
    - job_name: 'gcp-monitoring'
      gce_sd_configs:
      - project: "project-id"
        zone: "us-central1-a"
        port: 9100
    
    # Network performance monitoring
    - job_name: 'network-performance'
      static_configs:
      - targets: ['network-exporter:9116']
      metrics_path: /probe
      params:
        module: [icmp]
      relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: network-exporter:9116
```

### Network Flow Analysis

**VPC Flow Logs Analysis:**
```python
#!/usr/bin/env python3
import boto3
import json
from datetime import datetime, timedelta

class VPCFlowAnalyzer:
    def __init__(self, region='us-west-2'):
        self.ec2 = boto3.client('ec2', region_name=region)
        self.logs = boto3.client('logs', region_name=region)
    
    def analyze_traffic_patterns(self, vpc_id, hours=24):
        # Get flow logs
        end_time = datetime.utcnow()
        start_time = end_time - timedelta(hours=hours)
        
        log_group = f"/aws/vpc/flowlogs/{vpc_id}"
        
        query = """
        fields @timestamp, srcaddr, dstaddr, srcport, dstport, protocol, packets, bytes
        | filter @timestamp >= "{}" and @timestamp <= "{}"
        | stats sum(bytes) as total_bytes by srcaddr, dstaddr
        | sort total_bytes desc
        | limit 100
        """.format(start_time.isoformat(), end_time.isoformat())
        
        response = self.logs.start_query(
            logGroupName=log_group,
            startTime=int(start_time.timestamp()),
            endTime=int(end_time.timestamp()),
            queryString=query
        )
        
        return response['queryId']
    
    def detect_anomalies(self, vpc_id):
        # Detect unusual traffic patterns
        query = """
        fields @timestamp, srcaddr, dstaddr, action
        | filter action = "REJECT"
        | stats count() as rejected_count by srcaddr
        | sort rejected_count desc
        | limit 20
        """
        
        # Implementation for anomaly detection
        pass
    
    def generate_report(self, analysis_results):
        report = {
            'timestamp': datetime.utcnow().isoformat(),
            'top_talkers': analysis_results.get('top_talkers', []),
            'rejected_connections': analysis_results.get('rejected', []),
            'protocol_distribution': analysis_results.get('protocols', {}),
            'recommendations': []
        }
        
        # Add recommendations based on analysis
        if len(report['rejected_connections']) > 100:
            report['recommendations'].append(
                "High number of rejected connections detected. Review security group rules."
            )
        
        return report

# Usage
analyzer = VPCFlowAnalyzer()
query_id = analyzer.analyze_traffic_patterns('vpc-12345678')
```

## ✅ Knowledge Check

- [ ] Design multi-cloud network architectures
- [ ] Implement cloud interconnectivity solutions
- [ ] Configure global load balancing and CDN
- [ ] Secure cloud network communications
- [ ] Monitor multi-cloud network performance
- [ ] Optimize global network latency
- [ ] Implement zero trust networking

## 🔗 Next Steps

- [Network Automation](../Network-Automation/) - Cloud network automation
- [Performance Optimization](../Performance-Optimization/) - Global optimization
- [Service Mesh](../Service-Mesh/) - Multi-cloud service mesh