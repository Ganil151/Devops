# 💰 Infrastructure Cost Estimation (FinOps)

Automation isn't just about speed; it's about control. "FinOps" is the practice of bringing financial accountability to the variable spend model of cloud.

## 🛠️ Infracost
Infracost sits in your CI/CD pipeline (e.g., GitHub Actions) and estimates the cost impact of a Terraform Pull Request *before* you merge it.

### The Workflow
1.  **Engineer** opens a PR adding a "db.r5.24xlarge".
2.  **Infracost** runs `terraform plan`, calculates the cost diff (e.g., "+$4,000/month"), and posts a comment on the PR.
3.  **Manager** sees the cost and requests a change to a smaller instance.

## 🚀 The "DevOps Why": Shift Left on Cost
Just as we "Shift Left" on security (scanning code before deploy), we must "Shift Left" on cost. Catching a $10,000 mistake in the PR stage is free; catching it in the bill is expensive.
