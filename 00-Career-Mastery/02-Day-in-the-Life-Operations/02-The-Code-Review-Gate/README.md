# 🛡️ Simulation: The Code Review Gate

In DevOps, we are the **Guardians of the State**. Deploying bad infrastructure is much more expensive than deploying bad code. 

Your task is to review a teammate's Terraform PR and find the "Staff Standard" violations.

---

### 📂 Files in this Simulation:
1.  **[bad.tf](./bad.tf)**: The "Junior" approach. Full of security holes and hardcoded values.
2.  **[solution.tf](./solution.tf)**: The "SRE" approach. Standardized, secure, and modular.

---

### 🕵️ Your Code Review Checklist:
When reviewing IaC, always look for:
- [ ] **Exposure**: Are any ports open to `0.0.0.0/0` (The entire world)?
- [ ] **Hardcoding**: Are there secrets (API keys) or specific IDs (VPC IDs) baked into the code?
- [ ] **Naming**: Does it follow a convention (`company-env-service`)?
- [ ] **Persistence**: Is there a deletion protection policy on databases?

---

### 🚨 The "Bad" Code Analysis
Open `bad.tf`. You will notice:
*   **Security Risk**: Hardcoded AWS credentials. **NEVER do this.** Use IAM Roles or Environment Variables.
*   **Network Risk**: SSH (Port 22) is open to the entire internet. This is a magnet for brute-force attacks.
*   **Maintenance Risk**: Everything is hardcoded. If you want to deploy to "Staging" instead of "Dev," you have to rewrite the whole file.

---

### ✅ The "SRE" Upgrade
Now open `solution.tf`. Observe the improvements:
*   No credentials. It assumes an IAM context.
*   Port 22 is restricted to a specific `Management-VPC` CIDR.
*   Uses **Variables** and **Locals** for easier environment switching.
