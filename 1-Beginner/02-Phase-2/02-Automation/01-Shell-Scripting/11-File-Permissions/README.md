# 🔒 File Permissions (Chmod Authority)

> **"With great power comes great responsibility. Don't `chmod 777` everything."**

![Permissions Banner](../../assets/permissions_banner.png)

## 📚 Overview

Linux is a multi-user operating system. Every file and directory has a specific set of permissions determining who can **Read**, **Write**, or **Execute** it. Understanding this is the single most important security skill in DevOps.

## 🎓 Learning Objectives

By the end of this module, you will:

- ✅ Decode the permission string (`drwxr-xr-x`)
- ✅ Master the Octal (`755`) and Symbolic (`u+x`) modes of `chmod`
- ✅ Understand `chown` (Change Owner)
- ✅ Grasp the danger of `sudo` and root privileges
- ✅ Fix "Permission Denied" errors correctly

## 🏗️ The Permission Anatomy

When you run `ls -l`, you see this string:

```mermaid
graph LR
    String[drwxr-xr--]
    
    Type[d] --> Description[Directory vs File (-)]
    User[rwx] --> Owner[User Permissions]
    Group[r-x] --> GrpDesc[Group Permissions]
    Other[r--] --> OthDesc[Everyone Else]
    
    String --> Type
    String --> User
    String --> Group
    String --> Other
    
    style User fill:#e74c3c,color:#fff
    style Group fill:#f1c40f,stroke:#333
    style Other fill:#3498db,color:#fff
```

## 🛠️ The Triad: Read, Write, Execute

| Permission | Symbol | Octal | File Effect | Directory Effect |
|------------|--------|-------|-------------|------------------|
| **Read** | `r` | 4 | View contents | List files (`ls`) |
| **Write** | `w` | 2 | Edit/Delete content | Create/Delete files |
| **Execute** | `x` | 1 | Run as program | Enter directory (`cd`) |

### Octal Math (The "Matrix" Way)
We represent permissions by adding numbers:
- **Read + Write + Execute** = 4 + 2 + 1 = **7**
- **Read + Execute** = 4 + 0 + 1 = **5**
- **Read Only** = 4 + 0 + 0 = **4**

**Common Combinations:**
- `777` = Everyone can do everything (**Dangerous**)
- `755` = Owner does all, others read/execute (Standard for scripts/directories)
- `644` = Owner reads/writes, others read (Standard for text files)
- `600` = Owner reads/writes, others have NO ACCESS (Keys/Secrets)

## 🚀 Commands

### 1. `chmod` - Change Mode
```bash
# Symbolic Mode
chmod u+x script.sh      # Add eXecute for User
chmod g-w file.txt       # Remove Write for Group

# Octal Mode
chmod 755 script.sh      # rwxr-xr-x
chmod 400 private.key    # r-------- (Secure!)
```

### 2. `chown` - Change Owner
```bash
# Syntax: chown user:group file
chown bob:developers app.py
chown -R www-data:www-data /var/www/html/  # Recursive
```

## 🏆 Real-World DevOps Story

### 💡 **The WordPress Hack**

**Scenario**: A freelance developer set up a WordPress site. To fix a "Permission Denied" error during a plugin upload, they ran:
```bash
chmod -R 777 /var/www/html
```

**The Exploit**:
By giving **Write** permission to "Others" (the world), a hacker was able to upload a PHP shell script called `backdoor.php` into the `images` folder.
The hacker then executed the script (since it had `x`) and deleted the entire database.

**The Fix**:
Permissions should have been:
- Directories: `755`
- Files: `644`
- **Owner**: `www-data` (the web server user), not `root`.

**Lesson**: **Never** use `777` as a "fix". It's like leaving your house keys in the door lock.

## 🎓 Interview Questions

### Q1: What is the SUID bit?
<details>
<summary>Click to reveal answer</summary>

SUID (Set User ID) allows a user to run a file with the permissions of the file's **owner**.
Example: `passwd` command. It needs to modify `/etc/shadow` (root only), but needs to be run by normal users to change their password.
Typical permission: `4755` (The `4` is SUID).
</details>

### Q2: Why do directories need Execute `x` permission?
<details>
<summary>Click to reveal answer</summary>

On a directory, `x` allows you to **enter** it (`cd`) and access its metadata. Without `x`, even if you have `r`, you can list the filenames but cannot stat files inside (view sizes, dates, permissions).
</details>

### Q3: How do you specifically add execute permissions only to directories, recursively?
<details>
<summary>Click to reveal answer</summary>

Using `find` or `chmod`:
```bash
chmod -R +X .   # Capital X only applies to directories (or files already executable)
# OR
find . -type d -exec chmod 755 {} \;
```
</details>

## 📝 Quiz

1. **What is the numeric value for `r-x`?**
   - [ ] a) 3
   - [ ] b) 4
   - [x] c) 5
   - [ ] d) 6

2. **Which command gives Read/Write to owner, and Read to everyone else?**
   - [x] a) `chmod 644`
   - [ ] b) `chmod 777`
   - [ ] c) `chmod 755`
   - [ ] d) `chmod 600`

3. **What does the first `d` mean in `drwxr-xr-x`?**
   - [ ] a) Delete
   - [x] b) Directory
   - [ ] c) Data
   - [ ] d) Dynamic

4. **Who represents the last 3 characters in `rwxrwxrwx`?**
   - [ ] a) User
   - [ ] b) Group
   - [x] c) Others (World)
   - [ ] d) Root

5. **Which command changes the file owner?**
   - [ ] a) `chmod`
   - [x] b) `chown`
   - [ ] c) `chgrp`
   - [ ] d) `su`

**Answers**: 1-c, 2-a, 3-b, 4-c, 5-b

## 🔗 Next Steps

Continue to: **[Finally Scripting](../12-Finally-Scripting/README.md)** →

## 📚 Additional Resources
- [Chmod Calculator](https://chmod-calculator.com/)
- [Linux Permissions Explained](https://wiki.archlinux.org/title/File_permissions_and_attributes)

---
**📌 Pro Tip**: Use `ls -ld directoryname` to check permissions of the directory itself, rather than its contents!
