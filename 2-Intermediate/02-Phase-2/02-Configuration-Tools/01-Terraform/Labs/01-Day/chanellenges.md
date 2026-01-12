# Day 1 Tasks: Terraform Mastery — The Foundation
Navigate through these tasks to validate your local environment and practice the core Terraform lifecycle. Ensure you have referred to the **Day 1 Terraform Fundamentals, Architecture, and Setup.md** guide before starting.

---
## 🛠️ Task 1: Environment Validation
Verify that your development environment is correctly configured.
1.  **Check Terraform**: Run `terraform -version`. Ensure it is at least v1.0.0.
2.  **Verify Cloud CLIs**:
    - Run `aws --version`
    - Run `az --version`
    - Run `gcloud --version`
3.  **IDE Check**: Open VS Code and confirm you have the **HashiCorp Terraform** extension installed.
---
## 🏗️ Task 2: The "Offline" Workflow
Practice the commands that don't require an active connection to a cloud provider.
1.  **Create a Project Directory**: Create a folder named `terraform-lab-01` and navigate into it.
2.  **Create a Configuration**: Create a file named `main.tf` with the following content:
    ```hcl
    resource "local_file" "welcome" {
      filename = "hello.txt"
      content  = "Welcome to Terraform Day 1!"
    }
    ```
3.  **Format Your Code**: Intentionally add messy spacing to your `main.tf`, then run `terraform fmt`. Observe how it cleans the file.
4.  **Validate**: Run `terraform validate`. It should fail initially because you haven't "initialized" the provider.
---
## 🚀 Task 3: Initialization & The Inner Loop
Experience the lifecycle of a resource.
1.  **Initialize**: Run `terraform init`. 
    - **Self-Reflect**: Look inside the new `.terraform/` directory. What did it download?
2.  **Plan**: Run `terraform plan`. 
    - Review the output. What does the `+` sign mean?
3.  **Apply**: Run `terraform apply` (type `yes` when prompted).
    - **Observe**: Check your folder. Is the `hello.txt` file there?
4.  **Inspect State**: Open the newly created `terraform.tfstate` file. 
    - Locate the `filename` and `content` of your resource within the JSON.
5.  **Destroy**: Run `terraform destroy`. 
    - Verify that `hello.txt` has been removed.
---
## 🧩 Task 4: Mastering State & Logic
Understanding what happens when reality changes.
1.  **Adopt a Resource**: Re-run `terraform apply`.
2.  **Manual Intervention**: Manually delete the `hello.txt` file using your file explorer or `rm hello.txt`.
3.  **Drift Detection**: Run `terraform plan`. 
    - **Question**: Why does Terraform want to create the file again? What did it compare reality against?
4.  **The "Taint" Exercise**: Run `terraform apply`. Once the file is back, run `terraform taint local_file.welcome`.
5.  **Observe Taint**: Run `terraform plan`. 
    - Notice that Terraform now wants to destroy and recreate the file even though nothing changed in your code.
---
## 🎤 Knowledge Check (Self-Assessment)
*Draft your answers in your head or a notebook.*
1.  What is the main difference between a **Provider** and a **Resource**?
2.  Why is it dangerous to delete the `terraform.tfstate` file while resources are still running in the cloud?
3.  What command would you use to fix the indentation in 100 different `.tf` files at once?
4.  If `terraform init` fails with a network error, what is it likely trying to download?

---
### ✅ Completion Criteria
- [ ] All 3 Cloud CLIs return a version number.
- [ ] Successfully created and destroyed a `local_file` resource.
- [ ] Inspected and understood the JSON structure of a `terraform.tfstate` file.
- [ ] Successfully detected "Configuration Drift" by manually deleting a file.
