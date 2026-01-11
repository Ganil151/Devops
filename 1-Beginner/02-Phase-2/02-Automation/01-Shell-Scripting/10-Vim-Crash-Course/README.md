# 📝 Vim Crash Course

> **"I've been using Vim for about 2 years now, mostly because I can't figure out how to exit it."**

![Vim Banner](../../assets/vim_banner.png)

## 📚 Overview

Vim (Vi IMproved) is the ubiquitous text editor of the Linux world. It is installed on almost every server by default. Unlike Notepad or VS Code, it is **modal**, meaning keys do different things depending on which "mode" you are in. Mastering Vim is a superpower for DevOps engineers who need to edit configs on remote servers.

## 🎓 Learning Objectives

By the end of this module, you will:

- ✅ Understand the 3 Core Modes: Normal, Insert, Command
- ✅ Create, edit, and save files without a mouse
- ✅ Navigate effortlessly (`h`, `j`, `k`, `l`)
- ✅ Perform bulk actions (copy, paste, delete lines)
- ✅ **Successfully exit Vim** (The most important skill!)

## 🏗️ The Three Modes of Vim

```mermaid
stateDiagram-v2
    [*] --> NormalMatch: Open File
    
    NormalMatch --> InsertMode: Press 'i', 'a', 'o'
    InsertMode --> NormalMatch: Press 'Esc'
    
    NormalMatch --> CommandMode: Press ':'
    CommandMode --> NormalMatch: Press 'Enter' or 'Esc'
    
    CommandMode --> [*]: :wq or :q!
    
    state NormalMatch {
        direction LR
        note: "Navigation & Manipulation (h, j, k, l, dd, yy)"
    }
    state InsertMode {
        direction LR
        note: "Typing Text"
    }
    state CommandMode {
        direction LR
        note: "Save, Quit, Search (:w, :q, /text)"
    }
```

## 🛠️ The Survival Kit (Cheat Sheet)

### 1. File Operation (Command Mode)
| Keystrokes | Action | Pneumonic |
|------------|--------|-----------|
| `:w` | **W**rite (Save) | |
| `:q` | **Q**uit | |
| `:wq` | Write and Quit | |
| `:q!` | Quit **without** saving | Force Quit |

### 2. Changing Modes
| Key | Action |
|-----|--------|
| `Esc` | Go to Normal Mode (Spam this if stuck) |
| `i` | **I**nsert mode (before cursor) |
| `a` | **A**ppend mode (after cursor) |
| `o` | **O**pen new line below |

### 3. Navigation (Normal Mode)
Never use arrow keys! Keep hands on the home row.

| Key | Direction |
|-----|-----------|
| `h` | ⬅️ Left |
| `j` | ⬇️ Down |
| `k` | ⬆️ Up |
| `l` | ➡️ Right |
| `gg` | Go to top |
| `G` | Go to bottom |

### 4. Editing (Normal Mode)
| Key | Action |
|-----|--------|
| `dd` | **D**elete (cut) current line |
| `yy` | **Y**ank (copy) current line |
| `p` | **P**aste below |
| `u` | **U**ndo |

## 🏆 Real-World DevOps Story

### 💡 **The Firewall Emergency**

**Scenario**: A production database was getting hammered by traffic from a specific subnet. The GUI firewall tool was unresponsive due to load. 

**The Fix**:
The SysAdmin SSH'd into the gateway.
1. `vim /etc/iptables.rules`
2. `G` (Jump to bottom)
3. `o` (Open new line)
4. Typed the rule to drop the subnet.
5. `Esc` + `:wq`
6. Reloaded firewall.

**Time taken**: 15 seconds.
**Alternative**: Waiting for GUI to load (would have taken 10 mins).

**Lesson**: On a burning server, Vim is often the only tool that works fast enough.

## 🎓 Interview Questions

### Q1: How do you replace all occurrences of a word in Vim?
<details>
<summary>Click to reveal answer</summary>

Use the substitution command:
`:%s/old_word/new_word/g`
- `%`: Entire file
- `s`: Substitute
- `g`: Global (all occurrences on line)
</details>

### Q2: What is the difference between `i` and `a`?
<details>
<summary>Click to reveal answer</summary>

- `i` (Insert): Starts typing **before** the cursor character.
- `a` (Append): Starts typing **after** the cursor character.
Useful when you want to add a semicolon at the end of a line (`Shift+A` jumps to end and enters insert mode).
</details>

### Q3: Why use HJKL instead of arrow keys?
<details>
<summary>Click to reveal answer</summary>

Efficiency. Your fingers are already on the home row. Moving your hand to arrow keys takes time. Once you get muscle memory for HJKL, you navigate code at the speed of thought.
</details>

## 📝 Quiz

1. **Which key exits Insert Mode?**
   - [ ] a) `Ctrl + C`
   - [x] b) `Esc`
   - [ ] c) `Enter`
   - [ ] d) `:q`

2. **How do you save and quit?**
   - [ ] a) `Ctrl + S`
   - [ ] b) `:save`
   - [x] c) `:wq`
   - [ ] d) `:exit`

3. **What does `dd` do?**
   - [ ] a) Duplicate line
   - [x] b) Delete/Cut line
   - [ ] c) Debug mode
   - [ ] d) Date insert

4. **Which key moves the cursor DOWN?**
   - [ ] a) `h`
   - [ ] b) `k`
   - [x] c) `j`
   - [ ] d) `l`

5. **How do you undo the last change?**
   - [ ] a) `Ctrl + Z`
   - [x] b) `u`
   - [ ] c) `:undo`
   - [ ] d) `r`

**Answers**: 1-b, 2-c, 3-b, 4-c, 5-b

## 🔗 Next Steps

Continue to: **[File Permissions](../11-File-Permissions/README.md)** →

## 📚 Additional Resources
- [Vim Adventures (Game)](https://vim-adventures.com/)
- [OpenVim (Interactive Tutorial)](https://www.openvim.com/)

---
**📌 Pro Tip**: If you accidentally press `Ctrl+S`, your terminal will freeze (legacy flow control). Press `Ctrl+Q` to unfreeze it!
