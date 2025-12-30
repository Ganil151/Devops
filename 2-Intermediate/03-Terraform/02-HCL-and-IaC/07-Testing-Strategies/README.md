# Testing Strategies

Testing infrastructure prevents outages and ensures your HCL code behaves as expected.

## Types of Infrastructure Testing

### 1. Static Analysis (Linter/Linter)
- **terraform fmt**: Formatting.
- **terraform validate**: Syntax.
- **TFLint**: Finds provider-specific errors (e.g., invalid AWS instance types).

### 2. Security Scanning
- **tfsec / Checkov**: Scans for security holes (e.g., public S3 buckets, open SSH).

### 3. Unit Testing
- **Terraform Test (Built-in)**: Introduced in 1.6+, allows writing assertions in HCL.
- **Terratest**: Go-based framework for provisioning and validating real resources.

### 4. Integration Testing
Testing multiple modules together to ensure they interoperate.

## Example: Terraform Test (HCL)
```hcl
# tests/website.tftest.hcl
run "verify_status_code" {
  command = apply
  
  assert {
    condition     = output.website_status == 200
    error_message = "Website did not return a 200 OK"
  }
}
```

---

## 🏗️ Real-Life Scenario: The Unexpected Change
**Problem**: A developer refactored a module. It looked fine, but it unknowingly caused a "replace" rather than an "update" on a production database.
**Solution**: Use **Policy as Code** (Sentinel/OPA) to block any plan that attempts to delete a database in Production.

---

## ❓ Interview Questions
1.  **What is Terratest?**
    *   *Answer*: A Go library that makes it easier to write automated tests for your infrastructure. It provisions real resources, validates them (e.g., HTTP request), and destroys them.
2.  **Why is static analysis important for IaC?**
    *   *Answer*: It's fast and cheap. It catches errors before you even try to talk to the cloud API.

---

## 🧠 Quiz Snippet (5/20+)
1.  **Which command finds syntax errors without cloud access?** (`validate`)
2.  **What tool checks for public S3 buckets?** (`tfsec` or `checkov`)
3.  **True/False: Terraform 1.6+ has built-in testing.** (True)
4.  **Which language is Terratest written in?** (Go)
5.  **What is the purpose of a 'Mock' in testing?** (To simulate cloud responses without creating real resources)
