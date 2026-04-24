# 💰 Lab: Shifting Cost Left with Infracost

> **Scenario**: A developer submits a Pull Request changing an `m5.large` instance to an `r5.4xlarge`. 
> **The Problem**: This change costs an extra $800/month, but it goes unnoticed until the bill arrives 30 days later.
> **The Mission**: Integrate **Infracost** into GitHub Actions to comment the cost difference directly on the PR and fail the build if the cost spike is too high.

---

## 🏗️ The FinOps CI/CD Workflow

1.  **Developer** pushes code.
2.  **Infracost** parses the Terraform `plan`.
3.  **Infracost API** looks up current AWS pricing.
4.  **GitHub Action** posts a comment with the "Monthly Cost Delta."
5.  **Policy Engine** (OPA/JS) validates total cost against a budget.

---

## 🛠️ Step 1: The GitHub Action Template

```yaml
name: Infracost
on: [pull_request]

jobs:
  infracost:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Setup Infracost
        uses: infracost/actions/setup@v2
        with:
          api_key: ${{ secrets.INFRACOST_API_KEY }}

      - name: Generate Infracost JSON
        run: infracost breakdown --path . --format json --out-file /tmp/infracost.json

      - name: Post Cost Comment
        uses: infracost/actions/comment@v2
        with:
          path: /tmp/infracost.json
          behavior: update # Overwrite previous comments
```

---

## 🛠️ Step 2: Implementing a "Cost Guardrail" (Policy-as-Code)

We want to automatically **Fail** the CI if the increase is > $200.

```bash
# Script to run in CI
# USAGE: check_budget.sh <json_file> <limit>

COST_DIFF=$(cat /tmp/infracost.json | jq '.diffTotalMonthlyCost | tonumber')
LIMIT=200

if [ "$(echo "$COST_DIFF > $LIMIT" | bc)" -eq 1 ]; then
  echo "🚨 BUDGET EXCEEDED: Projected increase is \$$COST_DIFF, limit is \$$LIMIT"
  exit 1
fi
```

---

## 🛠️ Step 3: Optimization Suggestions

Infracost doesn't just report cost; it identifies **waste**.

### 🔍 Practical Optimization Wins:
- **GP2 to GP3**: Infracost will flag if you are using older EBS volumes and suggest GP3 for a 20% savings with zero performance loss.
- **NAT Gateway Scrutiny**: Flag if a developer is creating many NAT Gateways, suggesting VPC Endpoints instead.
- **Instance Generation Logic**: Suggest `m6i` (Intel) or `m6g` (Graviton) over older `m5` families.

---

## 🚨 Principal Architect Insights: "Don't Be a Cost Bottleneck"

- **Inform, Don't just Block**: The goal is to educate developers. If they see the cost in the PR, 90% of the time they will optimize it *before* you even review it.
- **The "Exception" Workflow**: Sometimes a $5k cost increase is technically necessary. Create a "FinOps Approval" label in GitHub that overrides the budget failure.
- **Focus on High-Impact Resources**: Don't worry about S3 bucket costs in the PR. Focus on the "Big Three": Compute (EC2/EKS), Databases (RDS), and Network (NAT/Data Transfer).

---
**Module**: FinOps & Cost Engineering
**Next Lab**: [Orchestrating Graviton & Spot Instances for 70% Savings](./spot-fleet-orchestration.md)
