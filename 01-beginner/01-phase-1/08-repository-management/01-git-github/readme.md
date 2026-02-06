# Git & GitHub Fundamentals

Git is the foundation of DevOps. It allows teams to collaborate, track changes, and maintain a history of their codebase. GitHub provides the platform to host these repositories and automate workflows.

## 🎯 Learning Objectives

- Master local version control (init, stage, commit)
- Understand branching and merging strategies
- Learn collaborative workflows (Forking, PRs)
- Navigate GitHub features for project management

## 📂 Module Structure

### 🔰 Beginner Level
- **[01-Introduction](./01-beginner-level/01-introduction/)**: Core concepts of Version Control, Git, and GitHub.
- **[02-Git-Fundamentals](./01-beginner-level/02-git-fundamentals/)**: Architecture, object models, and basic workflows.
- **[03-Git-Commands](./01-beginner-level/03-git-commands/)**: Essential commands for initialization, staging, and committing.

### 🚀 Intermediate Level
- **[01-Git-Workflows](./02-intermediate-level/01-git-workflows/)**: GitFlow, GitHub Flow, and Trunk-Based Development.
- **[02-GitHub-Integration](./02-intermediate-level/02-github-integration/)**: Issues, Projects, and Pull Requests.
- **[03-GitHub-Actions](./02-intermediate-level/03-github-actions/)**: CI/CD basics with GitHub Actions.

### 🛡️ Advanced Level
- **[01-Git-Advanced](./03-advanced-level/01-git-advanced/)**: Rebasing, hooks, stashing, and internals.
- **[02-Security-Best-Practices](./03-advanced-level/02-security-best-practices/)**: Signing commits, scanning for secrets, and branch protection.

---

## 📖 Essential Git Commands

### 📁 Initializing and Staging
*When to use: When starting a new project or tracking changes in an existing one.*

```bash
# Initialize a new repository
git init

# Check status of files
git status

# Add files to the staging area
git add <filename>
git add .         # Stage all changes

# Commit changes with a message
git commit -m "feat: initial commit"
```

### 🕒 History and Undo
*When to use: Reviewing past work or fixing mistakes.*

```bash
# View commit history
git log --oneline --graph --decorate

# Unstage a file
git reset HEAD <file>

# Revert a specific commit (creates a new commit)
git revert <commit_hash>

# Amend the last commit (Useful for fixing typos)
git commit --amend -m "Corrected message"
```

---

## 💡 Git Best Practices

- **Atomic Commits**: Each commit should do exactly one thing. This makes it easier to track bugs and roll back changes.
- **Meaningful Messages**: Use the [Conventional Commits](https://www.conventionalcommits.org/) format (e.g., `feat:`, `fix:`, `docs:`).
- **Branch for Everything**: Never work directly on `main`. Create feature branches (`feat/user-auth`, `fix/login-bug`).
- **Pull Frequently**: Avoid conflicts by pulling the latest changes from the remote repository regularly.

---

## 🧪 Practical Labs

### Lab 1: The "Emergency Hotfix"
**Scenario**: You are working on a feature branch, but a critical bug is found on `main` that needs to be fixed immediately.
**Task**: Pause current work, fix the bug, and resume.
**Solution**:
1.  **Stash**: Use `git stash` to save your work.
2.  **Switch**: `git checkout main` and fix the bug.
3.  **Resume**: Return to branch and run `git stash pop`.

### Lab 2: Diverged Branches
**Scenario**: You try to push your code, but Git says `Your branch is behind 'origin/main'`.
**Task**: Integrate remote changes without creating a messy merge bubble.
**Solution**:
1.  **Pull Rebase**: Run `git pull --rebase origin main`.
2.  **Resolve**: Fix any conflicts if they arise.

## 🧠 Knowledge Quiz

**1. What is the difference between `git reset` and `git revert`?**
- A) `reset` is for remote, `revert` is for local
- B) `reset` moves the HEAD pointer, `revert` creates a new commit to undo changes
- C) They are identical
- D) `revert` deletes history, `reset` preserves it

**2. Which command shows a visual representation of the branch graph?**
- A) `git history`
- B) `git status`
- C) `git log --graph`
- D) `git branch -v`

**3. What is the purpose of the "Staging Area" in Git?**
- A) It's where files are stored after being committed
- B) It's a preview area for GitHub pull requests
- C) It's a middle ground to prepare exactly what will go into the next commit
- D) It's used for resolving merge conflicts only

---

## ✅ Knowledge Check
- [ ] Initialize and clone repositories
- [ ] Understand the 3 stages of Git (Working, Staged, Committed)
- [ ] Create and merge branches
- [ ] Resolve merge conflicts manually
- [ ] Use `git stash` for context switching

## 🏆 Related Certifications

- **GitHub Foundations**: Validates your understanding of the core GitHub platform, including collaboration, products, and Git basics.
- **GitHub Actions**: Validates your skills in automating workflows using GitHub Actions (Intermediate level).

---

## 🔗 Next Steps
- **[Data Formats](readme.md)** - Master YAML and JSON for configuration.
- **[Docker Basics](readme.md)** - Containerize your code versions.
- **[GitHub Actions](readme.md)** - Automate your Git workflow.

---
*Version control is a muscle—the more you commit, the stronger your repository becomes.*