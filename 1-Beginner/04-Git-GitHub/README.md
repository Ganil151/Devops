# Git & GitHub Fundamentals

Git is the foundation of DevOps. It allows teams to collaborate, track changes, and maintain a history of their codebase. GitHub provides the platform to host these repositories and automate workflows.

## 🎯 Learning Objectives

- Master local version control (init, stage, commit)
- Understand branching and merging strategies
- Learn collaborative workflows (Forking, PRs)
- Navigate GitHub features for project management

## 🛠️ Essential Git Commands

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

## 🧠 Training & Assessment

### Knowledge Quiz

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

### Real-World Troubleshooting Scenarios

#### Scenario 1: The "Emergency Hotfix"
**Problem:** You are working on a feature branch, but a critical bug is found on `main` that needs to be fixed immediately.
**Investigation:**
1.  **Current State:** You have uncommitted changes in your feature branch.
2.  **The Fix:** You don't want to commit "broken" work just to switch branches.
**Solution:** Use `git stash` to save your work, switch to `main`, fix the bug, then return and run `git stash pop`.

#### Scenario 2: Diverged Branches
**Problem:** You try to push your code, but Git says `Your branch is behind 'origin/main'`.
**Investigation:**
1.  **Cause:** A teammate merged a PR while you were working.
2.  **Resolution:** You need to integrate their changes before you can push yours.
**Solution:** Run `git pull --rebase origin main`. This puts your local commits "on top" of the latest changes from the server, keeping history clean.

---

## ✅ Knowledge Check
- [ ] Initialize and clone repositories
- [ ] Understand the 3 stages of Git (Working, Staged, Committed)
- [ ] Create and merge branches
- [ ] Resolve merge conflicts manually
- [ ] Use `git stash` for context switching

## 🔗 Next Steps
- **[Data Formats](../05-Data-Formats/)** - Master YAML and JSON for configuration.
- **[Docker Basics](../06-Docker/)** - Containerize your code versions.
- **[GitHub Actions](../08-Basic-CI-CD/)** - Automate your Git workflow.

---
*Version control is a muscle—the more you commit, the stronger your repository becomes.*
