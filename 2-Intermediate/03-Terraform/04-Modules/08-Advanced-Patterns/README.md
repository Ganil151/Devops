# Advanced Patterns

Taking your modules to the professional tier with dynamic logic and loops.

## 1. Using `for_each` and `count` on Modules
You can deploy a module multiple times with a single block.
```hcl
module "s3_buckets" {
  for_each = toset(["logs", "media", "backups"])
  source   = "./modules/s3"
  name     = "${each.key}-bucket"
}
```

## 2. Dynamic Blocks inside Modules
Make your module's resources flexible.
```hcl
resource "aws_security_group" "this" {
  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
    }
  }
}
```

## 3. Conditional Module Calls
```hcl
module "monitoring" {
  count  = var.enable_monitoring ? 1 : 0
  source = "./modules/monitoring"
}
```

## 4. Toggling Resources with Boolean Flags
Inside a module, use a variable like `create_resource = true` to allow users to opt-out of specific parts of the module.

---

## 🏗️ Real-Life Scenario: The Regional Rollout
**Problem**: A global company needs to deploy a "Web Stack" module to 15 different regions.
**Inefficient Way**: Create 15 separate `module` blocks in the root, one for each region.
**Advanced Way**: Create a map of regions and their configurations. Use `for_each` on the module block. 
**Outcome**: If they add a 16th region, they just add one line to the map instead of 10 lines of HCL.

---

## ❓ Interview Questions
1.  **Can you use `count` and `for_each` on the same module block?**
    *   *Answer*: No. You must choose one or the other.
2.  **When should you use a nested module (a module calling another module)?**
    *   *Answer*: Only when the child module represents a truly separate, reusable component (like a "Standard Security Group" inside a "VPC" module). Avoid nesting more than 1-2 levels deep.

---

## 🧠 Quiz Snippet (5/20+)
1.  **Which meta-argument creates multiple module instances using a list?** (`count`)
2.  **Which meta-argument is better for creating instances from a map?** (`for_each`)
3.  **True/False: You can use `dynamic` blocks for anything in HCL.** (False - Only for nested configuration blocks within resources)
4.  **What is the benefit of a conditional module?** (Reducing cost by not deploying optional features)
5.  **How do you access the key in a `for_each` module?** (`each.key`)
