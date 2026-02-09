# Infrastructure Provisioning: Engineering Challenges

These challenges are designed to test your understanding of Terraform patterns, AWS architecture, and SRE principles.

---

## 🟢 Level 1: Beginner (Base Camp)

### 1. The "Wait" Problem
**Challenge:** How do you ensure an RDS database is fully ready before a Lambda function tries to run a DB migration?

- [ ] A) Use `depends_on` in the Lambda resource block.
- [ ] B) Use a for-loop in the Lambda code to wait for a 200 OK.
- [x] C) Use `depends_on` for strict resource ordering, or better, implement a "wait-for-db" init-container/script that checks port 5432 availability.
- [ ] D) RDS is always ready immediately after the Terraform apply starts.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** While `depends_on` ensures the RDS *resource* is created, it doesn't guarantee the database *engine* is finished booting and accepting connections. A specialized health check script or a wait-condition is the standard SRE approach to prevent "Connection Refused" errors during first deployment.
**Certification Alignment:** AWS Certified Developer Associate / Terraform Associate
</details>

### 2. Tagging Policy
**Challenge:** How do you force every resource to have a `Project`, `Owner`, and `Environment` tag without repeating code in every resource?

- [ ] A) Manually type them into every `tags = {}` block.
- [x] B) Use the `default_tags` block in the AWS provider configuration.
- [ ] C) Terraform doesn't support global tagging; you must use AWS Config.
- [ ] D) Use a global variable and a merge function in every resource.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** The AWS provider's `default_tags` block allows you to define tags at the provider level, which are then automatically applied to all resources managed by that provider. This ensures consistency and simplifies cost-allocation tagging.
**Certification Alignment:** AWS Certified SysOps Administrator / FinOps Basics
</details>

---

## 🟡 Level 2: Intermediate (The Professional)

### 1. The "DR" Switch
**Challenge:** Design a multi-region VPC Peering setup. If Region A goes down, how does your infrastructure handle the DNS failover?

- [ ] A) Manually update the A-record to point to Region B.
- [ ] B) Use a CNAME record with a short TTL.
- [x] C) Use Route 53 Failover Routing Policies with health checks pointed at an ALB or S3 endpoint in both regions.
- [ ] D) VPC Peering handles DNS failover automatically.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** Route 53 Health Checks combined with Failover policies allow for automated disaster recovery. If the primary region's health check fails, traffic is redirected to the secondary region within the TTL window.
**Certification Alignment:** AWS Certified Solutions Architect Professional
</details>

### 2. State Locking Mystery
**Challenge:** You try to run `terraform apply` and get a message saying the state is "Locked." What is the safest way to resolve this?

- [ ] A) Delete the `.terraform.tfstate.lock` file manually.
- [x] B) Use `terraform force-unlock <LOCK_ID>` after verifying that no other team member is currently running an apply.
- [ ] C) Close your terminal and try again in 5 minutes.
- [ ] D) Delete the DynamoDB table used for locking.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** State locking (often via DynamoDB) prevents concurrent writes. If a process crashes without releasing the lock, `force-unlock` is the native way to clear it. *Warning:* Doing this while someone else is actually applying can corrupt your state.
**Certification Alignment:** HashiCorp Certified: Terraform Associate
</details>

---

## 🔴 Level 3: Advanced (The Staff Engineer)

### 1. The Migration Hazard
**Challenge:** You need to rename a resource in your Terraform code (e.g., from `aws_instance.web` to `aws_instance.frontend`) without destroying and recreating the actual server.

- [ ] A) Just rename it in the `.tf` file and run `terraform apply`.
- [ ] B) Use `terraform destroy` and then `terraform apply`.
- [x] C) Use a `moved` block in HCL (TF 1.1+) or run `terraform state mv aws_instance.web aws_instance.frontend`.
- [ ] D) Manually edit the `terraform.tfstate` JSON file.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** Terraform identifies resources by their address in the code. Renaming the address makes TF think the old one is gone and a new one is needed. `moved` blocks allow you to refactor code safely while maintaining the link to existing infrastructure.
**Certification Alignment:** HashiCorp Certified: Terraform Associate (Advanced Refactoring)
</details>

---

*Solve these by searching the patterns library in `07-boilerplates/02-intermediate/terraform`!*
