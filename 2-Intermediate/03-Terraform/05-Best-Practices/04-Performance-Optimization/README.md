# Performance Optimization

As infrastructure grows, Terraform can become slow. Optimization ensures fast deployments and lower API costs.

## Optimization Techniques

### 1. Incremental deployments
Instead of running a full `apply`, use `-target` in emergencies (use with caution!) or split your code into smaller state files.

### 2. Provider Caching
If you have a slow internet connection, set `plugin_cache_dir` in your `.terraformrc`. This avoids downloading the same providers repeatedly.

### 3. Refreshing vs. Not Refreshing
- **Default**: `terraform plan` refreshes the state of every resource by calling the cloud API.
- **Fast**: `terraform plan -refresh=false`. This assumes the state file is perfect (risky but fast for large environments).

### 4. Parallelism
By default, Terraform runs 10 operations concurrently. Increase this for massive environments.
`terraform apply -parallelism=30`

---

## 🏗️ Real-Life Scenario: The 45-Minute Plan
**Problem**: An enterprise managed 5,000 S3 buckets in one project. Every time someone wanted to change one bucket, the `terraform plan` took 45 minutes because AWS rate-limited the API calls.
**Solution**: They split the project by "Department." Each department got its own state file.
**Outcome**: Plan time dropped from 45 minutes to 2 minutes.

---

## ❓ Interview Questions
1.  **How do you handle API rate limiting from a cloud provider?**
    *   *Answer*: Sub-divide your state files into smaller units, use `-refresh=false` when appropriate, and increase the intervals between CI/CD runs.
2.  **What is the `plugin_cache_dir` and why is it useful?**
    *   *Answer*: It's a directory on your machine that stores downloaded providers. This makes `terraform init` significantly faster and reduces bandwidth usage.

---

## 🧠 Quiz Snippet (5/20+)
1.  **What is the default parallelism value?** (10)
2.  **True/False: Higher parallelism is always better.** (False - it can trigger API rate limits)
3.  **Which flag skips the API check during a plan?** (`-refresh=false`)
4.  **Can you speed up `terraform init`?** (Yes, using a plugin cache)
5.  **What is the "Blast Radius" reason for splitting state?** (To ensure a failure in one area doesn't stall the whole system)
