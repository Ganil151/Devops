Terraform is an open-source Infrastructure as Code (IaC) tool created by HashiCorp that allows you to define and provision infrastructure using a declarative configuration language.

## Key Benefits
- **Infrastructure as Code**: Version control your infrastructure.
- **Multi-Cloud**: Support for 1000+ providers (AWS, Azure, GCP, etc.).
- **Declarative**: Describe the desired state, not the steps to get there.
- **Plan and Apply**: Preview changes before execution to avoid surprises.
- **State Management**: Track resource relationships and metadata.
- **Modular**: Build reusable infrastructure components.

## Use Cases
- **Cloud Infrastructure**: Managing AWS, Azure, GCP resources.
- **Multi-Cloud Deployments**: Consistent infrastructure across multiple clouds.
- **Application Infrastructure**: Managing Kubernetes, Docker, and databases.
- **Network Infrastructure**: Provisioning VPCs, load balancers, and DNS.
- **Security Infrastructure**: Configuring IAM, security groups, and certificates.

---

## 🏗️ Real-Life Scenario: The Manual Setup Trap
**Problem**: A startup needs to deploy their web app to AWS. The lead engineer manually creates the VPC, 3 EC2 instances, and an RDS database. When it's time to create a "staging" environment, they realize they can't remember all the manual settings, leading to "Environment Drift."
**Solution**: By using Terraform, the engineer defines the entire infrastructure in a `main.tf` file. They can now deploy identical copies of the environment (Dev, Staging, Prod) in minutes, ensuring consistency and version control.

---

## ❓ Interview Questions
1. **What is Infrastructure as Code (IaC)?**
   - *Answer*: IaC is the process of managing and provisioning computer data centers through machine-readable definition files, rather than physical hardware configuration or interactive configuration tools.
2. **How does Terraform differ from Ansible?**
   - *Answer*: Terraform is primarily an orchestration tool (Focuses on *Infrastructure*), while Ansible is a configuration management tool (Focuses on *Apps/OS*). Terraform is declarative, whereas Ansible can be procedural.

---

## 🧠 Quiz Snippet (5/20+)
1. **Who created Terraform?** (HashiCorp)
2. **What language does Terraform use?** (HCL - HashiCorp Configuration Language)
3. **Is Terraform Declarative or Imperative?** (Declarative)
4. **Name one advantage of using IaC.** (Version control, consistency, speed)
5. **Can Terraform manage on-premise infrastructure?** (Yes, with appropriate providers like VMware or OpenStack)
