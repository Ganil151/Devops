# 🚨 The Emergency Manual: Rollback Procedures

When a deployment goes wrong, your first job isn't to find the bug—it's to **stop the bleeding**. Recovery comes before Root Cause Analysis (RCA).

---
### 1. The "Git" Panic Button
If a bad configuration was committed and pushed:
```bash
# Finds the last stable commit and creates a new commit that undoes the bad changes
git revert HEAD

# Push the fix immediately
git push origin main
```
*   **Why?** This preserves history and doesn't "break" the branch for your teammates.

---

### 2. The "Helm" Undo (Kubernetes)
If you just deployed a broken version of an app to K8s via Helm:
```bash
# Check the history of the release
helm history my-app

# Roll back to the previous stable revision (e.g., revision 5)
helm rollback my-app 5
```
*   **Why?** Helm rollbacks are near-instant and handle the pod replacement automatically.

---
### 3. The "Terraform" State Rescue
If an infrastructure change triggered an outage (e.g., accidentally deleted a subnet):
```bash
# Option A: Revert your code to the previous Git commit, then apply
git revert <commit_id>
terraform apply

# Option B: Use the 'State' backup if applicable (Advanced)
# Search your S3 backend for the previous version of 'terraform.tfstate'
```

---
### 💡 Pro-Tip: The "Golden Rule" of Rollbacks
**Never try to 'Fix-Forward' during a Tier 1 outage.** 
If the site is down, don't try to write a patch and deploy it. **Roll back** to the last known good state first. Once the users are happy again, *then* you can debug and fix the code properly on your own time.