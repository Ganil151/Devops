# 🏗️ Technical Deep Dive: Terraform Interview Mastery

Master the infrastructure-as-code questions that distinguish a script-kiddie from a Cloud Architect.

---

## 🟢 Junior Tier: The Fundamentals

### 1. What is the difference between `terraform plan` and `terraform apply`?
**Problem:** The candidate needs to explain the execution lifecycle.
**Solution:** `plan` creates an execution plan, letting you preview changes without affecting real resources. `apply` executes the actions proposed in the plan.
**Insight (The Interviewer's Secret):** They are looking for your understanding of the **Reconciliation Loop**. A good candidate mentions that `plan` reads the current `state` and compares it to the `code`.
**Lab Correlation:** [05-labs/01-terraform-basics](../../05-labs/)

### 2. What is the "State File" and why is it dangerous to lose?
**Problem:** Understanding Terraform's source of truth.
**Solution:** The `.tfstate` file maps your code to real-world resources. If lost, Terraform loses track of what it managed, leading to duplicate resources or "Resource Already Exists" errors.
**Insight (The Interviewer's Secret):** They want to hear about **State Recovery**. Mentioning `terraform import` as a way to map existing resources back to code shows you've actually fixed this problem before.

---

## 🟡 Intermediate Tier: The Professional

### 1. Explain the "Provider" concept in Terraform.
**Problem:** How does Terraform talk to disparate APIs?
**Solution:** Providers are plugins that translate Terraform's HCL into API calls (AWS, Azure, GCP, Kubernetes, etc.).
**Insight (The Interviewer's Secret):** They are checking for **Version Pinning** knowledge. Mentioning why you should pin provider versions to avoid breaking changes in CI/CD is a "pro" move.

### 2. How do you handle secrets (like API keys) in Terraform?
**Problem:** Security best practices.
**Solution:** Never hardcode secrets. Use environment variables (`TF_VAR_`), a `.tfvars` file (added to `.gitignore`), or integrate with a secret manager like AWS Secrets Manager or HashiCorp Vault.
**Insight (The Interviewer's Secret):** They are looking for **State Security**. Even if you use variables, the secret might still be in the *plain text* state file. A Senior candidate mentions encrypting the S3 bucket where the state is stored.

---

## 🔴 Senior Tier: The Staff Engineer

### 1. You have a "State Lock" error in your CI/CD pipeline. How do you resolve it?
**Problem:** Handling race conditions and hung processes.
**Solution:** First, ensure no one else is actually running an apply. Then, identify the Lock ID (usually in the error message) and use `terraform force-unlock <ID>`.
**Insight (The Interviewer's Secret):** They are testing your **SRE mindset**. They want to know *why* it happened (e.g., a timed-out Jenkins agent) and how to prevent it (e.g., increasing timeout or improving network stability).
**Lab Correlation:** [05-labs/07-terraform-state-locking](../../05-labs/)

### 2. What are the pros/cons of a "Monolithic" vs. "Modular" Terraform architecture?
**Problem:** Architectural design.
**Solution:**
- **Monolithic**: Easier to see the whole environment but leads to slow plans and high "blast radius" for errors.
- **Modular**: Reusable, smaller blast radius, but requires careful versioning and output/input management.
**Insight (The Interviewer's Secret):** They are looking for **Scalability awareness**. A Senior engineer should advocate for "decoupled stacks" (e.g., Networking stack, Database stack, App stack) connected via Data Sources or Remote State.

---

## 🗝️ Master Key: "Interviewer's Secret" Summary
| Concept | What they are REALLY looking for |
| :--- | :--- |
| **Modules** | Do you understand DRY (Don't Repeat Yourself) principles? |
| **Workspaces** | Do you know how to manage multiple environments (Dev/Prod)? |
| **Provisioners** | This is a "trap" question. Good candidates say: "Avoid them; use UserData or Ansible instead." |
| **Terraform Cloud** | Do you understand the value of a managed execution environment? |
