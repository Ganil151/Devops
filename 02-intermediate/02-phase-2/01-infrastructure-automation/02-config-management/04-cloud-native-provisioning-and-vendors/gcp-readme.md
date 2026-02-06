# 🟢 Google Cloud Platform (GCP) IaC

![GCP IaC](https://img.shields.io/badge/GCP-IaC-green?style=for-the-badge&logo=googlecloud)

## 📋 Overview
Google Cloud offers two primary native ways to manage infrastructure as code: **Deployment Manager** and the newer, Kubernetes-native **Config Connector**.

### 1. Cloud Deployment Manager
The traditional declarative IaC for GCP.
- **Languages**: YAML, Jinja2, or Python.
- **Best for**: Standard infrastructure deployments not tied to GKE.

### 2. Config Connector
A Kubernetes-native way to manage GCP resources.
- **Languages**: Kubernetes YAML (CRDs).
- **Best for**: Teams already using Kubernetes/GKE who want to manage cloud resources using `kubectl` and GitOps.

---

## 🏗️ Architecture

### Deployment Manager
```mermaid
graph LR
    Template[YAML/Python/Jinja2] -->|gcloud deployment-manager| DM[Deployment Manager API]
    DM --> Resources[GCP Resources]
```

### Config Connector
```mermaid
graph LR
    Manifest[K8s YAML] -->|kubectl apply| CC[Config Connector Operator]
    CC -->|Manage| Azure[GCP Resources]
```

---

## 📂 Module Structure

### 🛠️ [GCP Deployment Manager](./06-gcp-deployment-manager/readme.md)
- [Beginner](./06-gcp-deployment-manager/beginner/readme.md)
- [Intermediate](./06-gcp-deployment-manager/intermediate/readme.md)
- [Advanced](./06-gcp-deployment-manager/advanced/readme.md)
- [Interview & Quiz](./06-gcp-deployment-manager/interview-questions/readme.md)

### ☸️ [GCP Config Connector](./07-gcp-config-connector/readme.md)
- [Beginner](./07-gcp-config-connector/beginner/readme.md)
- [Intermediate](./07-gcp-config-connector/intermediate/readme.md)
- [Advanced](./07-gcp-config-connector/advanced/readme.md)
- [Interview & Quiz](./07-gcp-config-connector/interview-questions/readme.md)
