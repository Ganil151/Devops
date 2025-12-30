# Testing Strategies

Testing is the only way to ensure your "Infrastructure as Code" doesn't become "Disaster as Code."

## The Testing Pyramid

### 1. Static Analysis (The base)
Checks syntax and style without running code.
- `terraform fmt -check`: Ensures style standards.
- `terraform validate`: Checks internal consistency.
- `tflint`: Finds cloud-specific errors.

### 2. Plan Validation
Checking the "Plan" output before applying.
- Use `terraform-config-inspect`.
- Use **Policy as Code** (OPA/Sentinel) to block plans that violate corporate rules (e.g., "No unencrypted buckets").

### 3. Integration Testing (The tip)
Deploying to a real sandbox environment.
- **Terratest**: Uses Go to spin up resources, verify they work, and destroy them.
- **`terraform test`**: (New in 1.6) Native testing framework for unit and integration tests.

---

## 🏗️ Real-Life Scenario: The $0.01 Test that Saved $10k
**Problem**: An engineer updates a module to use a `t3.large` instance by default. 
**Detection**: The CI pipeline runs `tfsec`. It flags that the module no longer complies with the "Low Cost" policy.
**Outcome**: The Pull Request is automatically blocked. The engineer fixes the default to `t3.micro`, saving the company thousands in accidental overspend.

---

## ❓ Interview Questions
1.  **What is "Policy as Code" in the context of Terraform?**
    *   *Answer*: It's the practice of using code (like Sentinel or OPA) to enforce rules on your infrastructure plans (e.g., "Allow only us-east-1 region").
2.  **Why should you run `terraform destroy` at the end of every Terratest?**
    *   *Answer*: To avoid leaving "Zombie Resources"—infrastructure that is running and costing money but isn't being used by anyone.

---

## 🧠 Quiz Snippet (5/20+)
1.  **Which command checks HCL syntax?** (`terraform validate`)
2.  **True/False: `terraform fmt` fixes logic errors.** (False - only formatting/style)
3.  **What is the Go-based framework for TF testing?** (Terratest)
4.  **Where should integration tests be run?** (In a non-production, isolated sandbox account)
5.  **Which Terraform version introduced the native `test` command?** (1.6)
