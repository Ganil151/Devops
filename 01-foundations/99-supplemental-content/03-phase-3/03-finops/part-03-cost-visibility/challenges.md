# Cost Visibility & Tagging Challenges 👁️

Put your financial governance skills to the test with these real-world FinOps simulation tasks.

---

## 🏆 Challenge 01: Designing the Enterprise Schema
**Objective**: Create a tagging standard that supports team-based chargeback.

1.  **Requirement**: Design a 10-tag "Golden Schema."
2.  **Constraint**: Include at least 3 categories: `Financial` (for budgets), `Technical` (for maintenance), and `Security` (for data sensitivity).
3.  **Task**: Write down the keys and example values (e.g., `data-class: pii`).
4.  **Verification**: Compare your schema against the "Global Tagging Standard" table in the `README.md`.

---

## 🏆 Challenge 02: Audit and Enforcement (CLI)
**Objective**: Find the "Ghost" resources that are draining your budget.

1.  **Simulation**: Imagine you have 500 EC2 instances. You need to find all instances that are **Missing** the `team` tag.
2.  **Research Task**: Find the AWS CLI command (using `--query` and `-filter`) to list resources without a specific tag key.
3.  **Action**: Draft a one-liner script that would output the IDs of these non-compliant resources.

---

## 🏆 Challenge 03: The Showback Report
**Objective**: Communicate value to stakeholders.

1.  **Scenario**: Your "Platform Team" spent $1,200 last month. $400 of that was on "Shared DB Hosting" used by the "Mobile Team" and the "Web Team."
2.  **Task**: Create a simple ASCII or Markdown table showing a **Showback** report.
3.  **Calculation**: Perform a "Proportional Split" assuming the Mobile Team uses 70% of the DB resources.
4.  **Goal**: Explain to the Mobile Team Lead why their part of the bill is higher.

---

## 📁 Solutions
Policy templates and reporting examples are found in the `Boilerplates/` directory.
