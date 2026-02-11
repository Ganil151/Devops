# Intermediate Level: Automation & Orchestration Quizzes

Deepen your understanding of cluster management, infrastructure as code, and automated configuration.

## Module 01: Kubernetes Core
**Study Resource**: [Kubernetes Modules](../../readme.md)

1. What is Kubernetes primarily used for?
- A) Container orchestration
- B) Version control
- C) Configuration management
- D) Monitoring

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** Kubernetes (K8s) is an open-source system for automating deployment, scaling, and management of containerized applications.
**Certification Alignment:** CKA / CKAD
</details>

2. What is a Pod in Kubernetes?
- A) The smallest deployable unit
- B) A type of service
- C) A namespace
- D) A volume

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** A Pod is the smallest and simplest unit in the Kubernetes object model that you create or deploy. It represents a single instance of a running process in your cluster.
**Certification Alignment:** CKA / CKAD
</details>

3. What is a Service in Kubernetes?
- A) A storage volume
- B) A deployment unit
- C) An abstraction for accessing Pods
- D) A config map

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** A Service is an abstract way to expose an application running on a set of Pods as a network service. It provides a stable IP address and DNS name.
**Certification Alignment:** CKA / CKAD
</details>

4. What is a ReplicaSet in Kubernetes?
- A) A single pod
- B) Ensures a specified number of pod replicas
- C) A network policy
- D) A persistent volume

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** A ReplicaSet's purpose is to maintain a stable set of replica Pods running at any given time. It is often used to guarantee the availability of a specified number of identical Pods.
**Certification Alignment:** CKA / CKAD
</details>

5. What is a ConfigMap in Kubernetes?
- A) A secret storage
- B) A pod template
- C) A network rule
- D) Non-sensitive configuration data

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** D
**Why?** ConfigMaps allow you to decouple environment-specific configuration from your container images, so that your applications are easily portable.
**Certification Alignment:** CKAD / CKA
</details>

6. What is the purpose of a Kubernetes Ingress?
- A) To store persistent data
- B) To manage external access to services, typically HTTP/HTTPS
- C) To scale pods automatically
- D) To secure container images

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource.
**Certification Alignment:** CKA / CKAD
</details>

---

## Module 02: Helm & Application Packaging
**Study Resource**: [Helm Packaging](../../readme.md)

1. What is Helm in Kubernetes?
- A) A container runtime
- B) A load balancer
- C) A package manager
- D) A monitoring tool

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** Helm is the package manager for Kubernetes. It helps you manage Kubernetes applications through Helm Charts.
**Certification Alignment:** CKA / Helm Best Practices
</details>

2. What is the primary purpose of a Helm Chart?
- A) To monitor CPU usage
- B) To define, install, and upgrade Kubernetes applications
- C) To manage Docker images
- D) To provision cloud servers

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Helm Charts are packages of pre-configured Kubernetes resources. They allow for easy sharing, versioning, and deployment of complex applications.
**Certification Alignment:** CKAD / Helm Best Practices
</details>

3. In Helm, how do you revert to a previous version of a release?
- A) helm delete
- B) helm rollback
- C) helm install --upgrade
- D) helm repo update

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** `helm rollback [RELEASE] [REVISION]` allows you to quickly revert to a previous known-good state of your application deployment.
**Certification Alignment:** CKAD / Helm Best Practices
</details>

4. What is the difference between a "Chart version" and an "App version" in Helm?
- A) Chart version is for the Helm tool; App version is for the application
- B) Chart version tracks changes to the packaging; App version tracks the version of the software inside
- C) They should always be the same
- D) Helm doesn't use App versions

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** This separation allows you to update the Helm deployment configuration (Chart version) without necessarily changing the application code itself (App version), or vice-versa.
**Certification Alignment:** Helm Best Practices
</details>

5. Which file in a Helm chart is used to define default configuration values?
- A) Chart.yaml
- B) configuration.json
- C) values.yaml
- D) settings.conf

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** `values.yaml` provides the default configuration for the chart. These values can be overridden by users during installation or upgrade.
**Certification Alignment:** CKAD / Helm Best Practices
</details>

---

## Module 03: Ansible & Configuration Management
**Study Resource**: [Ansible Automation](../../readme.md)

1. What is Ansible used for in DevOps?
- A) Container building
- B) CI/CD pipelines
- C) Configuration management and automation
- D) Load balancing

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** Ansible is an agentless automation tool used for configuration management, application deployment, and task automation.
**Certification Alignment:** Red Hat Certified Specialist in Ansible Automation
</details>

2. What is idempotency in configuration management?
- A) Applying the same configuration multiple times yields the same result
- B) Only one-time application
- C) Random results
- D) Error-prone execution

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** An idempotent operation can be performed many times without changing the result beyond the initial application. This is crucial for maintaining a consistent state across infrastructure.
**Certification Alignment:** Red Hat Certified Specialist in Ansible Automation / DevOps Best Practices
</details>

3. Which of the following is a configuration management tool?
- A) Jenkins
- B) Docker
- C) Chef
- D) Prometheus

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** Chef is a powerful configuration management tool that uses "Recipes" and "Cookbooks" to define the desired state of infrastructure.
**Certification Alignment:** Chef Basic Fluency / DevOps Tooling
</details>

4. What is an Ansible 'Role'?
- A) A user permission in Ansible Tower
- B) A way to group related tasks, variables, and handlers into a reusable structure
- C) A type of inventory file
- D) A cloud provider plugin

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Roles provide a framework for fully independent and reusable units of automation, allowing for better organization of complex playbooks.
**Certification Alignment:** Red Hat Certified Specialist in Ansible Automation
</details>

5. What is a "Handler" in Ansible?
- A) A script that runs at the very beginning of a playbook
- B) A task that only runs when notified by another task (usually for service restarts)
- C) A way to handle errors in code
- D) A physical device connected to the network

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Handlers are used to perform actions that should only occur if a change has been made, such as restarting a service after a configuration file update.
**Certification Alignment:** Red Hat Certified Specialist in Ansible Automation
</details>

---

## Module 4: Terraform (Infrastructure as Code)
**Study Resource**: [Terraform IaC](../../readme.md)

1. What is Infrastructure as Code (IaC)?
- A) Writing code for hardware
- B) Managing infrastructure through code and automation
- C) Manual configuration of servers
- D) Only for cloud environments

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** IaC is the managing and provisioning of infrastructure through code instead of through manual processes.
**Certification Alignment:** HashiCorp Certified: Terraform Associate
</details>

2. Which tool is used for infrastructure provisioning?
- A) Jenkins
- B) Git
- C) Docker
- D) Terraform

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** D
**Why?** Terraform is an open-source infrastructure as code software tool that provides a consistent CLI workflow to manage hundreds of cloud services.
**Certification Alignment:** HashiCorp Certified: Terraform Associate
</details>

3. What is Terraform's main language?
- A) HCL
- B) YAML
- C) JSON
- D) Python

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** HashiCorp Configuration Language (HCL) is designed to be human-readable and machine-friendly for infrastructure definitions.
**Certification Alignment:** HashiCorp Certified: Terraform Associate
</details>

4. What happens if you lose your Terraform State (`.tfstate`) file?
- A) Your infrastructure is automatically deleted
- B) Terraform loses track of the resources it managed, making updates difficult
- C) Nothing, Terraform will automatically rebuild it from the provider's API
- D) The code becomes read-only

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** The state file is Terraform's "source of truth." Without it, Terraform cannot know the current status of the infrastructure it created, leading to potential duplicate resource creation or errors.
**Certification Alignment:** HashiCorp Certified: Terraform Associate
</details>

5. What is the purpose of `terraform output`?
- A) To print the entire state file
- B) To extract and display specific values (like an IP address) from the state file
- C) To send logs to a remote server
- D) To delete all resources

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Output variables are a way to expose information about your infrastructure on the command line, and can also be used by other Terraform configurations.
**Certification Alignment:** HashiCorp Certified: Terraform Associate
</details>

---

## Module 05: CI/CD Pipelines & Testing
**Study Resource**: [Intermediate CI/CD](../../readme.md)

1. What is the difference between Continuous Delivery and Continuous Deployment?
- A) They are the same
- B) Continuous Delivery requires manual approval, while Deployment is automatic
- C) Delivery is for testing, Deployment for production
- D) No difference in automation

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Continuous Delivery is the practice of ensuring code is always in a deployable state. Continuous Deployment takes it a step further by automatically deploying every change that passes the pipeline to production.
**Certification Alignment:** AWS Certified DevOps Engineer Professional / DevOps Best Practices
</details>

2. What is blue-green deployment?
- A) A strategy for zero-downtime deployments
- B) A color-coding system for servers
- C) A testing environment setup
- D) A monitoring tool

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** Blue-green deployment involves running two identical production environments. Only one is live at a time. This allows for zero-downtime updates and instant rollbacks.
**Certification Alignment:** AWS Certified DevOps Engineer Professional
</details>

3. What is SonarQube used for?
- A) Deployment
- B) Monitoring
- C) Code quality analysis
- D) Logging

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** SonarQube is an open-source platform for continuous inspection of code quality to perform automatic reviews with static analysis of code.
**Certification Alignment:** DevOps Best Practices / Security Auditing
</details>

4. What is a Jenkinsfile?
- A) A Docker configuration
- B) A Kubernetes manifest
- C) A script defining a Jenkins pipeline
- D) A Git hook

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** A Jenkinsfile is a text file that contains the definition of a Jenkins Pipeline and is checked into source control. This is the "Pipeline as Code" approach.
**Certification Alignment:** Certified Jenkins Engineer (CJE)
</details>

---

## Module 06: Cloud Networking (VPC & Routing)
**Study Resource**: [VPC Networking](../../02-intermediate/01-phase-1/01-networking/readme.md)

1. Which CIDR notation represents a network with 256 IP addresses?
- A) /32
- B) /24
- C) /16
- D) /8

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** A /24 mask provides 2^(32-24) = 2^8 = 256 total IP addresses (some of which are reserved for network and broadcast).
**Certification Alignment:** AWS Certified Cloud Practitioner / Solutions Architect Associate
</details>

2. What is the primary purpose of a NAT Gateway in a cloud VPC?
- A) To allow inbound traffic from the internet to private instances
- B) To allow private instances to access the internet while remaining protected from inbound traffic
- C) To balance traffic between multiple web servers
- D) To store secret keys for network access

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** NAT Gateways enable instances in a private subnet to connect to the internet or other AWS services, but prevent the internet from initiating a connection with those instances.
**Certification Alignment:** AWS Certified Solutions Architect Associate
</details>

3. Which type of Load Balancer operates at Layer 7 (Application) and is ideal for path-based routing?
- A) Classic Load Balancer
- B) Network Load Balancer (NLB)
- C) Application Load Balancer (ALB)
- D) Gateway Load Balancer

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** ALBs operate at the application layer and can make routing decisions based on the content of the HTTP/HTTPS request, such as URL paths or headers.
**Certification Alignment:** AWS Certified Solutions Architect Associate
</details>

4. What is the main difference between a Public and Private subnet in a cloud VPC?
- A) Public subnets have a route to an Internet Gateway; Private subnets do not.
- B) Private subnets are encrypted; Public subnets are not.
- C) Only Public subnets can host Kubernetes pods.
- D) There is no functional difference.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** The defining characteristic of a public subnet is that its route table includes a path to an Internet Gateway (0.0.0.0/0 -> IGW).
**Certification Alignment:** AWS Certified Solutions Architect Associate
</details>

---

## Module 07: Managed Databases & Serverless
**Study Resource**: [Cloud Foundations](../../readme.md)

1. What is a primary advantage of using a Managed Database service (like Amazon RDS) instead of running a DB on a VM?
- A) It is always free
- B) Automated backups, patching, and high availability
- C) It eliminates the need for any SQL knowledge
- D) It prevents database table deletions

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Managed database services handle the "undifferentiated heavy lifting" of database administration, allowing developers to focus on application logic.
**Certification Alignment:** AWS Certified Cloud Practitioner / Solutions Architect Associate
</details>

2. Which cloud-native database service is best for highly scalable, non-relational (NoSQL) data?
- A) Amazon RDS
- B) Amazon Aurora
- C) Amazon DynamoDB
- D) PostgreSQL on EC2

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** DynamoDB is a key-value and document database that delivers single-digit millisecond performance at any scale.
**Certification Alignment:** AWS Certified Developer Associate
</details>

3. Which of the following is a "NoSQL" database service provided by cloud vendors?
- A) Amazon RDS (MySQL)
- B) Azure SQL Database
- C) Amazon DynamoDB
- D) Google Cloud SQL (PostgreSQL)

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** DynamoDB is a fully managed NoSQL database service that supports key-value and document data structures.
**Certification Alignment:** AWS Certified Solutions Architect Associate
</details>

4. What does "Serverless" computing mean in the context of tools like AWS Lambda or Azure Functions?
- A) There are no physical servers involved at all
- B) The developer does not need to manage or provision the underlying server infrastructure
- C) Applications run on user's local machines instead of the cloud
- D) It only works for static HTML websites

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Serverless computing allows you to build and run applications and services without having to manage infrastructure. Your application still runs on servers, but all the server management is done by AWS.
**Certification Alignment:** AWS Certified Developer Associate / Cloud Practitioner
</details>

5. In a Multi-AZ (Availability Zone) database deployment, what is the primary goal?
- A) Lower latency for all users
- B) Higher storage capacity
- C) High Availability and Disaster Recovery (Failover)
- D) Cheaper monthly costs

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** Multi-AZ deployments provide enhanced availability and durability for database instances by automatically failing over to a standby replica in a different AZ in case of failure.
**Certification Alignment:** AWS Certified Solutions Architect Associate
</details>

---

## Module 08: Scripting & Advanced Config (Chef)
**Study Resource**: [Chef Automation](../../readme.md) & [Automation Foundations](../../readme.md)

1. In a Bash script, which variable contains the exit status of the most recently executed command?
- A) `$@`
- B) `$?`
- C) `$$`
- D) `$0`

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** `$?` captures the exit code of the last command. An exit code of `0` typically means success, while any other value indicates an error.
**Certification Alignment:** CompTIA Linux+ / LPIC-1
</details>

2. What is the fundamental difference between Chef and Ansible's architecture?
- A) Chef is push-based; Ansible is pull-based
- B) Chef is pull-based (agents check-in); Ansible is push-based (SSH from controller)
- C) Ansible requires a permanent agent; Chef does not
- D) There is no architectural difference

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Ansible uses a "push" model over SSH, making it agentless. Chef uses a "pull" model where agents installed on the target nodes periodically check the Chef Server for updates.
**Certification Alignment:** DevOps Tooling Comparison / Chef Basic Fluency
</details>

3. In Chef, what is a "Recipe"?
- A) A list of users in the cloud
- B) A script that defines a set of resources and their desired state
- C) A type of Docker image
- D) A network firewall rule

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** A recipe is the fundamental unit of configuration in Chef, written in Ruby, defining how a particular piece of infrastructure should be set up.
**Certification Alignment:** Chef Basic Fluency
</details>

4. Which Chef tool is used to manage the local development of cookbooks and interface with the Chef Server?
- A) Ohai
- B) Knife
- C) Kitchen
- D) InSpec

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** `knife` is a command-line tool that provides an interface between a local chef-repo and the Chef Server.
**Certification Alignment:** Chef Basic Fluency
</details>

---

## 🏗️ Real-World Scenarios (Intermediate)

**Scenario S1: The "Manual Configuration Drift"**
A Large enterprise has 50 web servers. An admin manually patched one server but forgot the others, leading to inconsistent behavior.
**Question**: Which tool should the team use to ensure all 50 servers have the exact same configuration automatically?
- A) Kubernetes
- B) Terraform
- C) Ansible
- D) Jenkins

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** Ansible is ideal for configuration management across a large fleet of virtual machines, ensuring that all servers are brought to the desired state defined in a playbook.
**Certification Alignment:** Red Hat Certified Specialist in Ansible Automation
</details>

**Scenario S2: The "Cluster Overload"**
Your Kubernetes cluster is running out of resources because a single deployment created 100 replicas of a memory-heavy app. You need a way to ensure this doesn't happen again.
**Question**: What Kubernetes resource object should you define to limit the CPU/Memory a namespace can use?
- A) LimitRange / ResourceQuota
- B) Ingress
- C) ConfigMap
- D) Service

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** A
**Why?** A ResourceQuota provides constraints that limit aggregate resource consumption per Namespace. LimitRange can be used to set default or min/max requests and limits for individual containers.
**Certification Alignment:** CKA / CKAD
</details>

**Scenario S3: The "Broken Infrastructure Update"**
You used Terraform to update your VPC, but the change accidentally blocked all inbound traffic to your database, breaking the production app. You need to quickly see what exactly changed in the infrastructure before deciding how to fix it.
**Question**: Which command would have previevented this if run before applying changes?
- A) terraform init
- B) terraform plan
- C) terraform state list
- D) terraform output

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** `terraform plan` compares the current state with the desired state defined in your code and shows you exactly what actions Terraform will take (create, update, delete) BEFORE you commit to them.
**Certification Alignment:** HashiCorp Certified: Terraform Associate
</details>

**Scenario S4: The "Silent Database"**
An application server in a private subnet cannot connect to its database server in another private subnet within the same VPC. Pings are failing. The DB server is verified to be running on the correct port.
**Question**: If the Network ACL allows the traffic, what is the most likely missing configuration?
- A) The Route Table doesn't have a path to the internet.
- B) The Security Group of the database doesn't allow inbound traffic from the application server's security group/IP.
- C) The database needs a Public IP address.
- D) The NAT Gateway is down.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Security Groups must explicitly allow inbound traffic from either the CIDR block of the application subnet or, more securely, from the Security Group ID of the application server.
**Certification Alignment:** AWS Certified Solutions Architect Associate
</details>

**Scenario S5: The "Scaling Database"**
A growing startup is experiencing frequent downtime because their single PostgreSQL server on a small virtual machine cannot handle sudden traffic spikes. They also have no automated backups.
**Question**: Which migration path offers the most immediate improvement for both reliability and scalability with minimal management overhead?
- A) Upgrading the VM to a larger size manually
- B) Moving the database to a Managed Service like Amazon RDS with Multi-AZ enabled
- C) Shredding the data into smaller text files
- D) Replacing the database with a static JSON file

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Amazon RDS (Relational Database Service) takes care of backups, patching, and hardware scaling, while Multi-AZ provides high availability and automatic failover.
**Certification Alignment:** AWS Certified Solutions Architect Associate
</details>

**Scenario S6: The "Automation Choice"**
Your company has thousands of servers that need constant configuration updates and compliance audits. You need a system where the servers "phone home" to pull their latest configurations, rather than having a central server push to all of them at once.
**Question**: Which tool/model fits this "pull" requirement best?
- A) Ansible
- B) Chef (with Chef Client)
- C) A manual Bash script run via Cron
- D) Terraform

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** Chef Client runs as a background process on each node and periodically "pulls" configuration updates from the Chef Server, ensuring the node stays in compliance even at massive scales.
**Certification Alignment:** Chef Basic Fluency / DevOps Tooling
</details>

---

## Answer Key (Summary)
1. A | 2. A | 3. C | 4. B | 5. D | 6. B
Helm: 1. C | 2. B | 3. B | 4. B | 5. C
Ansible: 1. C | 2. A | 3. C | 4. B | 5. B
Terraform: 1. B | 2. D | 3. A | 4. B | 5. B
CI/CD: 1. B | 2. A | 3. C | 4. C
Networking: 1. B | 2. B | 3. C | 4. A
Databases: 1. B | 2. C | 3. C | 4. B | 5. C
Scripting: 1. B | 2. B | 3. B | 4. B
Scenarios: S1. C | S2. A | S3. B | S4. B | S5. B | S6. B