# Naming Conventions

Consistent naming is the difference between a self-documenting project and a confusing mess.

## 🏁 General Rules
1.  **Use Underscores (`_`)**: Use snake_case for resource names, variables, and outputs (e.g., `web_server_id`).
2.  **Use Hyphens (`-`)**: Use hyphens for cloud resource names (e.g., an S3 bucket named `company-prod-logs`).
3.  **Avoid Redundancy**: Don't name a resource `resource "aws_vpc" "vpc"`. Use `resource "aws_vpc" "main"` or `resource "aws_vpc" "app"`.

## Standard Naming Pattern
Follow this formula for cloud resources:
`{Project}-{Environment}-{Component}-{Resource}`
Example: `phoenix-prod-api-lb`

## Terraform Logic Naming
- **Variables**: `vpc_cidr`, `instance_type`.
- **Outputs**: `vpc_id`, `public_ip_addresses`.
- **Modules**: Use standard registry naming: `terraform-aws-modules/vpc/aws`.

---

## 🏗️ Real-Life Scenario: The "Server1" Mystery
**Problem**: An administrator logs into the AWS Console and sees 10 servers named `server1`, `server1-dev`, `server2`, and `Server_A`.
**Conflict**: They need to shut down the "Testing" server to save money. They pick `server2`, but it turns out `server2` was a critical production database proxy named by a previous hire.
**Fix**: Implement a naming convention policy. Use `prefix-env-role` (e.g., `app-prod-db-proxy`). Now, any human or script knows exactly what a resource does just by reading the name.

---

## ❓ Interview Questions
1.  **Why do we use snake_case for Terraform resource names but hyphens for AWS resource names?**
    *   *Answer*: Terraform's HCL syntax prefers snake_case for internal identifiers. However, many cloud providers (like AWS) don't allow underscores in DNS-compliant names (like S3 buckets or Load Balancers), so we use hyphens there.
2.  **What is the benefit of the name `this` or `main` for a primary resource in a module?**
    *   *Answer*: It makes the module generic and easier to copy-paste or refactor, as the internal logic doesn't depend on a specific business name.

---

## 🧠 Quiz Snippet (5/20+)
1.  **Is `Web-Server` a good Terraform resource name?** (No - use snake_case: `web_server`)
2.  **True/False: You should include the provider name in every resource name.** (False - the resource type already contains it)
3.  **What character is preferred for environment variables in Linux?** (Underscore)
4.  **Should a list variable be named `instance` or `instances`?** (`instances` - use plural for collections)
5.  **Which naming style is preferred for HCL?** (snake_case)
