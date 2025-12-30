# Testing Modules

Testing ensures that your module does exactly what it says on the tin.

## Levels of Testing

### 1. Static Analysis (The "Cheap" Tests)
- **`terraform validate`**: Checks for syntax errors and internal consistency.
- **`tflint`**: Finds cloud-specific errors (e.g., using an instance type that doesn't exist in a specific region).
- **`checkov` / `tfsec`**: Scans for security holes (e.g., S3 bucket without encryption).

### 2. Native Testing (`terraform test`)
Introduced in Terraform 1.6, this allows you to write tests in HCL.
```hcl
# tests/vpc.tftest.hcl
run "verify_vpc_cidr" {
  command = plan
  
  assert {
    condition     = output.vpc_cidr == "10.0.0.0/16"
    error_message = "VPC CIDR did not match expected value"
  }
}
```

### 3. Integration Testing (The "Expensive" Tests)
- **Terratest**: A Go library that actually `apply`s your module, verifies real cloud resources, and then `destroy`s them.
- **Kitchen-Terraform**: Using Ruby/Chef tools for infra testing.

---

## 🏗️ Real-Life Scenario: The Broken Refactor
**Problem**: An engineer optimizes a module's `locals` block. It looks correct, but it accidentally changes the logic for calculating subnet IDs.
**Safety net**: The team has a CI/CD pipeline that runs `terratest` on every Pull Request. The test attempts to spin up a VPC, fails to find the subnets, and blocks the merge.
**Outcome**: The bug is caught in development, saving the Production environment from a total network failure.

---

## ❓ Interview Questions
1.  **What is the difference between `terraform validate` and `terraform plan`?**
    *   *Answer*: `validate` only checks syntax and local logic without talking to the cloud. `plan` connects to the cloud provider to compare your code against real resources.
2.  **What is the primary risk of using Terratest?**
    *   *Answer*: Cost and Time. It creates real resources in the cloud, so you must ensure they are destroyed even if the test fails.

---

## 🧠 Quiz Snippet (5/20+)
1.  **Which command was added in TF 1.6 for HCL-based testing?** (`terraform test`)
2.  **True/False: You should run tests in a dedicated sandbox account.** (True)
3.  **What does a "Check Block" do?** (Continuous validation of resources *after* deployment)
4.  **Which language is used for Terratest?** (Go / Golang)
5.  **What is "Linting" in Terraform?** (Static analysis for style and common mistakes)
