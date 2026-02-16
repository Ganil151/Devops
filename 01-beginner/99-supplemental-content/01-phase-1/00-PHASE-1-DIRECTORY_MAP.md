# 🗺️ Phase 1: Beginner Foundations - Directory Map

> **Purpose**: Navigate the 6 foundational modules that build essential DevOps skills from the ground up.

---

## 📋 Table of Contents

1. [Phase Overview](#-phase-overview)
2. [Module Navigation](#-module-navigation)
3. [Learning Objectives](#-learning-objectives)
4. [Quick Start](#-quick-start)

---

## 🎯 Phase Overview

### Phase 1: Beginner Foundations

**Duration**: Weeks 1-8 (8 weeks)  
**Prerequisites**: None - start here if you're new to DevOps  
**Modules**: 6  
**Total Files**: 463+

### What You'll Learn

This phase builds **fundamental skills required for DevOps work**:

- **Windows Administration**: PowerShell, WSL2, system management for hybrid-cloud
- **Data Formats**: JSON, YAML, TOML, XML, Markdown for configuration management
- **DevOps Tooling**: Overview of the DevOps ecosystem and software stack
- **Web Development**: Frontend and backend frameworks for full-stack understanding
- **Cloud Platforms**: AWS, Azure, GCP basics (networking, storage, compute)
- **Version Control**: Git, GitLab, Bitbucket, Azure DevOps Repos

---

## 📚 Module Navigation

### 1. Windows Basics (174 files) ⭐ **COMPREHENSIVE DOCUMENTATION**

📂 **Location**: [`03-windows-basics/`](./03-windows-basics/)  
📖 **Module Guide**: [`03-windows-basics/00-DIRECTORY_MAP.md`](./03-windows-basics/00-DIRECTORY_MAP.md)

**Purpose**: Master Windows PowerShell for hybrid-cloud infrastructure management

**Key Topics**:
- PowerShell automation (93 atomic command files)
- WSL2 Linux integration
- Package management (Chocolatey, Winget)
- Windows Server administration
- System auditing and performance tuning
- Network troubleshooting

**Why This Matters**:
> "Windows PowerShell is **not optional** for modern DevOps practitioners managing hybrid environments spanning AWS EC2 Windows instances, Azure VMs, on-premises servers, and WSL2 developer workstations."

**Real-World Scenario**:
- Managing Jenkins CI/CD on Windows Server 2019
- Configuring SonarQube on Windows VMs
- Setting up developer workstations with WSL2
- Automating Windows infrastructure with Terraform/Ansible

**Module Documentation**:
- ✅ Complete directory map with DevOps context
- ✅ Comprehensive audit log
- ✅ Executive summary
- ✅ Restoration summary

**Start Here**:
- [`03-windows-basics/part-1-powershell-automation/`](./03-windows-basics/part-1-powershell-automation/) - PowerShell commands
- [`03-windows-basics/part-2-wsl-linux-integration/`](./03-windows-basics/part-2-wsl-linux-integration/) - WSL2 setup

---

### 2. Data Formats (30 files)

📂 **Location**: [`04-data-formats/`](./04-data-formats/)

**Purpose**: Master configuration file formats used throughout DevOps

**Key Topics**:
- **JSON**: API responses, configuration files, data interchange
- **YAML**: Kubernetes manifests, CI/CD pipelines, Ansible playbooks
- **TOML**: Modern configuration format (Rust, Python projects)
- **XML**: Legacy systems, Maven POM files, enterprise integrations
- **Markdown**: Documentation, README files, technical writing

**DevOps Applications**:
- Writing Kubernetes YAML manifests
- Configuring CI/CD pipelines (GitLab CI, GitHub Actions)
- Managing Ansible playbooks
- Parsing API responses
- Documenting infrastructure

**Challenges Included**:
- JQ query challenges for JSON processing
- YAML DRY (Don't Repeat Yourself) exercises
- Markdown documentation best practices

---

### 3. Software Stack (24 files)

📂 **Location**: [`05-software-stack/`](./05-software-stack/)

**Purpose**: Understand the DevOps tooling ecosystem

**Key Topics**:
- DevOps lifecycle overview
- Core principles and methodologies
- Tool categories (CI/CD, IaC, monitoring, etc.)
- Software installation and configuration
- Development environment setup
- DevOps metrics and KPIs

**Tooling Overview**:
- Version control (Git, GitLab, GitHub)
- CI/CD (Jenkins, GitLab CI, GitHub Actions)
- Infrastructure as Code (Terraform, Ansible)
- Containerization (Docker, Kubernetes)
- Monitoring (Prometheus, Grafana)

**Resources**:
- DevOps automation cookbook (PDF)
- DevOps for beginners guide (PDF)
- Interview Q&A (PDF)

---

### 4. Web Design (73 files)

📂 **Location**: [`06-web-design/`](./06-web-design/)

**Purpose**: Learn web frameworks for full-stack DevOps understanding

**Frontend Frameworks**:
- **React**: Component-based UI development
- **Angular**: Enterprise frontend framework
- **Vue.js**: Progressive JavaScript framework
- **TailwindCSS**: Utility-first CSS framework

**Backend Frameworks**:
- **Flask**: Lightweight Python web framework
- **Django**: Full-featured Python web framework
- **FastAPI**: Modern Python API framework
- **Spring Boot**: Enterprise Java framework
- **Node.js/Express**: JavaScript backend

**Mobile Development**:
- React Native
- Flutter

**DevOps Relevance**:
> "Understanding web frameworks helps you deploy, troubleshoot, and optimize applications in production environments."

**Use Cases**:
- Deploying React apps to S3/CloudFront
- Containerizing Flask/Django applications
- Setting up Spring Boot CI/CD pipelines
- Configuring Nginx reverse proxy for Node.js

---

### 5. Cloud Foundations (133 files) ⭐ **SECOND LARGEST MODULE**

📂 **Location**: [`07-cloud-foundations/`](./07-cloud-foundations/)

**Purpose**: Master cloud platform fundamentals (AWS, Azure, GCP)

**Core Concepts**:
- Cloud computing models (IaaS, PaaS, SaaS)
- Deployment models (Public, Private, Hybrid)
- Global infrastructure (Regions, Availability Zones)
- Networking fundamentals (VPC, Subnets, Security Groups)
- Storage types (Object, Block, File)

**AWS Deep Dive** (Largest section):
- **Networking**: VPC, Subnets, Route Tables, Internet Gateways
- **Storage**: S3, EBS, EFS
- **Compute**: EC2, Lambda (serverless)
- **Containers**: ECS, EKS, ECR
- **Identity**: IAM, Active Directory, Cognito
- **Messaging**: SNS, SQS
- **Web Hosting**: Route 53, WordPress on EC2

**Azure Basics**:
- Compute, Storage, Networking, Security, DevOps

**GCP Basics**:
- Compute, Storage, Networking, Security, DevOps

**Hands-On**:
- Terraform modules for S3 buckets
- AWS CLI command references
- ECS/EKS deployment guides

---

### 6. Repository Management (29 files)

📂 **Location**: [`08-repository-management/`](./08-repository-management/)

**Purpose**: Master version control and repository management

**Git Fundamentals**:
- Git architecture and internals
- Branching strategies (GitFlow, GitHub Flow, Trunk-Based)
- Merge vs. Rebase
- Conflict resolution
- Git hooks and automation

**Platform-Specific**:
- **GitLab**: Repository management, basic CI/CD, issue tracking
- **Bitbucket**: Atlassian ecosystem integration
- **Azure DevOps Repos**: Microsoft ecosystem integration
- **Mercurial & SVN**: Legacy VCS (for migration scenarios)

**Enterprise Patterns**:
- Monorepo vs. Polyrepo
- Branch protection rules
- Code review workflows
- GitLab vs. GitHub comparison

**Resources**:
- Git guide (PDF)
- Branching strategies comparison
- Real-life scenarios and challenges

---

## 🎓 Learning Objectives

### By the End of Phase 1, You Will:

✅ **Manage Windows Infrastructure**
- Automate tasks with PowerShell
- Configure WSL2 for Linux tooling
- Troubleshoot network and disk issues

✅ **Work with Configuration Files**
- Parse and manipulate JSON/YAML
- Write Kubernetes manifests
- Configure CI/CD pipelines

✅ **Understand Cloud Platforms**
- Navigate AWS, Azure, GCP consoles
- Create VPCs and configure networking
- Deploy EC2 instances and S3 buckets

✅ **Use Version Control**
- Manage code with Git
- Implement branching strategies
- Collaborate via pull requests

✅ **Deploy Web Applications**
- Understand frontend/backend frameworks
- Containerize applications
- Configure web servers

---

## 🚀 Quick Start

### Recommended Learning Path

#### **Week 1-2: Cloud Foundations**
1. Start with [`07-cloud-foundations/`](./07-cloud-foundations/)
2. Learn cloud computing models
3. Create your first AWS resources (VPC, EC2, S3)

#### **Week 3-4: Data Formats & Git**
1. Master YAML and JSON: [`04-data-formats/`](./04-data-formats/)
2. Learn Git basics: [`08-repository-management/`](./08-repository-management/)
3. Practice with real configuration files

#### **Week 5-6: Windows Basics (if applicable)**
1. Explore PowerShell: [`03-windows-basics/`](./03-windows-basics/)
2. Set up WSL2 for hybrid workflows
3. Automate Windows administration tasks

#### **Week 7-8: Web Development & Tooling**
1. Understand web frameworks: [`06-web-design/`](./06-web-design/)
2. Learn DevOps tooling: [`05-software-stack/`](./05-software-stack/)
3. Deploy a simple web app to the cloud

---

## 📊 Module Complexity

| **Module** | **Complexity** | **Time Estimate** |
|:-----------|:--------------:|:-----------------:|
| Data Formats | ⭐ | 1 week |
| Software Stack | ⭐ | 1 week |
| Repository Management | ⭐⭐ | 1 week |
| Windows Basics | ⭐⭐ | 2 weeks |
| Cloud Foundations | ⭐⭐ | 2 weeks |
| Web Design | ⭐⭐ | 1 week |

---

## 🔗 Related Resources

### Next Steps (Phase 2)
- [Automation](../02-phase-2/01-automation/) - Build on scripting skills
- [Basic CI/CD](../02-phase-2/05-basic-ci-cd/) - Apply Git and cloud knowledge
- [Observability](../02-phase-2/07-observability-fundamentals/) - Monitor cloud resources

### External Resources
- [AWS Free Tier](https://aws.amazon.com/free/)
- [Azure Free Account](https://azure.microsoft.com/free/)
- [GCP Free Tier](https://cloud.google.com/free)

---

## 📝 Navigation

- **Back to Master Map**: [`../00-MASTER_DIRECTORY_MAP.md`](../00-MASTER_DIRECTORY_MAP.md)
- **Phase 2 (Intermediate)**: [`../02-phase-2/00-PHASE-2-DIRECTORY_MAP.md`](../02-phase-2/00-PHASE-2-DIRECTORY_MAP.md)
- **Phase 3 (Advanced)**: [`../03-phase-3/00-PHASE-3-DIRECTORY_MAP.md`](../03-phase-3/00-PHASE-3-DIRECTORY_MAP.md)

---

## 🎯 Success Criteria

### You're Ready for Phase 2 When You Can:

✅ Write PowerShell scripts to automate Windows tasks  
✅ Parse JSON/YAML files with command-line tools  
✅ Create and configure AWS VPCs, EC2 instances, and S3 buckets  
✅ Use Git for version control and collaboration  
✅ Deploy a simple web application to the cloud  
✅ Explain the DevOps lifecycle and core principles

---

**Last Updated**: 2026-02-16  
**Total Modules**: 6  
**Total Files**: 463+  
**Phase Duration**: 8 weeks
