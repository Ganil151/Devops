# Module Registry

The Terraform Registry is a centralized repository for sharing and discovering Terraform modules.

## Public Registry
Located at [registry.terraform.io](https://registry.terraform.io). 
- Thousands of community and vendor-supported modules (e.g., `terraform-aws-modules/vpc/aws`).
- **Verified Modules**: Blue badge indicates high-quality, vendor-maintained code.

## Private Registry
Available in **Terraform Cloud** and **Terraform Enterprise**.
- Share modules internally within your organization.
- Avoid exposing proprietary infrastructure patterns to the public.

## Calling a Registry Module
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0" # Always pin your version!
  
  name = "my-vpc"
  cidr = "10.0.0.0/16"
}
```

## Publishing Requirements
To publish to the Public Registry, your GitHub repo must follow these rules:
1. **Naming**: `terraform-<PROVIDER>-<NAME>` (e.g., `terraform-aws-secure-vpc`).
2. **Standard Structure**: Must have `main.tf`, `variables.tf`, and `outputs.tf`.
3. **Tagging**: Must use Semantic Versioning tags (e.g., `v1.0.0`).

---

## 🏗️ Real-Life Scenario: The "Not Invented Here" Syndrome
**Problem**: A company spends 6 months building its own VPC module from scratch to handle subnets, NAT gateways, and routing tables.
**Reality Check**: They find the `terraform-aws-modules/vpc/aws` module online. It's used by 10,000+ teams, has automated tests, and handles edge cases they missed.
**Outcome**: They switch to the registry module, reducing their maintenance burden to zero and improving their network's stability.

---

## ❓ Interview Questions
1.  **Why should you always use a `version` constraint when calling a registry module?**
    *   *Answer*: To prevent "Auto-Updates." If a module author releases a new version with breaking changes, your next `init` could break your infrastructure if you don't pin the version.
2.  **What is a "Verified Module"?**
    *   *Answer*: It's a module in the public registry that has been vetted by HashiCorp and is typically maintained by a cloud provider or a trusted partner.

---

## 🧠 Quiz Snippet (5/20+)
1.  **Where do you find public Terraform modules?** (registry.terraform.io)
2.  **What is the required naming convention for registry modules?** (`terraform-<PROVIDER>-<NAME>`)
3.  **True/False: You must pay to use modules from the public registry.** (False)
4.  **Does the registry host the code or just the metadata?** (Metadata; the code usually stays on GitHub/GitLab)
5.  **Which badge indicates a trusted module?** (Verified Badge / Blue Checkmark)
