# SOP Anatomy and Structure

A consistent structure acts as a "mental map," allowing an engineer to find the right information in seconds, even while panicked.

## The Standard Blueprint

### 1. Metadata (The Context)
- **Title**: Clear, searchable, and action-oriented.
- **Owner**: The specific team responsible for the service.
- **SLO Impact**: Which metric does this affect? (e.g., "Uptime").

### 2. Prerequisites (The 'Before You Start' List)
- **Access**: IAM roles, VPN connection, or SSH keys.
- **Tools**: Required software versions (e.g., `Terraform 1.5+`).
- **Safety Warning**: "CAUTION: This procedure will restart production traffic."

### 3. Verification (The 'Is it broken?' Check)
- Proof that the problem exists (e.g., a link to a failing CloudWatch alarm).

### 4. Remediation (The 'Meat')
- **Numbered Steps**: Linear, atomic actions.
- **Code Blocks**: Copy-pasteable commands.
- **Expected Output**: "You should see `Success` in the console."

### 5. Resolution Verification (The 'Is it fixed?' Check)
- How to prove the change worked.

### 6. Rollback (The 'Emergency Exit')
- How to undo the changes if things go wrong.

---

## 🏗️ Real-Life Scenario: The "Missing Step" Chaos
**Problem**: An SOP for "Rotating API Keys" forgotten to mention that the old keys must be disabled *after* the new ones are confirmed.
**Crisis**: An engineer follows the guide, adds new keys, but leaves the old compromised keys active. The hacker continues the attack.
**Outcome**: A security breach that could have been prevented with a clearer "Verification" section.
**Fix**: Add an "Audit Verification" step to the SOP template to ensure all old credentials are destroyed.

---

## ❓ Interview Questions
1.  **What is the 'Anatomy' of a typical SOP in your experience?**
    *   *Answer*: It usually includes Context/Metadata, Prerequisites, the Step-by-Step Remediation, a Verification check, and a Rollback plan.
2.  **Why is a 'Rollback' section mandatory for production SOPs?**
    *   *Answer*: Because even a "proven" fix can have unexpected side effects. A rollback plan provides an immediate path to safety, preventing "Action Bias" from making an incident worse.

---

## 🧠 Quiz Snippet (5/50+)
1.  **Which section lists the required IAM permissions?** (Prerequisites)
2.  **True/False: You should put the history of the project in the Remediation section.** (False)
3.  **Why include 'Expected Output' after a command?** (To prevent errors and confirm progress)
4.  **What is 'Metadata'?** (Data about the document, such as title, owner, and links)
5.  **Should an SOP include a link to the monitoring dashboard?** (Yes, in the Metadata or Verification sections)
