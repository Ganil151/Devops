# 🏗️ Part 04: Platform Engineering & IDPs

DevOps focuses on the *process*; Platform Engineering focuses on the *product*. This phase teaches you how to build internal platforms that provide a "Golden Path" for developers, reducing cognitive load and increasing velocity.

## Core Concept: The Internal Developer Portal (IDP)
**[REFERENCE: Internal Developer Platforms](./reference/internal-developer-platforms-ref.md)**

Organizing complexity through a "Golden Path" for engineers:
- **Backstage Architecture**: Utilizing the industry-standard framework to centralize discovery, documentation, and service health.
- **Software Templates**: Providing "Push-Button" service creation that automatically follows security and architectural standards.
- **TechDocs-as-Code**: Bridging the gap between engineering and knowledge through distributed metadata.

## Enterprise Governance: The Platform-as-a-Product
**[REFERENCE: Database SRE \u0026 Platforms](./reference/database-sre-platform-ref.md)**

Scaling infrastructure through self-service and strict guardrails:
- **Managed State (DBaaS)**: Encapsulating database lifecycle (backups, HA, encryption) behind declarative APIs using Crossplane or ACK.
- **Ownership Enforcement**: Mandating metadata attribution to ensure every cloud resource is linked to a specific team and budget.
- **Automated Guardrails**: Implementing "Health Scores" that automatically flag or block services that deviate from compliance standards.
- **Zero-Touch Provisioning**: Moving away from ticket-based infrastructure to fully automated, identity-driven self-service.

---

## 🏛️ The Core Concept
Platform Engineering is the discipline of designing and building toolchains and workflows that enable self-service capabilities for software engineering organizations in the cloud-native era.

### Why for Advanced DevOps?
1.  **Reduced Cognitive Load**: Developers don't need to know how to write complex Terraform/Helm for every new microservice.
2.  **Standards-by-Default**: Every service created through the platform automatically has the right logging, security, and alerting setup.
3.  **Scalability**: A small Platform team (5-10 people) can support hundreds of developers without becoming a bottleneck.

---

## 📚 Modules in This Part

### 1️⃣ [01-Backstage-IDP](./01-backstage-idp/readme.md)
The industry standard Internal Developer Portal (IDP) by Spotify. Learn how to create Service Catalogs, software templates, and technical documentation as code.

### 2️⃣ [02-Database-SRE](./02-database-sre/readme.md)
Platformizing state. Learn how to provide "Database-as-a-Service" internally using Kubernetes Operators like Crossplane or ACK.

---

## 👔 Career Impact
- **Target Roles**: Platform Engineer, Product Manager (Internal Platforms), IDP Architect.
- **Enterprise Necessity**: Vital for "True DevOps" at scale, where manual ticket-based resource provisioning is no longer viable.

---

**Parent Path**: [Advanced Phase-2: Strategic Skills](../readme.md)
