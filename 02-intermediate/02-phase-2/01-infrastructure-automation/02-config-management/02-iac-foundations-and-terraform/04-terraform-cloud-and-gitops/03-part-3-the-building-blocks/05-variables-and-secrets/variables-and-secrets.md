![TFC Architecture](../../01-part-1-the-blueprint/01-introduction-and-architecture/tfc-architecture.png)
In a collaborative environment, managing credentials, API keys, and configuration toggles is a major security challenge. HCP Terraform centralizes this through **<font color="#92d050">Secure Variables</font>**, ensuring that sensitive data never touches a developer's local disk or Git history.

---
## 🏗️ 1. Understanding Variable Categories
HCP Terraform categorizes variables into two distinct types based on how they interact with the Terraform process.
### Category Comparison
| Category | Purpose | Injection Mechanism | Example |
| :--- | :--- | :--- | :--- |
| **Terraform Variables** | Populate your `variables.tf` inputs. | Passed via `-var` flags internally. | `instance_count`, `environment` |
| **Environment Variables** | Configure the runner shell. | Set as OS env vars (e.g., `export AWS...`). | `AWS_REGION`, `TF_LOG` |
### The "<font color="#ff0000">Sensitive</font>" Shield
Any variable can be marked as **Sensitive**. 
- **Encryption at Rest**: Values are encrypted using HashiCorp Vault internally.
- **Write-Only UI**: Once saved, the value is invisible in the UI (showing only `*****`).
- **Log Redaction**: HCP Terraform's runner scans stdout/stderr and attempts to redact sensitive values if they are accidentally printed.

---
## 🔄 2. Variable Sets: The DRY Protocol
Managing variables one-by-one for 100 workspaces is impossible. **Variable Sets** allow you to group common configurations and apply them at scale.
### Scoping & Precedence
Variable sets can be applied at three different levels, with the most specific always taking precedence:
1.  **Workspace Specific**: Unique to one environment (Highest Precedence).
2.  **Project Level**: Shared by all workspaces in a specific Project (e.g., all "Payments" apps).
3.  **Global / Organization Level**: Applied to every workspace in the entire Org (e.g., corporate proxy settings).
**Rule**: If `var.region` is defined in both a Global Set and a Workspace, the **Workspace value** wins.
---
## 🛡️ 3. Modern Pattern: Dynamic Provider Credentials (OIDC)
**Rule**: The best secret is the one you never have to store.
Instead of storing long-lived static AWS/Azure keys (which are prone to leakage), use **OIDC (OpenID Connect)**.
### The OIDC Handshake
1.  **Identity Request**: The HCP Terraform runner requests a JWT (JSON Web Token) from TFC.
2.  **Verification**: The runner sends this JWT to the Cloud Provider (e.g., AWS IAM).
3.  **Credential Grant**: AWS verifies the TFC identity and returns short-lived (1 hour) credentials.
4.  **Execution**: The runner uses these temporary keys for the apply and then discards them.

---
## 🚀 4. Real-Life Scenarios

### Scenario 1: The "90-Day Rotation" Nightmare
*   **The Problem**: Security policy requires rotating 50 different service account keys every quarter.
*   **The HCP Solution**: The keys are stored in a **Variable Set**. The administrator updates the values in one place (the Variable Set UI).
*   **Outcome**: All 50 workspaces pick up the new keys on their next run without a single manual change to the individual workspaces.
### Scenario 2: The Plain-Text Leak
*   **The Problem**: A developer accidentally printed a private SSH key to the console because they forgot to mark the variable as sensitive.
*   **The HCP Solution**: The team rotated the SSH key immediately. They then configured **HCP Terraform Sentinel** policies to block any code that includes `sensitive = false` on variables named `*key` or `*password`.
*   **Outcome**: Automated governance now prevents the mistake from happening again.
### Scenario 3: Global Cost Center Enforcement
*   **The Problem**: Cloud bills are spiraling because 30% of resources are untagged.
*   **The HCP Solution**: A **Global Variable Set** was created with a required `var.cost_center`.
*   **Outcome**: Every workspace in the organization was forced to acknowledge this variable. Combined with a policy check, no infrastructure can be created without a valid cost center tag.

---

## ❓ 5. Interview Questions (Expert Deep Dive)

1.  **Can you retrieve the value of a sensitive variable via the HCP Terraform API?**
    <details>
    <summary>Show Answer</summary>
    **No**. The API will return `null` or a placeholder for the value. Sensitive variables are strictly "write-only." If you lose the password, you must overwrite it with a new one; you cannot recover the old one from the platform.
    </details>

2.  **What is the "HCL" vs. "Plain" variable toggle in the UI?**
    <details>
    <summary>Show Answer</summary>
    - **Plain**: The value is treated as a literal string (e.g., `db_user = "admin"`).
    - **HCL**: The value is parsed as HCL code. This allows you to pass complex types like Lists, Maps, or even entire Objects (e.g., `["us-east-1", "us-west-2"]`) directly through the UI.
    </details>

3.  **Explain how variable precedence works when using multiple Variable Sets.**
    <details>
    <summary>Show Answer</summary>
    If multiple Variable Sets contain the same variable, the most specific scope wins (Workspace > Project > Global). If two sets at the same scope (e.g., two Global sets) conflict, the behavior is undefined/error-prone, and TFC will warn you about the collision.
    </details>

4.  **What is the `TFC_` prefix for environment variables?**
    <details>
    <summary>Show Answer</summary>
    The prefix `TFC_` (e.g., `TFC_AWS_PROVIDER_AUTH`) is reserved for configuring HCP Terraform's internal behavior, such as enabling OIDC authentication or setting up private agents.
    </details>

5.  **How do you handle multiline secrets, like an RSA Private Key?**
    <details>
    <summary>Show Answer</summary>
    You can paste the multiline string directly into the value field in the TFC UI. HCP Terraform preserves the newlines correctly. For automation, you can use the `tfe` provider and the `heredoc` syntax in HCL to maintain formatting.
    </details>

---

## 🧠 6. Knowledge Check (Quiz)

### Management & Security
1.  **To encrypt a database password in the UI, you check the:**
    - [ ] Encrypt box.
    - [x] **Sensitive** box.
2.  **Environment Variables are used primarily to:**
    - [ ] Pass list variables to code.
    - [x] Configure Provider credentials (AWS/Azure/GCP).
3.  **A "Global" Variable set is visible to:**
    - [ ] Only the admin who created it.
    - [x] **Every workspace** in the organization.

### Logic & Scoping
4.  **Values marked as HCL in the UI are:**
    - [x] Parsed as Terraform code (allowing Lists/Maps).
    - [ ] Treated as raw text.
5.  **If you update a Variable Set, which runs are affected?**
    - [ ] All currently running plans.
    - [x] **Only future runs** triggered after the update.
6.  **OIDC authentication removes the need for:**
    - [ ] Terraform code.
    - [x] **Static Access Keys** (long-lived secrets).

---

## 📖 7. Summary & Best Practices

**Best Practices:**
- ✅ **Default to Sensitive**: If it's a password, token, or key, mark it sensitive immediately.
- ✅ **Use Variable Sets early**: Don't wait until you have 100 workspaces; start grouping credentials as soon as you have two.
- ✅ **Prefer OIDC**: Stop storing static AWS/Azure keys; use dynamic trust relationships.
- ✅ **HCL for Complex Types**: Use the HCL toggle for maps and lists to keep your code flexible.
- ✅ **Name consistently**: Use prefixes like `GLOBAL_` or `APP_` in your variable sets for easier identification.
---
**Module Status**: ✅ Comprehensive Verified
**Last Updated**: 2026-01-08
