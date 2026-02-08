# Infrastructure Design Patterns & Architectural Audit

This document serves as a reference for the 17 core infrastructure models and provides a decision matrix for modern architectural choices.

## 🏛️ The 17 Infrastructure Types

| Type | Name | Definition | Key Tools |
|---|---|---|---|
| 1 | **Enterprise** | Multi-account, high-governance environments. | AWS Organizations, Control Tower |
| 2 | **Cloud-Native** | Designed for the cloud; dynamic and resilient. | Kubernetes, Prometheus, Helm |
| 3 | **Hybrid** | Bridging on-premise data centers with the cloud. | Site-to-Site VPN, Direct Connect |
| 4 | **Multi-Cloud** | Operating across AWS, Azure, and GCP. | Terraform, Spacelift, Crossplane |
| 5 | **Edge** | Processing data closer to the user. | CloudFront, Lambda@Edge, IoT |
| 6 | **Serverless** | Zero server management; purely event-driven. | AWS Lambda, SQS, DynamoDB |
| 7 | **On-Premise** | Traditional physical data center management. | Rack management, SAN, UPS |
| 8 | **Containerized** | Standardized, portable application packaging. | Docker, ECS, Docker Compose |
| 9 | **Monolithic** | Single-tier, tightly coupled applications. | Traditional EC2, VM Images |
| 10 | **Microservices** | Highly decoupled, independent services. | Service Mesh (Istio), gRPC |
| 11 | **Event-Driven** | Asynchronous, reactive systems. | EventBridge, SNS, Kafka |
| 12 | **Bare Metal** | Physical hardware provisioning without OS. | Tinkerbell, MaaS, Ironic |
| 13 | **Virtualized** | Virtual Machine-centric infrastructure. | VMware, KVM, Nutanix |
| 14 | **Software-Defined** | Programmable networking and storage. | Cilium, Software-Defined Storage |
| 15 | **Immutable** | Zero in-place updates; always re-deploy. | Packer, Golden AMI, Blue/Green |
| 16 | **Dynamic** | Ephemeral, autoscaling environments. | ASGs, Karpenter, Spot Fleet |
| 17 | **Legacy** | Technical debt targets for migration. | Lift-and-Shift, Refactoring |

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

To ensure consistency across any new IaC project, use the following structure:

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

## 🌳 Architectural Tree Diagrams

### 1. Cloud-Native (EKS-based)
```text
cloud-native-stack/
├── iac/
│   ├── terraform/
│   │   ├── modules/ (vpc, eks, rds)
│   │   └── envs/ (dev, prod)
│   └── helm/
│       └── petclinic-charts/
└── app/
    ├── src/
    └── Dockerfile (Multi-stage)
```

### 2. Hybrid (AWS + On-Prem VPN)
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

### 3. Serverless (Event-Driven)
```text
serverless-backend/
├── functions/
│   ├── processor/ (lambda_handler.py)
│   └── authorizer/ (auth.py)
├── events/
│   └── s3-triggers.json
└── template.yaml (SAM or Serverless Framework)
```
