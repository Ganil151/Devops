# 🛠️ IaC Architecture Patterns

> **"Architecture is about trade-offs. You can have Fast Updates (Mutable) or Reliable Updates (Immutable), but rarely both."**

This reference breaks down the high-level design choices for Infrastructure as Code.

---

## 🏗️ 1. Provisioning vs Configuration

The "Two-Layer Model" is the industry standard.

| Layer | Tool | Responsibility | Lifecycle |
| :--- | :--- | :--- | :--- |
| **Provisioning** | Terraform | Creates the "Metal" (VPC, EC2, DNS, RDS). | Infrequent changes. |
| **Configuration** | Ansible | Configures the "OS" (Nginx, Users, Cron). | Frequent changes. |

### The "UserData" Bridge
Terraform passes data to Ansible/Bash via `user_data`:
```hcl
resource "aws_instance" "web" {
  user_data = templatefile("init.sh", {
    db_ip = aws_db_instance.main.address
  })
}
```

---

## 🔄 2. Mutable vs Immutable

How do you handle updates?

### Mutable (The "Update" Model)
- **Concept**: SSH into the server and run `apt-get upgrade`.
- **Tool**: Ansible / Chef / Puppet.
- **Pros**: Fast. Valid for Stateful Data bases.
- **Cons**: **Configuration Drift**. Over 2 years, "Server A" becomes different from "Server B".

### Immutable (The "Replace" Model)
- **Concept**: Bake a new Image (AMI) with the update. Destroy old server. Launch new one.
- **Tool**: Packer + Terraform.
- **Pros**: Zero Drift. Exact Replica in Dev/Prod. Easy Rollback.
- **Cons**: Slow Deployment (Baking takes time). Stateless apps only.

**Staff Recommendation**:
- **Stateless Web Apps**: Immutable (Packer + ASG).
- **Databases**: Mutable (RDS or Ansible managed).

---

## 📡 3. Push vs Pull

How does code get to the server?

### Push Mode (Ansible)
- **Flow**: Laptop -> SSH -> Server.
- **Pros**: Immediate control. No agent required. Simpler.
- **Cons**: Needs inbound SSH access. Harder to scale to 10k nodes.

### Pull Mode (Puppet / Chef / GitOps)
- **Flow**: Agent on Server -> Polls Git/Master -> Applies Change.
- **Pros**: Scalable. No inbound ports open (Security). Automatic Drift Correction.
- **Cons**: Requires Agent management. Complex setup.

---

## 🧩 4. The Module Pattern

Don't Repeat Yourself (DRY).

### The "Root Module"
Your `main.tf` should mostly call modules, not define resources directly.

```hcl
# main.tf (Prod)
module "network" {
  source = "./modules/vpc"
  cidr   = "10.0.0.0/16"
}

module "app" {
  source      = "git::github.com/org/terraform-app-module"
  instance_type = "m5.large"
  vpc_id      = module.network.vpc_id
}
```

This allows you to verify the *Infrastructure Logic* once (in the module) and reuse it everywhere.

---

[⬅️ Back to Reference Hub](./readme.md)
