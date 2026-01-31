# 🛠️ Reference: Provisioning & IaC Keywords

Provisioning is the act of defining the "Shell" of your infrastructure. These keywords are fundamental to tools like Terraform, Pulumi, and CloudFormation.

---

## 🏗️ The Terraform HCL Toolkit

### `Provider`
*   **Definition**: The plugin that allows Terraform to communicate with an API (AWS, GitHub, Kubernetes).
*   **DevOps Why**: It translates the declarative HCL code into specific API calls.

### `Resource`
*   **Definition**: The basic building block of infrastructure (e.g., an EC2 instance, an S3 bucket).
*   **Lifecycle**: Terraform tracks the creation, update, and deletion of every resource via its ID.

### `Data Source`
*   **Definition**: Read-only information fetched from the provider (e.g., "Find the latest Ubuntu AMI ID").
*   **DevOps Why**: Allows your code to be dynamic. Instead of hardcoding an ID, you "Search" for it at runtime.

### `State` (`tfstate`)
*   **Definition**: The mapping between your code and the real resources in the cloud.
*   **Critical Fact**: If you lose your state file, Terraform "forgets" what it created and will try to recreate everything from scratch.

---

## 🗄️ Backend & Management

### `Backend`
*   **Definition**: Where the state file is stored (Local, S3, GCS, Terraform Cloud).
*   **Standard**: Always use a remote backend with **State Locking** for team collaboration.

### `Workspaces`
*   **Definition**: Separate instances of state within a single configuration.
*   **DevOps Why**: Allows you to manage Dev, Stage, and Prod using the exact same code, but with different state records.

### `Plan` vs `Apply`
*   **Plan**: A "Dry Run" that shows what will happen without making changes.
*   **Apply**: The execution phase that modifies the environment.

---

## 🎙️ Staff Interview Context

*   **"What happens if two people run 'terraform apply' at the same time?"**
    *   *Answer*: Without **State Locking**, you get race conditions and possible state corruption. With locking (e.g., DynamoDB), the second user is blocked until the first operation completes.
*   **"How do you handle secrets (API Keys) in Terraform code?"**
    *   *Answer*: **Never** hardcode them. Use environment variables (`TF_VAR_xxx`), secret managers (AWS Secrets Manager), or sensitive variable types to ensure they aren't printed in logs.
*   **"Explain the 'Destroy' lifecycle of a resource."**
    *   *Answer*: Terraform compares the state file to the code. If a resource exists in the state/cloud but is missing from the code, Terraform identifies it for destruction during the next `apply`.
