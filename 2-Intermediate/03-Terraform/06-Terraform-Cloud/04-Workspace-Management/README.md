# Workspace Management

An HCP Terraform Workspace is far more than just a state file. It is a complete operational environment.

## Anatomy of a Workspace
1.  **State**: Managed and versioned automatically. You can view every historical version.
2.  **Run History**: Log of every plan and apply ever performed.
3.  **Variables**: Terraform (.tf) and Environment (e.g., AWS keys) variables.
4.  **Settings**: Execution mode (Local vs. Remote), Workspace name, and VCS link.
5.  **Output**: Visible in the UI for easy copy-pasting or consumption by other workspaces.

## Execution Modes
- **Remote (Default)**: Runs happen on HashiCorp runners. Highly recommended for teams.
- **Local**: TFC only stores the state. Runs happen on your computer (Manual and risky).

## Workspace Health
- **Locked**: A workspace is locked during a run to prevent corruption.
- **Drifted**: Indicates a difference between code and reality (if Drift Detection is on).
- **Errored**: The last run failed.

---

## 🏗️ Real-Life Scenario: The Forensic Audit
**Problem**: An auditor asks why the staging environment was deleted 3 months ago.
**Solution**: The team goes to the `aws-staging` workspace in TFC and looks at the **Run History**. They find a run from August 12th titled "Decommission Staging." They can see exactly which user started the run, the exact code used, and the logs of the destruction.
**Result**: Immediate compliance proof.

---

## ❓ Interview Questions
1.  **How is a TFC Workspace different from a Terraform CLI Workspace?**
    *   *Answer*: A CLI workspace is just a separate state file. A TFC workspace includes state, variables, run history, permissions, and VCS integration—it's a full management environment.
2.  **Can you see the past versions of a state file in the TFC UI?**
    *   *Answer*: Yes, under the "States" tab, TFC keeps a history of every state change, allowing you to download or compare previous versions.

---

## 🧠 Quiz Snippet (5/50+)
1.  **Where do you find the logs of all previous deployments?** (Run History)
2.  **True/False: A workspace can be shared between two different Organizations.** (False)
3.  **What happens when a run is in progress?** (The workspace is "Locked")
4.  **Which tab shows the values produced by your Terraform code?** (Outputs)
5.  **Can you rename a workspace without losing the state?** (Yes)
