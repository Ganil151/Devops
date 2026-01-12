# 🕵️ Hidden Files (Dotfiles Mastery)
> **"In Linux, what you don't see controls everything you do. The invisible configuration layer."**
![Dotfiles Iceberg Theory](./dotfiles_iceberg.svg)
## 📚 Overview
In the Unix/Linux world, files starting with a dot (`.`) are "hidden" from normal view. These aren't just for secrets; they represent the **nervous system** of your user environment. From shell behavior (`.bashrc`) to identity management (`.ssh`) and version control (`.git`), mastering dotfiles is what separates a casual user from a DevOps professional.
## 🎓 Learning Objectives
By the end of this module, you will:
- ✅ Identify the **Core Dotfiles** that control system behavior.
- ✅ Master the `ls -a` command to reveal hidden architecture.
- ✅ Understand the difference between **Login** and **Interactive** shells.
- ✅ Guard against **Malicious Dotfiles** and security vulnerabilities.
- ✅ Manage dotfiles using **Version Control** (Git) and **GNU Stow**.
---
## 🏗️ The Dotfile Hierarchy
### 1. The Big Three
| File | Role | DevOps Purpose |
|------|------|----------------|
| **`.bashrc`** | Shell Config | Aliases, custom prompts, and PATH exports. |
| **`.ssh/`** | Security Identity | Storing keys for remote server access. |
| **`.gitconfig`**| VCS Identity | Global Git user name and email settings. |
### 2. Detection Logic
Hidden files are just a convention. The shell and `ls` simply ignore them by default unless the `-a` (all) flag is passed.
```bash
# See everything, including the invisible layer
ls -lah ~
```
---
## 🚀 Practical Examples for Automation
### Example A: The `.bashrc` Power-up
Adding a custom alias to speed up Docker commands.
```bash
# Add this to your ~/.bashrc
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
```
### Example B: Git Global Setup
Ensuring every commit you make is properly attributed.
```bash
git config --global user.name "Ganil"
git config --global user.email "ganil@example.com"
```
---
## 🔐 Forensic Audit: The Hidden Threat
Because dotfiles are hidden, attackers often use them to hide malware or backdoors.
- **`.hidden_script`**: A script that runs every time you log in.
- **`.ssh/authorized_keys`**: Adding an attacker's key to gain permanent access.
**Audit Command:**
```bash
find ~ -maxdepth 1 -name ".*" -ls
```
---
## 📑 The Dotfile Cheat Sheet
| File/Folder | Purpose |
|-------------|---------|
| `~/.bashrc` | Interactive non-login shell config. |
| `~/.profile`| Login shell settings. |
| `~/.ssh/` | Private and Public SSH keys. |
| `~/.bash_history` | Record of every command you typed. |
| `~/.gitconfig` | Global Git configuration. |
| `~/.vimrc` | Custom Vim settings. |
---
## 🏆 Real-World DevOps Story
### 💡 **The Ghost In The Shell**
**The Scenario**: An engineer's terminal started running very slowly every morning. They checked CPU and RAM, but everything looked fine.
**The Discovery**:
They looked at their `~/.bashrc` and found a line added by a "helpful" script that was trying to update 100 different packages *every time* a new terminal was opened.
**The Fix**:
By cleaning the `~/.bashrc` and moving that logic to a weekly cron job, the engineer restored their terminal performance instantly.
---
## 📝 Knowledge Check
1. **Which flag allows `ls` to show hidden files?**
   - [ ] a) `-h`
   - [x] b) `-a`
   - [ ] c) `-l`
2. **Where are your SSH keys usually stored?**
   - [ ] a) `~/ssh`
   - [x] b) `~/.ssh`
   - [ ] c) `/etc/ssh`
3. **What is the purpose of `.bash_history`?**
   - [x] a) It stores a list of previously run commands
   - [ ] b) It hides your browsing history
   - [ ] c) It predicts your next command
**Answers**: 1-b, 2-b, 3-a
## 🔗 Next Steps
Continue to: **[Searching in Files](../05-Searching-in-Files/README.md)** →
