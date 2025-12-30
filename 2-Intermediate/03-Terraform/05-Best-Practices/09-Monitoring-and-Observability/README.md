# Monitoring and Observability

Deploying infrastructure is only half the battle. You must also monitor its health and cost.

## 👁️ Key Areas

### 1. Cost Observability
Terraform is a "Money Printing Machine" for Cloud Providers. Use tools like **Infracost** to see the cost impact of your PR *before* merging.
```bash
# Infracost estimate in CI
infracost breakthrough --path .
```

### 2. Infrastructure Health
Integrate your Terraform modules with monitoring tools:
- **AWS**: Automatically create CloudWatch Alarms and Dashboards for every resource.
- **Datadog/New Relic**: Use their Terraform providers to manage monitors and alerts alongside the infrastructure.

### 3. Drift Detection
Standard monitoring doesn't catch "Drift" (manual changes).
- **Solution**: Schedule a daily `terraform plan` in your CI. If it detects a change (non-empty plan), send an alert to Slack/PagerDuty.

---

## 🏗️ Real-Life Scenario: The Silent DynamoDB Cost
**Problem**: A developer increases the Read Capacity Units on a DynamoDB table from 5 to 5,000 to "speed up a migration" and forgets to revert it.
**Outcome**: The monthly bill jumps by $2,000. 
**Detection**: The team didn't have cost monitoring. They only found out when the billing department called 30 days later.
**Fix**: Add `Infracost` to the CI pipeline. In the future, any change to capacity units will show the exact dollar impact in the Pull Request comment.

---

## ❓ Interview Questions
1.  **What is "Infrastructure Drift"?**
    *   *Answer*: It occurs when the real-world resources (e.g., in the AWS Console) have different settings than what is recorded in the Terraform code and state.
2.  **How do you monitor for drift automatically?**
    *   *Answer*: By running a scheduled `terraform plan` (e.g., every 6 hours). If the plan is not empty, it means drift has occurred.

---

## 🧠 Quiz Snippet (5/20+)
1.  **Which tool estimates cost changes in a PR?** (Infracost)
2.  **True/False: Monitoring should be managed as code.** (True)
3.  **What happens to a plan if there is no drift?** (It says "No changes. Your infrastructure matches the configuration.")
4.  **Which provider allows creating CloudWatch alarms?** (The `aws` provider)
5.  **Why is cost observability important for DevOps?** (To prevent "Shadow IT" and budget overruns)
