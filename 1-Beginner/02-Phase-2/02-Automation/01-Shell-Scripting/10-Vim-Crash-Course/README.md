# 📝 Vim Crash Course (The DevOps Survival Editor)

> **"I've been using Vim for about 2 years now, mostly because I can't figure out how to exit it. But once you learn, you never go back."**

![Vim Modes State Diagram](./vim_modes_state.svg)

## 📚 Overview

Vim (Vi IMproved) is the ubiquitous text editor of the Linux world. It is installed on almost every server, container, and IoT device by default. Unlike Notepad or VS Code, it is **modal**, meaning keys do different things depending on which "mode" you are in. 

Mastering Vim isn't just about editing files; it's about **editing code at the speed of thought** without ever touching your mouse.

---

## 🎓 Learning Objectives

By the end of this module, you will:

- ✅ Pivot between the **4 Essential Modes** fluently.
- ✅ Navigate code using **Motions** (`w, e, b, G, gg`) instead of arrows.
- ✅ Perform surgical edits using **Counts** (e.g., "Delete 5 lines").
- ✅ Master **Search and Replace** across entire files.
- ✅ Manage **Visual Blocks** to mass-comment code.

---

## 🕹️ The Home Row Philosophy (Navigation)

In Vim, you never use arrow keys. You keep your hands on the "Home Row" (`asdf jkl;`). This minimizes physical movement and maximizes speed.

| Key | Action | Mental Model |
|-----|--------|--------------|
| `h` | ⬅️ Left | |
| `j` | ⬇️ Down | Looks like a downward arrow |
| `k` | ⬆️ Up | |
| `l` | ➡️ Right | |
| `w` | **Next Word** | Jump by words, not chars |
| `b` | **Back a Word** | |
| `0` | **Start of Line** | |
| `$` | **End of Line** | Regular Expression standard |

---

## 🛠️ The Power User Toolkit

### 1. The Survival Modes
- **NORMAL mode (Esc)**: For moving and deleting. This is where you spend 90% of your time.
- **INSERT mode (i)**: For typing. Use `Esc` to get out the second you stop typing.
- **VISUAL mode (v)**: For highlighting. Use `Ctrl-v` to select columns (perfect for indentation).
- **COMMAND mode (:)**: For system actions like `:w` (save) or `:q` (quit).

### 2. Surgical Editing (Normal Mode)
Vim uses a "Verb + Motion" grammar.
- `d` (Delete) + `w` (Word) = `dw` (Delete word).
- `c` (Change) + `i` (Inside) + `"` (Quotes) = `ci"` (Delete everything inside quotes and start typing).

| Key | Action |
|-----|--------|
| `u` | **Undo** |
| `Ctrl+r`| **Redo** |
| `.` | **Repeat** (Repeats your last action - the best tool in Vim!) |
| `x` | Delete single character |
| `dd`| Delete entire line (3dd = delete 3 lines) |
| `yy`| "Yank" (Copy) line |
| `p` | Paste below |

---

### 3. Search & Replace (Command Mode)
Don't scroll looking for text. Jump to it.

- Search: `/keyword` (Press `n` for next match).
- **Global Replace**: `:%s/old/new/g`
- **Global Replace with Confirmation**: `:%s/old/new/gc`

---

## 🏆 Real-World DevOps Case Study

### 🚨 **The YAML Tab Tragedy**

**The Scenario**: A Kubernetes deployment was failing with an `indentation error`. The YAML file was 200 lines long, and the error was "Somewhere near line 150". 

**The Fix**:
A DevOps engineer SSH'd in and used Vim maneuvers:
1. `vim deployment.yaml`
2. `:set number` (Show line numbers)
3. `150G` (Jump directly to line 150)
4. Found that 10 lines were indented with tabs instead of spaces.
5. `Ctrl-v` (Visual Block mode) to select the leading tab column.
6. `d` to delete the block.
7. `Esc` + `:wq`

**Outcome**: Deployment succeeded in under 60 seconds.
**Lesson**: Visual Block mode allows you to edit entire columns of text simultaneously, a feature traditional editors often hide behind complex menus.

---

## 🎓 Interview Questions

#### Q1: How do you jump to the end of a very long file?
<details>
<summary>Click to reveal answer</summary>
Press `G` (Capital G) in Normal mode. To jump back to the top, press `gg`.
</details>

#### Q2: What is the difference between `:q` and `:q!`?
<details>
<summary>Click to reveal answer</summary>
`:q` will quit only if there are no unsaved changes. If you have modified the file, Vim will block you. `:q!` is a "force quit"—it discards all unsaved changes and exits immediately.
</details>

#### Q3: How do you indent a block of code in Vim?
<details>
<summary>Click to reveal answer</summary>
1. Enter Visual mode (`v` or `V`).
2. Highlight the lines.
3. Press `>` to indent right or `<` to indent left.
</details>

---

## 📝 Knowledge Check

1. **How do you enter "Visual Block" mode?**
   - [ ] a) `v`
   - [ ] b) `V`
   - [x] c) `Ctrl + v`
   - [ ] d) `Alt + v`

2. **What does the `.` (dot) key do in Normal mode?**
   - [ ] a) Deletes a character
   - [ ] b) Moves to the end of the line
   - [x] c) Repeats the last editing command
   - [ ] d) Saves the file

3. **Which command allows you to search for the word 'production'?**
   - [ ] a) `:find production`
   - [x] b) `/production`
   - [ ] c) `f production`
   - [ ] d) `s/production`

4. **How do you "Yank" (Copy) a line?**
   - [ ] a) `cc`
   - [x] b) `yy`
   - [ ] c) `pp`
   - [ ] d) `dd`

**Answers**: 1-c, 2-c, 3-b, 4-b

## 🔗 Additional Resources
- [Vim Cheat Sheet (Interactive)](https://vim.rtorr.com/)
- [Vim Genius](http://vimgenius.com/)
- [Learn Vim Progressively](http://yannesposito.com/Scratch/en/blog/Learn-Vim-Progressively/)

---
**📌 Pro Tip**: Run `vimtutor` in your terminal right now. It is a 30-minute interactive lesson built into most Linux systems that will teach you 90% of what you need to know.
