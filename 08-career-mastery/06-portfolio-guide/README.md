<div align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&height=250&section=header&text=Ganil%20Batist%20Yan&fontSize=80" />

<div align="center">
<h1>Continuous Learning - Continuous Improvement</h1>
</div>
  
<div align="center">

[![AWS SAA](https://img.shields.io/badge/AWS-Solutions_Architect_Associate-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://credly.com)
[![CKA](https://img.shields.io/badge/CNCF-CKA_Certified-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://credly.com)
[![Terraform](https://img.shields.io/badge/HashiCorp-Terraform_Associate-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://credly.com)

</div>
</div>

<div align="center">
  <a href="https://www.linkedin.com/in/ganil-batist-yan/"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" /></a>
  <a href="mailto:ganilbatistyan@gmail.com"><img src="https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white" /></a>
  <a href="https://github.com/Ganil151"><img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" /></a>
</div>

---

### 👨‍💻 About Me

👨‍💻 About Me
I am a Senior DevOps & Platform Engineer with 4+ years of experience bridging the gap between legacy infrastructure and modern cloud-native automation. My core mission is to build resilient, self-healing platforms that empower developers rather than slowing them down.

I specialize in managing complex, mixed Linux/Windows environments and implementing GitOps-driven CI/CD that delivers measurable business value. I believe that infrastructure should be predictable, automated, and invisible—the "foundation of agility" that allows engineering teams to ship high-quality code at scale.

- 🔭 Current Focus: Engineering high-throughput, multi-region AWS EKS platforms and enhancing security through Zero-Trust networking.

- 🌱 Exploring: The intersection of eBPF-based Observability (Cilium) and automated FinOps governance.

- 🚀 Mission: Bridging the gap from manual "snowflake" servers to fully version-controlled, Infrastructure-as-Code (IaC) solutions.

- 🤝 Collaboration: Active contributor to internal developer platforms (IDP) and an advocate for blameless post-mortem culture.

### 🎯 Engineering Philosophy

- **Automation over Documentation:** If a task is performed twice, it must be scripted.
- **Security by Design:** Shifting security left by integrating automated scanning into every CI/CD gate.
- **Data-Driven Ops:** Making architectural decisions based on SLIs/SLOs and Prometheus metrics, not "gut feeling."

---

### 🛠️ My Tech Stack

| Domain                         | Tools                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| :----------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Cloud & Containerization**   | ![AWS](https://img.shields.io/badge/AWS-FF9900?style=flat-square&logo=amazon-aws&logoColor=white) ![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat-square&logo=kubernetes&logoColor=white) ![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white) ![Helm](https://img.shields.io/badge/Helm-0F1689?style=flat-square&logo=helm&logoColor=white) ![Karpenter](https://img.shields.io/badge/Karpenter-005571?style=flat-square&logo=amazon&logoColor=white) |
| **Infrastructure as Code**     | ![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat-square&logo=terraform&logoColor=white) ![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=flat-square&logo=ansible&logoColor=white) ![CloudFormation](https://img.shields.io/badge/CloudFormation-FF4F8B?style=flat-square&logo=amazon&logoColor=white)                                                                                                                                                                                       |
| **CI/CD & GitOps**             | ![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=flat-square&logo=jenkins&logoColor=white) ![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat-square&logo=github-actions&logoColor=white) ![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=flat-square&logo=argocd&logoColor=white)                                                                                                                                                                                        |
| **Observability & Networking** | ![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat-square&logo=prometheus&logoColor=white) ![Grafana](https://img.shields.io/badge/Grafana-F46800?style=flat-square&logo=grafana&logoColor=white) ![Cilium](https://img.shields.io/badge/Cilium-4285F4?style=flat-square&logo=cilium&logoColor=white)                                                                                                                                                                                                    |

---

### 🏆 Professional Impact (The Numbers)

| Metric                     | Achievement                                    | Impact                                 |
| :------------------------- | :--------------------------------------------- | :------------------------------------- |
| 💰 **Cost Reduction**      | Automated environment lifecycle scheduling     | **$66k/year** in AWS savings           |
| ⚡ **Deployment Velocity** | Re-engineered Jenkins & ArgoCD pipelines       | **50%** faster deployment frequency    |
| 📈 **Performance**         | Optimized K8s cluster resources & auto-scaling | **20%** improvement in app performance |
| 🛡️ **Resilience**          | Implemented multi-region GitOps failover       | **<10 minute** disaster recovery time  |

---

## 🧪 Featured Project: Enterprise Microservice Failover

> #### Production-Grade Disaster Recovery for Spring PetClinic on AWS EKS
>
> **Challenge:** Architect a solution to guarantee 99.99% availability for a critical microservice application, with the ability to survive a full AWS region failure.

> **Solution Architecture:**
>
> - **🏗️ IaC Foundation:** Multi-region EKS clusters provisioned via modular **Terraform** codebase.
> - **🔄 GitOps Sync:** **ArgoCD** maintained state parity across primary and standby clusters.
> - **🛡️ Data Resiliency:** **Amazon RDS Read Replicas** with automated **Route 53** failover.

---

<!-- BLOG-POST-LIST:START -->

### ✍️ Thought Leadership (Coming Soon)

> #### **[Draft] How eBPF is Revolutionizing Cloud-Native Observability**

> _By Ganil Batist Yan_

> **The Hook:** Traditional monitoring tells you _that_ a service is slow; eBPF tells you _why_ by looking directly at the kernel without the overhead of sidecars.
>
> **What I’m Exploring:**

> - Moving beyond basic metrics to deep kernel-level tracing with **Cilium**.
> - How eBPF reduces CPU overhead in high-concurrency **EKS** clusters compared to traditional iptables.
>
> _Status: Researching & Benchmarking. Stay tuned!_

## <!-- BLOG-POST-LIST:END -->

<p align="center">
  <i>"Automating the world, one commit at a time."</i>
</p>
