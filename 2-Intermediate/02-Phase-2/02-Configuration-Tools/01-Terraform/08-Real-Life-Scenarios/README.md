# Terraform Real-Life Scenarios

Master Terraform by understanding how to solve common, high-pressure situations found in production environments.

---

## 🛠️ Scenario 1: The "Locked State" Deadlock
**Setting:** You are working in a team using AWS S3 and DynamoDB for state management. You try to run `terraform plan`, but it fails.

**The Error:**
`Error: Error acquiring the state lock`

**Investigation:**
1. Check if a teammate is currently running an `apply`.
2. Check the CI/CD pipeline to see if a job is hung.

**The Fix:**
If you are 100% sure no one is actually using the state:
1. Identify the **Lock ID** from the error message.
2. Run: `terraform force-unlock <LOCK_ID>`
3. Always investigate *why* it got stuck (usually a crashed process or network timeout).

---

## 🏗️ Scenario 2: Refactoring into Modules
**Setting:** Your `main.tf` has grown to 2,000 lines. It’s hard to read and dangerous to change.

**The Challenge:** Move the "Networking" section (VPC, Subnets, IGW) into a separate module without destroying existing resources.

**The Steps:**
1. Create a `modules/networking` directory.
2. Move the networking resource code into `modules/networking/main.tf`.
3. In your root `main.tf`, call the module:
   ```hcl
   module "network" {
     source = "./modules/networking"
     vpc_cidr = "10.0.0.0/16"
   }
   ```
4. **CRITICAL:** Use `terraform state mv` to tell Terraform that the resource moved from the root to the module.
   - Example: `terraform state mv aws_vpc.main module.network.aws_vpc.main`
5. Run `terraform plan` to verify that 0 resources will be added/destroyed.

---

## 🕵️ Scenario 3: Recovering from Resource Drift
**Setting:** A developer manually changed a Security Group rule in the AWS Console to fix an emergency. Now, your Terraform code says that rule doesn't exist.

**The Options:**
1. **Revert:** Run `terraform apply` and let Terraform delete the manual change (bringing it back to the "known good" state).
2. **Adopt:** Manually update your Terraform code to include the new rule, then run `terraform plan`. It should now show "No changes".

**Best Practice:** Always **Adopt** if the manual change was necessary. Never leave drift unresolved.

---

## 🌩️ Scenario 4: Importing Existing Infrastructure
**Setting:** Your company has an old S3 bucket created manually 3 years ago. You want to start managing it with Terraform.

**The Steps:**
1. Write the empty resource block in your code:
   ```hcl
   resource "aws_s3_bucket" "legacy" {
     # Leave empty for now
   }
   ```
2. Run the import command:
   `terraform import aws_s3_bucket.legacy my-manual-bucket-name`
3. Run `terraform show` to see what Terraform now "knows" about that bucket.
4. Copy the attributes from `terraform show` into your code until `terraform plan` says "No changes".

---

## 🏢 Scenario 5: Multi-Environment Management
**Setting:** You need to deploy the same infrastructure to `Dev`, `Staging`, and `Production` with different CIDR blocks and instance types.

**The Solution (Workspaces):**
1. Create a workspace: `terraform workspace new prod`
2. Use the workspace name in your code:
   ```hcl
   instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.micro"
   ```
3. Switch between them: `terraform workspace select dev`

**Alternative (Directory Structure):**
Create folder `env/dev`, `env/prod`, and use a shared module. (This is often preferred for large-scale enterprise environments for better isolation).

---

## 💡 Key Takeaway
Real-world DevOps isn't just about writing code; it's about managing **state** and **people**. These scenarios represent the 80% of "Terraform Headache" situations you will face.
