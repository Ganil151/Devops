# Interview Questions: Linux Permissions

## 🟢 Beginner Level

### 1. What do the symbols `r`, `w`, and `x` stand for?
**Answer**:
- `r` (Read): Ability to view file content or list directory contents.
- `w` (Write): Ability to modify file content or create/delete files in a directory.
- `x` (Execute): Ability to run a file as a program or enter a directory.

### 2. How do you change the owner of a file?
**Answer**: Use the `chown` (change owner) command. For example: `sudo chown user:group filename`.

### 3. What does `chmod 777` mean, and is it a good practice?
**Answer**: `777` gives Read, Write, and Execute permissions to the Owner, Group, and Others (Everyone). It is **not** good practice because it allows anyone to modify or delete sensitive files, creating a significant security hole.

---

## 🟡 Intermediate Level

### 4. What is the difference between `644` and `755`?
**Answer**: 
- `644` (`rw-r--r--`): Owner can read/write; Group and Others can only read. Typically used for regular data/config files.
- `755` (`rwxr-xr-x`): Owner can read/write/execute; Group and Others can read/execute. Typically used for directories and executable scripts.

### 5. What is the "Sticky Bit" and where is it commonly used?
**Answer**: The sticky bit (represented by `t` at the end of permissions) ensures that only the owner of a file (or root) can delete or rename that file, even if other users have write access to the directory. It is commonly used on `/tmp`.

### 6. Explain the `umask` command.
**Answer**: `umask` (user mask) defines the default permissions for newly created files and directories. It works by "subtracting" the mask from the system default (usually 666 for files and 777 for directories). A mask of `022` results in `644` for files and `755` for directories.

---

## 🔴 Advanced (DevOps/SRE) Level

### 7. What are SUID and SGID bits?
**Answer**:
- **SUID (Set User ID)**: When an executable with SUID is run, it executes with the permissions of the file's owner (usually root), regardless of who runs it.
- **SGID (Set Group ID)**: For executables, it runs with the group's permissions. For directories, any new file created inside will inherit the directory's group rather than the user's primary group.

### 8. How do you find all files that are "world-writable" on a system?
**Answer**:
```bash
find / -type f -perm -o+w 2>/dev/null
```

### 9. What happens if a directory has the `x` (execute) permission but not the `r` (read) permission?
**Answer**: The user can `cd` into the directory and access files inside if they know the exact filename, but they cannot list the contents of the directory (i.e., `ls` will fail).
