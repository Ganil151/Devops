# 💰 Reference: Infracost Automation Keywords

Infracost is the cornerstone of **"Shift Left" FinOps**. It allows engineers to see cloud cost estimates before any infrastructure is actually provisioned. Understanding these keywords is essential for building cost-aware CI/CD pipelines.

---

## 🏗️ Core CLI Keywords

### `breakdown`
*   **Definition**: The primary command used to analyze a directory, plan file, or HCL code and output a full cost report.
*   **DevOps Why**: Used to get a baseline of current infrastructure costs or to analyze the total cost of a new project.

### `diff`
*   **Definition**: Compares the cost impact of code changes between two states (e.g., current branch vs. main).
*   **Keyword: `--compare-to`**: Points to a JSON file representing the baseline cost.
*   **DevOps Why**: This is the heart of PR automation. It shows exactly how much the bill will go up or down if the code is merged.

### `usage.yml`
*   **Definition**: A configuration file used to provide "usage-based" metrics (e.g., GB of data transferred, number of requests) that Infracost cannot determine from code alone.
*   **DevOps Why**: Critical for accurate estimates of Lambda, S3, and Data Transfer costs.

---

## 🛡️ Governance & Policy Keywords

### `Guardrails`
*   **Definition**: Automated checks that compare cost changes against predefined limits.
*   **DevOps Why**: Prevents "Sticker Shock" by blocking PRs that exceed a specific threshold (e.g., +$500/mo) without manual sign-off.

### `Policy-as-Code (PaC)`
*   **Definition**: Using a language like **Rego (OPA)** to write complex financial rules that go beyond simple price checks.
*   **Example**: "No instance types larger than `m5.large` allowed in Dev environment."

---

## 🎙️ Staff Interview Context

*   **"Why is Infracost better than standard Cloud Billing Alerts?"**
    *   *Answer*: Billing alerts are **Reactive**—you find out *after* you've spent the money. Infracost is **Proactive**—you find out *before* the money is spent, while it's still just a line of code in a Pull Request.
*   **"How do you handle 'Elastic' costs that depend on traffic?"**
    *   *Answer*: Infracost uses a `usage.yml` file. We can automate the population of this file by pulling actual metrics from CloudWatch or Datadog, or by using "worst-case" assumptions to ensure our guardrails are safe.
*   **"Does Infracost require AWS/Azure/GCP credentials to run?"**
    *   *Answer*: No. It parses the **HCL (Terraform)** or the **Plan File**. It only needs an Infracost API key to fetch current pricing data from the Infracost Cloud Pricing API.
