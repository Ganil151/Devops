# 📍 Terminal Navigation (The DevOps GPS)
> **"You can't automate where you haven't been. Mastering navigation is the first step to controlling the machine."**
![Navigation Architecture](./navigation_architecture.svg)
## 📚 Overview
The terminal is your headquarters. Unlike the mouse-driven "Finder" or "Explorer," the terminal is a precise, text-based interface for the Unix filesystem. In DevOps, you don't navigate by clicking folders; you navigate by understanding the hierarchy of the system. This module covers the essential "GPS" commands required to move safely across local and remote servers.
## 🎓 Learning Objectives
By the end of this module, you will:
- ✅ Master the **Primary Command Trio**: `cd`, `ls`, and `pwd`.
- ✅ Understand the **Filesystem Root** (`/`) vs. **User Home** (`~`).
- ✅ Navigate using **Absolute** vs. **Relative** paths.
- ✅ Utilize **Terminal Shortcuts** (Tab competition, history) to increase speed.
- ✅ Customize your terminal prompt for better situational awareness.
---
## 🏗️ Path Architecture: Absolute vs. Relative
### 1. Absolute Paths
Always start from the **Root** (`/`). They work from anywhere in the system.
- **Example**: `/var/log/nginx/access.log`
### 2. Relative Paths
Start from your **Current Directory**. They depend on where you are standing.
- **`.`**: Current directory.
- **`..`**: Parent directory (Go back one level).
- **Example**: `../config/sites-enabled/`
---
## 🚀 Practical Navigation Logic
### 1. The "Where Am I?" Test
Always run `pwd` before running destructive commands like `rm` to ensure you are in the correct location.
### 2. The Power of Tab Completion
Never type full folder names. Type the first two letters and hit `Tab`. If the terminal beeps, there are multiple matches; hit `Tab` twice to see them.

---
## 📑 Navigation Cheat Sheet
| Command | Mnemonic                            | Result                                 |
| ------- | ----------------------------------- | -------------------------------------- |
| `pwd`   | **P**rint **W**orking **D**irectory | Shows your current location.           |
| `ls -l` | **L**ist **L**ong                   | Shows details (Size, Date, Perms).     |
| `cd ~`  | **C**hange to **Home**              | Jumps back to your user folder.        |
| `cd -`  | **C**hange to **Previous**          | Jumps back to where you just were.     |
| `cd ..` | **C**hange **Up**                   | Moves up one level.                    |
| `clear` | Clear Screen                        | Wipes the terminal clutter (`Ctrl+L`). |

---
## 🏆 Real-World DevOps Story
### 💡 **The Lost Root Deletion**
**The Scenario**: An engineer meant to delete a `tmp` folder inside their project. They typed `rm -rf /tmp`.
**The Discovery**:
Because they started the path with a `/`, they told the system to delete the **Global System Root /tmp** folder instead of the one in their local project.
**The Lesson**: Always use relative paths (`./tmp`) for local project work to prevent accidental system-wide damage.

---
## 📝 Knowledge Check
1. **Which symbol represents the Root directory?**
   - [x] a) `/`
   - [ ] b) `~`
   - [ ] c) `$`
2. **What does `cd ..` do?**
   - [ ] a) Goes to the home folder
   - [x] b) Moves up one level in the hierarchy
   - [ ] c) Deletes the current folder
3. **True or False: `pwd` tells you the path of the file you are editing.**
   - [ ] a) True
   - [x] b) False (It tells you the directory you are *in*)
**Answers**: 1-a, 2-b, 3-b
## 🔗 Next Steps
Continue to: **[Basic File Manipulation](../03-Basic-File-Manipulation/README.md)** →
