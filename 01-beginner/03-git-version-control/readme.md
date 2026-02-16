# 🌿 Git: Version Control & Collaboration

> **"Git is the 'Undo' button for your entire infrastructure. If it's not in Git, it doesn't exist. If it's not on 'main', it's not in production."**

---

## 🏗️ The Collaborative Workflow
In modern DevOps, we follow a branching strategy that ensures only stable, reviewed code reaches production.

<GIT_WORKFLOW_FLOWCHART>

| Phase | Git Action | Junior Tip |
| :--- | :--- | :--- |
| **New Work** | `git checkout -b feat/xyz` | Always branch off the latest `main`. |
| **Staging** | `git add .` | Use `git status` FIRST to avoid committing junk files. |
| **Commit** | `git commit -m "..."` | Use [Conventional Commits](https://www.conventionalcommits.org/). |
| **Update** | `git pull --rebase origin main` | Rebase to keep your history clean and linear. |
| **Finalize** | `gh pr create` | Never merge your own PR without a peer review. |

---

## 💡 Senior Tips: Git Mastery
> **Tip 1**: Never use `git push --force` on shared branches. It's like deleting the team's brain. Use `--force-with-lease` if you MUST force.

> **Tip 2**: Use `.gitignore` religiously. Committing `.env` files or `node_modules` is a capital offense in DevOps.

---

## 🛠️ Essential Git Commands
| Command | Purpose | DevOps Why |
| :--- | :--- | :--- |
| `git log --oneline` | View history | Quick audit of what changed and when. |
| `git stash` | Context switch | Pause work on a feature to fix a production bug. |
| `git revert` | Safe undo | Undoing a commit by creating a new one (preserving history). |
| `git diff` | Change inspection | Reviewing code before staging it. |

---

## 📂 Module Structure

1. **[01-Introduction](./01-beginner-level/01-introduction/)**: Why Version Control?
2. **[02-Git-Fundamentals](./01-beginner-level/02-git-fundamentals/)**: Objects, Trees, and Hashes.
3. **[03-Git-Commands](./01-beginner-level/03-git-commands/)**: The daily driver commands.
4. **[Workflows](./02-intermediate-level/01-git-workflows/)**: GitFlow vs. Trunk-Based Development.

---

**Next Step**: Start with [01-Introduction](./01-beginner-level/01-introduction/)