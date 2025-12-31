# Testing Strategies

"Hope is not a strategy." In Infrastructure as Code, testing is the only way to ensure your 5,000-line change doesn't take down Production.

## 1. The IaC Testing Pyramid

Just like software, infrastructure testing has layers.

```mermaid
graph TD
    A[E2E / Integration Tests (Terratest)] -->|High Cost, High Confidence| B
    B[Unit Tests (terraform test)] -->|Medium Cost, Functional Logic| C
    C[Static Analysis (TFLint/Checkov)] -->|Low Cost, Fast Feedback| D
    D[Formatting (Fmt/Validate)] -->|Free, Instant| E[Base]
```

---

## 2. Static Analysis (Linting)

Catch syntax errors and style violations instantly.

*   **`terraform fmt -check`**: Ensures code style consistency.
*   **`terraform validate`**: Checks for syntax errors and internal consistency (e.g., missing variables).
*   **TFLint**: A linter that enforces best practices (e.g., "Instance type `t2.micro` is invalid in region `us-east-1`").
*   **Checkov/tfsec**: Security scanners (e.g., "S3 bucket missing encryption").

**Usage**: Run these in your CI pipeline on every Pull Request.

---

## 3. Unit Testing (`terraform test`)

Introduced in Terraform 1.6, this allows you to write tests in HCL.

**Example `tests/website.tftest.hcl`:**
```hcl
run "verify_website_response" {
  command = apply

  assert {
    condition     = output.status_code == 200
    error_message = "Website returned non-200 status code"
  }
}
```

*   **Pros**: Native HCL, fast (if using `command = plan`), no extra language to learn.
*   **Cons**: Limited logic compared to Go/Python.

---

## 4. Integration Testing (Terratest)

Written in Go. It spins up real infrastructure, validates it, and destroys it.

**Example Flow:**
1.  `terraform init` & `apply`.
2.  Use Go HTTP library to `GET` the Load Balancer URL.
3.  Assert response is "Welcome to App".
4.  `terraform destroy` (defer execution).

**Pros**: Ultimate confidence. Tests real behavior.
**Cons**: Slow (deployment takes minutes), costs money (real AWS resources).

---

## 5. Policy as Code (Sentinel / OPA)

Tests that run *against the Plan* to enforce compliance.

*   **Sentinel**: HashiCorp's policy engine (Enterprise).
*   **OPA (Open Policy Agent)**: Open-source standard using Rego.

**Example OPA Rule**:
> "Deny any Security Group with rule allows `0.0.0.0/0` on port 22."

---

## 6. Real-Life Scenarios

### Scenario 1: "The Syntax Error Release"
**Problem**: A developer deleted a closing brace `}` by mistake and pushed to main.
**Outcome**: The CI pipeline tried to deploy and failed immediately. The "Build is Broken" light went red.
**Fix**: Added a `pre-commit` hook that runs `terraform validate` locally before allowing a commit.

### Scenario 2: "The Logic Bug"
**Problem**: A module calculation for subnet CIDRs was off by one bit (`/24` became `/23`), causing network overlap errors during apply.
**Outcome**: Terraform Apply failed halfway through.
**Fix**: Wrote a `terraform test` unit test that mocks the input and asserts the calculated output CIDRs are correct *without* creating real resources.

### Scenario 3: "The Broken API"
**Problem**: The Terraform code was valid, the resources were created (Instance + SG), but the application failed to connect to the DB because of a missing route table entry.
**Discovery**: Detected only after users complained.
**Fix**: Implemented **Terratest**. The test spins up the stack, attempts a real DB connection from the instance, and fails the build if connectivity is missing.

---

## 7. ❓ Interview Questions

1.  **What is the difference between `terraform validate` and `terraform plan`?**
    *   **Answer**: `validate` checks syntax and internal references locally (offline). `plan` checks state and cloud provider status (online) to determine changes.

2.  **Can `terraform test` destroy resources automatically?**
    *   **Answer**: Yes, at the end of the test suite, it tears down the temporary infrastructure it created.

3.  **What are the trade-offs of using Terratest vs. `terraform test`?**
    *   **Answer**: Terratest requires Go knowledge but offers powerful libraries (SSH, HTTP, K8s). `terraform test` is HCL-native and simpler but less flexible for complex validation (e.g., verifying a file exists on a server).

4.  **How do you prevent expensive infrastructure from being created during tests?**
    *   **Answer**: Use `command = plan` in `terraform test` for logic checks. For integration tests, use short-lived environments and aggressive cleanup (defer destroy).

5.  **What is a "Golden File" test?**
    *   **Answer**: A test that compares the generated `terraform plan` output (JSON) against a known-good saved file to ensure no unexpected changes occur.

6.  **Why is "Linting" important in Terraform?**
    *   **Answer**: It enforces consistency (naming, formatting) across a team, making code readable and preventing simple errors.

7.  **What is "Policy as Code"?**
    *   **Answer**: Defining governance rules (e.g., security compliance, cost limits) as code that can automatically accept/reject a Terraform Plan.

8.  **Does `terraform fmt` change logic?**
    *   **Answer**: No, it only changes whitespace and indentation.

9.  **How can you test a private module?**
    *   **Answer**: Configure the test to authenticate to the private registry or Git repo, just like a regular usage.

10. **Is it possible to unit test `provisioners`?**
    *   **Answer**: Not easily. Provisioners run heavily dependent on the runtime environment. It's better to test the result (e.g., HTTP 200) after the provisioner finishes (Integration Test).

---

## 8. 🧠 Knowledge Check (Quiz)

### Tooling
1.  **`terraform validate` checks:**
    *   [x] Syntax and validity.
    *   [ ] Cloud resources.

2.  **`tflint` detects:**
    *   [x] Provider-specific issues (e.g., invalid instance types).
    *   [ ] Logic errors.

3.  **`terraform test` is written in:**
    *   [ ] Go.
    *   [x] HCL (Terraform language).

4.  **Terratest is written in:**
    *   [x] Go.
    *   [ ] Python.

5.  **Checkov is primarily for:**
    *   [x] Security scanning.
    *   [ ] Performance testing.

### Concepts
6.  **The fastest tests are:**
    *   [x] Static Analysis.
    *   [ ] Integration Tests.

7.  **Integration tests usually involve:**
    *   [x] Creating and destroying real resources.
    *   [ ] Parsing text files.

8.  **Policy as Code runs:**
    *   [x] After Plan, Before Apply.
    *   [ ] After Apply.

9.  **"Shift Left" means:**
    *   [x] Testing earlier in the development lifecycle (Dev/PR).
    *   [ ] Moving text to the left.

10. **A "Dry Run" is similar to:**
    *   [x] `terraform plan`
    *   [ ] `terraform apply`

### Scenarios
11. **To catch a credentials leak before commit:**
    *   [x] Use `pre-commit` hooks (detect-secrets).
    *   [ ] Use `terraform plan`.

12. **To ensure an HTTP server is actually responding:**
    *   [ ] `terraform apply`
    *   [x] Use Terratest (HTTP GET).

13. **To enforce that all tags are lowercase:**
    *   [x] Use OPA or Sentinel policies.
    *   [ ] Use `terraform fmt`.

14. **If a test leaves a "zombie" resource (not destroyed):**
    *   [x] It costs money/clutter. Use "nuke" tools to clean up sandboxes.
    *   [ ] It's fine.

15. **Can you ignore a specific checkov rule?**
    *   [x] Yes, with a skip comment.
    *   [ ] No.

### General
16. **Is standard output testing (regex on stdout) reliable?**
    *   [ ] Yes.
    *   [x] No, CLI output format can change between versions. Use JSON output (`-json`).

17. **Does `terraform test` require a separate test runner binary?**
    *   [x] No, it's built into the `terraform` CLI.
    *   [ ] Yes.

18. **Can you mock providers in `terraform test`?**
    *   [x] Yes (in recent versions), avoiding real API calls.
    *   [ ] No.

19. **Unit tests are best for:**
    *   [x] Testing logic (e.g., subnet calculation).
    *   [ ] Testing database connectivity.

20. **Why verify `terraform.lock.hcl` in CI?**
    *   [x] To ensure provider versions match what was tested locally.
    *   [ ] It's not needed.
