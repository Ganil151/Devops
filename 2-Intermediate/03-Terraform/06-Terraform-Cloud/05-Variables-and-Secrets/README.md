# Variables and Secrets

Managing secrets in plain text `tfvars` files is manageable for 1 developer, but dangerous for 50. TFC centralizes credentials securely.

## 1. Variable Categories

TFC distinguishes between two types of variables:

| Type | Purpose | Example |
| :--- | :--- | :--- |
| **Terraform Variables** | Inputs to your code (usually defined in `variables.tf`). | `instance_force = "t3.micro"` |
| **Environment Variables** | Shell env vars needed by the provider or scripts. | `AWS_ACCESS_KEY_ID`, `TF_LOG` |

---

## 2. Variable Sets (The 'DRY' Solution)

Imagine you have 50 workspaces that all need the same AWS Credentials.
*   **Old Way**: Copy-paste credentials 50 times into each workspace. (Nightmare to rotate keys).
*   **New Way**: Create a **Variable Set**.
    1.  Create Set "AWS Production Credentials".
    2.  Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.
    3.  Apply this Set to "All workspaces with tag `env:prod`".

Now, rotating keys means updating **one** place.

---

## 3. The Hierarchy of Injection

When TFC runs, it stomps variables on top of each other. Order matters!

```mermaid
graph TD
    Project[Variable Set (Global)] --> Org[Variable Set (Org-Wide)]
    Org --> Workspace[Workspace Specific Variables]
    Workspace --> Run[Run-Specific (API only)]
    
    style Run fill:#f96,stroke:#333
    style Workspace fill:#9f6,stroke:#333
```
*   **Rule**: More specific overrides less specific. A Workspace Variable overwrites a Global Variable Set.

---

## 4. Security & Sensitive Values

*   **Write-Only**: If you mark a variable as "Sensitive", TFC encrypts it. You can **never** see the value again in the UI (it shows as `*****`).
*   **Output Redaction**: Use `sensitive = true` in your Terraform `outputs.tf`. TFC respects this and hides the value in the UI/Logs.

---

## 5. Real-Life Scenarios

### Scenario 1: "Rolling Keys"
**Problem**: Security demands AWS keys be rotated every 90 days. You have 200 workspaces.
**Old Way**: 2 days of manual copy-pasting.
**New Way**: Update the **Global Variable Set**. All 200 workspaces pick up the new key on their next run instantly.

### Scenario 2: "The Leaked Token"
**Problem**: A developer printed a Datadog API Key to the console using `output "key" { value = var.dd_key }`.
**Consequence**: The key was visible in the TFC UI logs to anyone with read access.
**Fix**: Marked the Output as `sensitive = true`. Now TFC displays `(sensitive value)` in the UI.

### Scenario 3: "Standardizing Tags"
**Problem**: Every workspace needs a `CostCenter` tag, but people keep making typos (`cost-center`, `Cost_Center`).
**Fix**: Created a Variable Set called "Standard Tags" containing a Terraform Map variable `standard_tags`.
*   Code: `tags = merge(var.standard_tags, local.tags)`
*   Enforced consistency across the organization.

---

## 6. ❓ Interview Questions

1.  **What is the difference between `TF_VAR_name` and a Terraform Variable?**
    *   **Answer**: `TF_VAR_name` is an Environment Variable that Terraform CLI automatically reads to populate the input variable `var.name`. In TFC, you usually just set a "Terraform Variable" directly in the UI.

2.  **Can you retrieve a Sensitive variable via API?**
    *   **Answer**: No. The API returns `null` or a placeholder for sensitive values. They are write-only.

3.  **If I update a Variable Set, does it trigger a run?**
    *   **Answer**: No. It only affects the *next* run. You must manually trigger runs if you need the new value to take effect immediately.

4.  **Can Variable Sets be scoped to specific projects?**
    *   **Answer**: Yes, TFC Projects (in the new hierarchy) support Project-scoped Variable Sets.

5.  **How do you handle `*.tfvars` files in TFC?**
    *   **Answer**: TFC generally ignores local `*.tfvars` files unless you use the CLI-driven workflow. In VCS workflow, the UI Variables replace `tfvars` files.

6.  **Does TFC support `GOOLE_CREDENTIALS` (JSON)?**
    *   **Answer**: Yes, but since it contains newlines, you must remove the newlines (make it single line) or careful copy-pasting to ensure TFC handles the multiline string correctly.

7.  **What is the priority if both a Var Set and a Workspace override the same variable?**
    *   **Answer**: The Workspace variable wins (Specific beats Generic).

8.  **Can I delete a Variable Set that is in use?**
    *   **Answer**: Yes, but it immediately strips those variables from all associated workspaces, likely causing the next plan to fail.

9.  **How do dynamic credentials (OIDC) work with Variables?**
    *   **Answer**: Instead of static `AWS_ACCESS_KEY_ID` variables, you set `TFC_AWS_PROVIDER_AUTH = true` and configure OIDC trust between TFC and AWS, removing the need for long-lived secret variables entirely.

10. **Why are Environment Variables needed for AWS Provider?**
    *   **Answer**: The AWS Provider automatically looks for `AWS_...` env vars to authenticate. You don't need to define `variable "aws_access_key" {}` in your code if you use Env Vars.

---

## 7. 🧠 Knowledge Check (Quiz)

### Configuration
1.  **To pass credentials to the AWS Provider, use:**
    *   [x] Environment Variables (`AWS_ACCESS_KEY_ID`).
    *   [ ] Terraform Variables.

2.  **Variable Sets reduce:**
    *   [x] Duplication (DRY).
    *   [ ] Cost.

3.  **Sensitive variables are visible in the UI:**
    *   [x] Never (`*****`).
    *   [ ] To Admins only.

4.  **If you delete a variable set:**
    *   [x] All linked workspaces lose those variables.
    *   [ ] TFC creates a backup.

### Priority & Scoping
5.  **Which has highest precedence?**
    *   [x] Workspace-specific variable.
    *   [ ] Global Variable Set.

6.  **Can you apply a Variable Set to specific workspaces?**
    *   [x] Yes.
    *   [ ] No, it's all or nothing.

7.  **Variable Sets work for:**
    *   [x] Both Env Vars and Terraform Vars.
    *   [ ] Only Env Vars.

8.  **Updating a variable triggers a run:**
    *   [x] False.
    *   [ ] True.

9.  **`TF_VAR_my_var` is an example of:**
    *   [x] An Environment Variable mapping to a Terraform Input.
    *   [ ] A syntax error.

10. **Global Variable Sets apply to:**
    *   [x] Every workspace in the Organization.
    *   [ ] Only new workspaces.

### Scenarios
11. **Best practice for AWS Keys:**
    *   [x] Use Dynamic Credentials (OIDC) or rotate static keys in a Var Set.
    *   [ ] Hardcode in `main.tf`.

12. **To enforce a standard naming prefix across all apps:**
    *   [x] Use a Global Variable Set with `prefix`.
    *   [ ] Email all developers.

13. **If a variable is "Sensitive" but you output it in plaintext:**
    *   [x] Terraform prints it (unless output is also `sensitive=true`).
    *   [ ] TFC automatically hides it.

14. **Multiline variables (like SSH Keys):**
    *   [x] Are supported by TFC.
    *   [ ] Must be base64 encoded.

15. **To use a different region for one specific workspace:**
    *   [x] Override the `AWS_REGION` variable in that workspace settings.
    *   [ ] Create a new Organization.

### General
16. **Are variables encrypted at rest?**
    *   [x] Yes, always.
    *   [ ] Only sensitive ones.

17. **Can you update variables via API?**
    *   [x] Yes (`tfe_variable`).
    *   [ ] No.

18. **The `TFC_` prefix is reserved for:**
    *   [x] TFC internal configuration (e.g., Agents, OIDC).
    *   [ ] User variables.

19. **If you lose the value of a sensitive variable:**
    *   [x] You must generate a new one (you can't retrieve the old one).
    *   [ ] Ask HashiCorp support.

20. **Variable Sets are available in:**
    *   [x] Free Usage Tier (Global/Workspace scope).
    *   [ ] Enterprise Only.
