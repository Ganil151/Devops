# Advanced Level: Enterprise Excellence Quizzes

Thrive in mission-critical infrastructure by mastering observability, security-as-code, and advanced orchestration patterns.

## Module 01: GitOps & DeclarativeCD
**Study Resource**: [GitOps with ArgoCD](../../3-Advanced/01-GitOps/README.md)

1. What is GitOps?
- A) Using Git for operations only
- B) A methodology using Git for declarative infrastructure and applications
- C) A branching strategy in Git
- D) A monitoring tool

2. What is ArgoCD?
- A) A CI tool
- B) A monitoring dashboard
- C) A GitOps continuous delivery tool for Kubernetes
- D) A container builder

---

## Module 02: Observability & Monitoring
**Study Resource**: [Advanced Observability](../../3-Advanced/02-Observability/README.md)

3. What is Prometheus used for?
- A) Configuration management
- B) Containerization
- C) Monitoring and alerting
- D) Version control

4. What is the role of ELK stack in DevOps?
- A) Continuous integration
- B) Log management and analysis
- C) Infrastructure provisioning
- D) Container orchestration

5. What is observability in DevOps?
- A) Only logging
- B) Understanding system internals through metrics, logs, and traces
- C) Deployment strategy
- D) Version control

6. What is the purpose of Grafana?
- A) Build automation
- B) Visualization of metrics
- C) Code repository
- D) Container registry

7. What is Splunk used for?
- A) CI/CD
- B) Containerization
- C) Log analysis and SIEM
- D) IaC

8. What is the function of Nagios?
- A) Build automation
- B) Code deployment
- C) Container management
- D) System monitoring

---

## Module 03: Advanced Orchestration & Networking
**Study Resource**: [Advanced Kubernetes](../../3-Advanced/03-Advanced-K8s/README.md)

9. What is the role of Istio in DevOps?
- A) Version control
- B) Service mesh for microservices
- C) Log aggregation
- D) Build automation

10. What is microservices architecture?
- A) Breaking applications into small, independent services
- B) A single monolithic application
- C) Hardware-based services
- D) Database services only

---

## Module 04: DevSecOps & Security
**Study Resource**: [Enterprise Security](../../3-Advanced/04-Security/README.md)

11. Which tool is used for secrets management?
- A) Jenkins
- B) Docker
- C) Vault
- D) Git

12. What is DevSecOps?
- A) Development and security only
- B) Operations without security
- C) Integrating security into DevOps practices
- D) Separate security team

13. What is the benefit of using immutable infrastructure?
- A) Predictable and reproducible environments
- B) Easy to modify at runtime
- C) Reduces automation
- D) Increases manual intervention

---

## Module 05: Performance & Resilience

14. What is canary deployment?
- A) Full deployment to all users
- B) Gradual rollout to a subset of users
- C) Backup deployment strategy
- D) Manual rollback process

15. What is Chaos Engineering?
- A) Intentionally introducing failures to test resilience
- B) Fixing bugs in production
- C) Automating tests only
- D) Monitoring tools

16. What is serverless architecture?
- A) Running code without managing servers
- B) Using physical servers only
- C) Manual scaling
- D) Database-focused

17. What is an ArgoCD 'Sync Policy'?
- A) A rule that determines how Git branches are merged
- B) A configuration that defines if and how ArgoCD automatically synchronizes Git state to the cluster
- C) A load balancing strategy
- D) A password rotation policy

18. What is the role of an OpenTelemetry (OTel) Collector?
- A) To store logs permanently
- B) To receive, process, and export telemetry data (metrics, logs, traces) to various backends
- C) To run containerized applications
- D) To manage cloud billing

19. In a DevSecOps "Shift Left" strategy, what is the best way to handle container vulnerabilities?
- A) Scan containers only in production
- B) Implement automated container scanning in the CI/CD pipeline before deployment
- C) Manual inspection of every Docker image
- D) Ignore vulnerabilities unless a breach occurs

20. What is a 'Sidecar' container in a Service Mesh (like Istio)?
- A) A backup server
- B) A helper container that runs alongside the main application container to handle networking, security, or logging
- C) A type of database
- D) A monitoring dashboard

21. What is the benefit of a Multi-Cloud strategy?
- A) It is always cheaper than single-cloud
- B) It avoids vendor lock-in and increases resilience by distributing workloads across multiple providers
- C) It simplifies networking
- D) It reduces the need for Kubernetes

---

## 🏗️ Real-World Scenarios (Advanced)

**Scenario S1: The "Silent Data Loss"**
A distributed microservices application is reporting internal errors (500), but the standard monitoring dashbaord shows "Green" (All systems up). Logs show errors, but you can't see which specific service in the 20-service chain started the failure.
**Question**: Which observability pillar should you implement/check to trace the request path across all services?
- A) Metrics
- B) Logs
- C) Distributed Tracing (e.g., Jaeger)
- D) Monitoring Dashboards

**Scenario S2: The "Cluster Drift Nightmare"**
A developer manually edited a Kubernetes Deployment on the production cluster to increase memory. However, the next time ArgoCD synced with Git, the manual change was overwritten and the pod crashed due to OOM (Out of Memory).
**Question**: What is the GitOps principle that caused this, and what should the developer have done instead?
- A) Principle: Declarative State. Action: They should have committed the change to Git first.
- B) Principle: Manual Override. Action: They should have disabled ArgoCD.
- C) Principle: Reconciliation Loop. Action: They should have used a different cluster.
- D) Principle: Immutability. Action: They should have restarted the pod.

**Scenario S3: The "Security Gateway Failure"**
An attacker managed to exploit a vulnerability in one service and is now trying to move laterally through your internal cluster network to access the database.
**Question**: Which Advanced Kubernetes/Networking concept could have prevented this lateral movement by strictly defining which pods can talk to each other?
- A) Load Balancer
- B) Network Policies / Service Mesh (mTLS)
- C) Node Affinity
- D) Horizontal Pod Autoscaling

---

## Answer Key
1. B
2. C
3. C
4. B
5. B
6. B
7. C
8. D
9. B
10. A
11. C
12. C
13. A
14. B
15. A
16. A
17. B
18. B
19. B
20. B
21. B

**Scenarios:**
S1. C
S2. A
S3. B
