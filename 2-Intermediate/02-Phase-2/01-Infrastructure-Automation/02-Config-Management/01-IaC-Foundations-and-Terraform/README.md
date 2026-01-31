# 🏗️ IaC Foundations & Terraform Architecture

Terraform is the world's most widely used Infrastructure as Code (IaC) tool. It uses a declarative configuration language (HCL) to manage almost any service that has an API.

## 📂 Learning Path

1.  **[Fundamentals](./Fundamentals)**: Providers, Resources, Variables, and the Data flow.
2.  **[State-Management](./State-Management)**: The source of truth. Remote backends, Locking, and State manipulation (`import`, `rm`, `mv`).
3.  **[Modules-and-Composition](./Modules-and-Composition)**: Building reusable, versioned infrastructure components.
4.  **[Terraform-Cloud-and-GitOps](./Terraform-Cloud-and-GitOps)**: Moving from CLI-driven workflows to automated CI/CD pipelines.

---

## 🏗️ Core Architecture: How Terraform Works

![Terraform Workflow](Diagram: A technical overview showing: 1. Write HCL -> 2. Init Providers -> 3. Plan (Dry Run) -> 4. Apply (Actual Change) -> 5. State File (Persistence).)

### The Declarative Mindset
In Terraform, you describe the **Desired State**, not the steps to get there.
- **Wrong (Imperative)**: "Create a VM, then install Docker, then open port 80."
- **Right (Declarative)**: "The infrastructure must always have a VM with Docker and port 80 open."

---

## 🔐 Deep-Dive: Remote State Persistence

State management is the difference between "playing with Terraform" and "using Terraform in Production."

| Strategy | Risk | Production Ready? |
| :--- | :--- | :--- |
| **Local State** | **HIGH**. Losing your laptop means losing your infrastructure control. | ❌ No |
| **S3 Backend** | **MEDIUM**. Persistent, but lacks locking. Two people can write at once. | ⚠️ Partially |
| **S3 + DynamoDB**| **LOW**. Highly persistent with mandatory locking via DynamoDB. | ✅ Yes |

---

## 🛠️ Production Scenarios

### Scenario: The "Orphaned Resource"
**Problem**: An engineer manually deleted a Security Group in the AWS Console. Terraform still thinks it exists in the state file.
**Solution**: Running `terraform plan` will detect the drift. Terraform will see that the actual state is "Missing" and will attempt to re-create the resource to match the configuration. This is known as **Self-Healing**.

### Scenario: Multi-Region High Availability
**Goal**: Deploy a load balancer in `us-east-1` and `us-west-2` with identical configurations.
**Tooling**: Use **Terraform Modules**. Define the LB logic once, and instantiate it twice using different `providers` (aliased).

---

## 🚦 Best Practices (Production Check-list)

- [ ] **Always** use a version-controlled Remote State.
- [ ] **Never** hardcode credentials. Use environment variables or IAM Roles.
- [ ] **Use Modules** for everything. The root module should just be a composition of child modules.
- [ ] **Lock Versions**: Lock your provider and terraform version in `required_providers`.
