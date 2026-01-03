# Terraform Interview Questions & Quiz

Become job-ready by mastering these common interview questions and testing your knowledge with a comprehensive quiz.

---

## 🎤 Top 20 Terraform Interview Questions

<b>1. </b>
<details>
<summary>Show Answer</summary>
Answer: * Terraform is a declarative Infrastructure as Code (IaC) tool primarily for provisioning infrastructure, whereas Ansible is more focused on configuration management. Terraform manages the lifecycle of resources, while Ansible manages the software inside them.
</details>


<b>2. </b>
<details>
<summary>Show Answer</summary>
Answer: * `init` (initialize provider), `plan` (preview changes), `apply` (deploy resources), and `destroy` (remove resources).
</details>


<b>3. </b>
<details>
<summary>Show Answer</summary>
Answer: * A Provider is a plugin that Terraform uses to interact with cloud providers (AWS, Azure, GCP), SaaS providers, or other APIs.
</details>


<b>4. </b>
<details>
<summary>Show Answer</summary>
Answer: * It is the "source of truth" that records the mapping between your code and the actual resources deployed in the cloud.
</details>


<b>5. </b>
<details>
<summary>Show Answer</summary>
Answer: * Using the `variable "name" { ... }` block. You can specify a type, default value, and description.
</details>


<b>6. </b>
<details>
<summary>Show Answer</summary>
Answer: * State locking prevents multiple users from running Terraform at the same time on the same state file, which could corrupt the state. Backends like S3 (with DynamoDB) or Terraform Cloud handle this automatically.
</details>


<b>7. </b>
<details>
<summary>Show Answer</summary>
Answer: * Modules are containers for multiple resources that are used together. They allow for code reuse, standardization, and better organization.
</details>


<b>8. </b>
<details>
<summary>Show Answer</summary>
Answer: * `count` is better for creating multiple identical resources, while `for_each` is better for creating resources based on a map or set of strings, allowing for more specific configurations.
</details>


<b>9. </b>
<details>
<summary>Show Answer</summary>
Answer: * Use environment variables (`TF_VAR_name`), secret management services (AWS Secrets Manager, HashiCorp Vault), or mark variables as `sensitive = true`. Never commit secrets to version control.
</details>


<b>10. </b>
<details>
<summary>Show Answer</summary>
Answer: * Data sources allow Terraform to use information defined outside of Terraform, or defined by another separate Terraform configuration (e.g., fetching an existing VPC ID).
</details>


<b>11. </b>
<details>
<summary>Show Answer</summary>
Answer: * Used to control how Terraform treats specific resources, such as `create_before_destroy`, `prevent_destroy`, or `ignore_changes`.
</details>


<b>12. </b>
<details>
<summary>Show Answer</summary>
Answer: * Drift occurs when the real-world infrastructure changes independently of Terraform (e.g., manual console change). Running `terraform plan` or `terraform refresh` detects this drift.
</details>


<b>13. </b>
<details>
<summary>Show Answer</summary>
Answer: * Storing the state file in a remote location (S3, GCS, Terraform Cloud) rather than locally, enabling team collaboration and security.
</details>


<b>14. </b>
<details>
<summary>Show Answer</summary>
Answer: * Use the `-target` flag: `terraform apply -target=aws_instance.web`. Note: This is usually for troubleshooting and not recommended for routine use.
</details>


<b>15. </b>
<details>
<summary>Show Answer</summary>
Answer: * It initializes the working directory, downloads provider plugins, and sets up the backend for state management.
</details>


<b>16. </b>
<details>
<summary>Show Answer</summary>
Answer: * Using Terraform Workspaces, or more commonly, separate directory structures or separate state files for each environment.
</details>


<b>17. </b>
<details>
<summary>Show Answer</summary>
Answer: * To expose information about your infrastructure (like an IP address or DNS name) so it can be used by developers or other Terraform modules.
</details>


<b>18. </b>
<details>
<summary>Show Answer</summary>
Answer: * Terraform will have updated the state for the resources it successfully created or modified. You should fix the error and run `apply` again; Terraform will pick up where it left off.
</details>


<b>19. </b>
<details>
<summary>Show Answer</summary>
Answer: * Implicit dependencies are automatically handled by Terraform when one resource references another. Explicit dependencies are manually defined using the `depends_on` argument.
</details>


<b>20. </b>
<details>
<summary>Show Answer</summary>
Answer: * A centralized repository for providers and community-contributed modules.
</details>


---

## 🧠 Terraform Knowledge Quiz (20+ Questions)

<b>1. Which command shows what Terraform will do before making any changes?</b>
<details>
<summary>Show Answer</summary>
Answer: D
</details>


<b>2. What is the default file extension for Terraform configuration files?</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>3. Which file contains the "Source of Truth" for your infrastructure?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>4. How do you provision multiple similar resources without repeating code?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>5. Which command initializes the working directory?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>6. What does `terraform fmt` do?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>7. Which block is used to fetch information from an existing resource not managed by the current Terraform code?</b>
<details>
<summary>Show Answer</summary>
Answer: D
</details>


<b>8. Where should you NOT store your secrets?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>9. What is the purpose of a "Backend"?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>10. Which command removes all infrastructure managed by the current configuration?</b>
<details>
<summary>Show Answer</summary>
Answer: D
</details>


<b>11. What is HCL short for?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>12. If you want to prevent a resource from being deleted, which lifecycle argument do you use?</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>13. Which command is used to download provider plugins?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>14. What is a "Module"?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>15. Which character is used for comments in HCL?</b>
<details>
<summary>Show Answer</summary>
Answer: D
</details>


<b>16. How do you pass a variable value via the command line?</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>17. What is "State Drift"?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>18. Which argument ensures that a new resource is created before the old one is destroyed?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>19. What is the scope of a variable defined in a module?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>20. Which command syncs the local state with the actual real-world infrastructure?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>21. What happens if you run `terraform apply` and it crashes?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>22. Which flag is used to automatically approve the plan during apply?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


---

## 🔝 Summary
Use these questions to self-assess or prepare for interviews. Remember, rote memorization is less important than understanding **why** Terraform works the way it does!