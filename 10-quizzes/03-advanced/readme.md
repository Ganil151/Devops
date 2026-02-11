# Advanced Level: Enterprise Excellence Quizzes

Thrive in mission-critical infrastructure by mastering observability, security-as-code, and advanced orchestration patterns.

---

## Module 01: GitOps & Declarative CD
**Study Resource**: [GitOps with ArgoCD](../../readme.md)

1. What is GitOps?
- A) Using Git for operations only
- B) A methodology using Git for declarative infrastructure and applications
- C) A branching strategy in Git
- D) A monitoring tool

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** GitOps is a set of practices to manage infrastructure and application configurations using Git as a single source of truth for declarative infrastructure and applications.
**Certification Alignment:** GitOps Certified Associate / CKA
</details>

2. What is ArgoCD?
- A) A CI tool
- B) A monitoring dashboard
- C) A GitOps continuous delivery tool for Kubernetes
- D) A container builder

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. It follows the GitOps pattern of using Git repositories as the source of truth for defining the desired application state.
**Certification Alignment:** ArgoCD Certified Professional / CKA
</details>

---

## Module 02: Observability & Monitoring
**Study Resource**: [Advanced Observability](../../readme.md)

1. What is Prometheus used for?
- A) Configuration management
- B) Containerization
- C) Monitoring and alerting
- D) Version control

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** Prometheus is an open-source systems monitoring and alerting toolkit originally built at SoundCloud. It is now a standalone open source project and a CNCF graduated project.
**Certification Alignment:** PCA (Prometheus Certified Associate)
</details>

2. What is the role of ELK stack in DevOps?
- A) Continuous integration
- B) Log management and analysis
- C) Infrastructure provisioning
- D) Container orchestration

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** ELK (Elasticsearch, Logstash, Kibana) is the world's most popular log analysis platform. It provides a way to centralize, search, and visualize log data from all applications.
**Certification Alignment:** Elastic Certified Engineer
</details>

3. What is observability in DevOps?
- A) Only logging
- B) Understanding system internals through metrics, logs, and traces
- C) Deployment strategy
- D) Version control

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Observability is more than monitoring. It’s the ability to ask arbitrary questions about your system without knowing the problem in advance, typically powered by the three pillars: metrics, logs, and traces.
**Certification Alignment:** SRE Principles / Google Professional Cloud DevOps Engineer
</details>

4. What is the purpose of Grafana?
- A) Build automation
- B) Visualization of metrics
- C) Code repository
- D) Container registry

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Grafana is a multi-platform open source analytics and interactive visualization web application. It provides charts, graphs, and alerts for the web when connected to supported data sources.
**Certification Alignment:** PCA / AWS Certified SysOps Administrator
</details>

5. What is Splunk used for?
- A) CI/CD
- B) Containerization
- C) Log analysis and SIEM
- D) IaC

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** Splunk is a data platform used for searching, monitoring, and analyzing machine-generated data. It is widely used in enterprise environments for security (SIEM) and operational intelligence.
**Certification Alignment:** Splunk Certified Enterprise Admin
</details>

6. What is the function of Nagios?
- A) Build automation
- B) Code deployment
- C) Container management
- D) System monitoring

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** D
**Why?** Nagios is a classic monitoring tool that monitors systems, networks, and infrastructure. It provides alerting services for servers, switches, applications and services.
**Certification Alignment:** ITIL Foundations / SRE Basics
</details>

---

## Module 03: Advanced Orchestration & Networking
**Study Resource**: [Advanced Kubernetes](../../03-advanced/01-phase-1/04-container-orchestration/advanced-k8s/readme.md)

1. What is the role of Istio in DevOps?
- A) Version control
- B) Service mesh for microservices
- C) Log aggregation
- D) Build automation

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Istio is a service mesh that provides a transparent and language-independent way to automate network functions like traffic management, security, and observability for microservices.
**Certification Alignment:** Certified Istio Administrator
</details>

2. What is microservices architecture?
- A) Breaking applications into small, independent services
- B) A single monolithic application
- C) Hardware-based services
- D) Database services only

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** Microservices are an architectural style that structures an application as a collection of services that are highly maintainable and testable, loosely coupled, and independently deployable.
**Certification Alignment:** AWS Certified Developer Associate / Microservices Design Patterns
</details>

---

## Module 04: DevSecOps & Security
**Study Resource**: [Enterprise Security](readme.md)

1. Which tool is used for secrets management?
- A) Jenkins
- B) Docker
- C) Vault
- D) Git

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** HashiCorp Vault is the industry standard for secrets management. It provides a secure way to store and control access to tokens, passwords, certificates, and API keys.
**Certification Alignment:** HashiCorp Certified: Vault Associate
</details>

2. What is DevSecOps?
- A) Development and security only
- B) Operations without security
- C) Integrating security into DevOps practices
- D) Separate security team

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** DevSecOps is the practice of integrating security testing and compliance at every stage of the software development lifecycle, from initial design through integration, testing, deployment, and software delivery.
**Certification Alignment:** AWS Certified Security Specialty / CompTIA Security+
</details>

3. What is the benefit of using immutable infrastructure?
- A) Predictable and reproducible environments
- B) Easy to modify at runtime
- C) Reduces automation
- D) Increases manual intervention

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** Immutable infrastructure is a strategy where servers are not modified after they are deployed. If a change is needed, new servers are built from a common image with the changes, ensuring consistency and predictability.
**Certification Alignment:** AWS Certified DevOps Engineer Professional
</details>

---

## Module 05: Performance & Resilience

1. What is canary deployment?
- A) Full deployment to all users
- B) Gradual rollout to a subset of users
- C) Backup deployment strategy
- D) Manual rollback process

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Canary deployment is a pattern for rolling out new versions of an application by first exposing it to a small percentage of users to verify its stability before a full rollout.
**Certification Alignment:** AWS Certified DevOps Engineer Professional
</details>

2. What is Chaos Engineering?
- A) Intentionally introducing failures to test resilience
- B) Fixing bugs in production
- C) Automating tests only
- D) Monitoring tools

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** Chaos Engineering is the discipline of experimenting on a system in order to build confidence in the system's capability to withstand turbulent conditions in production.
**Certification Alignment:** AWS Certified DevOps Engineer Professional / Chaos Engineering Principles
</details>

3. What is serverless architecture?
- A) Running code without managing servers
- B) Using physical servers only
- C) Manual scaling
- D) Database-focused

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** Serverless architecture is a way to build and run applications and services without having to manage infrastructure. Your application still runs on servers, but all the server management is done by the cloud provider.
**Certification Alignment:** AWS Certified Developer Associate
</details>

4. What is an ArgoCD 'Sync Policy'?
- A) A rule that determines how Git branches are merged
- B) A configuration that defines if and how ArgoCD automatically synchronizes Git state to the cluster
- C) A load balancing strategy
- D) A password rotation policy

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** An automated sync policy allows ArgoCD to automatically detect when the Git state differs from the cluster state and apply the changes without human intervention.
**Certification Alignment:** ArgoCD Certified Professional
</details>

5. What is the role of an OpenTelemetry (OTel) Collector?
- A) To store logs permanently
- B) To receive, process, and export telemetry data (metrics, logs, traces) to various backends
- C) To run containerized applications
- D) To manage cloud billing

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** The collector is a vendor-agnostic proxy that allows you to offload the responsibility of data processing and exporting from your applications.
**Certification Alignment:** CNCF OpenTelemetry Best Practices
</details>

6. In a DevSecOps "Shift Left" strategy, what is the best way to handle container vulnerabilities?
- A) Scan containers only in production
- B) Implement automated container scanning in the CI/CD pipeline before deployment
- C) Manual inspection of every Docker image
- D) Ignore vulnerabilities unless a breach occurs

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Automated scanning tools like Trivy or Clair should be integrated into the build phase. This ensures that vulnerable images are "blocked" from ever reaching the registry.
**Certification Alignment:** AWS Certified Security Specialty / SRE Best Practices
</details>

7. What is a 'Sidecar' container in a Service Mesh (like Istio)?
- A) A backup server
- B) A helper container that runs alongside the main application container to handle networking, security, or logging
- C) A type of database
- D) A monitoring dashboard

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Sidecars (typically Envoy proxies) intercept all network traffic entering and leaving the pod, allowing the mesh to apply traffic rules, telemetry, and security without changing the application code.
**Certification Alignment:** Certified Istio Administrator / CKA
</details>

8. What is the benefit of a Multi-Cloud strategy?
- A) It is always cheaper than single-cloud
- B) It avoids vendor lock-in and increases resilience by distributing workloads across multiple providers
- C) It simplifies networking
- D) It reduces the need for Kubernetes

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Multi-cloud provides the ultimate high availability. If one cloud provider suffers a global outage, your critical services can stay alive on another platform.
**Certification Alignment:** Google Professional Cloud Architect / AWS Certified Solutions Architect Professional
</details>

---

## Module 06: Cloud-Native & Hybrid Networking
**Study Resource**: [Multi-Cloud Networking](../../readme.md)

1. Which Service Mesh feature allows for fine-grained control over traffic splitting (e.g., 90% to v1, 10% to v2)?
- A) Ingress Gateway
- B) VirtualService (Istio) / TrafficSplit (Linkerd)
- C) Sidecar Injection
- D) mTLS

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** These resources define routing rules that allow you to split traffic between different versions of a service based on weights, headers, or cookies.
**Certification Alignment:** Certified Istio Administrator
</details>

2. What is Global Server Load Balancing (GSLB) primarily used for?
- A) Balancing traffic between pods in a single cluster.
- B) Routing users to the closest healthy cloud region or provider based on DNS.
- C) Managing internal VPC traffic.
- D) Encrypting database connections.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** GSLB uses DNS to route traffic globally. For example, a user in Europe is sent to `eu-west-1` while a user in Asia is sent to `ap-southeast-1`.
**Certification Alignment:** AWS Certified Solutions Architect Professional (Networking)
</details>

3. Which high-speed private connectivity option is typical for AWS and Azure respectively?
- A) Direct Connect and ExpressRoute
- B) VPN and Peering
- C) Cloud Interconnect and Transit Gateway
- D) PrivateLink and Service Endpoints

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** These are the physical fiber connections that link your on-premises data center directly to the cloud provider's backbone, bypassing the public internet for lower latency and higher bandwidth.
**Certification Alignment:** AWS Certified Advanced Networking Specialty
</details>

4. In an Istio-enabled cluster, which component is responsible for providing mutual TLS (mTLS) identities to workloads?
- A) Galley
- B) Citadel (Istiod)
- C) Envoy
- D) Pilot

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Citadel (now part of the unified `istiod` binary) acts as a Certificate Authority (CA) to manage keys and certificates for mTLS.
**Certification Alignment:** Certified Istio Administrator
</details>

---

## Module 07: SRE & FinOps Essentials
**Study Resource**: [Multi-Cloud Management & Governance](../../readme.md)

1. What is the main difference between an SLO (Service Level Objective) and an SLA (Service Level Agreement)?
- A) SLOs are internal goals; SLAs are external legal contracts with customers
- B) SLAs are for developers; SLOs are for managers
- C) SLOs are measured in dollars; SLAs are measured in time
- D) There is no difference

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** If you miss an SLO, your SRE team stops shipping features. If you miss an SLA, your company pays the customer money.
**Certification Alignment:** SRE Principles / Google Professional Cloud DevOps Engineer
</details>

2. What is an "Error Budget" in Site Reliability Engineering (SRE)?
- A) The total amount of money a team can spend on AWS
- B) The maximum allowable amount of unreliability before the team must stop feature work and focus on stability
- C) A list of all historical bugs in a project
- D) A penalty paid to the customer for downtime

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** The Error Budget (e.g., 0.1% downtime if SLO is 99.9%) represents the buffer that developers can use to move fast and break things before stability must be prioritized.
**Certification Alignment:** Google Professional Cloud DevOps Engineer
</details>

3. Which FinOps strategy involves committing to a certain amount of cloud usage for 1-3 years in exchange for a deep discount?
- A) Spot Instances
- B) On-Demand Pricing
- C) Reserved Instances / Savings Plans
- D) Preemptible VMs

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** RI and Savings Plans allow you to lower your bill significantly by guaranteeing spend to the cloud provider, moving from variable OpEx to a more predictable model.
**Certification Alignment:** FinOps Certified Practitioner / AWS Business Professional
</details>

4. What is the "Golden Signals" of monitoring in SRE?
- A) Latency, Traffic, Errors, and Saturation
- B) CPU, Memory, Disk, and Network
- C) Code, Test, Build, and Deploy
- D) User, Group, Role, and Policy

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** These four signals provide a high-level overview of the health of a request-oriented system from the user's perspective.
**Certification Alignment:** Google Professional Cloud DevOps Engineer / SRE Best Practices
</details>

---

## Module 08: Microservices & Architectural Patterns
**Study Resource**: [Microservices Guide](../../readme.md) & [Specialized Tech](readme.md)

1. In the **12-Factor App** methodology, how should application configuration be stored?
- A) Hardcoded in the source code
- B) In environment variables
- C) In a local XML file on the disk
- D) In a private Git repository only accessible to admins

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Storing config in the environment allows the exact same build to be deployed to Dev, Staging, and Prod without change, simply by swapping the environment variables.
**Certification Alignment:** AWS Certified Developer Associate / Cloud-Native Design Patterns
</details>

2. Which communication pattern is best for **loose coupling** between microservices?
- A) Synchronous REST calls
- B) Asynchronous Message Queues (Pub/Sub)
- C) Direct Database Sharing
- D) Shared Memory

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Pub/Sub allows services to communicate without needing to know if the other service is even alive. This prevents a failure in one service from causing a "cascading failure" in the whole system.
**Certification Alignment:** AWS Certified Developer Associate (Messaging)
</details>

3. What is the "Strangler Fig" pattern in microservices?
- A) Deleting all code and starting from scratch
- B) Gradually replacing parts of a monolith with new microservices until the monolith is gone
- C) A type of security vulnerability
- D) A way to encrypt microservices traffic

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Named after a tree that grows around its host, this pattern allows for gradual migration to microservices while maintaining the functionality of the existing monolith system.
**Certification Alignment:** Microservices Design Patterns / Solutions Architect Professional
</details>

4. Which technology is specifically designed for high-performance, contract-first communication between microservices?
- A) REST
- B) gRPC
- C) FTP
- D) SNMP

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** gRPC uses Protocol Buffers (Protobuf) as its Interface Definition Language (IDL), providing extremely fast, binary-based communication with strict type-safety.
**Certification Alignment:** Microservices Architectural Specialty / Google Professional Cloud Developer
</details>

---

## 🏗️ Real-World Scenarios (Advanced)

**Scenario S1: The "Silent Data Loss"**
A distributed microservices application is reporting internal errors (500), but the standard monitoring dashbaord shows "Green" (All systems up). Logs show errors, but you can't see which specific service in the 20-service chain started the failure.
**Question**: Which observability pillar should you implement/check to trace the request path across all services?
- A) Metrics
- B) Logs
- C) Distributed Tracing (e.g., Jaeger)
- D) Monitoring Dashboards

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** Distributed tracing allows you to follow a single request as it passes through multiple services, providing a visual timeline of where latencies or errors occurred.
**Certification Alignment:** CNCF Distributed Tracing Best Practices / SRE Principles
</details>

**Scenario S2: The "Cluster Drift Nightmare"**
A developer manually edited a Kubernetes Deployment on the production cluster to increase memory. However, the next time ArgoCD synced with Git, the manual change was overwritten and the pod crashed due to OOM (Out of Memory).
**Question**: What is the GitOps principle that caused this, and what should the developer have done instead?
- A) Principle: Declarative State. Action: They should have committed the change to Git first.
- B) Principle: Manual Override. Action: They should have disabled ArgoCD.
- C) Principle: Reconciliation Loop. Action: They should have used a different cluster.
- D) Principle: Immutability. Action: They should have restarted the pod.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** In GitOps, the Git repo is the source of truth. ArgoCD continuously reconciles the cluster state to match the Git state. Any manual changes are "drift" and are automatically reverted by the controller.
**Certification Alignment:** ArgoCD Certified Professional
</details>

**Scenario S3: The "Security Gateway Failure"**
An attacker managed to exploit a vulnerability in one service and is now trying to move laterally through your internal cluster network to access the database.
**Question**: Which Advanced Kubernetes/Networking concept could have prevented this lateral movement by strictly defining which pods can talk to each other?
- A) Load Balancer
- B) Network Policies / Service Mesh (mTLS)
- C) Node Affinity
- D) Horizontal Pod Autoscaling

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Network Policies act as pod-level firewalls. Combined with mTLS, they ensure that only authorized services can communicate, following the Zero Trust model.
**Certification Alignment:** CKS (Certified Kubernetes Security Specialist)
</details>

**Scenario S4: The "Expensive Cloud Pipe"**
An enterprise is running its analytics on GCP and its production databases on AWS. The data transfer costs (egress) between the two clouds are becoming unsustainable, and the latency is affecting real-time dashboards.
**Question**: Which combination of architectural changes would most effectively reduce both cost and latency?
- A) Moving all data to a single cloud provider and using a dedicated private connection (e.g., Megaport) if multi-cloud is still required.
- B) Increasing the frequency of data syncs using `gsutil`.
- C) Upgrading to more expensive VM instances in both clouds.
- D) Implementing a basic VPN between the two clouds.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** Consolidating data reduces inter-cloud egress fees. For high-bandwidth multi-cloud requirements, a dedicated L2 connection like Megaport or Equinix Fabric is significantly cheaper and more stable than a VPN over the public internet.
**Certification Alignment:** AWS Certified Advanced Networking Specialty / Solutions Architect Professional
</details>

**Scenario S5: The "Reliability vs. Features" Dilemma**
Your production system has had several major outages this month, and you have consumed 95% of your quarterly Error Budget. The product manager wants to push a risky new feature tomorrow.
**Question**: According to standard SRE practices, how should the team respond?
- A) Push the feature anyway and hope for the best
- B) Halt new feature releases and focus entirely on engineering tasks to improve system reliability
- C) Delete the SLOs so the budget is reset
- D) Fire the person who caused the outages

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** The Error Budget is a shared contract. When it is depleted, the team enters "Freeze" mode. No new features until the reliability is restored and the budget refreshes.
**Certification Alignment:** Google Professional Cloud DevOps Engineer / SRE Principles
</details>

**Scenario S6: The "Monolith Split"**
You are breaking down a massive legacy e-commerce monolith. You want to move the "Inventory" logic to a separate service, but the original database has complex foreign key relationships between Inventory and Orders.
**Question**: What is the most recommended approach to handle data in a microservices architecture?
- A) Keep using the same shared database for both services to maintain referential integrity.
- B) Give the Inventory service its own private database and use asynchronous events (Eventual Consistency) to keep it in sync with Orders.
- C) Copy the entire database for every service.
- D) Disable all foreign keys and keep the shared database.

<details>
<summary>Click to Reveal Answer**Correct Answer:** B
**Why?** "Database per Service" is a core microservices pattern. It ensures that services are truly independent. Integrity is managed at the application/event layer rather than the database layer.
**Certification Alignment:** Microservices Design Patterns / AWS Certified Developer Associate
</details>

---

## Answer Key (Summary)
1. B | 2. C | 3. C | 4. B | 5. B | 6. B | 7. C | 8. D
K8s/Orchestration: 1. B | 2. A
Security: 1. C | 2. C | 3. A
Performance/Resilience: 1. B | 2. A | 3. A | 4. B | 5. B | 6. B | 7. B | 8. B
Networking: 1. B | 2. B | 3. A | 4. B
SRE/FinOps: 1. A | 2. B | 3. C | 4. A
Microservices: 1. B | 2. B | 3. B | 4. B
Scenarios: S1. C | S2. A | S3. B | S4. A | S5. B | S6. B