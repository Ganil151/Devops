# 🗺️ Phase 2: Intermediate Skills - Directory Map

> **Purpose**: Navigate the 10 intermediate-level modules that develop automation, CI/CD, and modern DevOps capabilities.

---

## 📋 Table of Contents

1. [Phase Overview](#-phase-overview)
2. [Module Navigation](#-module-navigation)
3. [Learning Objectives](#-learning-objectives)
4. [Quick Start](#-quick-start)

---

## 🎯 Phase Overview

### Phase 2: Intermediate Skills

**Duration**: Weeks 9-20 (12 weeks)  
**Prerequisites**: Complete Phase 1 or have equivalent foundational knowledge  
**Modules**: 10  
**Total Files**: 600+

### What You'll Learn

This phase focuses on **automation, CI/CD, and modern DevOps practices**:

- **Scripting & Automation**: Python and Bash for infrastructure automation
- **API Development**: REST API design and implementation
- **Web Infrastructure**: Nginx configuration and management
- **Build Tools**: Maven for Java applications
- **CI/CD Pipelines**: Jenkins, GitLab CI, GitHub Actions
- **AI-Assisted Development**: Prompt engineering for LLMs
- **Observability**: Logging, metrics, and tracing
- **GitOps**: Declarative infrastructure management
- **Compliance**: Policy as code with OPA
- **Security**: Container security fundamentals

---

## 📚 Module Navigation

### 1. Automation (448 files) ⭐ **LARGEST MODULE**

📂 **Location**: [`01-automation/`](./01-automation/)

**Purpose**: Master Python and Bash scripting for DevOps automation

**Key Topics**:
- Python fundamentals for DevOps
- Bash scripting best practices
- AWS automation with Boto3
- File operations and data processing
- Error handling and logging
- Cloud resource management

**Why This Matters**:
> "Automation is the foundation of DevOps. This module contains 448 files covering everything from Python basics to advanced cloud automation with Boto3."

**Start Here**:
- [`01-automation/02-python-basics/`](./01-automation/02-python-basics/) - Python fundamentals
- [`01-automation/00-foundations/`](./01-automation/00-foundations/) - Automation philosophy

---

### 2. API Basics (22 files)

📂 **Location**: [`02-api-basics/`](./02-api-basics/)

**Purpose**: Learn REST API design, implementation, and testing

**Key Topics**:
- HTTP methods (GET, POST, PUT, DELETE)
- RESTful API design principles
- API authentication and authorization
- API testing with Postman/curl
- JSON request/response handling

**DevOps Use Case**:
- Integrating with cloud provider APIs
- Building internal automation APIs
- Testing microservices endpoints

---

### 3. Nginx (18 files)

📂 **Location**: [`03-nginx/`](./03-nginx/)

**Purpose**: Configure Nginx as web server, reverse proxy, and load balancer

**Key Topics**:
- Nginx installation and configuration
- Virtual hosts and server blocks
- Reverse proxy setup
- Load balancing strategies
- SSL/TLS configuration
- Performance tuning

**Real-World Scenario**:
> "Nginx powers many production environments as a reverse proxy for microservices, handling SSL termination and load balancing."

---

### 4. Maven (24 files)

📂 **Location**: [`04-maven/`](./04-maven/)

**Purpose**: Master Java build automation and dependency management

**Key Topics**:
- Maven project structure
- POM file configuration
- Dependency management
- Build lifecycle phases
- Plugin configuration
- Multi-module projects

**DevOps Integration**:
- CI/CD pipeline integration
- Artifact repository management
- Automated testing and deployment

---

### 5. Basic CI/CD (18 files)

📂 **Location**: [`05-basic-ci-cd/`](./05-basic-ci-cd/)

**Purpose**: Implement CI/CD pipelines with Jenkins, GitLab CI, and GitHub Actions

**Key Topics**:
- CI/CD fundamentals and principles
- Jenkins pipeline configuration
- GitLab CI YAML syntax
- GitHub Actions workflows
- Build, test, deploy automation
- Pipeline best practices

**Critical Skill**:
> "CI/CD is the backbone of modern software delivery. This module covers the three most popular platforms."

---

### 6. Prompt Engineering (30 files)

📂 **Location**: [`06-prompt-engineering/`](./06-prompt-engineering/)

**Purpose**: Leverage AI/LLMs for DevOps tasks through effective prompting

**Key Topics**:
- Prompt design patterns
- Context management
- Few-shot learning
- Chain-of-thought prompting
- AI-assisted code generation
- Debugging with LLMs

**Modern DevOps**:
> "AI is transforming DevOps. Learn to use LLMs for script generation, troubleshooting, and documentation."

---

### 7. Observability Fundamentals (12 files)

📂 **Location**: [`07-observability-fundamentals/`](./07-observability-fundamentals/)

**Purpose**: Implement logging, metrics, and tracing for system visibility

**Key Topics**:
- The three pillars: Logs, Metrics, Traces
- Structured logging
- Metric collection and visualization
- Distributed tracing
- Observability vs. monitoring
- SLIs, SLOs, SLAs

**SRE Foundation**:
> "You can't manage what you can't measure. Observability is essential for production systems."

---

### 8. GitOps Fundamentals (10 files)

📂 **Location**: [`08-gitops-fundamentals/`](./08-gitops-fundamentals/)

**Purpose**: Implement declarative infrastructure management with GitOps

**Key Topics**:
- GitOps principles and patterns
- ArgoCD for Kubernetes deployments
- Flux for continuous delivery
- Git as single source of truth
- Automated reconciliation
- Rollback strategies

**Modern Practice**:
> "GitOps brings Git workflows to infrastructure management, enabling version control, code review, and audit trails for all changes."

---

### 9. Compliance as Code Foundations (9 files)

📂 **Location**: [`09-compliance-as-code-foundations/`](./09-compliance-as-code-foundations/)

**Purpose**: Automate compliance and policy enforcement

**Key Topics**:
- Policy as code principles
- Open Policy Agent (OPA)
- Rego policy language
- Compliance automation
- Security policy enforcement
- Audit and reporting

**Enterprise Requirement**:
> "Compliance as code enables automated policy enforcement across your infrastructure, reducing manual audits and human error."

---

### 10. Container Security Basics (9 files)

📂 **Location**: [`10-container-security-basics/`](./10-container-security-basics/)

**Purpose**: Secure containers from build to runtime

**Key Topics**:
- Container image scanning
- Vulnerability management
- Base image selection
- Runtime security
- Network policies
- Secrets management

**Security First**:
> "Container security must be integrated into every stage of the CI/CD pipeline, from image build to production runtime."

---

## 🎓 Learning Objectives

### By the End of Phase 2, You Will:

✅ **Automate Infrastructure Tasks**
- Write Python scripts for cloud resource management
- Create Bash scripts for system administration
- Use Boto3 for AWS automation

✅ **Build CI/CD Pipelines**
- Configure Jenkins pipelines
- Write GitLab CI YAML configurations
- Create GitHub Actions workflows

✅ **Implement Observability**
- Set up structured logging
- Collect and visualize metrics
- Implement distributed tracing

✅ **Apply Modern Practices**
- Use GitOps for infrastructure management
- Enforce policies with OPA
- Secure container images and runtime

✅ **Leverage AI Tools**
- Design effective prompts for LLMs
- Use AI for code generation and debugging
- Integrate AI into DevOps workflows

---

## 🚀 Quick Start

### Recommended Learning Path

#### **Week 9-12: Automation Mastery**
1. Start with [`01-automation/00-foundations/`](./01-automation/00-foundations/)
2. Learn Python basics: [`01-automation/02-python-basics/`](./01-automation/02-python-basics/)
3. Practice with real-world examples

#### **Week 13-15: CI/CD Fundamentals**
1. Understand CI/CD principles: [`05-basic-ci-cd/`](./05-basic-ci-cd/)
2. Set up Jenkins pipelines
3. Explore GitLab CI and GitHub Actions

#### **Week 16-17: Observability & Security**
1. Learn observability: [`07-observability-fundamentals/`](./07-observability-fundamentals/)
2. Implement container security: [`10-container-security-basics/`](./10-container-security-basics/)

#### **Week 18-20: Modern Practices**
1. Explore GitOps: [`08-gitops-fundamentals/`](./08-gitops-fundamentals/)
2. Learn compliance as code: [`09-compliance-as-code-foundations/`](./09-compliance-as-code-foundations/)
3. Master prompt engineering: [`06-prompt-engineering/`](./06-prompt-engineering/)

---

## 📊 Module Complexity

| **Module** | **Complexity** | **Time Estimate** |
|:-----------|:--------------:|:-----------------:|
| Automation | ⭐⭐⭐ | 4 weeks |
| API Basics | ⭐⭐ | 1 week |
| Nginx | ⭐⭐ | 1 week |
| Maven | ⭐⭐ | 1 week |
| Basic CI/CD | ⭐⭐⭐ | 2 weeks |
| Prompt Engineering | ⭐⭐ | 1 week |
| Observability | ⭐⭐⭐ | 1 week |
| GitOps | ⭐⭐⭐ | 1 week |
| Compliance as Code | ⭐⭐⭐ | 1 week |
| Container Security | ⭐⭐⭐ | 1 week |

---

## 🔗 Related Resources

### Prerequisites (Phase 1)
- [Cloud Foundations](../01-phase-1/07-cloud-foundations/) - Required for automation module
- [Data Formats](../01-phase-1/04-data-formats/) - Required for API and CI/CD work

### Next Steps (Phase 3)
- [Advanced CI/CD](../03-phase-3/01-ci-cd-foundations/) - Build on basic CI/CD knowledge
- [Container Orchestration](../03-phase-3/02-container-orchestration/) - Extend container security to Kubernetes

---

## 📝 Navigation

- **Back to Master Map**: [`../00-MASTER_DIRECTORY_MAP.md`](../00-MASTER_DIRECTORY_MAP.md)
- **Phase 1 (Foundations)**: [`../01-phase-1/00-PHASE-1-DIRECTORY_MAP.md`](../01-phase-1/00-PHASE-1-DIRECTORY_MAP.md)
- **Phase 3 (Advanced)**: [`../03-phase-3/00-PHASE-3-DIRECTORY_MAP.md`](../03-phase-3/00-PHASE-3-DIRECTORY_MAP.md)

---

**Last Updated**: 2026-02-16  
**Total Modules**: 10  
**Total Files**: 600+  
**Phase Duration**: 12 weeks
