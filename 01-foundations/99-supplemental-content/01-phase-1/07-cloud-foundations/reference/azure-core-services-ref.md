# 🔵 Azure Core Services: Enterprise Integration
*Version 1.0 | Leveraging Microsoft's Cloud for Scalable Systems*

---

## 📖 Overview
Microsoft Azure is a leading cloud platform favored by enterprises for its deep integration with existing Microsoft technologies like Active Directory and Windows Server.

---

## 🏗️ Technical Pillars (Compute)

### Azure Virtual Machines (VM)
**Definition**: On-demand, scalable computing resources.
**SRE Impact**: Supports both Linux and Windows with comprehensive monitoring via Azure Monitor.

### Azure App Service
**Definition**: A PaaS for building, deploying, and scaling web apps and APIs.
**Advantage**: Built-in CI/CD integration with GitHub Actions and Azure DevOps.

---

## 🗄️ Storage & Databases

### Azure Blob Storage
**Definition**: Massively scalable object storage for any type of unstructured data—images, videos, backups.
**Hierarchy**: Account -> Container -> Blob.

### Azure SQL Database
**Definition**: Fully managed relational database service based on the latest stable version of Microsoft SQL Server.

---

## 🌐 Networking & Identity

### Virtual Network (VNet)
**Definition**: A logically isolated network in Azure. VNets enable Azure resources to communicate with each other, the internet, and on-premises networks.

### Entra ID (Formerly Azure Active Directory)
**Definition**: A cloud-based identity and access management service.
**SRE Advantage**: Unified identity across M365 and Azure resources.

---

## 🚀 Advanced Deployment Tools

- **Azure Kubernetes Service (AKS)**: Managed K8s clusters.
- **ARM Templates / Bicep**: Native IaC for Azure resource deployment.
- **Azure Functions**: Serverless event-driven computing.

---

## 💡 SRE Pro-Tips
- **Resource Groups**: Organize everything into logical containers (Resource Groups) to simplify management and deletion.
- **Azure Advisor**: Regularly check this for personalized recommendations on high availability, security, performance, and cost.
- **Policy**: Use **Azure Policy** to enforce organizational standards and assess compliance at scale.

---
**Next Step**: [GCP Core Services →](./gcp-core-services-ref.md)
