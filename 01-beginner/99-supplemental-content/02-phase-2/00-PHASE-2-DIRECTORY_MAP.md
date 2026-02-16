# 🗺️ Phase 2: Automation & Infrastructure - Directory Map

> **Purpose**: Navigation guide for Phase 2 content covering automation scripting, infrastructure tools, and DevOps fundamentals.

---

## 📊 Phase 2 Overview

### Statistics

| **Metric** | **Value** |
|:-----------|:----------|
| **Total Modules** | 10 |
| **Programming Languages** | Python, Go, Bash, JavaScript |
| **Technologies** | 20+ tools and frameworks |
| **Directories** | 544 |

### Learning Objectives

By completing Phase 2, you will:
- ✅ Write automation scripts in Python, Go, and Bash
- ✅ Integrate with REST APIs and webhooks
- ✅ Configure Nginx as a reverse proxy and load balancer
- ✅ Build Java applications with Maven
- ✅ Create CI/CD pipelines with GitHub Actions
- ✅ Use AI for code generation and debugging
- ✅ Implement observability with metrics, logs, and traces
- ✅ Apply GitOps principles
- ✅ Enforce compliance as code
- ✅ Scan containers for security vulnerabilities

---

## 📂 Module Index

### 01. Automation (`01-automation/`)

**Purpose**: Master scripting languages for DevOps automation

**Sub-Modules**:
- **Bash Basics** (`01-bash-basics/`) - Shell scripting fundamentals
- **Python Basics** (`02-python-basics/`) - Python for automation and cloud SDKs
- **Go Basics** (`03-go-basics/`) - Go for CLI tools and microservices
- **Idempotency** (`03-idempotency/`) - Write safe, repeatable automation
- **Job Scheduling** (`04-job-scheduling-and-cron/`) - Cron, systemd timers
- **Event-Driven Webhooks** (`05-event-driven-webhooks/`) - Webhook handlers
- **Ansible Dynamic Inventory** (`06-ansible-dynamic-inventory/`) - Cloud inventory management
- **Terraform Patterns** (`07-terraform-patterns/`) - IaC best practices

**Key Skills**:
- Python automation (boto3, requests, subprocess)
- Go CLI tools (cobra, viper)
- Bash scripting (error handling, idempotency)
- Terraform modules and state management
- Ansible dynamic inventory plugins

**Start Here**: [`01-automation/readme.md`](./01-automation/readme.md)

---

### 02. API Basics (`02-api-basics/`)

**Purpose**: Understand HTTP, REST, and API integration

**Sub-Modules**:
- **Web Foundations** - HTTP protocol, REST architecture, status codes
- **API Security & Auth** - Authentication, authorization, security best practices
- **Advanced API Workflows** - DevOps integration, testing, monitoring

**Key Skills**:
- HTTP methods (GET, POST, PUT, DELETE)
- REST API design
- Authentication (API keys, OAuth, JWT)
- API testing and automation

**Start Here**: [`02-api-basics/readme.md`](./02-api-basics/readme.md)

---

### 03. Nginx (`03-nginx/`)

**Purpose**: Configure Nginx for reverse proxy, load balancing, and SSL termination

**Sub-Modules**:
- **Architecture & Foundations** - Installation, reverse proxy basics
- **Traffic Management & Performance** - Load balancing, caching, optimization
- **Security & Hardening** - SSL/TLS, security headers, rate limiting

**Key Skills**:
- Reverse proxy configuration
- Load balancing strategies (round-robin, least connections)
- SSL certificate management
- Performance tuning

**Start Here**: [`03-nginx/readme.md`](./03-nginx/readme.md)

---

### 04. Maven (`04-maven/`)

**Purpose**: Build and manage Java applications with Maven

**Sub-Modules**:
- **Maven Fundamentals** - Installation, project structure, POM configuration
- **Core Build Workflows** - Dependencies, build lifecycle
- **Enterprise Maven & Optimization** - CI/CD integration, best practices, troubleshooting

**Key Skills**:
- POM.xml configuration
- Dependency management
- Build lifecycle (compile, test, package, deploy)
- CI/CD integration

**Start Here**: [`04-maven/readme.md`](./04-maven/readme.md)

---

### 05. Basic CI/CD (`05-basic-ci-cd/`)

**Purpose**: Create automated pipelines with GitHub Actions

**Sub-Modules**:
- **Principles & Fundamentals** - CI/CD foundations
- **GitHub Actions Core** - Workflows, actions, secrets
- **Advanced Workflows** - Security gates, continuous deployment

**Key Skills**:
- YAML workflow syntax
- GitHub Actions marketplace
- Secrets management
- Automated testing and deployment

**Start Here**: [`05-basic-ci-cd/readme.md`](./05-basic-ci-cd/readme.md)

---

### 06. Prompt Engineering (`06-prompt-engineering/`)

**Purpose**: Use AI to accelerate DevOps workflows

**Sub-Modules**:
- **AI Fundamentals** - LLM basics, prompt toolkit
- **DevOps Automation** - Code generation, IaC automation, debugging
- **Governance & Ethics** - Security, responsible AI use

**Key Skills**:
- Effective prompt design
- AI-assisted code generation
- Debugging with AI
- Security considerations

**Start Here**: [`06-prompt-engineering/readme.md`](./06-prompt-engineering/readme.md)

---

### 07. Observability Fundamentals (`07-observability-fundamentals/`)

**Purpose**: Implement monitoring, logging, and tracing

**Sub-Modules**:
- **The Signals** - Metrics, Events, Logs, Traces (MELT)
- **Active Monitoring** - Health checks, alerting

**Key Skills**:
- Metrics collection (Prometheus)
- Log aggregation
- Distributed tracing
- Health check automation

**Start Here**: [`07-observability-fundamentals/readme.md`](./07-observability-fundamentals/readme.md)

---

### 08. GitOps Fundamentals (`08-gitops-fundamentals/`)

**Purpose**: Use Git as the single source of truth for infrastructure

**Sub-Modules**:
- **Core Philosophy** - Git as source of truth
- **Architecture Models** - Push vs. pull deployment models

**Key Skills**:
- Declarative infrastructure
- Git-based workflows
- ArgoCD/Flux basics
- Continuous reconciliation

**Start Here**: [`08-gitops-fundamentals/readme.md`](./08-gitops-fundamentals/readme.md)

---

### 09. Compliance as Code Foundations (`09-compliance-as-code-foundations/`)

**Purpose**: Automate security and compliance checks

**Sub-Modules**:
- **Policy Foundations** - Introduction to policy as code
- **Security Auditing** - Manual checklists, automated scanning

**Key Skills**:
- Policy definition (OPA, Sentinel)
- Security scanning
- Compliance automation
- Audit reporting

**Start Here**: [`09-compliance-as-code-foundations/readme.md`](./09-compliance-as-code-foundations/readme.md)

---

### 10. Container Security Basics (`10-container-security-basics/`)

**Purpose**: Scan and secure container images

**Sub-Modules**:
- **Vulnerability Detection** - Image scanning fundamentals
- **Configuration Security** - Docker security best practices

**Key Skills**:
- Image scanning (Trivy, Clair)
- Dockerfile security
- Runtime security
- Vulnerability remediation

**Start Here**: [`10-container-security-basics/readme.md`](./10-container-security-basics/readme.md)

---

## 🎯 Learning Paths

### Path 1: Automation Engineer

**Focus**: Scripting and infrastructure automation

1. **Automation** → Python Basics
2. **Automation** → Terraform Patterns
3. **Automation** → Ansible Dynamic Inventory
4. **API Basics** → REST integration
5. **GitOps Fundamentals** → Declarative infrastructure

---

### Path 2: Platform Engineer

**Focus**: Infrastructure and tooling

1. **Automation** → Go Basics (CLI tools)
2. **Nginx** → Reverse proxy and load balancing
3. **Basic CI/CD** → GitHub Actions
4. **Observability Fundamentals** → Monitoring
5. **Container Security Basics** → Image scanning

---

### Path 3: Security-Focused DevOps

**Focus**: Security automation and compliance

1. **Automation** → Python Basics
2. **Compliance as Code** → Policy enforcement
3. **Container Security Basics** → Vulnerability scanning
4. **API Basics** → Secure API integration
5. **Basic CI/CD** → Security gates

---

## 🔍 Quick Reference

### By Technology

| **Technology** | **Location** |
|:---------------|:-------------|
| **Python** | `01-automation/02-python-basics/` |
| **Go** | `01-automation/03-go-basics/` |
| **Bash** | `01-automation/01-bash-basics/` |
| **Terraform** | `01-automation/07-terraform-patterns/` |
| **Ansible** | `01-automation/06-ansible-dynamic-inventory/` |
| **Nginx** | `03-nginx/` |
| **Maven** | `04-maven/` |
| **GitHub Actions** | `05-basic-ci-cd/` |
| **Prometheus** | `07-observability-fundamentals/` |
| **ArgoCD** | `08-gitops-fundamentals/` |

### By Use Case

| **Use Case** | **Navigate To** |
|:-------------|:----------------|
| **Automate AWS with Python** | `01-automation/02-python-basics/part-01-python-foundations/08-cloud-automation-boto3/` |
| **Build CLI tools** | `01-automation/03-go-basics/` |
| **Write Terraform modules** | `01-automation/07-terraform-patterns/part-02-modular-architecture/` |
| **Configure reverse proxy** | `03-nginx/part-01-architecture-and-foundations/02-reverse-proxy-basics/` |
| **Create GitHub Actions workflows** | `05-basic-ci-cd/part-02-github-actions-core/` |
| **Implement monitoring** | `07-observability-fundamentals/part-02-active-monitoring/` |
| **Scan container images** | `10-container-security-basics/part-01-vulnerability-detection/` |

---

## 📝 Recommended Study Order

### Week 1-2: Scripting Foundations
- Python Basics (Part 1: Foundations)
- Bash Basics
- Idempotency patterns

### Week 3-4: Infrastructure as Code
- Terraform Patterns
- Ansible Dynamic Inventory
- GitOps Fundamentals

### Week 5-6: CI/CD & Automation
- GitHub Actions
- API Basics
- Event-Driven Webhooks

### Week 7-8: Operations & Security
- Nginx configuration
- Observability Fundamentals
- Container Security Basics
- Compliance as Code

---

## 🚀 Next Steps

**After completing Phase 2**:
- Progress to **Phase 3** for enterprise operations (Jenkins, Kubernetes, FinOps)
- Apply skills in real-world projects
- Build a portfolio of automation scripts and IaC modules

**Prerequisites for Phase 3**:
- ✅ Proficiency in Python or Go
- ✅ Understanding of CI/CD concepts
- ✅ Experience with containers (Docker)
- ✅ Familiarity with cloud platforms (AWS/Azure/GCP)

---

**Document Version**: 1.0  
**Last Updated**: 2026-02-16  
**Status**: ✅ **PRODUCTION READY**

---

*For the complete curriculum navigation, see [`00-MASTER_DIRECTORY_MAP.md`](../00-MASTER_DIRECTORY_MAP.md)*
