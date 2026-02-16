# 🧪 Git Workflow & Conflict Lab

> **"Merge conflicts are not errors; they are Git asking for your help in a disagreement."**

## 🚩 Task 1: The Atomic Commit
Create a file, add one line, commit it. Add another line, commit it. Use `git log` to see the history. This is how we track the evolution of our code.

## 🚩 Task 2: Parallel Universes (Branching)
1.  Create a branch named `feature/add-logo`.
2.  Switch to it.
3.  Add a line about a logo to `README.md`.
4.  Commit it.
5.  Switch back to `main`. Is the logo line there? (It shouldn't be!)

## 🚩 Task 3: The Collision (Merge Conflicts)
1.  On `main`, change the SAME line you changed in the feature branch.
2.  Commit it on `main`.
3.  Try to `git merge feature/add-logo` into `main`.
4.  **CONFLICT!** Open the file, locate the markers (`<<<<<<<`), fix the code, and commit the resolution.

---
*Success Metric: A clean Git history with no active conflict markers.*
