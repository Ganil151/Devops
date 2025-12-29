# Terraform Interview Questions & Quiz

Become job-ready by mastering these common interview questions and testing your knowledge with a comprehensive quiz.

---

## 🎤 Top 20 Terraform Interview Questions

### 🔰 Basic Questions
1. **What is Terraform and how does it differ from other IaC tools like Ansible?**
   - *Answer:* Terraform is a declarative Infrastructure as Code (IaC) tool primarily for provisioning infrastructure, whereas Ansible is more focused on configuration management. Terraform manages the lifecycle of resources, while Ansible manages the software inside them.
2. **What are the main steps in the Terraform workflow?**
   - *Answer:* `init` (initialize provider), `plan` (preview changes), `apply` (deploy resources), and `destroy` (remove resources).
3. **What is a "Provider" in Terraform?**
   - *Answer:* A Provider is a plugin that Terraform uses to interact with cloud providers (AWS, Azure, GCP), SaaS providers, or other APIs.
4. **What is the `terraform.tfstate` file?**
   - *Answer:* It is the "source of truth" that records the mapping between your code and the actual resources deployed in the cloud.
5. **How do you define a variable in Terraform?**
   - *Answer:* Using the `variable "name" { ... }` block. You can specify a type, default value, and description.

### ⚙️ Intermediate Questions
6. **Explain the concept of "State Locking". Why is it important?**
   - *Answer:* State locking prevents multiple users from running Terraform at the same time on the same state file, which could corrupt the state. Backends like S3 (with DynamoDB) or Terraform Cloud handle this automatically.
7. **What are Terraform Modules and why would you use them?**
   - *Answer:* Modules are containers for multiple resources that are used together. They allow for code reuse, standardization, and better organization.
8. **What is the difference between `count` and `for_each`?**
   - *Answer:* `count` is better for creating multiple identical resources, while `for_each` is better for creating resources based on a map or set of strings, allowing for more specific configurations.
9. **How do you manage secrets in Terraform?**
   - *Answer:* Use environment variables (`TF_VAR_name`), secret management services (AWS Secrets Manager, HashiCorp Vault), or mark variables as `sensitive = true`. Never commit secrets to version control.
10. **What is a "Data Source" in Terraform?**
    - *Answer:* Data sources allow Terraform to use information defined outside of Terraform, or defined by another separate Terraform configuration (e.g., fetching an existing VPC ID).

### 🚀 Advanced-ish Questions
11. **Explain the use of `lifecycle` blocks.**
    - *Answer:* Used to control how Terraform treats specific resources, such as `create_before_destroy`, `prevent_destroy`, or `ignore_changes`.
12. **What is "Drift" and how does Terraform handle it?**
    - *Answer:* Drift occurs when the real-world infrastructure changes independently of Terraform (e.g., manual console change). Running `terraform plan` or `terraform refresh` detects this drift.
13. **What is a Remote Backend?**
    - *Answer:* Storing the state file in a remote location (S3, GCS, Terraform Cloud) rather than locally, enabling team collaboration and security.
14. **How do you perform a "Targeted Apply"?**
    - *Answer:* Use the `-target` flag: `terraform apply -target=aws_instance.web`. Note: This is usually for troubleshooting and not recommended for routine use.
15. **What is the `terraform init` command actually doing?**
    - *Answer:* It initializes the working directory, downloads provider plugins, and sets up the backend for state management.
16. **How do you handle multi-environment setups (Dev/Staging/Prod)?**
    - *Answer:* Using Terraform Workspaces, or more commonly, separate directory structures or separate state files for each environment.
17. **What is the purpose of `outputs.tf`?**
    - *Answer:* To expose information about your infrastructure (like an IP address or DNS name) so it can be used by developers or other Terraform modules.
18. **What happens if a `terraform apply` fails midway?**
    - *Answer:* Terraform will have updated the state for the resources it successfully created or modified. You should fix the error and run `apply` again; Terraform will pick up where it left off.
19. **Can you explain "Implicit" vs "Explicit" dependencies?**
    - *Answer:* Implicit dependencies are automatically handled by Terraform when one resource references another. Explicit dependencies are manually defined using the `depends_on` argument.
20. **What is the Terraform registry?**
    - *Answer:* A centralized repository for providers and community-contributed modules.

---

## 🧠 Terraform Knowledge Quiz (20+ Questions)

**1. Which command shows what Terraform will do before making any changes?**
- A) `terraform apply`
- B) `terraform check`
- C) `terraform preview`
- D) `terraform plan`
*Answer: D*

**2. What is the default file extension for Terraform configuration files?**
- A) `.tf`
- B) `.yaml`
- C) `.hcl`
- D) `.json`
*Answer: A*

**3. Which file contains the "Source of Truth" for your infrastructure?**
- A) `main.tf`
- B) `terraform.tfvars`
- C) `terraform.tfstate`
- D) `backend.tf`
*Answer: C*

**4. How do you provision multiple similar resources without repeating code?**
- A) Use the `duplicate` block
- B) Use `count` or `for_each`
- C) Copy-paste the code
- D) Use `multi_resource`
*Answer: B*

**5. Which command initializes the working directory?**
- A) `terraform start`
- B) `terraform setup`
- C) `terraform init`
- D) `terraform build`
*Answer: C*

**6. What does `terraform fmt` do?**
- A) Fast-forward migrations
- B) Format your configuration files to standard HCL style
- C) Fix logical errors in your code
- D) Find meta-data
*Answer: B*

**7. Which block is used to fetch information from an existing resource not managed by the current Terraform code?**
- A) `resource`
- B) `variable`
- C) `output`
- D) `data`
*Answer: D*

**8. Where should you NOT store your secrets?**
- A) Environment Variables
- B) `terraform.tfvars` committed to Git
- C) AWS Secrets Manager
- D) Variables with `sensitive = true`
*Answer: B*

**9. What is the purpose of a "Backend"?**
- A) To host the application's database
- B) To define where the state file is stored
- C) To write the logic for the API
- D) To configure the web server
*Answer: B*

**10. Which command removes all infrastructure managed by the current configuration?**
- A) `terraform delete`
- B) `terraform remove`
- C) `terraform cleanup`
- D) `terraform destroy`
*Answer: D*

**11. What is HCL short for?**
- A) High-speed Command Language
- B) HashiCorp Configuration Language
- C) Hybrid Cloud Logic
- D) Hyper-Converged Layout
*Answer: B*

**12. If you want to prevent a resource from being deleted, which lifecycle argument do you use?**
- A) `prevent_destroy = true`
- B) `ignore_changes = all`
- C) `no_deletion = true`
- D) `immutable = true`
*Answer: A*

**13. Which command is used to download provider plugins?**
- A) `terraform get`
- B) `terraform fetch`
- C) `terraform init`
- D) `terraform install`
*Answer: C*

**14. What is a "Module"?**
- A) A single line of code
- B) A set of configuration files in a specific directory
- C) A specific type of cloud resource
- D) A Terraform provider
*Answer: B*

**15. Which character is used for comments in HCL?**
- A) `#` or `//`
- B) `--`
- C) `/* */`
- D) Both A and C
*Answer: D*

**16. How do you pass a variable value via the command line?**
- A) `-var="key=value"`
- B) `--variable "key=value"`
- C) `-v="key=value"`
- D) `set key=value`
*Answer: A*

**17. What is "State Drift"?**
- A) When the code is pushed to a new branch
- B) When the real infrastructure differs from the state file
- C) When the cloud provider updates their API
- D) When the state file grows too large
*Answer: B*

**18. Which argument ensures that a new resource is created before the old one is destroyed?**
- A) `recreate_first = true`
- B) `safe_update = true`
- C) `create_before_destroy = true`
- D) `update_sequence = "new-first"`
*Answer: C*

**19. What is the scope of a variable defined in a module?**
- A) Global (accessible everywhere)
- B) Local to that specific module
- C) Only accessible in `main.tf`
- D) Only accessible in the root module
*Answer: B*

**20. Which command syncs the local state with the actual real-world infrastructure?**
- A) `terraform sync`
- B) `terraform refresh`
- C) `terraform update`
- D) `terraform check`
*Answer: B*

**21. What happens if you run `terraform apply` and it crashes?**
- A) All resources are deleted automatically
- B) The state file becomes completely useless
- C) Part of your infrastructure may be deployed; you should fix issues and re-run
- D) You must manually delete everything and start over
*Answer: C*

**22. Which flag is used to automatically approve the plan during apply?**
- A) `-y`
- B) `--force`
- C) `-auto-approve`
- D) `-silent`
*Answer: C*

---

## 🔝 Summary
Use these questions to self-assess or prepare for interviews. Remember, rote memorization is less important than understanding **why** Terraform works the way it does!
