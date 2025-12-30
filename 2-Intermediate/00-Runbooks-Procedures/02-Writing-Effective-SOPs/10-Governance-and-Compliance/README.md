# Governance and Compliance

In high-stakes industries (Banking, Healthcare, Defense), an SOP isn't just a "good idea"—it is a legal requirement.

## 1. The Review Cycle
Documentation "rots" over time as the system evolves.
- **Policy**: Every SOP must be reviewed and re-approved every 6 months.
- **Automation**: Use a script to crawl the `LastReviewed` date in metadata and open a Jira ticket for the owner when it's due.

## 2. Segregation of Duties (SoD)
The person who creates the infrastructure should not be the *only* one who approves the documentation for it. This ensures a "second pair of eyes" for both the code and the process.

## 3. Secret Management
**NEVER** put passwords, API keys, or private SSH keys in an SOP.
- **Bad**: "Step 1: Set password to `Admin123!`."
- **Good**: "Step 1: Retrieve the database password from Vault using path `secret/prod/db/root`."

## 4. Audit Trails
In an audit, you must prove that people are actually following the procedures.
- **Evidence**: Link Git commit hashes of your SOPs to the corresponding Incident Tickets in ServiceNow or Jira.

---

## 🏗️ Real-Life Scenario: The $2M Audit Failure
**Problem**: An auditor asks a Fintech company for the "Disaster Recovery" plan. They provide an SOP. The auditor points to a line that says "Use the Admin password from Bob's drawer."
**Outcome**: Immediate compliance failure. Bob hasn't worked at the company for 2 years, and the safe was deleted. The company loses a primary banking license for 2 months. 
**Fix**: Implement a **Secret Management Policy** for documentation and an automated **Review Audit**. 
**Outcome**: All credentials are now in HashiCorp Vault, and the auditor is satisfied that the docs are "Living and Secure."

---

## ❓ Interview Questions
1.  **How do you prevent sensitive information (secrets) from leaking into your documentation?**
    *   *Answer*: Through a combination of training (policies against it), secret scanning tools (like TruffleHog) in the CI pipeline, and the use of 'Reference-Based' instructions (referring to a Secret Manager rather than writing the key).
2.  **What is 'Documentation Rot' and how do you fight it at scale?**
    *   *Answer*: It's the obsolescence of documentation as systems change. Fight it by making doc updates part of the 'Definition of Done' for every feature, using 'Last Reviewed' metadata, and conducting regular Gameday tests.

---

## 🧠 Final Module Quiz (5/50+)
1.  **How often should a critical SOP be reviewed?** (Every 6-12 months)
2.  **True/False: It is okay to put 'Temporary' secrets in documentation.** (False)
3.  **What is 'Segregation of Duties' (SoD)?** (Requiring multiple people to complete a control task)
4.  **What tool proves 'Who' changed a document?** (Git History / Blame)
5.  **What is an 'Audit Trail'?** (A chronological record of changes and approvals)
