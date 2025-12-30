# Code Organization

Professional Terraform projects follow a strict organizational structure to ensure scalability and ease of maintenance.

## The Standard Structure
For most production environments, a split between **Environments** and **Modules** is the gold standard.

```text
infrastructure/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── modules/
    ├── networking/
    ├── compute/
    └── database/
```

## Why Organize?
1.  **Blast Radius Reduction**: By separating environments (e.g., using different state files), a typo in `dev` cannot delete `prod`.
2.  **Logic Separation**: Keeping reusable logic in `modules/` and environment-specific values in `environments/` makes the code cleaner.
3.  **Concurrency**: Different teams can work on different directories without causing state lock conflicts.

## Project File Layout
Every directory should contain:
- `main.tf`: The primary resources.
- `variables.tf`: Input parameters.
- `outputs.tf`: Data for other modules.
- `backend.tf`: Remote state configuration.

---

## 🏗️ Real-Life Scenario: The "Giant File" Disaster
**Problem**: A startup puts their entire infrastructure—VPC, EKS, RDS, and IAM—into one single `main.tf` file.
**Crisis**: A developer tries to update an IAM policy. The `terraform plan` takes 15 minutes because it has to refresh 500 resources. They accidentally delete a comma, and the entire production environment goes down during the roll-forward.
**Solution**: Split the monolithic file. Move the VPC to a `networking` module. Move RDS to a `data` module. Now, `terraform plan` takes 30 seconds and only impacts the relevant component.

---

## ❓ Interview Questions
1.  **What is the benefit of separating environments into different directories instead of just using workspaces?**
    *   *Answer*: Separate directories allow for different backend configurations (e.g., different AWS accounts), distinct variables per environment, and a stronger security boundary.
2.  **What is a "Monolithic" Terraform configuration, and why should it be avoided?**
    *   *Answer*: It's a single directory managing all resources. It should be avoided because it leads to long execution times, large blast radii, and increased risk of state corruption.

---

## 🧠 Quiz Snippet (5/20+)
1.  **Which directory should contain environment-specific `.tfvars`?** (The environment sub-directory, e.g., `environments/prod/`)
2.  **True/False: You should put all your resources in `main.tf` for small projects.** (False - Standardize early to avoid refactoring later)
3.  **What is the primary goal of the "Modules" directory?** (Code reusability and abstraction)
4.  **How do you reduce the "Blast Radius"?** (By splitting state files across components and environments)
5.  **Which file should hold the `terraform {}` version block?** (`versions.tf` or `main.tf`)
