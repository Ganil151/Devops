# ☁️ Cloud Service Models: Shared Responsibility
*Version 1.0 | Detailed Analysis of IaaS, PaaS, and SaaS*

---

## 🏛️ Executive Summary
This guide explains the three primary cloud service models (IaaS, PaaS, SaaS) through the lens of the **Shared Responsibility Model**. It answers the critical question: "Who is responsible for patching the OS?"

---

## 🏗️ Technical Pillars

### 1. IaaS (Infrastructure as a Service)
- **Deep-Dive**: You are renting virtual hardware. The provider manages the physical server and the hypervisor (Xen/Nitro).
- **Responsibility**:
  - **Provider**: Hardware, Cooling, Physical Networking, Hypervisor stability.
  - **Customer**: EVERYTHING ELSE (OS kernel, Drivers, Application, Security patches, Firewall).
- **Visual Anchor**: <img src="https://raw.githubusercontent.com/Ganil151/Devops/main/01-Beginner/01-Phase-1/07-Cloud-Foundations/REFERENCE/assets/iaas-responsibility.webp" alt="IaaS Responsibility" width="600">

### 2. PaaS (Platform as a Service)
- **Deep-Dive**: You are renting a managed execution environment (e.g., Python runtime, Node.js). The OS and underlying VM are hidden.
- **Responsibility**:
  - **Provider**: OS Patching, Auto-scaling logic, Run-time environment security.
  - **Customer**: Source code, Data, and simple application configuration.
- **Visual Anchor**: <img src="https://raw.githubusercontent.com/Ganil151/Devops/main/01-Beginner/01-Phase-1/07-Cloud-Foundations/REFERENCE/assets/paas-responsibility.webp" alt="PaaS Responsibility" width="600">

### 3. SaaS (Software as a Service)
- **Deep-Dive**: You are consuming an application. The provider manages the entire stack.
- **Responsibility**:
  - **Provider**: Security of data, functionality of app, uptime.
  - **Customer**: User identity (SSO), data access policy (Who can see what?).

---

## ⚙️ Real-World Scenario: The "Dirty" Patch
**Scenario**: A massive security vulnerability (like Log4j) is discovered.
- **In IaaS**: You must immediately SSH into every server and update the library manually or via Ansible.
- **In SaaS**: You do nothing; the vendor patches it in the background before you even finish your morning coffee.

---

## 🧪 Quick Exercise
Categorize the following AWS services into IaaS, PaaS, or SaaS:
1. **S3**: ________ (Hint: Managed storage)
2. **EC2**: ________
3. **Lambda**: ________
4. **Office 365**: ________

---
**Next Step**: [Deployment Models](../deployment-models/deployment-models-guide.md)
