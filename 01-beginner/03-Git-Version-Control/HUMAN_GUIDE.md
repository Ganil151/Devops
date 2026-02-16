# 🛠️ 03: Git Version Control (The Time Machine of Code)

> **"Git is like a video game save point. If you mess up the boss fight (production deployment), you can just load your last save and try again."**

In modern DevOps, **Git is the Source of Truth**. We don't just store code in Git; we store our infrastructure (Terraform), our configurations (YAML), and our pipelines (GitHub Actions). If it’s not in Git, it doesn't exist.

---

## 🗺️ The Narrative: Your Journey

### Phase 1: The Three States (Workspace, Index, Repository)
Git tracks files in three places.
- **Analogy**:
  - **Workspace**: Your desk (where you are writing).
  - **Staging (Index)**: The "Outbox" tray (where you put things ready to be sent).
  - **Commit (Repository)**: The "Archive Vault" (where the mailman stores the records).

### Phase 2: Branch Management (Parallel Dimensions)
Branches allow you to work on new features without breaking the "Main" stability.
- **The DevOps Why**: In a professional environment, we never push directly to `main`. We use **Feature Branches** and **Pull Requests** (PRs) so our team can review the changes before they go live.

### Phase 3: The Handshake (Git & Automation)
Git is the trigger for **CI/CD**. When you `git push`, a robot (GitHub Action or Jenkins) wakes up, builds your code, and deploys it to the cloud.
- **The "Handshake"**: A pre-commit hook (bash script) can check your **Dockerfile** for security flaws *before* you even push the code. This is called "Shifting Left."

---

## 🏗️ Architectural Overview
<GIT_VERSION_CONTROL_DIAGRAM>

---

## 🆘 What to do when this fails: Git Edition

**Issue: "Merge Conflict" (The Dreaded Error)**
- **The Cause**: Two people changed the same line of code in different ways.
- **The Fix**: Open the file, look for `<<<<<<< HEAD`, choose the correct code, remove the markers, and `git commit`.

**Issue: "Detached HEAD state"**
- **The Cause**: You checked out a specific commit instead of a branch.
- **The Fix**: `git checkout main` to get back to the present.

---

## 🚀 Pro-Tips for SREs
> **Commit Often, Push Less**: Small, atomic commits are easier to debug than one giant "Big Bang" commit that changes 50 files.

---
*Visit the [Assessment/](./Assessment/) folder to test your knowledge!*
