# ☁️ Cloud Computing Models & Service Stacks
*Version 2.0 | The Definitive SRE Architectural Blueprint*

---

## 🏛️ Executive Summary
This reference acts as the **Single Source of Truth** for cloud delivery and deployment models. It moves beyond high-level definitions into the "Under the Hood" mechanics of shared responsibility, latency hurdles, and multi-cloud portability.

---

## 🏗️ Service Delivery Models (Deep-Dive)

### 1. IaaS (Infrastructure as a Service)
**"The Virtual Machine Layer"**
- **Technical Mechanism**: Hypervisor-level access where users provision processing, storage, and networks.
- **Shared Responsibility**:
  - **Provider**: Physical security, Hardware, Virtualization layer (Hypervisor).
  - **Customer**: OS Patching, Middleware, Runtime, Data, and IAM.
- **SRE Focus**: High availability via Auto Scaling Groups (ASG) and instance lifecycle management.
- **Analogy**: Leasing raw land; you build the house, plumbing, and wiring.

### 2. PaaS (Platform as a Service)
**"The Managed Execution Layer"**
- **Technical Mechanism**: Managed runtime environments (like Docker containers or managed JVMs) where the OS and Middleware are abstracted.
- **Shared Responsibility**:
  - **Provider**: OS Patching, Middleware updates, Physical infrastructure.
  - **Customer**: Application Code, Config settings, and Data.
- **SRE Focus**: Deployment pipelines (CI/CD) and application performance monitoring (APM).
- **Analogy**: Staying in a hotel; utilities handled, you just bring your luggage (code).

### 3. SaaS (Software as a Service)
**"The Application Layer"**
- **Technical Mechanism**: Multi-tenant software delivered via browsers or APIs.
- **Shared Responsibility**:
  - **Provider**: Everything from hardware to the application code and data security.
  - **Customer**: Identity (Users), Data access permissions, and Configuration logic.
- **SRE Focus**: API integration reliability and vendor service health monitoring.
- **Analogy**: Renting an apartment; fully furnished, just live in it.

---

## 🌐 Deployment Models & Technical Hurdles

| Model | Architecture | SRE Technical Hurdles |
| :--- | :--- | :--- |
| **Public Cloud** | Multi-tenant shared infra (AWS/Azure/GCP). | **Data Sovereignty**: Ensuring data stays in specific regions (GDPR/HIPAA). |
| **Private Cloud** | Dedicated infra for a single org. | **Capital Expenditure (CapEx)**: High upfront cost for hardware and cooling. |
| **Hybrid Cloud** | Orchestration between Public & Private. | **Latency**: High-frequency apps fail across Direct Connect links without local caching. |
| **Multi-Cloud** | Using multiple providers for resilience. | **Vendor Lock-in**: Avoiding proprietary APIs (e.g., AWS DynamoDB vs. Postgres). |

---

## 🏛️ Multi-Cloud Comparison Table

| Feature | AWS Equivalent | Azure Equivalent | GCP Equivalent |
| :--- | :--- | :--- | :--- |
| **Core Compute** | EC2 | Virtual Machines | Compute Engine |
| **Serverless** | Lambda | Azure Functions | Cloud Functions |
| **Object Store** | S3 | Blob Storage | Cloud Storage |
| **Managed K8s** | EKS | AKS | GKE |
| **Identity** | IAM | Entra ID | Cloud IAM |

---

## 💡 SRE Practical Scenario
**Troubleshooting Scenario**: "I migrated my app to the cloud, but it's 3x slower."
- **Root Cause**: Likely a **Hybrid-Cloud Latency** issue. The application is in AWS, but the database is still on-prem.
- **Solution**: Implement a "Migration Wave" where the DB and App move together, or use an **AWS Direct Connect** with dedicated bandwidth to reduce millisecond round-trips.

---
**Next Step**: [FinOps & Cloud Economics →](./finops-cloud-economics-ref.md)
