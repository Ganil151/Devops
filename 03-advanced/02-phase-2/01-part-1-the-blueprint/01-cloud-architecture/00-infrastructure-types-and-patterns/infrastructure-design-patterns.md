# Infrastructure Design Patterns: The 17 Infrastructure Types

This document serves as an advanced architectural reference for defining, auditing, and designing modern infrastructure. It maps various business requirements to specific structural models and provides a standardized IaC blueprint for each.

---

## 🚦 Junior Architect's Decision Matrix

| Requirement | Preferred Infrastructure | Reason |
|---|---|---|
| **Fast Time-to-Market** | Serverless | No infrastructure to manage; focus on code. |
| **Consistent Performance** | Containerized (EKS/ECS) | Dedicated resources with predictable overhead. |
| **Strict Security/Legacy** | On-Premise / Hybrid | Full control over physical hardware and data. |
| **Low Latency globally** | Edge | Reduces round-trip time by caching at the edge. |
| **Cost Control (Low Traffic)** | Serverless | Pay-per-use; zero cost for idle resources. |
| **Complex Orchestration** | Cloud-Native (K8s) | Advanced networking, storage, and auto-healing. |

---

## 📂 Standardized IaC Project Structure (Universal)

```text
project-root/
├── iac/
│   ├── modules/          # Reusable, atomic components
│   │   ├── vpc/
│   │   ├── security/
│   │   └── database/
│   ├── envs/             # Environment-specific variables
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   └── global/           # Cross-environment settings
│       ├── iam-roles.tf
│       ├── dns-zones.tf
│       └── backend.tf    # Remote state configuration
├── scripts/              # Automation and helper scripts
└── documentation/        # Architecture diagrams and README
```

---

## 🌳 The 17 Architectural Tree Diagrams

### 1. Enterprise (Multi-Account/Governance)
```text
enterprise-org/
├── terraform-root/
│   ├── organizational-units/
│   │   ├── security/ (Log Archive, Audit)
│   │   ├── workloads/ (Prod, Staging)
│   │   └── shared-services/ (Transit Gateway, DNS)
│   ├── scp-policies/ (Service Control Policies)
│   └── networking/ (Shared VPC, Hub-and-Spoke)
```

### 2. Cloud-Native (Kubernetes-Native)
```text
cloud-native-stack/
├── iac/
│   ├── terraform/
│   │   ├── modules/ (vpc, eks, rds)
│   │   └── envs/ (dev, prod)
│   └── helm/
│       └── web-app-charts/
└── app/
    ├── src/
    └── Dockerfile (Multi-stage)
```

### 3. Hybrid (Bridge Connectivity)
```text
hybrid-architecture/
├── connectivity/
│   ├── vpn-gateway.tf
│   └── customer-gateway.tf
├── site-to-site/
│   └── bgp-configs/
└── shared-resources/
    └── active-directory-connector/
```

### 4. Multi-Cloud (Cross-Provider)
```text
multi-cloud-deployment/
├── providers/
│   ├── aws/ (S3, EKS)
│   ├── azure/ (Resource Groups, AKS)
│   └── gcp/ (Project, GKE)
├── common-modules/
│   └── compute-abstraction/
└── backend-locking/ (Terraform Cloud/Spacelift)
```

### 5. Edge (Low Latency/Global)
```text
edge-optimized-app/
├── edge-logic/
│   ├── lambda-at-edge/ (auth.js, headers.js)
│   └── cloudfront-functions/
├── waf-rules/ (Geo-blocking, IP Sets)
└── static-content/ (S3 Origin)
```

### 6. Serverless (Purely Event-Driven)
```text
serverless-backend/
├── functions/
│   ├── processor/ (lambda_handler.py)
│   └── authorizer/ (auth.py)
├── events/
│   └── s3-triggers.json
└── template.yaml (SAM or Serverless Framework)
```

### 7. On-Premise (Physical/Data Center)
```text
on-prem-dc/
├── networking/ (Core Switches, Firewall Rules)
├── storage/ (SAN/NAS Configs)
├── compute/ (Physical Host Inventory)
└── virtualization/ (vSphere/KVM Templates)
```

### 8. Containerized (Docker/ECS)
```text
containerized-service/
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
├── ecs-task-definitions/
└── alb-routing/
```

### 9. Monolithic (Single Unit/VM-Based)
```text
monolithic-application/
├── packer/ (Build Golden Image)
├── app-binary/
├── config/ (One large settings file)
└── iac/ (Single AutoScaling Group + RDS)
```

### 10. Microservices (Decoupled/Service Mesh)
```text
microservices-mesh/
├── services/
│   ├── auth-service/
│   ├── order-service/
│   └── payment-service/
├── mesh-config/ (Istio/Linkerd manifests)
└── api-gateway/ (Kong/Apigee)
```

### 11. Event-Driven (Pub-Sub/Reactive)
```text
event-driven-engine/
├── event-bus/ (EventBridge/Kafka clusters)
├── producers/ (Order Created, User Login)
├── consumers/ (Email Notifier, Invoice Gen)
└── schemas/ (Avro/Protobuf definitions)
```

### 12. Bare Metal (Physical Provisioning)
```text
bare-metal-provisioner/
├── tftp-pxe/ (Boot images)
├── metadata-service/ (Cloud-init for metal)
├── hardware-profiles/ (Dell/HP specific configs)
└── os-images/ (Base RAW/ISO)
```

### 13. Virtualized (Hypervisor-Hosted)
```text
virtual-environment/
├── templates/ (Windows-Server-2022, Ubuntu-24.04)
├── hypervisor-cluster/ (ESXi/Xen settings)
└── dynamic-vms/ (Vagrant/Terraform Libvirt)
```

### 14. Software-Defined (SDN/SDS)
```text
software-defined-stack/
├── sdn/ (Cilium/Calico policies)
├── sds/ (Ceph/Rook storage classes)
└── control-plane/ (Operator/Controller configs)
```

### 15. Immutable (Standardized/Golden Image)
```text
immutable-infra/
├── pipeline-ci-images/ (Build images only)
├── artifacts/ (Versioned AMIs/Images)
└── blue-green-deployment/ (Traffic switching)
```

### 16. Dynamic (Elastic/Autoscaling)
```text
dynamic-env/
├── scaling-policies/ (CPU-based, Memory-based)
├── warmup-scripts/ (Pre-pulling images)
└── lifecycle-hooks/ (Instance termination logic)
```

### 17. Legacy (Technical Debt/Migration)
```text
legacy-refactor/
├── migration-scripts/ (Database dump/restore)
├── shim-layers/ (Bridges between old and new)
└── legacy-configs/ (Hardcoded IPs, manual docs)
```
