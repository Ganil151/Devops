# FinOps Cost Management Challenges 💰

Master the tools and strategies that turn "Cloud Billing" into "Cloud Economics."

---

## 🏆 Challenge 01: Infracost Integration
**Objective**: Prevent "Bill Shock" by checking costs before applying Terraform.

1.  **Requirement**: Setup a Terraform project with 10 EC2 `t3.large` instances.
2.  **Task**: Run `infracost breakdown --path .`
3.  **Observation**: Identify the monthly estimated cost.
4.  **Optimization**: Change the instance type to `t3.medium` and run the breakdown again.
5.  **Bonus**: Connect Infracost to a GitHub Pull Request to show "Cost Diff" in the comments.

---

## 🏆 Challenge 02: Kubecost Efficiency
**Objective**: Allocate Kubernetes expenses to specific teams.

1.  **Scenario**: Your EKS cluster costs $2,000/month. You have 3 namespaces: `billing`, `search`, and `frontend`.
2.  **Task**: Install **Kubecost** (via Helm).
3.  **Requirement**: Find the "Cost per Namespace" in the last 7 days.
4.  **Discovery**: Identify a pod that has "Requested" 2 CPUs but only "Uses" 0.01 CPUs.
5.  **Action**: Plan a "Rightsizing" strategy to reduce this waste.

---

## 🏆 Challenge 03: The Rightsizing Script
**Objective**: Automate cost reduction for non-production hours.

1.  **Scenario**: Dev instances stay on 24/7, costing money at night.
2.  **Task**: Write a Python/Boto3 script that finds all instances tagged `env: dev`.
3.  **Logic**: 
    *   **Stop**: Run at 8:00 PM.
    *   **Start**: Run at 8:00 AM.
4.  **Verification**: Test the script on a single demo instance.

---

## 📁 Solutions
Infracost YAML configs and rightsizing Python scripts are in the `Boilerplates/` directory.
