# 🚀 Shell Scripting Quick Reference Cheat Sheet

> **"Your instant reference for shell scripting essentials - Print this and keep it handy!"**

## 📁 File Operations

### Creating
```bash
# Create empty file
touch file.txt

# Create multiple files
touch file1.txt file2.txt file3.txt

# Create numbered files
touch file{1..10}.txt

# Create directory
mkdir mydir

# Create nested directories
mkdir -p path/to/deep/directory

# Create with specific permissions
mkdir -m 755 secure_dir
```
### Copying
```bash
# Copy file
cp source.txt dest.txt

# Copy directory
cp -r source_dir/ dest_dir/

#  Copy preserving attributes
cp -p file.txt backup/

# Archive copy (best for backups)
cp -a source/ destination/

# Interactive (ask before overwrite)
cp -i file.txt existing.txt

# Verbose (show what's copied)
cp -v file.txt backup/
```
### Moving/Renaming
```bash
# Rename file
mv oldname.txt newname.txt

# Move file
mv file.txt /destination/

# Move multiple files
mv file1.txt file2.txt /destination/

# Interactive mode
mv -i source.txt dest.txt

# Never overwrite
mv -n source.txt dest.txt
```
### Deleting
```bash
# Delete file
rm file.txt

# Interactive delete (SAFE)
rm -i file.txt

# Delete directory and contents (DANGEROUS!)
rm -rf directory/

# Safer directory deletion
rm -rI directory/

# Delete empty directory only
rmdir empty_dir
```
## 🧭 Navigation
```bash
# Print current directory
pwd

# Change directory
cd /path/to/directory

# Go to home
cd
cd ~

# Go to previous directory
cd -

# Go up one level
cd ..

# Go up two levels
cd ../..
```
## 📄 Viewing Files
```bash
# Display entire file
cat file.txt

# Page through file
less file.txt
more file.txt

# First 10 lines
head file.txt

# Last 10 lines
tail file.txt

# Follow live updates (logs)
tail -f logfile.txt

# First N lines
head -n 20 file.txt

# Last N lines
tail -n 50 file.txt
```
## 🔍 Searching
```bash
# Search for pattern in file
grep "pattern" file.txt

# Case-insensitive search
grep -i "pattern" file.txt

# Recursive search in directory
grep -r "pattern" /path/

# Show line numbers
grep -n "pattern" file.txt

# Invert match (lines NOT containing pattern)
grep -v "pattern" file.txt

# Find files by name
find /path -name "*.txt"

# Find files by type
find /path -type f  # files only
find /path -type d  # directories only

# Find and execute command
find /path -name "*.log" -exec rm {} \;
```
## 📋 Listing Files
```bash
# Basic listing
ls

# Long format (detailed)
ls -l

# Show hidden files
ls -a

# Human-readable sizes
ls -lh

# Sort by time (newest first)
ls -lt

# Sort by time (oldest first)
ls -ltr

# Recursive listing
ls -R

# Combination (common)
ls -lah
```
## 🔐 Permissions
```bash
# View permissions
ls -l file.txt

# Change permissions (symbolic)
chmod u+x script.sh      # Add execute for owner
chmod go-w file.txt      # Remove write for group/others
chmod a+r file.txt       # Add read for all

# Change permissions (octal)
chmod 755 script.sh      # rwxr-xr-x
chmod 644 file.txt       # rw-r--r--
chmod 600 secret.txt     # rw------- (owner only)
chmod 777 public/        # rwxrwxrwx (NOT recommended!)

# Change ownership
chown user:group file.txt
chown -R user:group directory/

# Set default permissions
umask 022  # New files: 644, new dirs: 755
```
### Permission Values

| Octal | Binary | Permissions | Description |
|-------|--------|-------------|-------------|
| 0 | 000 | --- | No permissions |
| 1 | 001 | --x | Execute only |
| 2 | 010 | -w- | Write only |
| 3 | 011 | -wx | Write + Execute |
| 4 | 100 | r-- | Read only |
| 5 | 101 | r-x | Read + Execute |
| 6 | 110 | rw- | Read + Write |
| 7 | 111 | rwx | All permissions |
## 💻 Variables

```bash
# Declare variable
name="John"
count=42

# Use variable
echo $name
echo ${name}  # safer

# Command substitution
current_date=$(date)
files=$(ls -l)

# Arithmetic
result=$((5 + 3))
count=$((count + 1))

# String operations
length=${#name}           # String length
substring=${name:0:3}      # Extract substring
replaced=${name/old/new}   # Replace

# Default values
${var:-default}   # Use default if var is unset
${var:=default}   # Assign default if var is unset
```

### Special Variables

| Variable | Meaning |
|----------|---------|
| `$0` | Script name |
| `$1, $2, ...` | Positional arguments |
| `$@` | All arguments (as separate strings) |
| `$*` | All arguments (as single string) |
| `$#` | Number of arguments |
| `$?` | Exit status of last command |
| `$$` | Current process ID |
| `$!` | PID of last background job |
| `$USER` | Current username |
| `$HOME` | Home directory |
| `$PWD` | Current directory |
| `$RANDOM` | Random number |
### Environment Management
```bash
# Export variable to child processes
export VAR_NAME="value"

# Persist in shell profile (append to ~/.bashrc)
echo 'export PATH=$PATH:/opt/bin' >> ~/.bashrc
source ~/.bashrc

# Source .env file (load variables)
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Safer sourcing (handles spaces/comments)
set -a
source .env
set +a
```
## 🛠️ Argument Parsing
### Using getopts (Standard)
```bash
while getopts "n:v" opt; do
  case $opt in
    n) name="$OPTARG" ;;
    v) verbose=true ;;
    *) echo "Usage: $0 [-n name] [-v]" >&2
       exit 1 ;;
  esac
done
# Shift arguments to remove processed flags
shift "$((OPTIND-1))"
```
### Manual Loop (Advanced)
```bash
while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--name)
      name="$2"
      shift 2
      ;;
    -v|--verbose)
      verbose=true
      shift
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done
```

## 🔀 Control Flow
### If Statements
```bash
# Basic if
if [ condition ]; then
    commands
fi

# If-else
if [ condition ]; then
    commands
else
    other_commands
fi

# If-elif-else
if [ condition1 ]; then
    commands1
elif [ condition2 ]; then
    commands2
else
    commands3
fi

# Recommended: [[ ]] (more features)
if [[ $var == "value" ]]; then
    echo "Match!"
fi
```
### Test Conditions

#### File Tests
```bash
[ -e file ]    # File exists
[ -f file ]    # Regular file exists
[ -d dir ]     # Directory exists
[ -r file ]    # File is readable
[ -w file ]    # File is writable
[ -x file ]    # File is executable
[ -s file ]    # File exists and not empty
[ -L link ]    # Symbolic link exists
[ file1 -nt file2 ]  # file1 newer than file2
[ file1 -ot file2 ]  # file1 older than file2
```
#### String Tests
```bash
[ -z "$str" ]       # String is empty
[ -n "$str" ]       # String is not empty
[ "$s1" = "$s2" ]   # Strings are equal
[ "$s1" != "$s2" ]  # Strings are not equal

# With [[ ]] (better)
[[ $str == pattern ]]  # Pattern matching
[[ $str =~ regex ]]    # Regex matching
```
#### Numeric Tests
```bash
[ $a -eq $b ]  # Equal
[ $a -ne $b ]  # Not equal
[ $a -lt $b ]  # Less than
[ $a -le $b ]  # Less than or equal
[ $a -gt $b ]  # Greater than
[ $a -ge $b ]  # Greater than or equal

# Arithmetic comparison (recommended)
(( a == b ))
(( a < b ))
(( a > b ))
```
#### Logical Operators
```bash
[ cond1 ] && [ cond2 ]  # AND
[ cond1 ] || [ cond2 ]  # OR
! [ cond ]              # NOT

# Within [[ ]]
[[ cond1 && cond2 ]]
[[ cond1 || cond2 ]]
[[ ! cond ]]
```
## 🔁 Loops

### For Loop
```bash
# Iterate over list
for item in item1 item2 item3; do
    echo $item
done

# Iterate over files
for file in *.txt; do
    echo "Processing $file"
done

# C-style for loop
for ((i=0; i<10; i++)); do
    echo $i
done

# Range
for i in {1..10}; do
    echo $i
done
```
### While Loop
```bash
# While condition is true
while [ condition ]; do
    commands
done

# Read file line by line
while IFS= read -r line; do
    echo "$line"
done < file.txt

# Infinite loop
while true; do
    commands
    sleep 1
done
```
### Until Loop
```bash
# Until condition becomes true
until [ condition ]; do
    commands
done
```
### Loop Control
```bash
break      # Exit loop
continue   # Skip to next iteration
```
## 📝 Functions
```bash
# Define function
function_name() {
    commands
    return 0
}

# With 'function' keyword
function function_name {
    commands
}

# Call function
function_name

# With arguments
function_name arg1 arg2

# Access arguments in function
func() {
    echo "First arg: $1"
    echo "Second arg: $2"
    echo "All args: $@"
    echo "Arg count: $#"
}

# Return value
get_value() {
    echo "result"  # Output via stdout
}
result=$(get_value)

# Exit code
check_status() {
    if [ condition ]; then
        return 0  # Success
    else
        return 1  # Failure
    fi
}
```
## ⚡ Input/Output

### Redirection
```bash
# Redirect stdout to file (overwrite)
command > file.txt

# Redirect stdout to file (append)
command >> file.txt

# Redirect stderr to file
command 2> error.txt

# Redirect both stdout and stderr
command > output.txt 2>&1
command &> output.txt  # Bash shortcut

# Redirect stdin from file
command < input.txt

# Here document
cat << EOF
Line 1
Line 2
EOF

# Here string
grep "pattern" <<< "string to search"
```
### Pipes

```bash
# Pipe stdout to another command
command1 | command2

# Pipe chain
command1 | command2 | command3

# Tee (write to file AND stdout)
command | tee file.txt

# Tee append
command | tee -a file.txt
```
## 🎨 Text Processing

### grep
```bash
grep "pattern" file.txt       # Search
grep -i "pattern" file.txt    # Case-insensitive
grep -v "pattern" file.txt    # Invert (exclude)
grep -n "pattern" file.txt    # Show line numbers
grep -r "pattern" /path       # Recursive
grep -E "regex" file.txt      # Extended regex
grep -o "pattern" file.txt    # Only matching part
grep -A 3 "pattern" file.txt  # 3 lines after
grep -B 3 "pattern" file.txt  # 3 lines before
grep -C 3 "pattern" file.txt  # 3 lines context
```
### sed
```bash
# Replace first occurrence
sed 's/old/new/' file.txt

# Replace all occurrences
sed 's/old/new/g' file.txt

# Replace in-place (modify file)
sed -i 's/old/new/g' file.txt

# Delete lines matching pattern
sed '/pattern/d' file.txt

# Print only matching lines
sed -n '/pattern/p' file.txt

# Multiple operations
sed -e 's/old/new/g' -e 's/foo/bar/g' file.txt
```
### awk
```bash
# Print specific column
awk '{print $1}' file.txt

# Print multiple columns
awk '{print $1, $3}' file.txt

# With custom delimiter
awk -F':' '{print $1}' /etc/passwd

# Conditions
awk '$3 > 100 {print $1}' file.txt

# Sum column
awk '{sum+=$1} END {print sum}' file.txt

# Print line numbers
awk '{print NR, $0}' file.txt
```
### cut
```bash
# Extract specific field
cut -d':' -f1 /etc/passwd

# Extract multiple fields
cut -d':' -f1,3 /etc/passwd

# Extract character range
cut -c1-10 file.txt
```
### tr
```bash
# Replace characters
tr 'a-z' 'A-Z' < file.txt  # Lowercase to uppercase

# Delete characters
tr -d '[:digit:]' < file.txt  # Remove digits

# Squeeze repeats
tr -s ' ' < file.txt  # Replace multiple spaces with one
```
## 📊 Process Management
```bash
# Show running processes
ps aux
ps -ef

# Interactive process viewer
top
htop

# Find process by name
pgrep processname
ps aux | grep processname

# Kill process
kill PID
kill -9 PID  # Force kill

# Kill by name
pkill processname
killall processname

# Background job
command &

# List jobs
jobs

# Bring to foreground
fg %1

# Send to background
bg %1

# Wait for background jobs
wait
```
## ⏱️ Scheduling & Automation

### Cron Expressions
Edit crontab: `crontab -e`
List jobs: `crontab -l`
```bash
# Syntax: m h dom mon dow command
# m=minute, h=hour, dom=day of month, mon=month, dow=day of week

# Run every 5 minutes
*/5 * * * * /path/to/script.sh

# Run at 2:00 AM daily
0 2 * * * /path/to/backup.sh

# Run at 5:30 AM every Monday
30 5 * * 1 /path/to/report.sh

# Common Strings
@reboot     # Run at startup
@daily      # Run once a day (midnight)
@hourly     # Run once an hour
```
### Systemd Timer (Modern Alternative)
Create `service.timer` and `service.service` files for robust scheduling.
## 🔧 Useful Commands
### System Information
```bash
uname -a        # System info
hostname        # Hostname
whoami          # Current user
id              # User ID and groups
uptime          # System uptime
df -h           # Disk usage
du -sh /path    # Directory size
free -h         # Memory usage
date            # Current date/time
cal             # Calendar
```
### Remote Operations (SSH/SCP)
```bash
# Execute remote command
ssh user@host "ls -la /var/www"

# Execute local script remotely
ssh user@host "bash -s" < script.sh

# Secure copy (Upload)
scp local_file.txt user@host:/remote/path/

# Secure copy (Download)
scp user@host:/remote/file.txt local_dir/

# Recursive copy (Directories)
scp -r user@host:/remote/dir target_dir/

# Synchronize directories (Best for Automation)
rsync -avz -e ssh /local/dir/ user@host:/remote/dir/
```
### Networking
```bash
ip addr          # IP addresses
ping host        # Test connectivity
curl URL         # Fetch URL
wget URL         # Download file
ssh user@host    # Remote login
scp file user@host:/path  # Copy file remotely
```
### Archives
```bash
# Create tar archive
tar -czf archive.tar.gz directory/

# Extract tar archive
tar -xzf archive.tar.gz

# Create zip
zip -r archive.zip directory/

# Extract zip
unzip archive.zip

# View archive contents
tar -tzf archive.tar.gz
```
## 🐛 Debugging
```bash
# Enable debugging (print commands)
set -x
bash -x script.sh

# Disable debugging
set +x

# Exit on error
set -e

# Exit on undefined variable
set -u

# Combination (robust scripts)
set -euo pipefail

# Check syntax without running
bash -n script.sh

# ShellCheck (lint tool)
shellcheck script.sh
```
## 🎯 Best Practices

### Script Header
```bash
#!/bin/bash
set -euo pipefail

# Script: deploy.sh
# Description: Deploy application
# Author: Your Name
# Date: 2026-01-10

# Configuration
readonly APP_NAME="myapp"
readonly LOG_FILE="/var/log/${APP_NAME}.log"
```
### Error Handling
```bash
# Check command success
if ! command; then
    echo "Error: command failed" >&2
    exit 1
fi

# Always quote variables
rm "$file"  # GOOD
rm $file    # BAD (word splitting issues)

# Check if variable is set
: "${VAR:?Variable VAR must be set}"

# Use functions for reusability
error_exit() {
    echo "ERROR: $1" >&2
    exit 1
}
```
### Portable Scripts
```bash
# Use portable shebang
#!/usr/bin/env bash

# Check dependencies
command -v jq >/dev/null 2>&1 || {
    echo "Error: jq is required" >&2
    exit 1
}
```
## ⌨️ Shell Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl + A` | Move to line start |
| `Ctrl + E` | Move to line end |
| `Ctrl + U` | Clear line before cursor |
| `Ctrl + K` | Clear line after cursor |
| `Ctrl + W` | Delete word before cursor |
| `Ctrl + L` | Clear screen |
| `Ctrl + R` | Search command history |
| `Ctrl + C` | Cancel command |
| `Ctrl + D` | Exit shell |
| `Ctrl + Z` | Suspend process |
| `!!` | Repeat last command |
| `!$` | Last argument of last command |
| `!*` | All arguments of last command |


## 🏗️ Production Templates

### Starter Boilerplate
A robust starting point for any script.

```bash
#!/usr/bin/env bash

# Strict Mode
set -euo pipefail
IFS=$'\n\t' 

# Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${SCRIPT_DIR}/script.log"

# Logging Helper
log() {
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [${1:-INFO}] $2" | tee -a "$LOG_FILE"
}

# Usage / Help
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help      Show this help message
  -v, --verbose   Enable verbose logging
EOF
    exit 0
}

# Main Logic
main() {
    local verbose=false
    
    # Simple argument parsing
    while getopts "hv" opt; do
        case $opt in
            h) usage ;;
            v) verbose=true ;;
            *) usage ;;
        esac
    done

    log "INFO" "Script started"
    
    if [ "$verbose" = true ]; then
        log "DEBUG" "Verbose mode enabled"
    fi
    
    # Your code here
    
    log "INFO" "Script completed successfully"
}

main "$@"
```
## 📚 Quick Examples

### Backup Script
```bash
#!/bin/bash
set -euo pipefail

BACKUP_DIR="/backup"
SOURCE="/data"
DATE=$(date +%Y%m%d_%H%M%S)

tar -czf "${BACKUP_DIR}/backup_${DATE}.tar.gz" "$SOURCE"
echo "Backup completed: backup_${DATE}.tar.gz"
```

### System Health Check
```bash
#!/bin/bash

CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
MEMORY=$(free | grep Mem | awk '{printf("%.2f"), $3/$2 * 100.0}')
DISK=$(df -h / | tail -1 | awk '{print $5}' | cut -d'%' -f1)

echo "CPU Usage: ${CPU}%"
echo "Memory Usage: ${MEMORY}%"
echo "Disk Usage: ${DISK}%"

[ "${DISK%.*}" -gt 90 ] && echo "WARNING: Disk usage critical!"
```

### Log Analysis
```bash
#!/bin/bash

LOG_FILE="/var/log/app.log"
ERROR_COUNT=$(grep -c "ERROR" "$LOG_FILE")
WARN_COUNT=$(grep -c "WARN" "$LOG_FILE")

echo "Errors: $ERROR_COUNT"
echo "Warnings: $WARN_COUNT"

echo -e "\nLast 5 errors:"
grep "ERROR" "$LOG_FILE" | tail -5
```

---

**📌 Pro Tip**: Save this cheat sheet as `~/cheatsheet.md` and alias it:
```bash
alias cheat='less ~/cheatsheet.md'
```

**🔗 Related Resources**:
- [Main Automation README](../../../README.md)
- [Master Index](../../../03-Go-Basics/GO_AUTOMATION_MASTER_INDEX.md)
- [Organization Plan](../../../03-Go-Basics/GO_AUTOMATION_ORGANIZATION_PLAN.md)

---

**Version**: 1.0.0  
**Last Updated**: 2026-01-10  
**Print-Friendly**: Yes ✅

🚀 **Keep scripting!**
