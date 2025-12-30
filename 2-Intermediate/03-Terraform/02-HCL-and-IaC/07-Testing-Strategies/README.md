# Testing Strategies

Testing infrastructure prevents outages and ensures your HCL code behaves as expected.

## The Testing Pyramid

Just like software development, IaC testing follows a pyramid structure. Testing should be heavy at the bottom (fast/cheap) and lighter at the top (slow/expensive).

```mermaid
graph TD
    E2E[End-to-End (Terratest)] --> Integ[Integration Tests]
    Integ --> Unit[Unit Tests (terraform test)]
    Unit --> Static[Static Analysis / Linting]
    
    style Static fill:#c8e6c9,stroke:#43a047
    style Unit fill:#fff9c4,stroke:#fbc02d
    style Integ fill:#ffcc80,stroke:#fb8c00
    style E2E fill:#ffcdd2,stroke:#e53935
```

---

## 1. Static Analysis (The Base)
Run these **locally** and in **CI** on every commit. They catch 90% of errors instantly.

*   **`terraform fmt -check`**: Ensures code follows the canonical HCL style.
*   **`terraform validate`**: Checks for syntax errors and valid argument references.
*   **`tflint`**: A linter that enforces best practices and finds provider-specific errors (e.g., checking if an instance type `t9.large` actually exists).
*   **`checkov` / `tfsec`**: Security scanners that find misconfigurations (e.g., open S3 buckets, unencrypted databases).

---

## 2. Unit Testing (`terraform test`)
Introduced in Terraform 1.6, this native framework allows you to verify your module logic without writing Go/Python wrappers. You can validate variable validation logic and resource output values.

**Example**: Testing an S3 Bucket Name
```hcl
# tests/website.tftest.hcl

# Helper: Create a random suffix to ensure unique names
run "setup" {
  command = plan
}

run "verify_bucket_naming" {
  command = plan

  variables {
    bucket_name = "my-test-bucket"
  }

  assert {
    condition     = aws_s3_bucket.main.bucket == "my-test-bucket"
    error_message = "Bucket name did not match input variable"
  }
}
```

---

## 3. Integration/End-to-End Testing (Terratest)
For creating real resources, deploying them, running checks, and destroying them. Written in Go, **Terratest** is the industry standard for robust module verification.

**Example**: Go Test
```go
package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformAwsS3(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/s3-basic",
	})

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Init and Apply
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	bucketID := terraform.Output(t, terraformOptions, "bucket_id")

	// Verify that the bucket status is what we expect (Pseudo-code verification)
	assert.NotEmpty(t, bucketID)
}
```

---

## 4. Policy as Code (Sentinel / OPA)
This is the final gatekeeper. It prevents "valid" Terraform code from being deployed if it violates company rules (e.g., "No deploying to `eu-west-1`").

*   **Open Policy Agent (OPA)**: Uses Rego language.
*   **Sentinel**: HashiCorp's policy language (Enterprise/Cloud).

**Example OPA Rule**: Deny creating resources in wrong regions.
```rego
deny[msg] {
  resource := input.resource_changes[_]
  resource.change.after.region != "us-east-1"
  msg := "Deployments allowed only in us-east-1"
}
```

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
