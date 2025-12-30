# State Operations

Mastering the CLI commands used to inspect and manipulate your state file.

## Essential Commands

### 1. `terraform show`
Displays a human-readable version of the current state.
```bash
terraform show
```

### 2. `terraform state list`
Lists all resources currently managed by the state.
```bash
terraform state list
```

### 3. `terraform state show`
Shows the detailed attributes of a specific resource in the state.
```bash
terraform state show aws_instance.web
```

### 4. `terraform state rm`
Removes a resource from the state file. **CRITICAL**: This does NOT delete the resource from the cloud; it just stop Terraform from managing it.
```bash
terraform state rm aws_instance.old_server
```

### 5. `terraform state mv`
Renames a resource in the state (useful after refactoring code).
```bash
terraform state mv aws_instance.old_name aws_instance.new_name
```

### 6. `terraform import`
Brings existing cloud resources into Terraform management.
```bash
terraform import aws_vpc.main vpc-12345678
```

---

## 🏗️ Real-Life Scenario: The Refactor Without the Mess
**Problem**: An engineer renames a resource in the code from `web` to `app`. When they run a plan, Terraform wants to *destroy* the `web` server and *create* a new `app` server, causing downtime.
**Solution**: Use `terraform state mv aws_instance.web aws_instance.app`. Now, Terraform understands that the resource is the same, just renamed in the code.

---

## ❓ Interview Questions
1.  **What is the difference between `terraform state rm` and `terraform destroy`?**
    *   *Answer*: `rm` only deletes the record from the state file (resource keeps running). `destroy` actually sends an API call to the cloud provider to delete the resource.
2.  **How do you manually edit a state file?**
    *   *Answer*: **DON'T!** Use `terraform state` commands. If you must, use `terraform state pull`, edit the JSON, and then `terraform state push`.

---

## 🧠 Quiz Snippet (5/20+)
1.  **Which command finds a resource's attributes?** (`terraform state show`)
2.  **Which command lists all managed resources?** (`terraform state list`)
3.  **True/False: `terraform state rm` deletes cloud resources.** (False)
4.  **Which command brings a manual resource into code?** (`terraform import`)
5.  **What happens after a `terraform state mv`?** (Terraform matches the new name to the existing resource)
