# Advanced Automation: Interview Questions, Quiz & Scenarios

Master enterprise-grade automation with Ansible, Terraform, and GitOps strategies.

---

## ❓ Interview Questions (Advanced Automation)

1.  **Explain the concept of "Immutable Infrastructure" vs. "Configuration Management".**
    *   *Answer*: **Immutable Infrastructure** (Terraform/Packer) involves replacing servers rather than updating them. **Configuration Management** (Ansible/Chef) involves updating existing servers. Immutable is preferred for stateless apps to avoid drift.

2.  **How do you handle Terraform State in a team environment?**
    *   *Answer*: Use a **Remote Backend** (S3 + DynamoDB, Terraform Cloud) to store the state file securely and lock it during operations to prevent race conditions and corruption.

3.  **What is the difference between an Ansible Module and a Role?**
    *   *Answer*: A **Module** is a reusable, standalone script (like `yum`, `copy`). A **Role** is a collection of tasks, variables, files, and handlers organized in a standard directory structure to configure a complete service.

4.  **How does Terraform calculate the dependency graph?**
    *   *Answer*: Terraform builds a DAG (Directed Acyclic Graph) based on resource interpolations (`${aws_instance.web.id}`). It uses this to determine the order of creation and parallelism.

5.  **What is "Drift" in the context of IaC?**
    *   *Answer*: The difference between the desired state defined in code and the actual state of the infrastructure. Tools like `terraform plan` or drift detection agents identify these discrepancies.

6.  **Explain the use of `ansible-pull` vs. `ansible-playbook` (push).**
    *   *Answer*: **Push** (default) runs on a control node and connects to hosts via SSH. **Pull** runs on the managed nodes themselves (via cron/daemon), fetching the repo and applying it locally. Useful for massive scale or auto-scaling groups.

7.  **How do you manage secrets in Terraform?**
    *   *Answer*: Never store them in plain text `tfvars`. Use environment variables (`TF_VAR_password`), external secret stores (Vault, AWS Secrets Manager), or sensitive variable definitions (`sensitive = true`).

8.  **What is the "Blast Radius" and how do you minimize it in automation?**
    *   *Answer*: The scope of impact if an automation fails. Minimize it by splitting monolithic state files into smaller, decoupled workspaces/stacks (e.g., separate networking, data, and app layers).

9.  **Describe a "Blue/Green" deployment strategy using automation.**
    *   *Answer*: Create a new (Green) environment alongside the existing (Blue) one. Validate Green. Switch traffic (Load Balancer/DNS). Destroy Blue. This ensures zero downtime and instant rollback.

10. **What is OPA (Open Policy Agent) and how does it fit into automation?**
    *   *Answer*: OPA provides "Policy as Code". It can audit Terraform plans (e.g., "Ensure all S3 buckets have encryption") before they are applied, preventing non-compliant infrastructure.

11. **How do Ansible "Handlers" trigger?**
    *   *Answer*: Handlers run only if a task notifies them and the task status is "changed". They run once at the end of the play, regardless of how many tasks notified them.

12. **What is a "Dynamic Inventory" in Ansible?**
    *   *Answer*: A script or plugin that queries a cloud provider (AWS, Azure) to get the current list of hosts and groups in real-time, rather than using a static `hosts` file.

13. **Explain the purpose of `terraform taint` (or `-replace`).**
    *   *Answer*: It marks a resource for destruction and recreation during the next apply. Useful if a resource exists but is in a degraded or known-bad state that Terraform can't detect.

14. **What is idempotency and why is it critical for automation?**
    *   *Answer*: The property that applying the same configuration multiple times results in the same outcome (no side effects). It allows safe re-running of pipelines without breaking production.

15. **How do you test your Infrastructure as Code?**
    *   *Answer*: Use linting (`tflint`, `ansible-lint`), static analysis (`checkov`), unit testing (rare but possible), and integration testing (`kitchen`, `terratest`) which spins up real resources, validates them, and tears them down.

16. **What is the difference between `count` and `for_each` in Terraform?**
    *   *Answer*: `count` creates a list of resources (index based). `for_each` creates a map (key based). `for_each` is safer because removing an item from the middle of the list doesn't force recreation of subsequent resources.

17. **How do you handle extensive long-running automation tasks?**
    *   *Answer*: Use async modes (Ansible `async`/`poll`), run in background workers (Jenkins/GitHub Actions), or use event-driven architectures to avoid timeout issues.

18. **What is "GitOps"?**
    *   *Answer*: Using Git as the single source of truth for declarative infrastructure and applications. An automated agent (like ArgoCD or Atlantis) ensures the real world matches the Git state continuously.

19. **Explain "Golden Image" vs. "Runtime Configuration".**
    *   *Answer*: **Golden Image** (Packer) bakes dependencies into the VM image (fast boot, hard to update). **Runtime Config** (User Data/Ansible) installs software at boot (slower boot, flexible). A hybrid approach is often best.

20. **How do you debug a failing Ansible playbook?**
    *   *Answer*: Use `-v` (verbose), `-vvvv` (connection debug), `debug` module to print variables, and `--step` to run interactively. Check host connectivity and privilege escalation settings.

---

## 🧠 Advanced Automation Quiz

<b>1. Which Terraform command reconciles the state with real infrastructure without making changes?</b>
<details>
<summary>Show Answer</summary>
Answer: `terraform refresh` (mostly deprecated in favor of `apply -refresh-only`) or `plan`
</details>

<b>2. In Ansible, what is the default precedence of variables (lowest to highest)?</b>
<details>
<summary>Show Answer</summary>
Answer: Role defaults < Inventory vars < Playbook vars < Extra vars (-e)
</details>

<b>3. What does `terraform layout` typically refer to?</b>
<details>
<summary>Show Answer</summary>
Answer: File structure (main.tf, variables.tf, outputs.tf)
</details>

<b>4. Which Ansible directive ignores errors for a specific task?</b>
<details>
<summary>Show Answer</summary>
Answer: `ignore_errors: yes`
</details>

<b>5. Ideally, Terraform State files should never be stored in:</b>
<details>
<summary>Show Answer</summary>
Answer: Git / Version Control (Security risk + no locking)
</details>

<b>6. What is a "Provisioner" in Terraform?</b>
<details>
<summary>Show Answer</summary>
Answer: A way to execute scripts (local-exec, remote-exec) on resources (Last resort option)
</details>

<b>7. Which tool allows you to build identical machine images for multiple platforms?</b>
<details>
<summary>Show Answer</summary>
Answer: Packer
</details>

<b>8. In Ansible, what module is used to manage Docker containers?</b>
<details>
<summary>Show Answer</summary>
Answer: `community.docker.docker_container`
</details>

<b>9. What feature allows Terraform to import existing resources into state?</b>
<details>
<summary>Show Answer</summary>
Answer: `terraform import`
</details>

<b>10. The "delegated" pattern in Ansible allows you to:</b>
<details>
<summary>Show Answer</summary>
Answer: Run a task on a different host than the current inventory target (e.g., strip a load balancer)
</details>

<b>11. What is the file extension for Terraform configuration?</b>
<details>
<summary>Show Answer</summary>
Answer: `.tf`
</details>

<b>12. Which Ansible plugin type handles secrets encryption?</b>
<details>
<summary>Show Answer</summary>
Answer: Ansible Vault
</details>

<b>13. True or False: You should commit the `.terraform` directory to Git.</b>
<details>
<summary>Show Answer</summary>
Answer: False (It contains downloaded plugins/providers)
</details>

<b>14. What is a "Workspace" in Terraform?</b>
<details>
<summary>Show Answer</summary>
Answer: An independent state file within the same configuration directory (e.g., dev/prod)
</details>

<b>15. Which command formats Terraform code to a canonical style?</b>
<details>
<summary>Show Answer</summary>
Answer: `terraform fmt`
</details>

<b>16. In Ansible, `gather_facts: no` is used to:</b>
<details>
<summary>Show Answer</summary>
Answer: Speed up playbook execution by skipping system discovery
</details>

<b>17. What is "Cloud-Init"?</b>
<details>
<summary>Show Answer</summary>
Answer: The industry standard for cross-platform cloud instance initialization
</details>

<b>18. How do you define a variable that is a map in Terraform?</b>
<details>
<summary>Show Answer</summary>
Answer: `type = map(string)`
</details>

<b>19. What is the default SSH user for Ansible if not specified?</b>
<details>
<summary>Show Answer</summary>
Answer: The current user running the playbook
</details>

<b>20. Which concept allows you to manage multiple Terraform versions?</b>
<details>
<summary>Show Answer</summary>
Answer: `tfenv` or similar version managers
</details>

---

## 🏗️ Real-Life Scenarios

### Scenario 1: The "Works on My Machine" TF State
**Problem**: Two engineers ran `terraform apply` concurrently. One overwrote the other's changes, destroying the production load balancer.
**Solution**: Migrated local state to **S3 Remote Backend** with **DynamoDB State Locking**. This forces sequential execution and provides a shared source of truth.

### Scenario 2: Slow Ansible Deployments
**Problem**: Configuring 500 servers took 2 hours.
**Solution**:
1. Increased `forks` in `ansible.cfg` from 5 to 50.
2. Disabled `gather_facts` for plays that didn't need them.
3. Used `pipelining = True` to reduce SSH connection overhead.
**Result**: Deployment time reduced to 15 minutes.

### Scenario 3: Drift Detection
**Problem**: A sysadmin manually changed a security group to allow SSH (0.0.0.0/0) for debugging and forgot to revert it. IaC repo still showed it as closed.
**Solution**: Implemented a nightly `terraform plan` scheduled job (or used a tool like Driftctl) that alerts on Slack if the live state differs from the code state.

### Scenario 4: Secrets Sprawl
**Problem**: API keys were found committed in `vars.yml` and `terraform.tfvars`.
**Solution**:
1. Rotated all keys immediately.
2. Implemented **Ansible Vault** for config files.
3. Configured Terraform to pull secrets from AWS Secrets Manager at runtime.
4. Added `git-secrets` pre-commit hook to block future commits of high-entropy strings.
