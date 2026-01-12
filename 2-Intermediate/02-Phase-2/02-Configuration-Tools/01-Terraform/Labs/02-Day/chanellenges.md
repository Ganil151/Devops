# Day 2 Tasks: Mastering Providers and Resources
Validate your understanding of how Terraform communicates with APIs and how to describe infrastructure objects.

---
## 🛠️ Task 1: Provider Exploration & Aliases
Practice configuring multiple versions of the same provider.

1.  **Project Setup**: Create a directory `terraform-lab-02` and a `main.tf` file.
2.  **Alias Configuration**: Configure the `local` provider with an alias.
    ```hcl
    provider "local" {
      # Default provider configuration
    }

    provider "local" {
      alias = "experimental"
    }
    ```
3.  **Resource Assignment**: Create two file resources. One using the default provider and one using the `experimental` alias.
    ```hcl
    resource "local_file" "default" {
      filename = "default.txt"
      content  = "Using default provider"
    }

    resource "local_file" "alt" {
      provider = local.experimental
      filename = "alias.txt"
      content  = "Using alias provider"
    }
    ```
4.  **Execute**: Run `terraform init` and `terraform apply`. Verify both files are created.
---
## 🏗️ Task 2: Implicit vs. Explicit Dependencies
Understand how Terraform builds the dependency graph.
1.  **Implicit Link**: Create a second resource that uses the filename of the first.
    ```hcl
    resource "local_file" "dependent" {
      filename = "info.txt"
      content  = "This file depends on ${local_file.default.filename}"
    }
    ```
2.  **Explicit Link**: Use `depends_on` to link a resource to the `alt` file even if there is no code reference.
    ```hcl
    resource "local_file" "manual_link" {
      filename   = "manual.txt"
      content    = "Explicitly linked"
      depends_on = [local_file.alt]
    }
    ```
3.  **Graphing (Optional)**: If you have Graphviz installed, try running `terraform graph | dot -Tpng > graph.png` to see the DAG.
---
## 🚀 Task 3: Meta-Arguments (`count` and `lifecycle`)
Practice scaling and protection strategies.
1.  **Scale Up**: Add a resource using `count`.
    ```hcl
    resource "local_file" "multi" {
      count    = 3
      filename = "file-${count.index}.txt"
      content  = "Instance number ${count.index}"
    }
    ```
2.  **Protect**: Add a lifecycle block to prevent deletion.
    ```hcl
    resource "local_file" "protected" {
      filename = "protected.txt"
      content  = "You cannot delete me!"
      lifecycle {
        prevent_destroy = true
      }
    }
    ```
3.  **The Test**: Run `terraform apply`, then try to run `terraform destroy`. 
    - **Observe**: What error does Terraform give? 
    - **Fix**: To finish the lab, you must set `prevent_destroy = false` to clean up.

---
## 🎤 Knowledge Check
*Think through these scenarios:*
1.  What directory are provider binaries stored in after `init`?
2.  If you change the content of `protected.txt` in the console, but not in the code, what happens during `terraform plan`?
3.  Why is `for_each` generally preferred over `count` for resources like AWS Subnets?

---
### ✅ Completion Criteria
- [ ] Successfully initialized a provider with an alias.
- [ ] Created resources using both implicit and explicit dependencies.
- [ ] Triggered a `prevent_destroy` error.
- [ ] Scales files using `count.index`.
