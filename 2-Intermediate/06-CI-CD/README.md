# Infrastructure as Code (IaC) and CI/CD

This module covers the implementation of Infrastructure as Code using Terraform, specifically focusing on modular architecture for AWS resources (EC2, Security Groups, Key Pairs). It also bridges the gap to CI/CD principles.

## Project Structure Overview

Based on the provided code, the infrastructure is organized into reusable modules:
- **Root Module**: Orchestrates the deployment.
- **`ec2_instance` Module**: Standardizes EC2 deployment with specific AMIs and instance types.
- **`security_group` Module**: Manages firewall rules dynamically.
- **`key_pair` Module**: Handles SSH key generation and AWS import.

---

## Real-Life Scenarios

### Scenario 1: Managing Configuration Drift
**Context**: A junior DevOps engineer manually changed a Security Group rule in the AWS Console to allow port 8080 for testing but forgot to revert it.
**Problem**: The actual infrastructure state no longer matches the Terraform code (Drift).
**Solution**:
1.  Run `terraform plan`. Terraform compares the live state (AWS) with the state file (`terraform.tfstate`) and the code.
2.  Terraform detects the extra rule as "drift".
3.  Run `terraform apply` to revert the manual change and enforce the configuration defined in code.
**Lesson**: Never make manual changes; always go through the IaC pipeline.

### Scenario 2: Multi-Environment Deployment
**Context**: You need to deploy the same application stack (EC2 + SG) to `dev`, `staging`, and `prod` environments, but `prod` needs larger instances (t3.large) than `dev` (t2.micro).
**Solution**:
1.  Use the existing **Modules**.
2.  Create separate `.tfvars` files (e.g., `dev.tfvars`, `prod.tfvars`) or separate workspaces.
3.  Pass different values to the `instance_type` variable:
    - Dev: `instance_type = "t2.micro"`
    - Prod: `instance_type = "t3.large"`
**Benefit**: Code reuse without duplication.

### Scenario 3: Secure Key Management in CI/CD
**Context**: The `key_pair` module generates a `.pem` file locally using `local_file`. In a CI/CD pipeline (e.g., Jenkins/GitHub Actions), this file is ephemeral and lost after the build.
**Solution**:
1.  Instead of `local_file`, store the private key content in a secure vault (e.g., AWS Secrets Manager or HashiCorp Vault) using Terraform resources.
2.  Or, generate the key beforehand and inject the public key as a variable, rather than generating it inside Terraform.
**Security Note**: Never commit `.pem` files or `.tfstate` files containing sensitive data to Git.

---

## Common Interview Questions

1.  **Q: What is the benefit of using `modules` in Terraform?**
    *   **A:** Modules allow for code reuse, better organization, and encapsulation. You can define a standard "Company EC2" configuration once and reuse it across hundreds of instances, ensuring consistency and easier updates.

2.  **Q: How does Terraform manage state, and why is it important?**
    *   **A:** Terraform uses a state file (`terraform.tfstate`) to map real-world resources to your configuration, track metadata, and improve performance. It is crucial for planning updates and detecting drift.

3.  **Q: What happens if you delete the `terraform.tfstate` file?**
    *   **A:** Terraform loses track of the infrastructure it created. Running `apply` again would attempt to create duplicate resources (which might fail due to name conflicts) or leave orphaned resources running in the cloud.

4.  **Q: Explain the difference between `ingress` and `egress` in Security Groups.**
    *   **A:** `Ingress` rules control inbound traffic (traffic coming *into* the instance). `Egress` rules control outbound traffic (traffic leaving the instance). By default, Terraform SGs deny all ingress and allow all egress.

5.  **Q: How do you handle sensitive data like private keys in Terraform?**
    *   **A:** Mark variables as `sensitive = true`. Use remote state with encryption (e.g., S3 + DynamoDB). Avoid using `local_file` for keys in production; prefer Secrets Manager.

6.  **Q: What is the purpose of `terraform init`?**
    *   **A:** It initializes the working directory, downloads the necessary provider plugins (like `hashicorp/aws`), and configures the backend for state storage.

---

## Comprehensive Knowledge Quiz

1.  Which command prepares the working directory and downloads providers?
    *   a) `terraform plan`
    *   b) `terraform apply`
    *   c) `terraform init`
    *   d) `terraform start`

2.  In the provided code, what does `var.ami` represent?
    *   a) A hardcoded value
    *   b) An output value
    *   c) An input variable
    *   d) A local value

3.  What is the default filename for the Terraform state?
    *   a) `terraform.state`
    *   b) `terraform.tfstate`
    *   c) `state.tf`
    *   d) `infrastructure.json`

4.  Which resource is used to create a private key in the provided code?
    *   a) `aws_key_pair`
    *   b) `tls_private_key`
    *   c) `local_file`
    *   d) `crypto_key`

5.  How do you reference an output from a module?
    *   a) `var.module_name.output`
    *   b) `module.module_name.output_name`
    *   c) `output.module_name`
    *   d) `terraform.output.module`

6.  What does the `count` meta-argument do?
    *   a) Counts the number of lines in the code
    *   b) Creates multiple instances of a resource based on a number or list length
    *   c) Calculates the cost of the resource
    *   d) Limits the number of resources

7.  In `aws_security_group`, what does `protocol = "-1"` mean?
    *   a) TCP only
    *   b) UDP only
    *   c) All protocols
    *   d) No protocols

8.  Which command allows you to preview changes before applying them?
    *   a) `terraform preview`
    *   b) `terraform plan`
    *   c) `terraform test`
    *   d) `terraform dry-run`

9.  What is the purpose of `terraform destroy`?
    *   a) Deletes the state file only
    *   b) Destroys all infrastructure managed by the configuration
    *   c) Deletes the Terraform binary
    *   d) Stops EC2 instances but keeps them

10. Where are local modules sourced from?
    *   a) The Terraform Registry
    *   b) A filesystem path (e.g., `./modules/ec2`)
    *   c) GitHub
    *   d) S3 Bucket

11. What file extension does Terraform use for configuration files?
    *   a) `.yaml`
    *   b) `.json`
    *   c) `.tf`
    *   d) `.hcl`

12. How do you define a dependency between resources explicitly?
    *   a) `depends_on`
    *   b) `wait_for`
    *   c) `after`
    *   d) `sequence`

13. What does the `local_file` resource do?
    *   a) Uploads a file to S3
    *   b) Creates a file on the local machine running Terraform
    *   c) Creates a file on the EC2 instance
    *   d) Reads a file from disk

14. Which block is used to configure the AWS provider?
    *   a) `resource "aws" {}`
    *   b) `provider "aws" {}`
    *   c) `module "aws" {}`
    *   d) `config "aws" {}`

15. If you change a resource's name in the `.tf` file, what happens during `apply`?
    *   a) Terraform renames the resource in AWS
    *   b) Terraform destroys the old resource and creates a new one
    *   c) Nothing happens
    *   d) Terraform updates the tag

16. What is "Drift"?
    *   a) Moving resources between regions
    *   b) The difference between your configuration and the actual infrastructure state
    *   c) A Terraform plugin
    *   d) Slow network performance

17. Which variable type is best for a list of security group rules?
    *   a) `string`
    *   b) `map`
    *   c) `list(object)`
    *   d) `bool`

18. How do you suppress sensitive output in the CLI?
    *   a) `hidden = true`
    *   b) `sensitive = true`
    *   c) `private = true`
    *   d) `secure = true`

19. What is the purpose of `terraform.tfvars`?
    *   a) To define variable types
    *   b) To store the state
    *   c) To assign values to input variables automatically
    *   d) To store provider plugins

20. Which command formats your Terraform code to a standard style?
    *   a) `terraform style`
    *   b) `terraform lint`
    *   c) `terraform fmt`
    *   d) `terraform fix`

21. What does `cidr_blocks = ["0.0.0.0/0"]` imply in a Security Group ingress rule?
    *   a) Allow traffic from local network only
    *   b) Allow traffic from anywhere (The Internet)
    *   c) Deny all traffic
    *   d) Allow traffic from AWS internal network only

22. Can a module call another module?
    *   a) Yes (Nested modules)
    *   b) No
    *   c) Only if they are in the same directory
    *   d) Only in Terraform Enterprise

23. What is the `terraform.lock.hcl` file?
    *   a) It locks the state file
    *   b) It locks provider versions to ensure consistency
    *   c) It stores passwords
    *   d) It prevents other users from running Terraform

24. How do you import existing infrastructure into Terraform?
    *   a) `terraform import`
    *   b) `terraform adopt`
    *   c) `terraform grab`
    *   d) You cannot; you must recreate it

25. What is a "Backend" in Terraform?
    *   a) The database used by the application
    *   b) The location where the state file is stored (e.g., Local, S3)
    *   c) The backend server of the app
    *   d) The provider logic

### Quiz Answer Key

1.  **c) terraform init**
2.  **c) An input variable**
3.  **b) terraform.tfstate**
4.  **b) tls_private_key**
5.  **b) module.module_name.output_name**
6.  **b) Creates multiple instances...**
7.  **c) All protocols**
8.  **b) terraform plan**
9.  **b) Destroys all infrastructure...**
10. **b) A filesystem path**
11. **c) .tf**
12. **a) depends_on**
13. **b) Creates a file on the local machine...**
14. **b) provider "aws" {}**
15. **b) Terraform destroys the old resource...** (Terraform tracks by resource name in state)
16. **b) The difference between configuration and state**
17. **c) list(object)**
18. **b) sensitive = true**
19. **c) To assign values to input variables automatically**
20. **c) terraform fmt**
21. **b) Allow traffic from anywhere**
22. **a) Yes**
23. **b) It locks provider versions...**
24. **a) terraform import**
25. **b) The location where the state file is stored**