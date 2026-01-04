# Complete Guide to chmod Permissions and File System Security

## Understanding Linux File Permissions

### Permission Types

Linux file permissions control three types of access for three categories of users:

#### Access Types:
- **Read (r)**: Permission to view file contents or list directory contents
- **Write (w)**: Permission to modify file contents or create/delete files in directory
- **Execute (x)**: Permission to run file as program or enter directory

#### User Categories:
- **Owner (u)**: The user who owns the file
- **Group (g)**: Users who belong to the file's group
- **Others (o)**: All other users on the system

### File Permission Display

When you run `ls -l`, permissions are displayed as a 10-character string:

```bash
-rwxr-xr--  1 user group 1024 Jan 15 10:30 filename
 ||||||||| 
 ||||||++-- Others permissions (r--)
 |||+++---- Group permissions (r-x)
 +++------- Owner permissions (rwx)
 +--------- File type (- = regular file, d = directory, l = link)
```

## Complete chmod Permission Reference

### Numeric (Octal) Permissions

Each permission type has a numeric value:
- **Read (r) = 4**
- **Write (w) = 2**
- **Execute (x) = 1**

Permissions are calculated by adding these values:

#### All Possible Numeric Combinations:

```bash
# Owner permissions (first digit)
0 = --- (no permissions)
1 = --x (execute only)
2 = -w- (write only)
3 = -wx (write + execute)
4 = r-- (read only)
5 = r-x (read + execute)
6 = rw- (read + write)
7 = rwx (read + write + execute)

# Same applies to group (second digit) and others (third digit)
```

#### Complete 3-Digit Permission Table:

```bash
# Format: chmod XYZ filename
# X = Owner permissions, Y = Group permissions, Z = Others permissions

000 = ---------  # No permissions for anyone
001 = ------x--  # Execute for others only
002 = -----w---  # Write for others only
003 = -----wx--  # Write + execute for others
004 = ----r----  # Read for others only
005 = ----r-x--  # Read + execute for others
006 = ----rw---  # Read + write for others
007 = ----rwx--  # All permissions for others

010 = ---x-----  # Execute for group only
011 = ---x--x--  # Execute for group and others
020 = --w------  # Write for group only
030 = --wx-----  # Write + execute for group
040 = -r-------  # Read for group only
050 = -r-x-----  # Read + execute for group
060 = -rw------  # Read + write for group
070 = -rwx-----  # All permissions for group

100 = --x------  # Execute for owner only
200 = -w-------  # Write for owner only
300 = -wx------  # Write + execute for owner
400 = r--------  # Read for owner only
500 = r-x------  # Read + execute for owner
600 = rw-------  # Read + write for owner
700 = rwx------  # All permissions for owner

# Common combinations:
644 = rw-r--r--  # Owner: read/write, Group/Others: read only
755 = rwxr-xr-x  # Owner: all, Group/Others: read/execute
777 = rwxrwxrwx  # All permissions for everyone (dangerous!)
000 = ---------  # No permissions (locked file)
```

### Symbolic Permissions

#### User Categories:
```bash
u = owner (user)
g = group
o = others
a = all (equivalent to ugo)
```

#### Operations:
```bash
+ = add permission
- = remove permission
= = set exact permission (removes others)
```

#### Permission Letters:
```bash
r = read
w = write
x = execute
s = setuid/setgid
t = sticky bit
```

#### Symbolic Permission Examples:

```bash
# Adding permissions
chmod u+x file.txt          # Add execute for owner
chmod g+w file.txt          # Add write for group
chmod o+r file.txt          # Add read for others
chmod a+x file.txt          # Add execute for all
chmod ug+rw file.txt        # Add read/write for owner and group

# Removing permissions
chmod u-x file.txt          # Remove execute from owner
chmod g-w file.txt          # Remove write from group
chmod o-r file.txt          # Remove read from others
chmod a-x file.txt          # Remove execute from all

# Setting exact permissions
chmod u=rwx file.txt        # Owner: read/write/execute only
chmod g=rx file.txt         # Group: read/execute only
chmod o= file.txt           # Others: no permissions
chmod a=r file.txt          # All: read only

# Complex combinations
chmod u=rwx,g=rx,o=r file.txt    # Owner: rwx, Group: rx, Others: r
chmod u+x,g-w,o=r file.txt       # Add execute to owner, remove write from group, set others to read only
```

## Common Permission Patterns

### File Permissions

```bash
# Regular files
chmod 644 file.txt          # rw-r--r-- (standard file)
chmod 600 file.txt          # rw------- (private file)
chmod 755 file.txt          # rwxr-xr-x (executable file)
chmod 700 file.txt          # rwx------ (private executable)
chmod 444 file.txt          # r--r--r-- (read-only for all)
chmod 400 file.txt          # r-------- (read-only for owner)

# Configuration files
chmod 640 config.conf       # rw-r----- (owner read/write, group read)
chmod 600 secret.key        # rw------- (owner only)

# Log files
chmod 664 app.log           # rw-rw-r-- (owner/group write, others read)
chmod 644 system.log        # rw-r--r-- (owner write, others read)

# Script files
chmod 755 script.sh         # rwxr-xr-x (executable by all)
chmod 750 admin_script.sh   # rwxr-x--- (executable by owner/group)
chmod 700 private_script.sh # rwx------ (executable by owner only)
```

### Directory Permissions

```bash
# Standard directories
chmod 755 /home/user        # rwxr-xr-x (standard user directory)
chmod 750 /home/user        # rwxr-x--- (restricted user directory)
chmod 700 /home/user        # rwx------ (private user directory)

# System directories
chmod 755 /usr/bin          # rwxr-xr-x (system binaries)
chmod 755 /etc              # rwxr-xr-x (configuration directory)
chmod 700 /root             # rwx------ (root's home directory)

# Application directories
chmod 755 /var/www          # rwxr-xr-x (web server directory)
chmod 750 /var/log          # rwxr-x--- (log directory)
chmod 700 /var/backups      # rwx------ (backup directory)

# Temporary directories
chmod 1777 /tmp             # rwxrwxrwt (sticky bit set)
chmod 755 /var/tmp          # rwxr-xr-x (standard temp)
```

## Special Permissions

### Setuid (SUID) - 4000

When set on executable files, the program runs with the owner's privileges:

```bash
chmod 4755 /usr/bin/passwd  # rwsr-xr-x (setuid bit set)
chmod u+s /usr/bin/passwd   # Alternative syntax

# Finding SUID files (security audit)
find / -type f -perm /4000 2>/dev/null
```

### Setgid (SGID) - 2000

When set on executable files, runs with group privileges. On directories, new files inherit the directory's group:

```bash
chmod 2755 /shared/project  # rwxr-sr-x (setgid on directory)
chmod g+s /shared/project   # Alternative syntax

# Finding SGID files
find / -type f -perm /2000 2>/dev/null
```

### Sticky Bit - 1000

On directories, only file owners can delete their own files:

```bash
chmod 1777 /tmp             # rwxrwxrwt (sticky bit set)
chmod +t /shared/temp       # Alternative syntax

# Finding sticky bit directories
find / -type d -perm /1000 2>/dev/null
```

### Combined Special Permissions

```bash
chmod 6755 file             # rwsr-sr-x (both SUID and SGID)
chmod 7755 directory        # rwsr-sr-t (SUID, SGID, and sticky)
```

## File System Security Examples Explained

### Secure Mount Options in /etc/fstab

```bash
# /etc/fstab entry explained
/dev/sda1 /tmp ext4 defaults,nodev,nosuid,noexec 0 2
#         |    |    |                            | |
#         |    |    |                            | +-- fsck pass number
#         |    |    |                            +---- dump frequency
#         |    |    +--------------------------------- mount options
#         |    +-------------------------------------- filesystem type
#         +------------------------------------------- mount point
```

#### Mount Option Explanations:

```bash
# Security-focused mount options
nodev     # Don't interpret character/block special devices
nosuid    # Don't allow setuid/setgid bits to take effect
noexec    # Don't allow execution of binaries on this filesystem
ro        # Mount read-only
rw        # Mount read-write (default)
noatime   # Don't update access times (performance)
relatime  # Update access times relative to modify time
sync      # Synchronous I/O
async     # Asynchronous I/O (default)
user      # Allow ordinary users to mount
nouser    # Only root can mount (default)
```

#### Secure Mount Examples:

```bash
# Temporary directories (prevent execution)
/dev/sda1 /tmp ext4 defaults,nodev,nosuid,noexec 0 2
/dev/sda2 /var/tmp ext4 defaults,nodev,nosuid,noexec 0 2

# Log directories (prevent device files and execution)
/dev/sda3 /var/log ext4 defaults,nodev,nosuid,noexec 0 2

# Home directories (prevent device files)
/dev/sda4 /home ext4 defaults,nodev,nosuid 0 2

# Web server directory (prevent execution of uploaded files)
/dev/sda5 /var/www ext4 defaults,nodev,nosuid,noexec 0 2

# Shared directories with quotas
/dev/sda6 /shared ext4 defaults,nodev,usrquota,grpquota 0 2
```

### Critical System File Permissions

```bash
# Root directory and system files
chmod 700 /root                    # Root home directory
chmod 600 /etc/shadow              # Password hashes
chmod 644 /etc/passwd              # User account information
chmod 600 /etc/gshadow             # Group password hashes
chmod 644 /etc/group               # Group information
chmod 600 /boot/grub/grub.cfg      # Boot loader configuration
chmod 600 /etc/ssh/ssh_host_*_key  # SSH host private keys
chmod 644 /etc/ssh/ssh_host_*_key.pub  # SSH host public keys

# SSH configuration
chmod 700 ~/.ssh                   # SSH directory
chmod 600 ~/.ssh/id_rsa            # Private key
chmod 644 ~/.ssh/id_rsa.pub        # Public key
chmod 600 ~/.ssh/authorized_keys   # Authorized keys
chmod 644 ~/.ssh/known_hosts       # Known hosts
chmod 600 ~/.ssh/config            # SSH client config

# Web server files
chmod 644 /var/www/html/*.html     # Web pages
chmod 755 /var/www/html/           # Web directory
chmod 600 /etc/ssl/private/*.key   # SSL private keys
chmod 644 /etc/ssl/certs/*.crt     # SSL certificates

# Database files
chmod 700 /var/lib/mysql           # MySQL data directory
chmod 600 /var/lib/mysql/*         # Database files
chmod 640 /etc/mysql/my.cnf        # MySQL configuration

# Log files
chmod 640 /var/log/auth.log        # Authentication logs
chmod 644 /var/log/syslog          # System logs
chmod 600 /var/log/secure          # Security logs (Red Hat)
```

---

## Security Best Practices

### Permission Auditing Commands

```bash
# Find world-writable files (security risk)
find / -type f -perm /o+w 2>/dev/null

# Find world-writable directories
find / -type d -perm /o+w 2>/dev/null

# Find files with no owner (orphaned files)
find / -nouser -o -nogroup 2>/dev/null

# Find SUID/SGID files (potential privilege escalation)
find / -type f \( -perm /4000 -o -perm /2000 \) 2>/dev/null

# Find files with unusual permissions
find / -type f -perm 777 2>/dev/null

# Check for files in /tmp older than 7 days
find /tmp -type f -mtime +7 2>/dev/null
```

### Automated Permission Hardening Script

```bash
#!/bin/bash
# System permission hardening script

# Secure system directories
chmod 700 /root
chmod 755 /home
chmod 1777 /tmp
chmod 755 /var/tmp

# Secure configuration files
chmod 600 /etc/shadow
chmod 600 /etc/gshadow
chmod 644 /etc/passwd
chmod 644 /etc/group

# Secure SSH
chmod 700 /etc/ssh
chmod 600 /etc/ssh/ssh_host_*_key
chmod 644 /etc/ssh/ssh_host_*_key.pub
chmod 644 /etc/ssh/sshd_config

# Remove world-writable permissions from system files
find /etc -type f -perm /o+w -exec chmod o-w {} \;

# Secure log files
chmod 640 /var/log/auth.log 2>/dev/null
chmod 640 /var/log/secure 2>/dev/null
chmod 644 /var/log/messages 2>/dev/null

echo "System permissions hardened successfully"
```

### Permission Monitoring

```bash
# Create baseline of critical file permissions
find /etc /usr/bin /usr/sbin -type f -exec stat -c "%n %a %U %G" {} \; > /var/log/file_permissions_baseline.txt

# Check for permission changes
find /etc /usr/bin /usr/sbin -type f -exec stat -c "%n %a %U %G" {} \; > /tmp/current_permissions.txt
diff /var/log/file_permissions_baseline.txt /tmp/current_permissions.txt

# Monitor for new SUID/SGID files
find / -type f \( -perm /4000 -o -perm /2000 \) 2>/dev/null > /tmp/suid_sgid_current.txt
if [ -f /var/log/suid_sgid_baseline.txt ]; then
    diff /var/log/suid_sgid_baseline.txt /tmp/suid_sgid_current.txt
fi
```

## Troubleshooting Permission Issues

### Common Permission Problems and Solutions

```bash
# Problem: Permission denied when accessing file
# Solution: Check and fix permissions
ls -l filename
chmod 644 filename  # For regular files
chmod 755 filename  # For executables

# Problem: Cannot execute script
# Solution: Add execute permission
chmod +x script.sh

# Problem: Web server cannot access files
# Solution: Set appropriate web server permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
find /var/www/html -type f -exec chmod 644 {} \;

# Problem: SSH key not working
# Solution: Fix SSH key permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/authorized_keys

# Problem: Database files inaccessible
# Solution: Set correct database permissions
chown -R mysql:mysql /var/lib/mysql
chmod 700 /var/lib/mysql
chmod 660 /var/lib/mysql/*
```

### Permission Debugging Tools

```bash
# Check effective permissions for a user
sudo -u username ls -la /path/to/file

# Test file access
test -r filename && echo "Readable" || echo "Not readable"
test -w filename && echo "Writable" || echo "Not writable"
test -x filename && echo "Executable" || echo "Not executable"

# Show detailed file attributes
stat filename
getfacl filename  # Access Control Lists (if enabled)

# Check directory permissions along path
namei -l /full/path/to/file
```

This comprehensive guide covers all aspects of chmod permissions and file system security, providing both theoretical understanding and practical examples for system administrators and DevOps engineers.