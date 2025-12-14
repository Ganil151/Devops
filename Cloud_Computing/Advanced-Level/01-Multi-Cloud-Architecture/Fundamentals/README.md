# Multi-Cloud Fundamentals

Comprehensive guide to multi-cloud strategies, management, and implementation for enterprise environments.

## What is Multi-Cloud?

Multi-cloud is a strategy that uses cloud computing services from multiple cloud providers (AWS, Azure, GCP, etc.) to avoid vendor lock-in, optimize costs, improve resilience, and leverage best-of-breed services from different providers.

## Multi-Cloud vs Hybrid Cloud

### Multi-Cloud Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    Multi-Cloud Strategy                      │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │     AWS     │  │    Azure    │  │     GCP     │        │
│  │             │  │             │  │             │        │
│  │ • EC2       │  │ • VMs       │  │ • Compute   │        │
│  │ • S3        │  │ • Blob      │  │ • Storage   │        │
│  │ • RDS       │  │ • SQL DB    │  │ • Cloud SQL │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│         │                 │                 │              │
│         └─────────────────┼─────────────────┘              │
│                           │                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           Multi-Cloud Management Layer              │   │
│  │  • Terraform  • Kubernetes  • Monitoring           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Hybrid Cloud Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    Hybrid Cloud Strategy                     │
│                                                             │
│  ┌─────────────────────┐    ┌─────────────────────┐        │
│  │    On-Premises      │    │   Public Cloud      │        │
│  │                     │    │                     │        │
│  │ • Physical Servers  │◄──►│ • Virtual Machines  │        │
│  │ • Private Cloud     │    │ • Managed Services  │        │
│  │ • Legacy Systems    │    │ • Auto Scaling      │        │
│  └─────────────────────┘    └─────────────────────┘        │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Hybrid Connectivity                    │   │
│  │  • VPN  • Direct Connect  • ExpressRoute           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Multi-Cloud Benefits

### 1. Avoid Vendor Lock-in
```bash
# Distribute workloads across providers
AWS: Primary compute and storage
Azure: Identity and productivity services
GCP: AI/ML and data analytics

# Use open standards and portable technologies
- Kubernetes for container orchestration
- Terraform for infrastructure as code
- Prometheus for monitoring
- Open-source databases
```

### 2. Best-of-Breed Services
```bash
# Leverage each provider's strengths
AWS Strengths:
- Mature ecosystem (EC2, S3, Lambda)
- Extensive service portfolio
- Strong enterprise adoption

Azure Strengths:
- Microsoft integration (Office 365, AD)
- Hybrid cloud capabilities
- Enterprise Windows workloads

GCP Strengths:
- AI/ML services (TensorFlow, BigQuery)
- Data analytics and processing
- Kubernetes-native services
```

### 3. Geographic Coverage
```bash
# Global presence optimization
AWS: 31+ regions, 99+ availability zones
Azure: 60+ regions, 140+ countries
GCP: 35+ regions, 106+ zones

# Regional compliance requirements
- Data sovereignty laws
- Latency optimization
- Disaster recovery across regions
```

### 4. Risk Mitigation
```bash
# Distributed risk strategy
- Provider outage protection
- Service failure resilience
- Pricing negotiation leverage
- Technology diversification
```

## Multi-Cloud Challenges

### 1. Complexity Management
```bash
# Operational complexity
- Multiple APIs and interfaces
- Different service models
- Varying pricing structures
- Diverse security models

# Mitigation strategies:
- Standardized tooling (Terraform, Kubernetes)
- Centralized monitoring and logging
- Unified CI/CD pipelines
- Common security frameworks
```

### 2. Skills and Training
```bash
# Team skill requirements
- Multiple cloud certifications
- Provider-specific knowledge
- Cross-platform integration
- Vendor management

# Training approach:
- Cloud-agnostic fundamentals
- Provider-specific deep dives
- Hands-on multi-cloud labs
- Continuous learning programs
```

### 3. Data Management
```bash
# Data challenges
- Cross-cloud data transfer costs
- Data consistency and synchronization
- Backup and disaster recovery
- Compliance across providers

# Solutions:
- Data replication strategies
- Cross-cloud backup solutions
- Unified data governance
- Compliance automation
```

### 4. Cost Management
```bash
# Cost complexity
- Multiple billing systems
- Different pricing models
- Data transfer charges
- Reserved capacity optimization

# Cost optimization:
- Unified cost monitoring
- Cross-cloud resource optimization
- Automated cost alerts
- Regular cost reviews
```

## Multi-Cloud Architecture Patterns

### 1. Cloud-Agnostic Pattern
```yaml
# Kubernetes deployment across clouds
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multi-cloud-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: multi-cloud-app
  template:
    metadata:
      labels:
        app: multi-cloud-app
    spec:
      containers:
      - name: app
        image: myapp:latest
        ports:
        - containerPort: 8080
        env:
        - name: CLOUD_PROVIDER
          valueFrom:
            configMapKeyRef:
              name: cloud-config
              key: provider
```

### 2. Service-Specific Pattern
```bash
# Distribute services by provider strengths
┌─────────────────────────────────────────────────────────────┐
│                Service Distribution                          │
│                                                             │
│  AWS                    Azure                    GCP        │
│  ├── Compute (EC2)      ├── Identity (AD)       ├── ML/AI   │
│  ├── Storage (S3)       ├── Office 365          ├── BigQuery│
│  ├── Database (RDS)     ├── Windows VMs         ├── Dataflow│
│  └── CDN (CloudFront)   └── Hybrid (Arc)        └── Pub/Sub │
└─────────────────────────────────────────────────────────────┘
```

### 3. Geographic Distribution Pattern
```bash
# Regional deployment strategy
North America: AWS (us-east-1, us-west-2)
Europe: Azure (West Europe, North Europe)
Asia Pacific: GCP (asia-southeast1, asia-northeast1)

# Benefits:
- Reduced latency for regional users
- Compliance with local regulations
- Disaster recovery across continents
```

### 4. Workload-Based Pattern
```bash
# Workload distribution by characteristics
Production Workloads: AWS (mature, stable)
Development/Testing: GCP (cost-effective, innovative)
Enterprise Integration: Azure (Microsoft ecosystem)
AI/ML Workloads: GCP (advanced ML services)
```

## Multi-Cloud Management Tools

### Infrastructure as Code

#### Terraform (Multi-Cloud)
```hcl
# main.tf - Multi-cloud infrastructure
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

# AWS Provider
provider "aws" {
  region = var.aws_region
}

# Azure Provider
provider "azurerm" {
  features {}
}

# GCP Provider
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

# AWS Resources
resource "aws_instance" "web_server" {
  ami           = var.aws_ami
  instance_type = "t3.micro"
  
  tags = {
    Name        = "MultiCloud-AWS-Web"
    Environment = var.environment
    Provider    = "AWS"
  }
}

# Azure Resources
resource "azurerm_resource_group" "main" {
  name     = "multicloud-rg"
  location = var.azure_location
}

resource "azurerm_virtual_machine" "web_server" {
  name                = "multicloud-azure-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  vm_size             = "Standard_B1s"
  
  tags = {
    Environment = var.environment
    Provider    = "Azure"
  }
}

# GCP Resources
resource "google_compute_instance" "web_server" {
  name         = "multicloud-gcp-vm"
  machine_type = "e2-micro"
  zone         = var.gcp_zone
  
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }
  
  network_interface {
    network = "default"
    access_config {}
  }
  
  labels = {
    environment = var.environment
    provider    = "gcp"
  }
}
```

#### Pulumi (Multi-Cloud)
```python
# __main__.py - Pulumi multi-cloud
import pulumi
import pulumi_aws as aws
import pulumi_azure_native as azure
import pulumi_gcp as gcp

# AWS Resources
aws_instance = aws.ec2.Instance(
    "multicloud-aws-instance",
    instance_type="t3.micro",
    ami="ami-0abcdef1234567890",
    tags={
        "Name": "MultiCloud-AWS",
        "Provider": "AWS"
    }
)

# Azure Resources
resource_group = azure.resources.ResourceGroup(
    "multicloud-rg",
    location="East US"
)

azure_vm = azure.compute.VirtualMachine(
    "multicloud-azure-vm",
    resource_group_name=resource_group.name,
    location=resource_group.location,
    vm_size="Standard_B1s",
    tags={
        "Provider": "Azure"
    }
)

# GCP Resources
gcp_instance = gcp.compute.Instance(
    "multicloud-gcp-instance",
    machine_type="e2-micro",
    zone="us-central1-a",
    boot_disk=gcp.compute.InstanceBootDiskArgs(
        initialize_params=gcp.compute.InstanceBootDiskInitializeParamsArgs(
            image="ubuntu-os-cloud/ubuntu-2004-lts"
        )
    ),
    network_interfaces=[gcp.compute.InstanceNetworkInterfaceArgs(
        network="default",
        access_configs=[gcp.compute.InstanceNetworkInterfaceAccessConfigArgs()]
    )],
    labels={
        "provider": "gcp"
    }
)

# Export outputs
pulumi.export("aws_instance_id", aws_instance.id)
pulumi.export("azure_vm_id", azure_vm.id)
pulumi.export("gcp_instance_id", gcp_instance.id)
```

### Container Orchestration

#### Kubernetes Multi-Cloud
```yaml
# multi-cloud-deployment.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cloud-config
data:
  aws-config: |
    provider: aws
    region: us-east-1
  azure-config: |
    provider: azure
    region: eastus
  gcp-config: |
    provider: gcp
    region: us-central1

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multi-cloud-app
spec:
  replicas: 6
  selector:
    matchLabels:
      app: multi-cloud-app
  template:
    metadata:
      labels:
        app: multi-cloud-app
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - multi-cloud-app
              topologyKey: failure-domain.beta.kubernetes.io/zone
      containers:
      - name: app
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"

---
apiVersion: v1
kind: Service
metadata:
  name: multi-cloud-service
spec:
  selector:
    app: multi-cloud-app
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

#### Istio Service Mesh
```yaml
# istio-multi-cloud.yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: multi-cloud-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"

---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: multi-cloud-vs
spec:
  hosts:
  - "*"
  gateways:
  - multi-cloud-gateway
  http:
  - match:
    - headers:
        cloud-preference:
          exact: aws
    route:
    - destination:
        host: aws-service
  - match:
    - headers:
        cloud-preference:
          exact: azure
    route:
    - destination:
        host: azure-service
  - route:
    - destination:
        host: gcp-service
      weight: 34
    - destination:
        host: aws-service
      weight: 33
    - destination:
        host: azure-service
      weight: 33
```

### Monitoring and Observability

#### Prometheus Multi-Cloud Monitoring
```yaml
# prometheus-config.yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "multi-cloud-rules.yml"

scrape_configs:
  # AWS EKS Cluster
  - job_name: 'aws-kubernetes'
    kubernetes_sd_configs:
    - api_server: 'https://aws-eks-cluster.amazonaws.com'
      role: endpoints
    relabel_configs:
    - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
      action: keep
      regex: true
    - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
      action: replace
      target_label: __address__
      regex: ([^:]+)(?::\d+)?;(\d+)
      replacement: $1:$2

  # Azure AKS Cluster
  - job_name: 'azure-kubernetes'
    kubernetes_sd_configs:
    - api_server: 'https://azure-aks-cluster.azurecontainer.io'
      role: endpoints
    relabel_configs:
    - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
      action: keep
      regex: true

  # GCP GKE Cluster
  - job_name: 'gcp-kubernetes'
    kubernetes_sd_configs:
    - api_server: 'https://gcp-gke-cluster.googleapis.com'
      role: endpoints
    relabel_configs:
    - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
      action: keep
      regex: true

alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - alertmanager:9093
```

#### Grafana Multi-Cloud Dashboard
```json
{
  "dashboard": {
    "title": "Multi-Cloud Overview",
    "panels": [
      {
        "title": "AWS Resources",
        "type": "stat",
        "targets": [
          {
            "expr": "count(up{cloud_provider=\"aws\"})",
            "legendFormat": "AWS Instances"
          }
        ]
      },
      {
        "title": "Azure Resources",
        "type": "stat",
        "targets": [
          {
            "expr": "count(up{cloud_provider=\"azure\"})",
            "legendFormat": "Azure Instances"
          }
        ]
      },
      {
        "title": "GCP Resources",
        "type": "stat",
        "targets": [
          {
            "expr": "count(up{cloud_provider=\"gcp\"})",
            "legendFormat": "GCP Instances"
          }
        ]
      },
      {
        "title": "Cross-Cloud Latency",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile latency"
          }
        ]
      }
    ]
  }
}
```

## Multi-Cloud Security

### Identity Federation

#### SAML/OIDC Integration
```yaml
# identity-federation.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: identity-config
data:
  aws-iam-role: "arn:aws:iam::123456789012:role/MultiCloudRole"
  azure-tenant-id: "12345678-1234-1234-1234-123456789012"
  gcp-service-account: "multicloud-sa@project.iam.gserviceaccount.com"
  
---
apiVersion: v1
kind: Secret
metadata:
  name: identity-secrets
type: Opaque
data:
  aws-access-key: <base64-encoded-key>
  azure-client-secret: <base64-encoded-secret>
  gcp-service-key: <base64-encoded-json-key>
```

### Cross-Cloud Encryption

#### HashiCorp Vault Multi-Cloud
```bash
# vault-multi-cloud-config.sh

# Enable cloud auth methods
vault auth enable aws
vault auth enable azure
vault auth enable gcp

# Configure AWS auth
vault write auth/aws/config/client \
    access_key=AKIAIOSFODNN7EXAMPLE \
    secret_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

# Configure Azure auth
vault write auth/azure/config \
    tenant_id=12345678-1234-1234-1234-123456789012 \
    resource=https://management.azure.com/ \
    client_id=12345678-1234-1234-1234-123456789012 \
    client_secret=MySecretValue

# Configure GCP auth
vault write auth/gcp/config \
    credentials=@/path/to/service-account.json

# Create multi-cloud policies
vault policy write multi-cloud-policy - <<EOF
path "secret/data/aws/*" {
  capabilities = ["read", "list"]
}
path "secret/data/azure/*" {
  capabilities = ["read", "list"]
}
path "secret/data/gcp/*" {
  capabilities = ["read", "list"]
}
EOF

# Create roles for each cloud
vault write auth/aws/role/multi-cloud-role \
    auth_type=iam \
    policies=multi-cloud-policy \
    max_ttl=1h \
    bound_iam_principal_arn=arn:aws:iam::123456789012:role/MultiCloudRole

vault write auth/azure/role/multi-cloud-role \
    policies=multi-cloud-policy \
    max_ttl=1h \
    bound_subscription_ids=12345678-1234-1234-1234-123456789012 \
    bound_resource_groups=multicloud-rg

vault write auth/gcp/role/multi-cloud-role \
    type=iam \
    policies=multi-cloud-policy \
    max_ttl=1h \
    bound_service_accounts=multicloud-sa@project.iam.gserviceaccount.com
```

## Multi-Cloud Networking

### Cross-Cloud Connectivity

#### VPN Connections
```bash
# AWS to Azure VPN
# AWS Side
aws ec2 create-vpn-gateway --type ipsec.1
aws ec2 create-customer-gateway \
    --type ipsec.1 \
    --public-ip 203.0.113.12 \
    --bgp-asn 65000

# Azure Side
az network vnet-gateway create \
    --resource-group MultiCloudRG \
    --name AzureVPNGateway \
    --public-ip-address AzureGatewayIP \
    --vnet MultiCloudVNet \
    --gateway-type Vpn \
    --sku VpnGw1 \
    --vpn-type RouteBased

# AWS to GCP VPN
# GCP Side
gcloud compute vpn-gateways create aws-to-gcp-gateway \
    --network=multicloud-network \
    --region=us-central1

gcloud compute vpn-tunnels create aws-tunnel \
    --peer-address=AWS_PUBLIC_IP \
    --shared-secret=SHARED_SECRET \
    --target-vpn-gateway=aws-to-gcp-gateway \
    --region=us-central1
```

#### Direct Connections
```bash
# AWS Direct Connect to Azure ExpressRoute
# Requires physical cross-connection at colocation facility

# AWS Direct Connect
aws directconnect create-connection \
    --location "Equinix DC2" \
    --bandwidth 1Gbps \
    --connection-name "AWS-to-Azure"

# Azure ExpressRoute
az network express-route create \
    --resource-group MultiCloudRG \
    --name AzureExpressRoute \
    --peering-location "Washington DC" \
    --bandwidth 1000 \
    --sku-family MeteredData \
    --sku-tier Standard
```

### Service Mesh Connectivity

#### Consul Connect Multi-Cloud
```hcl
# consul-multi-cloud.hcl
datacenter = "multicloud"
data_dir = "/opt/consul/data"
log_level = "INFO"
server = true
bootstrap_expect = 3

# Multi-cloud federation
primary_datacenter = "aws-east"
retry_join_wan = [
  "consul-aws-1.example.com",
  "consul-azure-1.example.com",
  "consul-gcp-1.example.com"
]

# Service mesh configuration
connect {
  enabled = true
}

ports {
  grpc = 8502
}

# Multi-cloud service discovery
services {
  name = "web"
  tags = ["aws", "production"]
  port = 80
  connect {
    sidecar_service {}
  }
}
```

## Multi-Cloud Data Management

### Data Replication Strategies

#### Cross-Cloud Database Replication
```yaml
# mysql-multi-cloud-replication.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-replication-config
data:
  master.cnf: |
    [mysqld]
    log-bin=mysql-bin
    server-id=1
    binlog-format=ROW
    gtid-mode=ON
    enforce-gtid-consistency=ON
    
  slave.cnf: |
    [mysqld]
    server-id=2
    relay-log=mysql-relay-bin
    log-slave-updates=1
    read-only=1
    gtid-mode=ON
    enforce-gtid-consistency=ON

---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql-master
  labels:
    cloud: aws
spec:
  serviceName: mysql-master
  replicas: 1
  selector:
    matchLabels:
      app: mysql-master
  template:
    metadata:
      labels:
        app: mysql-master
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: root-password
        volumeMounts:
        - name: mysql-config
          mountPath: /etc/mysql/conf.d
        - name: mysql-data
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-config
        configMap:
          name: mysql-replication-config
          items:
          - key: master.cnf
            path: master.cnf
  volumeClaimTemplates:
  - metadata:
      name: mysql-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 100Gi
```

#### Object Storage Synchronization
```bash
#!/bin/bash
# multi-cloud-sync.sh

# Sync between AWS S3, Azure Blob, and GCP Cloud Storage

# AWS S3 to Azure Blob
aws s3 sync s3://aws-bucket/ /tmp/sync-data/
az storage blob upload-batch \
    --destination azure-container \
    --source /tmp/sync-data/ \
    --account-name azurestorageaccount

# AWS S3 to GCP Cloud Storage
gsutil -m rsync -r s3://aws-bucket/ gs://gcp-bucket/

# Azure Blob to GCP Cloud Storage
az storage blob download-batch \
    --destination /tmp/azure-data/ \
    --source azure-container \
    --account-name azurestorageaccount

gsutil -m cp -r /tmp/azure-data/* gs://gcp-bucket/

# Cleanup temporary data
rm -rf /tmp/sync-data/ /tmp/azure-data/
```

### Backup and Disaster Recovery

#### Multi-Cloud Backup Strategy
```yaml
# velero-multi-cloud-backup.yaml
apiVersion: velero.io/v1
kind: BackupStorageLocation
metadata:
  name: aws-backup-location
spec:
  provider: aws
  objectStorage:
    bucket: velero-backups-aws
    prefix: multicloud
  config:
    region: us-east-1

---
apiVersion: velero.io/v1
kind: BackupStorageLocation
metadata:
  name: azure-backup-location
spec:
  provider: azure
  objectStorage:
    bucket: velero-backups-azure
    prefix: multicloud
  config:
    resourceGroup: VeleroBackups
    storageAccount: velerobackupstorage

---
apiVersion: velero.io/v1
kind: BackupStorageLocation
metadata:
  name: gcp-backup-location
spec:
  provider: gcp
  objectStorage:
    bucket: velero-backups-gcp
    prefix: multicloud
  config:
    project: my-gcp-project

---
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: multi-cloud-backup
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  template:
    storageLocation: aws-backup-location
    includedNamespaces:
    - production
    - staging
    ttl: 720h0m0s  # 30 days
```

## Multi-Cloud Cost Optimization

### Cost Monitoring and Analysis

#### Unified Cost Dashboard
```python
# multi-cloud-cost-analyzer.py
import boto3
import azure.mgmt.consumption
import google.cloud.billing

class MultiCloudCostAnalyzer:
    def __init__(self):
        self.aws_client = boto3.client('ce')
        self.azure_client = azure.mgmt.consumption.ConsumptionManagementClient(
            credential, subscription_id
        )
        self.gcp_client = google.cloud.billing.CloudBillingClient()
    
    def get_aws_costs(self, start_date, end_date):
        response = self.aws_client.get_cost_and_usage(
            TimePeriod={
                'Start': start_date,
                'End': end_date
            },
            Granularity='MONTHLY',
            Metrics=['BlendedCost'],
            GroupBy=[
                {
                    'Type': 'DIMENSION',
                    'Key': 'SERVICE'
                }
            ]
        )
        return response['ResultsByTime']
    
    def get_azure_costs(self, start_date, end_date):
        usage_details = self.azure_client.usage_details.list(
            scope=f'/subscriptions/{subscription_id}',
            filter=f"properties/usageStart ge '{start_date}' and properties/usageEnd le '{end_date}'"
        )
        return list(usage_details)
    
    def get_gcp_costs(self, project_id, start_date, end_date):
        # Implementation for GCP billing API
        pass
    
    def generate_unified_report(self):
        # Combine costs from all providers
        aws_costs = self.get_aws_costs('2024-01-01', '2024-01-31')
        azure_costs = self.get_azure_costs('2024-01-01', '2024-01-31')
        gcp_costs = self.get_gcp_costs('my-project', '2024-01-01', '2024-01-31')
        
        return {
            'aws': aws_costs,
            'azure': azure_costs,
            'gcp': gcp_costs,
            'total': self.calculate_total_cost(aws_costs, azure_costs, gcp_costs)
        }
```

### Resource Optimization

#### Multi-Cloud Resource Right-Sizing
```bash
#!/bin/bash
# multi-cloud-rightsizing.sh

# AWS EC2 Right-sizing
aws ce get-rightsizing-recommendation \
    --service EC2-Instance \
    --configuration '{
        "BenefitsConsidered": true,
        "RecommendationTarget": "SAME_INSTANCE_FAMILY"
    }' > aws-rightsizing.json

# Azure VM Right-sizing
az advisor recommendation list \
    --category Cost \
    --output table > azure-rightsizing.txt

# GCP Compute Right-sizing
gcloud recommender recommendations list \
    --project=my-project \
    --recommender=google.compute.instance.MachineTypeRecommender \
    --location=us-central1-a \
    --format=json > gcp-rightsizing.json

# Analyze and generate unified recommendations
python3 analyze-rightsizing.py \
    --aws aws-rightsizing.json \
    --azure azure-rightsizing.txt \
    --gcp gcp-rightsizing.json \
    --output unified-recommendations.json
```

## Multi-Cloud Governance

### Policy Management

#### Open Policy Agent (OPA) Multi-Cloud
```rego
# multi-cloud-policies.rego
package multicloud.security

# Deny resources without proper tags
deny[msg] {
    input.resource_type == "aws_instance"
    not input.tags.Environment
    msg := "AWS EC2 instances must have Environment tag"
}

deny[msg] {
    input.resource_type == "azurerm_virtual_machine"
    not input.tags.Environment
    msg := "Azure VMs must have Environment tag"
}

deny[msg] {
    input.resource_type == "google_compute_instance"
    not input.labels.environment
    msg := "GCP instances must have environment label"
}

# Enforce encryption
deny[msg] {
    input.resource_type == "aws_s3_bucket"
    not input.server_side_encryption_configuration
    msg := "S3 buckets must have encryption enabled"
}

deny[msg] {
    input.resource_type == "azurerm_storage_account"
    input.enable_blob_encryption == false
    msg := "Azure storage accounts must have blob encryption enabled"
}

# Restrict instance sizes
allowed_instance_types := {
    "aws": ["t3.micro", "t3.small", "t3.medium"],
    "azure": ["Standard_B1s", "Standard_B2s", "Standard_B4ms"],
    "gcp": ["e2-micro", "e2-small", "e2-medium"]
}

deny[msg] {
    input.resource_type == "aws_instance"
    not allowed_instance_types.aws[_] == input.instance_type
    msg := sprintf("AWS instance type %v not allowed", [input.instance_type])
}
```

### Compliance Automation

#### Multi-Cloud Compliance Scanning
```yaml
# compliance-scan.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: multi-cloud-compliance-scan
spec:
  schedule: "0 6 * * *"  # Daily at 6 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: compliance-scanner
            image: multicloud/compliance-scanner:latest
            env:
            - name: AWS_REGION
              value: "us-east-1"
            - name: AZURE_SUBSCRIPTION_ID
              valueFrom:
                secretKeyRef:
                  name: azure-credentials
                  key: subscription-id
            - name: GCP_PROJECT_ID
              value: "my-gcp-project"
            command:
            - /bin/bash
            - -c
            - |
              # Scan AWS resources
              aws-compliance-scanner --profile production --output /tmp/aws-results.json
              
              # Scan Azure resources
              azure-compliance-scanner --subscription $AZURE_SUBSCRIPTION_ID --output /tmp/azure-results.json
              
              # Scan GCP resources
              gcp-compliance-scanner --project $GCP_PROJECT_ID --output /tmp/gcp-results.json
              
              # Generate unified compliance report
              compliance-reporter \
                --aws /tmp/aws-results.json \
                --azure /tmp/azure-results.json \
                --gcp /tmp/gcp-results.json \
                --output /tmp/compliance-report.json
              
              # Upload to central reporting system
              curl -X POST \
                -H "Content-Type: application/json" \
                -d @/tmp/compliance-report.json \
                https://compliance-api.company.com/reports
          restartPolicy: OnFailure
```

This comprehensive multi-cloud fundamentals guide provides the foundation for implementing and managing multi-cloud strategies across AWS, Azure, and GCP environments.