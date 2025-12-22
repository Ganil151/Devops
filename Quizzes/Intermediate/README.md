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

6. What is the purpose of a Kubernetes Ingress?
- A) To store persistent data
- B) To manage external access to services, typically HTTP/HTTPS
- C) To scale pods automatically
- D) To secure container images

---

## Module 02: Helm & Application Packaging
**Study Resource**: [Helm Packaging](../../2-Intermediate/02-Helm/README.md)

7. What is Helm in Kubernetes?
- A) A container runtime
- B) A load balancer
- C) A package manager
- D) A monitoring tool

8. What is the primary purpose of a Helm Chart?
- A) To monitor CPU usage
- B) To define, install, and upgrade Kubernetes applications
- C) To manage Docker images
- D) To provision cloud servers

9. In Helm, how do you revert to a previous version of a release?
- A) helm delete
- B) helm rollback
- C) helm install --upgrade
- D) helm repo update

10. What is the difference between a "Chart version" and an "App version" in Helm?
- A) Chart version is for the Helm tool; App version is for the application
- B) Chart version tracks changes to the packaging; App version tracks the version of the software inside
- C) They should always be the same
- D) Helm doesn't use App versions

11. Which file in a Helm chart is used to define default configuration values?
- A) Chart.yaml
- B) configuration.json
- C) values.yaml
- D) settings.conf

---

## Module 03: Ansible & Configuration Management
**Study Resource**: [Ansible Automation](../../2-Intermediate/03-Ansible/README.md)

12. What is Ansible used for in DevOps?
- A) Container building
- B) CI/CD pipelines
- C) Configuration management and automation
- D) Load balancing

13. What is idempotency in configuration management?
- A) Applying the same configuration multiple times yields the same result
- B) Only one-time application
- C) Random results
- D) Error-prone execution

14. Which of the following is a configuration management tool?
- A) Jenkins
- B) Docker
- C) Chef
- D) Prometheus

15. What is an Ansible 'Role'?
- A) A user permission in Ansible Tower
- B) A way to group related tasks, variables, and handlers into a reusable structure
- C) A type of inventory file
- D) A cloud provider plugin

16. What is a "Handler" in Ansible?
- A) A script that runs at the very beginning of a playbook
- B) A task that only runs when notified by another task (usually for service restarts)
- C) A way to handle errors in code
- D) A physical device connected to the network

---

## Module 4: Terraform (Infrastructure as Code)
**Study Resource**: [Terraform IaC](../../2-Intermediate/04-Terraform/README.md)

17. What is Infrastructure as Code (IaC)?
- A) Writing code for hardware
- B) Managing infrastructure through code and automation
- C) Manual configuration of servers
- D) Only for cloud environments

18. Which tool is used for infrastructure provisioning?
- A) Jenkins
- B) Git
- C) Docker
- D) Terraform

19. What is Terraform's main language?
- A) HCL
- B) YAML
- C) JSON
- D) Python

20. What happens if you lose your Terraform State (`.tfstate`) file?
- A) Your infrastructure is automatically deleted
- B) Terraform loses track of the resources it managed, making updates difficult
- C) Nothing, Terraform will automatically rebuild it from the provider's API
- D) The code becomes read-only

21. What is the purpose of `terraform output`?
- A) To print the entire state file
- B) To extract and display specific values (like an IP address) from the state file
- C) To send logs to a remote server
- D) To delete all resources

---

## Module 05: CI/CD Pipelines & Testing
**Study Resource**: [Intermediate CI/CD](../../2-Intermediate/05-CI-CD/README.md)

22. What is the difference between Continuous Delivery and Continuous Deployment?
- A) They are the same
- B) Continuous Delivery requires manual approval, while Deployment is automatic
- C) Delivery is for testing, Deployment for production
- D) No difference in automation

23. What is blue-green deployment?
- A) A strategy for zero-downtime deployments
- B) A color-coding system for servers
- C) A testing environment setup
- D) A monitoring tool

24. What is SonarQube used for?
- A) Deployment
- B) Monitoring
- C) Code quality analysis
- D) Logging

25. What is a Jenkinsfile?
- A) A Docker configuration
- B) A Kubernetes manifest
- C) A script defining a Jenkins pipeline
- D) A Git hook

---

## Module 06: Cloud Networking (VPC & Routing)
**Study Resource**: [VPC Networking](../../1-Beginner/05-Networking/README.md)

26. Which CIDR notation represents a network with 256 IP addresses?
- A) /32
- B) /24
- C) /16
- D) /8

27. What is the primary purpose of a NAT Gateway in a cloud VPC?
- A) To allow inbound traffic from the internet to private instances
- B) To allow private instances to access the internet while remaining protected from inbound traffic
- C) To balance traffic between multiple web servers
- D) To store secret keys for network access

28. Which type of Load Balancer operates at Layer 7 (Application) and is ideal for path-based routing?
- A) Classic Load Balancer
- B) Network Load Balancer (NLB)
- C) Application Load Balancer (ALB)
- D) Gateway Load Balancer

29. What is the main difference between a Public and Private subnet in a cloud VPC?
- A) Public subnets have a route to an Internet Gateway; Private subnets do not.
- B) Private subnets are encrypted; Public subnets are not.
- C) Only Public subnets can host Kubernetes pods.
- D) There is no functional difference.

---

## Module 07: Managed Databases & Serverless
**Study Resource**: [Cloud Foundations - AWS Basics](../../1-Beginner/08-Cloud-Foundations/01-AWS-Basics/README.md)

30. What is a primary advantage of using a Managed Database service (like Amazon RDS) instead of running a DB on a VM?
- A) It is always free
- B) Automated backups, patching, and high availability
- C) It eliminates the need for any SQL knowledge
- D) It prevents database table deletions

31. Which cloud-native database service is best for highly scalable, non-relational (NoSQL) data?
- A) Amazon RDS
- B) Amazon Aurora
- C) Amazon DynamoDB
- D) PostgreSQL on EC2

32. Which of the following is a "NoSQL" database service provided by cloud vendors?
- A) Amazon RDS (MySQL)
- B) Azure SQL Database
- C) Amazon DynamoDB
- D) Google Cloud SQL (PostgreSQL)

33. What does "Serverless" computing mean in the context of tools like AWS Lambda or Azure Functions?
- A) There are no physical servers involved at all
- B) The developer does not need to manage or provision the underlying server infrastructure
- C) Applications run on user's local machines instead of the cloud
- D) It only works for static HTML websites

34. In a Multi-AZ (Availability Zone) database deployment, what is the primary goal?
- A) Lower latency for all users
- B) Higher storage capacity
- C) High Availability and Disaster Recovery (Failover)
- D) Cheaper monthly costs

---

## Module 08: Scripting & Advanced Config (Chef)
**Study Resource**: [Chef Automation](../../2-Intermediate/10-Chef/README.md) & [Automation Foundations](../../2-Intermediate/07-Automation/README.md)

35. In a Bash script, which variable contains the exit status of the most recently executed command?
- A) `$@`
- B) `$?`
- C) `$$`
- D) `$0`

36. What is the fundamental difference between Chef and Ansible's architecture?
- A) Chef is push-based; Ansible is pull-based
- B) Chef is pull-based (agents check-in); Ansible is push-based (SSH from controller)
- C) Ansible requires a permanent agent; Chef does not
- D) There is no architectural difference

37. In Chef, what is a "Recipe"?
- A) A list of users in the cloud
- B) A script that defines a set of resources and their desired state
- C) A type of Docker image
- D) A network firewall rule

38. Which Chef tool is used to manage the local development of cookbooks and interface with the Chef Server?
- A) Ohai
- B) Knife
- C) Kitchen
- D) InSpec

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

**Scenario S4: The "Silent Database"**
An application server in a private subnet cannot connect to its database server in another private subnet within the same VPC. Pings are failing. The DB server is verified to be running on the correct port.
**Question**: If the Network ACL allows the traffic, what is the most likely missing configuration?
- A) The Route Table doesn't have a path to the internet.
- B) The Security Group of the database doesn't allow inbound traffic from the application server's security group/IP.
- C) The database needs a Public IP address.
- D) The NAT Gateway is down.

**Scenario S5: The "Scaling Database"**
A growing startup is experiencing frequent downtime because their single PostgreSQL server on a small virtual machine cannot handle sudden traffic spikes. They also have no automated backups.
**Question**: Which migration path offers the most immediate improvement for both reliability and scalability with minimal management overhead?
- A) Upgrading the VM to a larger size manually
- B) Moving the database to a Managed Service like Amazon RDS with Multi-AZ enabled
- C) Shredding the data into smaller text files
- D) Replacing the database with a static JSON file

**Scenario S6: The "Automation Choice"**
Your company has thousands of servers that need constant configuration updates and compliance audits. You need a system where the servers "phone home" to pull their latest configurations, rather than having a central server push to all of them at once.
**Question**: Which tool/model fits this "pull" requirement best?
- A) Ansible
- B) Chef (with Chef Client)
- C) A manual Bash script run via Cron
- D) Terraform

---

## Answer Key
1. A
2. A
3. C
4. B
5. D
6. B
7. C
8. B
9. B
10. B
11. C
12. C
13. A
14. C
15. B
16. B
17. B
18. D
19. A
20. B
21. B
22. B
23. A
24. C
25. C
26. B
27. B
28. C
29. A
30. B
31. C
32. C
33. B
34. C
35. B
36. B
37. B
38. B

**Scenarios:**
S1. C
S2. A
S3. B
S4. B
S5. B
S6. B
