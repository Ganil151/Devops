# Advanced Features

HCP Terraform includes enterprise-grade features that go beyond simple deployment.

## 1. Private Module Registry
- **Standardization**: Publish your own pre-approved modules (e.g., `acme-vpc`) for internal use.
- **Versioning**: Teams can upgrade to new versions of your internal modules at their own pace.
- **No-Code Provisioning**: Allows non-technical teams to deploy infrastructure via a simple UI form.

## 2. Drift Detection
- **Constant Monitoring**: TFC periodically (e.g., every 30 mins) runs a silent plan in the background.
- **Alerting**: If reality doesn't match the code, the workspace state changes to "Drifted" and sends an alert.

## 3. Cost Estimation
- **Pre-Apply Insight**: Shows exactly how many dollars your monthly cloud bill will increase *before* you click Apply.
- **Policy Link**: You can write a Sentinel policy that blocks an apply if the monthly cost increase is more than $100.

## 4. Run Tasks
- **Extensibility**: Connect 3rd party tools (like Snyk for security, Infracost for pricing, or Bridgecrew for compliance) to your TFC pipeline. They run alongside Policy as Code.

---

## 🏗️ Real-Life Scenario: The "Nightmare" Consultant
**Problem**: A consultant is hired to fix a network issue. They log into the Azure Portal and "Temporarily" open port 22 (SSH) to the entire world. They forget to close it.
**Solution**: HCP Terraform has **Drift Detection**. 30 minutes later, TFC detects the unauthorized firewall change and sends a message to the SRE Slack channel: "Workspace 'Prod-Network' has drifted." 
**Outcome**: The team sees the change and runs an `apply` to overwrite the manual hack, closing the port within an hour.

---

## ❓ Interview Questions
1.  **What is "Drift" in the context of IaC?**
    *   *Answer*: Drift occurs when the state of real-world resources (managed by the cloud provider) differs from the state recorded in the Terraform code/state file, usually due to manual console changes.
2.  **How does Cost Estimation work in HCP Terraform?**
    *   *Answer*: TFC analyzes the plan, identifies the resources being created/modified, and cross-references those with a database of cloud provider prices to show the estimated monthly cost impact.

---

## 🧠 Quiz Snippet (5/50+)
1.  **Which feature helps share internal approved code?** (Private Module Registry)
2.  **True/False: Cost estimation can block a run by itself.** (False - it requires Policy as Code to block based on price)
3.  **What is the purpose of "Run Tasks"?** (Integrating 3rd party external tools into the TFC workflow)
4.  **Can TFC fix drift automatically?** (No, but it alerts you so you can manually trigger an 'apply' to fix it)
5.  **Which TFC tier usually includes Drift Detection?** (Standard / Plus / Enterprise)
