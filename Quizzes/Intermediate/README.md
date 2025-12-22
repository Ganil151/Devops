# Intermediate Level: Automation & Orchestration Quizzes

Deepen your understanding of cluster management, infrastructure as code, and automated configuration.

## Module 01: Kubernetes Core
**Study Resource**: [Kubernetes Modules](../../2-Intermediate/01-Kubernetes/README.md)

1. What is Kubernetes primarily used for?
- A) Container orchestration
- B) Version control
- C) Configuration management
- D) Monitoring

2. What is a Pod in Kubernetes?
- A) The smallest deployable unit
- B) A type of service
- C) A namespace
- D) A volume

3. What is a Service in Kubernetes?
- A) A storage volume
- B) A deployment unit
- C) An abstraction for accessing Pods
- D) A config map

4. What is a ReplicaSet in Kubernetes?
- A) A single pod
- B) Ensures a specified number of pod replicas
- C) A network policy
- D) A persistent volume

5. What is a ConfigMap in Kubernetes?
- A) A secret storage
- B) A pod template
- C) A network rule
- D) Non-sensitive configuration data

---

## Module 02: Helm & Application Packaging
**Study Resource**: [Helm Packaging](../../2-Intermediate/02-Helm/README.md)

6. What is Helm in Kubernetes?
- A) A container runtime
- B) A load balancer
- C) A package manager
- D) A monitoring tool

7. What is the primary purpose of a Helm Chart?
- A) To monitor CPU usage
- B) To define, install, and upgrade Kubernetes applications
- C) To manage Docker images
- D) To provision cloud servers

---

## Module 03: Ansible & Configuration Management
**Study Resource**: [Ansible Automation](../../2-Intermediate/03-Ansible/README.md)

8. What is Ansible used for in DevOps?
- A) Container building
- B) CI/CD pipelines
- C) Configuration management and automation
- D) Load balancing

9. What is idempotency in configuration management?
- A) Applying the same configuration multiple times yields the same result
- B) Only one-time application
- C) Random results
- D) Error-prone execution

10. Which of the following is a configuration management tool?
- A) Jenkins
- B) Docker
- C) Chef
- D) Prometheus

---

## Module 04: Terraform (Infrastructure as Code)
**Study Resource**: [Terraform IaC](../../2-Intermediate/04-Terraform/README.md)

11. What is Infrastructure as Code (IaC)?
- A) Writing code for hardware
- B) Managing infrastructure through code and automation
- C) Manual configuration of servers
- D) Only for cloud environments

12. Which tool is used for infrastructure provisioning?
- A) Jenkins
- B) Git
- C) Docker
- D) Terraform

13. What is Terraform's main language?
- A) HCL
- B) YAML
- C) JSON
- D) Python

---

## Module 05: CI/CD Pipelines & Testing
**Study Resource**: [Intermediate CI/CD](../../2-Intermediate/05-CI-CD/README.md)

14. What is the difference between Continuous Delivery and Continuous Deployment?
- A) They are the same
- B) Continuous Delivery requires manual approval, while Deployment is automatic
- C) Delivery is for testing, Deployment for production
- D) No difference in automation

15. What is blue-green deployment?
- A) A strategy for zero-downtime deployments
- B) A color-coding system for servers
- C) A testing environment setup
- D) A monitoring tool

16. What is SonarQube used for?
- A) Deployment
- B) Monitoring
- C) Code quality analysis
- D) Logging

17. What is a Jenkinsfile?
- A) A Docker configuration
- B) A Kubernetes manifest
- C) A script defining a Jenkins pipeline
- D) A Git hook

18. What is the purpose of a Kubernetes Ingress?
- A) To store persistent data
- B) To manage external access to services, typically HTTP/HTTPS
- C) To scale pods automatically
- D) To secure container images

19. In Helm, how do you revert to a previous version of a release?
- A) helm delete
- B) helm rollback
- C) helm install --upgrade
- D) helm repo update

20. What is an Ansible 'Role'?
- A) A user permission in Ansible Tower
- B) A way to group related tasks, variables, and handlers into a reusable structure
- C) A type of inventory file
- D) A cloud provider plugin

21. What happens if you lose your Terraform State (`.tfstate`) file?
- A) Your infrastructure is automatically deleted
- B) Terraform loses track of the resources it managed, making updates difficult
- C) Nothing, Terraform will automatically rebuild it from the provider's API
- D) The code becomes read-only

22. Which cloud-native database service is best for highly scalable, non-relational (NoSQL) data?
- A) Amazon RDS
- B) Amazon Aurora
- C) Amazon DynamoDB
- D) PostgreSQL on EC2

---

## 🏗️ Real-World Scenarios (Intermediate)

**Scenario S1: The "Manual Configuration Drift"**
A Large enterprise has 50 web servers. An admin manually patched one server but forgot the others, leading to inconsistent behavior.
**Question**: Which tool should the team use to ensure all 50 servers have the exact same configuration automatically?
- A) Kubernetes
- B) Terraform
- C) Ansible
- D) Jenkins

**Scenario S2: The "Cluster Overload"**
Your Kubernetes cluster is running out of resources because a single deployment created 100 replicas of a memory-heavy app. You need a way to ensure this doesn't happen again.
**Question**: What Kubernetes resource object should you define to limit the CPU/Memory a namespace can use?
- A) LimitRange / ResourceQuota
- B) Ingress
- C) ConfigMap
- D) Service

**Scenario S3: The "Broken Infrastructure Update"**
You used Terraform to update your VPC, but the change accidentally blocked all inbound traffic to your database, breaking the production app. You need to quickly see what exactly changed in the infrastructure before deciding how to fix it.
**Question**: Which command would have previevented this if run before applying changes?
- A) terraform init
- B) terraform plan
- C) terraform state list
- D) terraform output

---

## Answer Key
1. A
2. A
3. C
4. B
5. D
6. C
7. B
8. C
9. A
10. C
11. B
12. D
13. A
14. B
15. A
16. C
17. C
18. B
19. B
20. B
21. B
22. C

**Scenarios:**
S1. C
S2. A
S3. B
