Resources are the most important element in the Terraform language. Each resource block describes one or more infrastructure objects.

## Basic Resource Syntax
```hcl
resource "aws_instance" "web_server" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  
  tags = { Name = "Web" }
}
```

## Resource Meta-Arguments
Meta-arguments allow you to modify how Terraform handles resources:
- **count**: Creates multiple instances of the same resource.
- **for_each**: Creates multiple instances based on a map or set.
- **depends_on**: Explicitly defines the order of creation.
- **lifecycle**: Modifies behavior (e.g., `prevent_destroy`).

## Implicit vs Explicit Dependencies

### 1. Implicit Dependencies
The most common way to link resources. Terraform "reads" the code and automatically figures out the order when one resource references an attribute of another.

**Example**:
```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "frontend" {
  vpc_id = aws_vpc.main.id # Reference creates implicit dependency
  cidr_block = "10.0.1.0/24"
}
```

```mermaid
graph LR
    VPC[aws_vpc.main] ---|Automatic Link| Subnet[aws_subnet.frontend]
```

### 2. Explicit Dependencies
Used when there is a dependency that Terraform *cannot* see through code references (e.g., an application requires an S3 bucket to exist before starting, but doesn't reference its ID in the config).

**Example**:
```hcl
resource "aws_instance" "app" {
  ami           = "ami-xyz"
  instance_type = "t3.micro"

  depends_on = [aws_s3_bucket.data] # Manual link
}
```

```mermaid
graph LR
    S3[aws_s3_bucket.data] -.->|Manually Defined| App[aws_instance.app]
    style S3 stroke-dasharray: 5 5
```

---

## 🏗️ Real-Life Scenario: Blue/Green Cleanup
**Problem**: You want to update an EC2 instance, but destroying the old one before the new one is ready causes downtime.
**Solution**: Use the `create_before_destroy` lifecycle meta-argument.
```hcl
lifecycle {
  create_before_destroy = true
}
```
Terraform will create the new instance first and only delete the old one once the new one is running successfully.

---

## ❓ Interview Questions

1. **What is the difference between an implicit and explicit dependency?**
   - *Answer*: Implicit dependencies are created automatically by Terraform when one resource references another. Explicit dependencies are manually defined using the `depends_on` meta-argument.

2. **When should you use `count` vs `for_each`?**
   - *Answer*: `count` is better for identical resources (e.g., 5 web servers). `for_each` is better when resources have unique attributes (e.g., 3 subnets with different CIDRs).

3. **Explain the purpose of the `lifecycle` meta-argument.**
   - *Answer*: `lifecycle` modifies how Terraform handles resource creation, updates, and deletion. It supports options like `create_before_destroy` (create new before deleting old), `prevent_destroy` (block accidental deletion), and `ignore_changes` (ignore specific attribute changes).

4. **What happens if you remove a resource block from your configuration?**
   - *Answer*: During the next `terraform apply`, Terraform will detect the resource is no longer in the configuration and will destroy it in the actual infrastructure (unless `prevent_destroy` is set).

5. **How does `depends_on` affect Terraform's execution plan?**
   - *Answer*: `depends_on` creates an explicit ordering constraint, forcing Terraform to wait for the specified resources to be created/updated before proceeding with the current resource, even if there's no direct attribute reference.

6. **What is the difference between `count` and creating separate resource blocks?**
   - *Answer*: Using `count` creates multiple instances of the same resource type with a single block, making code DRY and easier to manage. Separate blocks would be repetitive and harder to maintain, though they allow for more customization per resource.

7. **Can you use both `count` and `for_each` in the same resource block?**
   - *Answer*: No, you cannot use both simultaneously in the same resource block. You must choose one or the other based on your use case.

---

## 🧠 Comprehensive Quiz (25 Questions)

**1. Which block defines a real-world object in Terraform?**
- A) `provider`
- B) `module`
- C) `resource`
- D) `variable`


<details>
<summary>Show Answer</summary>

**Answer: C**

</details>

**2. What meta-argument handles multiple identical resources?**
- A) `multiple`
- B) `count`
- C) `repeat`
- D) `duplicate`


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**3. True/False: Resources are provisioned exactly in the order they appear in the file.**
- A) True
- B) False - Terraform builds a dependency graph


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**4. Which lifecycle meta-argument prevents resource deletion?**
- A) `no_delete`
- B) `protect`
- C) `prevent_destroy`
- D) `ignore_destroy`


<details>
<summary>Show Answer</summary>

**Answer: C**

</details>

**5. What command lists all resources in the state?**
- A) `terraform list`
- B) `terraform resources`
- C) `terraform state list`
- D) `terraform show resources`


<details>
<summary>Show Answer</summary>

**Answer: C**

</details>

**6. How do you create an implicit dependency between resources?**
- A) Use `depends_on`
- B) Reference one resource's attribute in another
- C) Put them in the same file
- D) Use the `link` meta-argument


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**7. What is the syntax for referencing a resource attribute?**
- A) `${resource_type.resource_name.attribute}`
- B) `resource_type.resource_name.attribute`
- C) `resource.resource_name.attribute`
- D) `@resource_type.resource_name.attribute`


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**8. Which meta-argument creates resources based on a map or set?**
- A) `count`
- B) `for_each`
- C) `map`
- D) `iterate`


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**9. What does `create_before_destroy = true` do?**
- A) Deletes the old resource first
- B) Creates new resource before deleting the old one
- C) Prevents creation of new resources
- D) Creates a backup before destroying


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**10. When should you use `depends_on`?**
- A) Always, for every resource
- B) When there's a dependency Terraform can't automatically detect
- C) Never, implicit dependencies are always better
- D) Only with provider resources


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**11. What is the first argument in a resource block?**
- A) Resource name
- B) Resource type
- C) Provider name
- D) Resource ID


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**12. What is the second argument in a resource block?**
- A) Resource type
- B) Resource ID
- C) Resource name (local identifier)
- D) Provider


<details>
<summary>Show Answer</summary>

**Answer: C**

</details>

**13. Can you have multiple resources with the same type but different names?**
- A) No, each type can only appear once
- B) Yes, as long as names are unique within that type
- C) Only in different files
- D) Only with modules


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**14. What does `ignore_changes` do in a lifecycle block?**
- A) Prevents all changes to the resource
- B) Ignores specific attributes during updates
- C) Deletes the resource
- D) Skips validation


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**15. How do you access a resource created with count?**
- A) `resource_type.resource_name`
- B) `resource_type.resource_name[index]`
- C) `resource_type[index].resource_name`
- D) `resource_type.resource_name.count`


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**16. What happens if you reference a non-existent resource attribute?**
- A) Terraform assigns a default value
- B) Terraform shows an error during plan/apply
- C) The value is null
- D) Terraform ignores it


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**17. Can a resource depend on a module output?**
- A) No, only on resources
- B) Yes, you can reference module outputs
- C) Only with explicit depends_on
- D) Only in Terraform 1.0+


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**18. What is the purpose of resource meta-arguments?**
- A) To define resource attributes
- B) To modify how Terraform handles the resource lifecycle
- C) To authenticate with providers
- D) To validate configuration


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**19. Which is NOT a valid lifecycle meta-argument?**
- A) `create_before_destroy`
- B) `prevent_destroy`
- C) `ignore_changes`
- D) `delete_after_create`


<details>
<summary>Show Answer</summary>

**Answer: D**

</details>

**20. How does Terraform handle resources with no dependencies?**
- A) Creates them sequentially
- B) Creates them in parallel
- C) Skips them
- D) Requires manual intervention


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**21. What value does `count.index` start at?**
- A) 1
- B) 0
- C) -1
- D) Random


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**22. Can you use expressions in resource type or name arguments?**
- A) Yes, for both
- B) Yes for type, no for name
- C) No for type, yes for name
- D) No, they must be literal strings


<details>
<summary>Show Answer</summary>

**Answer: D**

</details>

**23. What does `each.key` reference when using for_each?**
- A) The resource type
- B) The current iteration's key from the map/set
- C) The resource name
- D) The provider


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**24. If a resource block is removed, when is the resource destroyed?**
- A) Immediately
- B) During the next `terraform apply`
- C) After 24 hours
- D) Never, must use `terraform destroy`


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**25. What is a common use case for `ignore_changes`?**
- A) Preventing all updates
- B) Ignoring attributes managed outside Terraform (e.g., autoscaling)
- C) Skipping validation
- D) Faster deployments


<details>
<summary>Show Answer</summary>

**Answer: B**

</details>
