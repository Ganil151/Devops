# Versioning Strategy

Versioning is what makes a module "Safe" for production. It allows you to update code for one project without breaking another.

## Semantic Versioning (SemVer)
Most modules follow the `MAJOR.MINOR.PATCH` format:
- **Major (1.0.0 -> 2.0.0)**: Breaking changes. User must change their HCL code to migrate.
- **Minor (1.0.0 -> 1.1.0)**: New features, fully backward compatible.
- **Patch (1.0.0 -> 1.0.1)**: Bug fixes, no new features.

## Version Constraints
When calling a module, define which versions you accept:
- **Exact**: `version = "1.2.3"` (Safest).
- **Pessimistic**: `version = "~> 1.2.0"` (Accepts 1.2.1, 1.2.2, but NOT 1.3.0).
- **Range**: `version = ">= 1.0, < 2.0"` (Any version in the 1.x range).

## Pinning vs. Floating
- **Pinning**: Hardcoding a version. Good for Production.
- **Floating**: Using `>=` or `~>`. Good for Development to get latest fixes automatically.

---

## 🏗️ Real-Life Scenario: The "Friday Afternoon" Disaster
**Problem**: A Developer uses a common module from the registry but doesn't pin the version (`version = ">= 1.0"`).
**Event**: Late on Friday, the module author releases version 2.0 with a breaking change: the variable `vpc_id` is renamed to `network_id`.
**Outcome**: The Developer runs a final `terraform apply`. Terraform downloads the new 2.0 version, can't find `vpc_id`, and the deployment fails, causing a 3-hour troubleshooting session on a Friday evening.
**Lesson**: Always pin to at least a Minor version.

---

## ❓ Interview Questions
1.  **What does the `~>` operator do in a version constraint?**
    *   *Answer*: It is the "Pessimistic Constraint" operator. It allows the rightmost version component to increase. `~> 1.2.0` allows `1.2.x`, while `~> 1.2` allows `1.x.y`.
2.  **Why should researchers use exact pinning?**
    *   *Answer*: To ensure that the infrastructure is immutable and reproducible. If you run the code 6 months later, it should behave exactly the same way.

---

## 🧠 Quiz Snippet (5/20+)
1.  **Which part of SemVer changes when a feature is added?** (Minor)
2.  **What does `~> 5.1` allow?** (>= 5.1.0 and < 6.0.0)
3.  **True/False: Private modules don't need versioning.** (False - Teams still need stability)
4.  **Which file in your root module tracks the installed version of a module?** (The `.terraform.lock.hcl` file)
5.  **How do you upgrade a pinned module version?** (Update the `version` string and run `terraform init -upgrade`)
