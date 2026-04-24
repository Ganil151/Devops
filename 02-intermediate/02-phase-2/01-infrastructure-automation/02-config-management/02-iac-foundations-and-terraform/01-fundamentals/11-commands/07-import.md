# terraform import

## 📋 Overview

`terraform import` is used to bring existing, manually created infrastructure resources under Terraform management. It is the bridge for **<mark style="background:#d4b106">"Brownfield" projects</mark>** (existing infrastructure) moving to Infrastructure as Code.

---

## 🎯 Purpose

- Taking control of resources created via the Cloud Console (GUI)
- Restoring management of "orphaned" resources
- Migrating resources from other IaC tools to Terraform
- Consolidating scattered cloud assets into a single state

---

## 📝 Basic Syntax

```bash
terraform import [options] ADDR ID
```
- **ADDR**: The address of the resource in your Terraform code (e.g., `aws_instance.web`).
- **ID**: The real-world ID of the resource in the Cloud (e.g., `i-0abcdef123456`).

---

## 🚀 The Import Workflow (4 Steps)

### Step 1: Write the Code
Create a "skeleton" resource block in your `.tf` file. You don't need all attributes yet, just the type and name.
```hcl
resource "aws_s3_bucket" "existing_bucket" {
  # Leave empty or add minimal required fields
}
```

### Step 2: Run the Import
Execute the command to map the Cloud ID to your code address.
```bash
terraform import aws_s3_bucket.existing_bucket my-manual-bucket-name
```

### Step 3: Run a Plan
Run `terraform plan`. It will show a massive difference between your "skeleton" code and the real state.
```bash
terraform plan
```

### Step 4: Align the Code
Update your `.tf` code with the attributes shown in the plan until `terraform plan` reports **<font color="#92d050">"No changes. Your infrastructure matches the configuration."</font>**

---

## 🛠️ Real-World Scenarios

### Scenario 1: The "ClickOps" Legacy
A company created their entire production VPC using the AWS Console in 2019.
- **Goal**: Move to Terraform without destroying the VPC.
- **Solution**: Use `terraform import` for the VPC, Subnets, and Route Tables one by one.

### Scenario 2: Shadow IT Discovery
An engineer created a few Lambda functions manually for a "quick fix."
- **Goal**: Bring them into the official deployment pipeline.
- **Solution**: Identify the Lambda names and import them into the relevant app module.

---

## ⚙️ Important Considerations

| Limitation | Explanation |
|------------|-------------|
| **No Code Generation** | Import only updates the **state file**. It does NOT write the `.tf` code for you. |
| **One at a Time** | Standard import works on a per-resource basis (though Terraform 1.5+ introduced bulk import). |
| **Exact Mapping** | You must know the specific ID format required by the provider (e.g., Amazon ARN vs. simple ID). |

---

## ⚠️ Common Errors & Solutions

### Error: "Resource address not found"
**Cause**: You haven't defined the `resource "type" "name"` block in your code yet.
**Solution**: Create the resource block before running import.

### Error: "Import not supported"
**Cause**: Some legacy or niche resources don't support the import function.
**Solution**: Check the provider documentation; you may have to recreate the resource or use a specialized tool.

---

## 🎓 Best Practices

1. **Check Documentation**: Every resource's documentation page (e.g., on registry.terraform.io) has an "Import" section at the very bottom showing the required ID format.
2. **Import incrementally**: Start with foundational resources (VPC, Network) before moving to compute or apps.
3. **Use Versioning**: If you make a mistake during import alignment, the ability to revert your state file is a lifesaver.

---

## 📖 Summary

**terraform import** is the migration tool of choice. It allows you to adopt existing infrastructure with zero downtime. It is a slow, methodical process but essential for modernizing legacy environments.

---

**[⬅️ Back to Commands README](readme.md)** | **[Previous: terraform state](06-state.md)** | **[Next: terraform fmt](09-fmt.md)**
