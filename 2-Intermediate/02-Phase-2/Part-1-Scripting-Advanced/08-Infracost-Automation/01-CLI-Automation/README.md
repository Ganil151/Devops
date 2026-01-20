# Infracost CLI Automation

Automation starts with the CLI. Before you put it in a pipeline, you need to understand how to script the binary.

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `cost_diff.sh` (Comparing infra changes).
- **[CHALLENGES](./CHALLENGES.md)**: Parsing JSON cost outputs.

---

## 🔑 Key Commands

| Command | Action |
| :--- | :--- |
| **`infracost breakdown`** | Show full cost estimate for a Terraform directory. |
| **`infracost diff`** | Compare the current state vs a saved JSON state (Delta). |
| **`infracost output`** | Convert results to specific formats (HTML, Markdown, Slack). |

---

## 🏗️ Robust Pattern: The Diff Loop
When automating at scale, you want to compare your current PR against the "Master" branch cost.

```bash
# 1. Capture base cost
infracost breakdown --path main_branch/ --format json --out-file base.json

# 2. Capture PR cost
infracost breakdown --path pr_branch/ --format json --out-file pr.json

# 3. Create a human-readable diff
infracost diff --path pr.json --compare-to base.json
```

---

## 📖 Real-World Story: The "Accidental Metal"
A developer tried to test a large database migration and switched the instance type to `m5.metal` ($4/hour). They forgot to switch it back.
**Automation**: A weekly cron job ran `infracost breakdown` on all production repos and emailed the total monthly estimate.
**Result**: The team noticed the $3,000/month spike on Monday morning before the bill arrived.

---

## ❓ Interview Questions
1. **How is Infracost different from AWS Budgets?**
   - *Answer*: AWS Budgets are "Reactive" (alerting after money is spent). Infracost is "Proactive" (estimating before money is spent).
2. **Does Infracost need your AWS credentials?**
   - *Answer*: No, it parses your Terraform HCL locally. It only needs an API key to fetch the current prices from the Infracost Cloud Pricing API.

---

[Next: GitHub Actions](../02-GitHub-Actions-Integration/README.md)
