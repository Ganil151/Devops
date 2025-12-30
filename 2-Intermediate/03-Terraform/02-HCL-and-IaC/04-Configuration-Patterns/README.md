# Configuration Patterns

Efficiently managing complex infrastructure requires advanced HCL patterns level.

## Key Patterns

### 1. The DRY (Don't Repeat Yourself) Pattern
Use **modules** and **locals** to avoid duplicating values or resource blocks.

### 2. Composition
Instead of one massive module, compose your infrastructure out of smaller, specialized modules (Networking + Database + App).

### 3. Feature Flags
Use booleans and `count` to optionally toggle resources.
```hcl
resource "aws_db_instance" "replica" {
  count = var.enable_replica ? 1 : 0
  ...
}
```

### 4. The Loop Pattern
Use `for_each` and `dynamic blocks` to handle variable numbers of objects (like security group rules).

## Dynamic Blocks Example
```hcl
resource "aws_security_group" "rules" {
  dynamic "ingress" {
    for_each = var.service_ports
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
    }
  }
}
```

---

## 🏗️ Real-Life Scenario: The Port Explosion
**Problem**: A developer needs to open 50 different ports for a legacy application. Manually writing 50 `ingress` blocks makes the code 500 lines long and unreadable.
**Solution**: Use a **Dynamic Block**. Define the ports in a list variable and use a few lines of code to loop through them. This keeps the code clean and maintainable.

---

## ❓ Interview Questions
1.  **What is a Dynamic Block?**
    *   *Answer*: It allows you to produce nested configuration blocks (like `ingress` or `subnet`) dynamically based on a collection.
2.  **How do you handle conditional creation of resources?**
    *   *Answer*: By using a combination of a boolean variable and the `count` meta-argument (`count = var.enabled ? 1 : 0`).

---

## 🧠 Quiz Snippet (5/20+)
1.  **Which keyword allows looping over a list in a resource?** (`for_each` or `count`)
2.  **What is the result of `count = 0`?** (No resource is created)
3.  **True/False: You can use `count` and `for_each` in the same block.** (False)
4.  **What does `lookup(map, key, default)` do?** (Safely retrieves a value or returns a default)
5.  **Which block is used for reusable internal expressions?** (`locals`)
