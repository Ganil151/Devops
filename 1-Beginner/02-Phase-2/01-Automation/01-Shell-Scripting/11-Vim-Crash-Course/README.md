# 📝 Vim Crash Course: The DevOps Survival Editor

> **"Vim is not just an editor; it's a language. Once you learn the grammar, you can edit configuration as fast as you can think."**

```mermaid
stateDiagram-v2
    [*] --> Normal: vim filename
    Normal --> Insert: i / a / o
    Insert --> Normal: Esc
    Normal --> Command: :
    Command --> Normal: Enter / Esc
    Normal --> Visual: v / Ctrl+v
    Visual --> Normal: Esc
    
    state Normal {
        navigation: h j k l
        edit: x dd yy p u
    }
```

## 📚 Overview
Vim (Vi IMproved) is the ubiquitous text editor of the Linux world. For a DevOps engineer, it is a **survival tool**. When you SSH into a remote server, a minimal container, or a crashed production node, VS Code isn't there. Vim is. 

It is a **Modal Editor**, meaning keys behave differently based on your current "Mode." Mastering this modal logic allows you to perform surgical edits on production configs without ever touching a mouse.

## 🎓 Learning Objectives
By the end of this module, you will:
- ✅ **Toggle the 4 Core Modes**: Normal, Insert, Visual, and Command.
- ✅ Navigate using **Home Row Precision** (h, j, k, l).
- ✅ Master the **Vim Grammar** (Verb + Adjective + Noun).
- ✅ Perform **Global Search & Replace** for cluster-wide config updates.
- ✅ Utilize **Visual Block Editing** for mass-commenting code.
- ✅ **Escape Emergencies**: Sudo-saving and force-quitting.

---

## 🏗️ The Modal Mindset: Editing as a Language
Unlike standard editors, Vim uses a compositional language for text manipulation.

### 1. The Verb-Noun Logic
Commands in Vim often follow a grammar: **[Verb] + [Count] + [Object]**.
- **`d` (Delete)** + **`w` (Word)** = `dw` (Delete word).
- **`c` (Change)** + **`i` (Inside)** + **`"` (Quotes)** = `ci"` (Delete everything inside quotes and start typing).
- **`4`** + **`dd`** = Delete 4 lines.

### 2. The 4 Modes
| Mode | Purpose | Command Key |
| :--- | :--- | :--- |
| **Normal** | Navigation and structural edits. | `Esc` |
| **Insert** | Standard typing. | `i` |
| **Visual** | Selecting and highlighting text. | `v` |
| **Command**| File operations and global search. | `:` |

---

## 🚀 Professional Patterns for Automation

### Pattern A: Mass-Commenting (Visual Block)

Need to comment out 20 lines of a YAML file?

1. In **Normal Mode**, place cursor on the first line.
2. Press `Ctrl + v` (Visual Block Mode).
3. Use `j` to highlight down 20 lines.
4. Press `Shift + i` (Insert at start).
5. Type `# ` and hit `Esc`. Vim will apply the `# ` to every highlighted line instantly.

### Pattern B: The Sudo-Save Hack

It happens to everyone: you spend 10 minutes editing a complex config only to realize you forgot to use `sudo`. Vim won't let you save. 
**The Solution**:
`:w !sudo tee %`
This pipes the current Vim buffer into the `sudo tee` command, which has the permission to write to the file.

### Pattern C: Global Search & Replace

To change an IP or an Image version across an entire file:
`:%s/old-value/new-value/g`
- `%`: Entire file.
- `s`: Substitute.
- `g`: Global (every instance per line).

---

## 🏆 Real-World DevOps Story: The Config-Edit Deadlock

**The Scenario**: An SRE was troubleshooting a firewall configuration on a remote edge server with a latent connection. Using a mouse to navigate or waiting for a GUI editor would have timed out.
**The Discovery**: The engineer used Vim's search (`/error_code`) to jump straight to the offending line, used `ciw` to fix the parameter, and `:wq` to save—all in under 3 seconds.
**The Lesson**: When the network is slow or the environment is minimal, your speed in Vim is your greatest asset.

---

## ❓ Interview Preparation (Vim)

1. **Q: What is a "Modal Editor"?**
   *A: It is an editor where keys have different functions depending on which mode you are in. For example, in 'Normal Mode' the 'd' key deletes text, while in 'Insert Mode' it simply types the letter 'd'.*

2. **Q: How do you quit Vim without saving changes if you make a mistake?**
   *A: Use the command `:q!`. The exclamation mark forces the operation and discards all unsaved changes.*

3. **Q: What is the benefit of using `h, j, k, l` for navigation instead of arrow keys?**
   *A: It allows you to keep your hands on the "home row" of the keyboard, significantly increasing speed and reducing hand movement once the muscle memory is established.*

4. **Q: How do you search for a word in Vim and move to the next occurrence?**
   *A: Use `/` followed by the word (e.g., `/database`). Press `n` to jump to the next match and `N` to jump to the previous match.*

5. **Q: What does the command `u` and `Ctrl + r` do?**
   *A: `u` is for Undo (reversing the last change), and `Ctrl + r` is for Redo (reversing the undo).*

---

## 📝 Knowledge Check

1. **Which key takes you back to Normal Mode from any other mode?**
   - [ ] a) `Enter`
   - [x] b) `Esc`
   - [ ] c) `Space`

2. **How do you delete an entire line in Normal Mode?**
   - [ ] a) `Delete`
   - [ ] b) `x`
   - [x] c) `dd`

3. **What command is used to save a file?**
   - [ ] a) `:s`
   - [x] b) `:w`
   - [ ] c) `:q`

4. **Which mode allows you to edit a vertical block of text?**
   - [ ] a) Visual Mode (`v`)
   - [x] b) Visual Block Mode (`Ctrl + v`)
   - [ ] c) Insert Mode

5. **True or False: Vim can handle files that are too large for standard text editors.**
   - [x] a) True (It is extremely memory efficient)
   - [ ] b) False

---

## 🔗 Next Steps

Now that you can edit files like a pro, let's learn how to secure them!

Proceed to: **[File Permissions](../12-File-Permissions/README.md)** →
