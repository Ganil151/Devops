# Module Best Practices

The "Seven Commandments" for writing world-class modules.

## 1. Do Not Repeat Yourself (DRY)
If you find yourself copy-pasting code three times, it belongs in a module.

## 2. Keep it Small & Focused
A module should do one thing well (SRP - Single Responsibility Principle). 
- **Good**: `vpc-module`, `eks-module`.
- **Bad**: `everything-on-aws-module`.

## 3. Standardize Naming
Use a consistent prefix for all resources within a module.
- `resource "aws_s3_bucket" "this"` is a common pattern for the "Main" resource.

## 4. Document Everything
Use `terraform-docs` to auto-generate README tables for your inputs and outputs. Never let a variable go without a `description`.

## 5. Expose "Knobs," Not Internals
Only make a variable for things users actually need to change. Hardcode internal logic that shouldn't be touched.

## 6. Version Early, Version Often
Release a `v1.0.0` as soon as the module is stable. Use Git tags.

## 7. Pass Providers Explicitly
Allow the Root Module to control the `alias` and `region` of the providers. Don't hardcode region `us-east-1` inside a module.

---

## 🏗️ Real-Life Scenario: The $20k Region Mistake
**Problem**: A module has `region = "us-east-1"` hardcoded inside its `aws_instance` resource.
**Outcome**: A developer calls the module from a root module configured for `eu-west-1`. They think they are deploying to Europe, but the module secretly deploys 100 instances to the US.
**Fix**: Remove the region from the module. Let the resource inherit the provider from the caller.

---

## ❓ Interview Questions
1.  **What is the Single Responsibility Principle as applied to modules?**
    *   *Answer*: A module should manage a single logical component (like a database or a network). Combining them makes the code hard to reuse and increases the blast radius.
2.  **What is the benefit of using the name "this" for the main resource in a module?**
    *   *Answer*: It makes the code more generic and easier to copy-paste or refactor without renaming every internal reference.

---

## 🧠 Quiz Snippet (5/20+)
1.  **What tool auto-generates module documentation?** (`terraform-docs`)
2.  **True/False: You should include a provider block inside every module.** (False - Pass them from the root)
3.  **What is a "Monolithic Module"?** (A module that tries to do too many things)
4.  **How many `outputs` should a module have?** (As many as needed for other modules to work)
5.  **Which file should contain the description of the module's behavior?** (`README.md`)
