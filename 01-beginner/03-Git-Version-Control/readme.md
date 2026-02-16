# 🛠️ Pillar 03: Git Version Control

> **"Git is a time machine. If you break the present, you can just load a save point from the past."**

Git is the foundation of **Collaboration**. In DevOps, we don't just store code; we store our infrastructure (IaC). If your Git workflow is messy, your infrastructure will be messy. This pillar teaches you how to manage multiple parallel dimensions of code without losing your mind.

---

## 🗺️ The Narrative: Parallel Realities

### Part A: The Local Workflow (Your Private Lab)
Before you share your work, you experiment in your own workspace.
- **Analogy**: A sketchbook. You draw, you erase, you refine (Staging). Once you like the page, you ink it (Commit).
- **Senior Perspective**: Commit early, commit often. Use atomic commits (each commit does ONE thing) so it's easy to undo a single mistake.

### Part B: Remote Collaboration (The Team Hub)
How do five engineers work on the same file without overwriting each other?
- **Workflow**: Branches and Pull Requests (PRs). You fork the timeline, make your changes, and then "request" to merge your timeline back into the "Main" reality.
- **Real-World Incident**: Someone pushed a bug to the `main` branch, and production went down. Deployment is halted. Git allows you to `revert` the change in seconds.

---

## 🏗️ Study Guide
1.  **[01-Reference/Local-Workflow](./01-Reference/Local-Workflow/)**: Mastering the basics on your machine.
2.  **[01-Reference/Remote-Collaboration](./01-Reference/Remote-Collaboration/)**: PRs, Merge Conflicts, and Branching Strategies.
3.  **[03-Assessment](./03-Assessment/)**: Git Challenges—can you survive a rebase?

---
*Pro-Tip: Never `force push` to a shared branch. It’s like rewriting history for everyone else—it makes people angry.*
