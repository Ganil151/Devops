# 🛡️ Linux Permissions & Ownership: The Security Manual
*Version 1.0 | Shielding Data & Ensuring Access Integrity*

---

## 📖 Overview
Linux is a multi-user system where access is controlled by two factors: **Who owns the file** and **What can they do with it**. In DevOps, misconfigured permissions are the leading cause of "Permission Denied" errors in CI/CD pipelines and security vulnerabilities in production.

---

## 🏗️ The Trio of Access (rwx)

### Read (`r`)
**Definition**: The ability to open and look at the content of a file, or list the contents of a directory.
**Octal Value**: 4.
**Example**: `cat /etc/passwd` requires Read access.

### Write (`w`)
**Definition**: The ability to modify or delete a file, or create/delete files inside a directory.
**Octal Value**: 2.
**Example**: `echo "Hello" > log.txt` requires Write access.

### Execute (`x`)
**Definition**: The ability to run a file as a program/script, or enter/search a directory.
**Octal Value**: 1.
**Example**: `./deploy.sh` requires Execute access.

---

## 🔢 Octal & Symbolic Standards

### Symbolic Notation
**Definition**: Representing bits as `rwx`.
**Legend**:
- `-rwxr-xr-x`: Owner can do all; Group/Others can Read/Execute.
- `d`: Directory.
- `l`: Symbolic Link.

### Octal Notation (Absolute)
**Definition**: Using numbers (0-7) to represent permissions for **User**, **Group**, and **Others**.
**Common Codes**:
- `755`: Standard for scripts and directories (Owner all, others read/exec).
- `644`: Standard for data files (Owner read/write, others read only).
- `600`: Standard for private keys (Exclusive access for owner only).

---

## 🔧 Essential Permission Commands

### `chmod`
**Definition**: Changes the mode (permissions) of a file or directory.
**Example**: `chmod 700 ~/.ssh` (Secure SSH directory).

### `chown`
**Definition**: Changes the owner and/or group of a file or directory.
**Example**: `chown www-data:www-data /var/www/html` (Give ownership to the webserver).

### `umask`
**Definition**: Sets the default permissions applied to newly created files.
**Example**: Setting `umask 022` results in new files having `644` permissions.

---

## 💡 SRE Pro-Tips
- **The "Execution" Trap**: Remember that for a directory, `x` (Execute) means you can "enter" it. If a user has `r` but not `x` on a directory, they can see the file names but cannot access the files themselves.
- **Recursive Dangers**: Use `chmod -R` with extreme caution. Running `chmod -R 777 /` will effectively destroy the system's security model.
- **Sticky Bit**: Used on directories like `/tmp` to ensure that only the owner of a file can delete it, even if others have write access to the directory.

---
**Next Step**: [Essential SRE Commands →](./linux-essential-commands-ref.md)
