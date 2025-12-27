# Linux Commands Reference for SysAdmin/DevOps/DevSecOps Engineers

## File and Directory Operations

### Basic Navigation and Listing

#### `ls` - List Directory Contents
```bash
ls                          # List files in current directory
ls -l                       # Long format with permissions, ownership, size, date
ls -la                      # Include hidden files (starting with .)
ls -lh                      # Human-readable file sizes (K, M, G)
ls -lt                      # Sort by modification time (newest first)
ls -ltr                     # Sort by modification time (oldest first)
ls -lS                      # Sort by file size (largest first)
ls -R                       # Recursive listing of subdirectories
ls -i                       # Show inode numbers
ls --color=auto             # Colorize output
ls -d */                    # List only directories
ls -1                       # One file per line
```

#### `cd` - Change Directory
```bash
cd /path/to/directory       # Change to absolute path
cd ../                      # Go up one directory level
cd ~                        # Go to home directory
cd -                        # Go to previous directory
cd                          # Go to home directory (same as cd ~)
```

#### `pwd` - Print Working Directory
```bash
pwd                         # Show current directory path
pwd -P                      # Show physical path (resolve symlinks)
```

### File and Directory Creation/Removal

#### `mkdir` - Create Directories
```bash
mkdir directory_name        # Create single directory
mkdir -p /path/to/nested/dirs  # Create nested directories
mkdir -m 755 directory      # Create with specific permissions
mkdir dir1 dir2 dir3        # Create multiple directories
mkdir -v directory          # Verbose output
```

#### `rmdir` - Remove Empty Directories
```bash
rmdir directory_name        # Remove empty directory
rmdir -p path/to/empty/dirs # Remove nested empty directories
rmdir -v directory          # Verbose output
```

#### `rm` - Remove Files and Directories
```bash
rm file.txt                 # Remove single file
rm file1.txt file2.txt      # Remove multiple files
rm -f file.txt              # Force removal (no prompts)
rm -i file.txt              # Interactive removal (prompt for each)
rm -r directory             # Remove directory recursively
rm -rf directory            # Force recursive removal
rm *.log                    # Remove all .log files
rm -v file.txt              # Verbose output
```

#### `touch` - Create Empty Files or Update Timestamps
```bash
touch file.txt              # Create empty file or update timestamp
touch file1.txt file2.txt   # Create multiple files
touch -t 202401151200 file.txt  # Set specific timestamp (YYYYMMDDhhmm)
touch -r reference_file new_file  # Copy timestamp from reference file
```

### File Operations

#### `cp` - Copy Files and Directories
```bash
cp source.txt destination.txt     # Copy file
cp source.txt /path/to/dest/      # Copy to directory
cp -r source_dir dest_dir         # Copy directory recursively
cp -p file.txt backup.txt         # Preserve permissions and timestamps
cp -u source.txt dest.txt         # Copy only if source is newer
cp -v source.txt dest.txt         # Verbose output
cp -a source_dir dest_dir         # Archive mode (preserve all attributes)
cp --backup=numbered file.txt dest.txt  # Create numbered backups
```

#### `mv` - Move/Rename Files and Directories
```bash
mv old_name.txt new_name.txt      # Rename file
mv file.txt /path/to/dest/        # Move file to directory
mv dir1 dir2                      # Rename directory
mv -i file.txt dest.txt           # Interactive (prompt before overwrite)
mv -u source.txt dest.txt         # Move only if source is newer
mv -v file.txt dest.txt           # Verbose output
mv *.txt /backup/                 # Move all .txt files
```

#### `ln` - Create Links
```bash
ln target_file link_name          # Create hard link
ln -s target_file symlink_name    # Create symbolic link
ln -sf new_target existing_link   # Force update symbolic link
ln -v target link                 # Verbose output
```

### File Content Operations

#### `cat` - Display File Contents
```bash
cat file.txt                      # Display entire file
cat file1.txt file2.txt           # Display multiple files
cat -n file.txt                   # Display with line numbers
cat -b file.txt                   # Number non-blank lines only
cat -A file.txt                   # Show all characters (including non-printing)
cat > file.txt                    # Create file from stdin (Ctrl+D to end)
cat >> file.txt                   # Append to file from stdin
```

#### `less` and `more` - Page Through Files
```bash
less file.txt                     # Page through file (better than more)
less +F file.txt                  # Follow file like tail -f
less +/pattern file.txt           # Start at first occurrence of pattern
more file.txt                     # Page through file (basic pager)

# Less navigation keys:
# Space/f - Next page
# b - Previous page
# / - Search forward
# ? - Search backward
# n - Next search result
# N - Previous search result
# q - Quit
```

#### `head` and `tail` - Display File Portions
```bash
head file.txt                     # Show first 10 lines
head -n 20 file.txt               # Show first 20 lines
head -c 100 file.txt              # Show first 100 characters
tail file.txt                     # Show last 10 lines
tail -n 20 file.txt               # Show last 20 lines
tail -f file.txt                  # Follow file (monitor for new content)
tail -F file.txt                  # Follow file even if rotated
tail -n +10 file.txt              # Show from line 10 to end
```

## Text Processing and Search

### `grep` - Search Text Patterns
```bash
grep "pattern" file.txt           # Search for pattern in file
grep -i "pattern" file.txt        # Case-insensitive search
grep -v "pattern" file.txt        # Invert match (lines NOT containing pattern)
grep -n "pattern" file.txt        # Show line numbers
grep -c "pattern" file.txt        # Count matching lines
grep -r "pattern" /path/          # Recursive search in directory
grep -l "pattern" *.txt           # Show only filenames with matches
grep -w "word" file.txt           # Match whole words only
grep -E "regex" file.txt          # Extended regex (same as egrep)
grep -F "string" file.txt         # Fixed string search (same as fgrep)
grep -A 3 "pattern" file.txt      # Show 3 lines after match
grep -B 3 "pattern" file.txt      # Show 3 lines before match
grep -C 3 "pattern" file.txt      # Show 3 lines before and after match
grep --color=always "pattern" file.txt  # Highlight matches
```

### `sed` - Stream Editor
```bash
sed 's/old/new/' file.txt         # Replace first occurrence per line
sed 's/old/new/g' file.txt        # Replace all occurrences
sed 's/old/new/gi' file.txt       # Case-insensitive global replace
sed -i 's/old/new/g' file.txt     # Edit file in-place
sed -i.bak 's/old/new/g' file.txt # Edit in-place with backup
sed '5d' file.txt                 # Delete line 5
sed '1,5d' file.txt               # Delete lines 1-5
sed '/pattern/d' file.txt         # Delete lines matching pattern
sed -n '5,10p' file.txt           # Print lines 5-10 only
sed 'G' file.txt                  # Double-space file
```

### `awk` - Pattern Scanning and Processing
```bash
awk '{print $1}' file.txt         # Print first field
awk '{print $NF}' file.txt        # Print last field
awk '{print NR, $0}' file.txt     # Print line number and line
awk '/pattern/ {print $2}' file.txt  # Print second field of matching lines
awk -F: '{print $1}' /etc/passwd  # Use colon as field separator
awk '{sum += $1} END {print sum}' file.txt  # Sum first column
awk 'length > 80' file.txt        # Print lines longer than 80 characters
awk '{print NF}' file.txt         # Print number of fields per line
awk 'NR==5' file.txt              # Print line 5
awk 'NR>=5 && NR<=10' file.txt    # Print lines 5-10
```

### `sort` - Sort Lines
```bash
sort file.txt                     # Sort lines alphabetically
sort -n file.txt                  # Numeric sort
sort -r file.txt                  # Reverse sort
sort -u file.txt                  # Sort and remove duplicates
sort -k2 file.txt                 # Sort by second field
sort -k2,2n file.txt              # Numeric sort by second field only
sort -t: -k3n /etc/passwd         # Sort by third field using colon separator
sort -f file.txt                  # Case-insensitive sort
sort -h file.txt                  # Human-readable numeric sort (1K, 2M, 3G)
```

### `uniq` - Report or Omit Repeated Lines
```bash
uniq file.txt                     # Remove consecutive duplicate lines
uniq -c file.txt                  # Count occurrences
uniq -d file.txt                  # Show only duplicate lines
uniq -u file.txt                  # Show only unique lines
uniq -i file.txt                  # Case-insensitive comparison
sort file.txt | uniq              # Remove all duplicates (not just consecutive)
```

### `cut` - Extract Columns
```bash
cut -d: -f1 /etc/passwd           # Extract first field using colon delimiter
cut -c1-10 file.txt               # Extract characters 1-10
cut -f2,4 file.txt                # Extract fields 2 and 4 (tab-delimited)
cut -d, -f1-3 file.csv            # Extract first 3 fields from CSV
```

### `tr` - Translate Characters
```bash
tr 'a-z' 'A-Z' < file.txt         # Convert lowercase to uppercase
tr -d '0-9' < file.txt            # Delete all digits
tr -s ' ' < file.txt              # Squeeze multiple spaces to single space
tr '\n' ' ' < file.txt            # Replace newlines with spaces
tr -c 'a-zA-Z0-9\n' '_' < file.txt  # Replace non-alphanumeric with underscore
```

## File Permissions and Ownership

### `chmod` - Change File Permissions
```bash
chmod 755 file.txt                # rwxr-xr-x (owner: rwx, group: r-x, other: r-x)
chmod 644 file.txt                # rw-r--r-- (owner: rw-, group: r--, other: r--)
chmod +x script.sh                # Add execute permission for all
chmod u+x script.sh               # Add execute permission for owner
chmod g-w file.txt                # Remove write permission for group
chmod o-r file.txt                # Remove read permission for others
chmod a+r file.txt                # Add read permission for all (a=ugo)
chmod -R 755 directory            # Recursive permission change
chmod u=rwx,g=rx,o=rx file.txt    # Set specific permissions
chmod --reference=ref_file target_file  # Copy permissions from reference file
```

### `chown` - Change File Ownership
```bash
chown user file.txt               # Change owner
chown user:group file.txt         # Change owner and group
chown :group file.txt             # Change group only
chown -R user:group directory     # Recursive ownership change
chown --reference=ref_file target_file  # Copy ownership from reference file
```

### `chgrp` - Change Group Ownership
```bash
chgrp group file.txt              # Change group
chgrp -R group directory          # Recursive group change
```

### `umask` - Set Default Permissions
```bash
umask                             # Show current umask
umask 022                         # Set umask (new files: 644, directories: 755)
umask 077                         # Restrictive umask (new files: 600, directories: 700)
```

## Process Management

### `ps` - Display Running Processes
```bash
ps                                # Show processes for current user
ps aux                            # Show all processes with detailed info
ps -ef                            # Show all processes in full format
ps -u username                    # Show processes for specific user
ps -C process_name                # Show processes by name
ps --forest                       # Show process tree
ps -o pid,ppid,cmd                # Custom output format
ps aux --sort=-%cpu               # Sort by CPU usage (highest first)
ps aux --sort=-%mem               # Sort by memory usage (highest first)
```

### `top` and `htop` - Real-time Process Monitoring
```bash
top                               # Real-time process viewer
top -u username                   # Show processes for specific user
top -p PID                        # Monitor specific process
htop                              # Enhanced interactive process viewer

# Top interactive keys:
# k - Kill process
# r - Renice process
# M - Sort by memory usage
# P - Sort by CPU usage
# T - Sort by running time
# q - Quit
```

### `kill` - Terminate Processes
```bash
kill PID                          # Send TERM signal to process
kill -9 PID                       # Send KILL signal (force kill)
kill -15 PID                      # Send TERM signal (graceful shutdown)
kill -HUP PID                     # Send HUP signal (reload config)
kill -USR1 PID                    # Send USR1 signal
killall process_name              # Kill all processes by name
killall -9 process_name           # Force kill all processes by name
pkill pattern                     # Kill processes matching pattern
pgrep pattern                     # Find process IDs matching pattern
```

### `jobs` and Background Processes
```bash
command &                         # Run command in background
jobs                              # List active jobs
jobs -l                           # List jobs with PIDs
fg %1                             # Bring job 1 to foreground
bg %1                             # Send job 1 to background
nohup command &                   # Run command immune to hangups
disown %1                         # Remove job from shell's job table
```

### `systemctl` - Systemd Service Management
```bash
systemctl status service_name     # Show service status
systemctl start service_name      # Start service
systemctl stop service_name       # Stop service
systemctl restart service_name    # Restart service
systemctl reload service_name     # Reload service configuration
systemctl enable service_name     # Enable service at boot
systemctl disable service_name    # Disable service at boot
systemctl list-units              # List all units
systemctl list-units --failed     # List failed units
systemctl daemon-reload           # Reload systemd configuration
systemctl mask service_name       # Mask service (prevent start)
systemctl unmask service_name     # Unmask service
```

## System Information and Monitoring

### System Information Commands
```bash
uname -a                          # System information
uname -r                          # Kernel version
hostname                          # System hostname
hostname -I                       # IP addresses
uptime                            # System uptime and load
whoami                            # Current username
id                                # User and group IDs
w                                 # Who is logged in and what they're doing
who                               # Who is logged in
last                              # Last login history
lastlog                           # Last login for all users
```

### Hardware Information
```bash
lscpu                             # CPU information
lsblk                             # Block devices
lsusb                             # USB devices
lspci                             # PCI devices
lshw                              # Hardware information
dmidecode                         # DMI/SMBIOS information
cat /proc/cpuinfo                 # CPU details
cat /proc/meminfo                 # Memory information
cat /proc/version                 # Kernel version details
```

### Memory and Storage
```bash
free -h                           # Memory usage (human-readable)
free -m                           # Memory usage in MB
df -h                             # Disk space usage (human-readable)
df -i                             # Inode usage
du -h /path                       # Directory size (human-readable)
du -sh /path                      # Summary of directory size
du -ah /path | sort -rh | head -10  # Top 10 largest files/directories
lsof                              # List open files
lsof /path/to/file                # Processes using specific file
lsof -p PID                       # Files opened by specific process
lsof -i :80                       # Processes using port 80
```

### Performance Monitoring
```bash
iostat                            # I/O statistics
iostat -x 1                       # Extended I/O stats every second
vmstat                            # Virtual memory statistics
vmstat 1 5                        # VM stats every second for 5 times
sar -u 1 10                       # CPU usage every second for 10 times
sar -r 1 10                       # Memory usage statistics
sar -d 1 10                       # Disk activity statistics
mpstat                            # Multi-processor statistics
iotop                             # I/O usage by process (requires installation)
```

## Network Commands

### Network Configuration
```bash
ip addr show                      # Show IP addresses
ip addr add 192.168.1.100/24 dev eth0  # Add IP address
ip addr del 192.168.1.100/24 dev eth0  # Remove IP address
ip route show                     # Show routing table
ip route add default via 192.168.1.1   # Add default route
ip link show                      # Show network interfaces
ip link set eth0 up               # Bring interface up
ip link set eth0 down             # Bring interface down
```

### Network Connectivity
```bash
ping host                         # Test connectivity
ping -c 4 host                    # Ping 4 times only
ping6 host                        # IPv6 ping
traceroute host                   # Trace route to host
tracepath host                    # Trace path to host
mtr host                          # Network diagnostic tool (combines ping and traceroute)
```

### Network Services and Ports
```bash
netstat -tuln                     # Show listening ports
netstat -tulpn                    # Show listening ports with process names
netstat -an                       # Show all connections
ss -tuln                          # Modern replacement for netstat
ss -tulpn                         # Show listening ports with processes
ss -s                             # Show socket statistics
lsof -i                           # Show network connections
lsof -i :80                       # Show processes using port 80
nmap localhost                    # Port scan localhost
nmap -sS target                   # SYN scan
```

### Network File Transfer
```bash
wget http://example.com/file.txt  # Download file
wget -c http://example.com/file.txt  # Continue partial download
wget -r http://example.com/       # Recursive download
curl http://example.com           # Transfer data from server
curl -O http://example.com/file.txt  # Download and save file
curl -I http://example.com        # Show headers only
curl -X POST -d "data" http://api.example.com  # POST request
scp file.txt user@host:/path/     # Secure copy to remote host
scp user@host:/path/file.txt .    # Secure copy from remote host
rsync -av source/ destination/    # Synchronize directories
rsync -av --delete source/ dest/  # Sync and delete extra files
```

## Archive and Compression

### `tar` - Archive Files
```bash
tar -cvf archive.tar files/       # Create tar archive
tar -czvf archive.tar.gz files/   # Create gzipped tar archive
tar -cjvf archive.tar.bz2 files/  # Create bzip2 compressed archive
tar -xvf archive.tar              # Extract tar archive
tar -xzvf archive.tar.gz          # Extract gzipped archive
tar -xjvf archive.tar.bz2         # Extract bzip2 archive
tar -tvf archive.tar              # List contents without extracting
tar -xvf archive.tar file.txt     # Extract specific file
tar --exclude='*.log' -czf archive.tar.gz /path/  # Exclude pattern
```

### Compression Utilities
```bash
gzip file.txt                     # Compress file (creates file.txt.gz)
gunzip file.txt.gz                # Decompress gzip file
zcat file.txt.gz                  # View compressed file without extracting
bzip2 file.txt                    # Compress with bzip2
bunzip2 file.txt.bz2              # Decompress bzip2 file
zip archive.zip files/            # Create zip archive
unzip archive.zip                 # Extract zip archive
unzip -l archive.zip              # List zip contents
```

## User and Group Management

### User Management
```bash
useradd username                  # Add user
useradd -m username               # Add user with home directory
useradd -m -s /bin/bash username  # Add user with specific shell
usermod -aG group username        # Add user to group
usermod -s /bin/zsh username      # Change user shell
userdel username                  # Delete user
userdel -r username               # Delete user and home directory
passwd username                   # Change user password
chage -l username                 # Show password aging info
chage -E 2024-12-31 username      # Set account expiry date
```

### Group Management
```bash
groupadd groupname                # Add group
groupmod -n newname oldname       # Rename group
groupdel groupname                # Delete group
groups username                   # Show user's groups
id username                       # Show user and group IDs
getent passwd username            # Get user info from database
getent group groupname            # Get group info from database
```

### Sudo and Privileges
```bash
sudo command                      # Run command as root
sudo -u username command          # Run command as specific user
sudo -i                           # Switch to root shell
sudo -s                           # Run shell as root
visudo                            # Edit sudoers file safely
sudo -l                           # List allowed commands for current user
```

## File System Operations

### Disk and Partition Management
```bash
fdisk -l                          # List all disks and partitions
fdisk /dev/sda                    # Partition disk (interactive)
parted -l                         # List partitions (parted)
lsblk                             # List block devices in tree format
blkid                             # Show block device attributes
```

### File System Creation and Mounting
```bash
mkfs.ext4 /dev/sda1               # Create ext4 filesystem
mkfs.xfs /dev/sda1                # Create XFS filesystem
mount /dev/sda1 /mnt              # Mount filesystem
mount -t ext4 /dev/sda1 /mnt      # Mount with specific type
umount /mnt                       # Unmount filesystem
mount -a                          # Mount all filesystems in /etc/fstab
mount | grep ext4                 # Show mounted ext4 filesystems
```

### File System Checking
```bash
fsck /dev/sda1                    # Check filesystem
fsck -y /dev/sda1                 # Auto-repair filesystem
e2fsck /dev/sda1                  # Check ext2/3/4 filesystem
xfs_repair /dev/sda1              # Repair XFS filesystem
```

## Log Management and Analysis

### System Logs with `journalctl`
```bash
journalctl                        # Show all journal entries
journalctl -f                     # Follow journal (like tail -f)
journalctl -u service_name        # Show logs for specific service
journalctl -u service_name -f     # Follow service logs
journalctl --since "2024-01-01"  # Show logs since date
journalctl --since "1 hour ago"  # Show logs from last hour
journalctl --until "2024-01-01"  # Show logs until date
journalctl -p err                 # Show error level logs only
journalctl -p warning..err        # Show warning and error logs
journalctl -n 50                  # Show last 50 entries
journalctl --disk-usage           # Show journal disk usage
journalctl --vacuum-time=7d       # Remove logs older than 7 days
journalctl --vacuum-size=100M     # Keep only 100MB of logs
```

### Traditional Log Files
```bash
tail -f /var/log/syslog           # Follow system log
tail -f /var/log/auth.log         # Follow authentication log
tail -f /var/log/nginx/access.log # Follow web server access log
grep "ERROR" /var/log/application.log  # Search for errors
grep "$(date '+%b %d')" /var/log/syslog  # Today's logs
zgrep "pattern" /var/log/old.log.gz  # Search in compressed logs
```

### Log Analysis
```bash
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr  # Top IP addresses
grep "404" /var/log/nginx/access.log | wc -l  # Count 404 errors
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c  # Failed login attempts by IP
```

## Security and Monitoring Commands

### Security Scanning and Monitoring
```bash
nmap -sS target                   # Stealth port scan
nmap -sV target                   # Version detection scan
nmap -O target                    # OS detection scan
nmap -A target                    # Aggressive scan (OS, version, script, traceroute)
ss -tuln                          # Show listening ports
netstat -tulpn                    # Show listening ports with processes
lsof -i                           # Show network connections
```

### File Integrity and Security
```bash
find /etc -type f -perm /o+w      # Find world-writable files
find / -type f -perm /u+s         # Find SUID files
find / -type f -perm /g+s         # Find SGID files
find /tmp -type f -atime +7       # Find files not accessed in 7 days
md5sum file.txt                   # Calculate MD5 checksum
sha256sum file.txt                # Calculate SHA256 checksum
```

### Process and System Monitoring
```bash
ps aux --sort=-%cpu | head -10    # Top CPU consuming processes
ps aux --sort=-%mem | head -10    # Top memory consuming processes
lsof +D /path                     # Files open in directory
lsof -u username                  # Files opened by user
strace -p PID                     # Trace system calls of process
ltrace -p PID                     # Trace library calls of process
```

## Environment and Variables

### Environment Variables
```bash
env                               # Show all environment variables
printenv                          # Show all environment variables
echo $PATH                        # Show PATH variable
export VAR_NAME=value             # Set environment variable
unset VAR_NAME                    # Remove environment variable
export PATH=$PATH:/new/path       # Add to PATH
```

### Shell Configuration
```bash
source ~/.bashrc                  # Reload bash configuration
. ~/.bashrc                       # Reload bash configuration (alternative)
which command                     # Show path to command
type command                      # Show command type and location
alias ll='ls -la'                 # Create alias
unalias ll                        # Remove alias
history                           # Show command history
history | grep pattern            # Search command history
!!                                # Repeat last command
!n                                # Repeat command number n
```

## Package Management

### APT (Debian/Ubuntu)
```bash
apt update                        # Update package list
apt upgrade                       # Upgrade installed packages
apt install package_name          # Install package
apt remove package_name           # Remove package
apt purge package_name            # Remove package and config files
apt autoremove                    # Remove unnecessary packages
apt search pattern                # Search for packages
apt show package_name             # Show package information
apt list --installed              # List installed packages
apt list --upgradable             # List upgradable packages
```

### YUM/DNF (Red Hat/CentOS/Fedora)
```bash
yum update                        # Update all packages
yum install package_name          # Install package
yum remove package_name           # Remove package
yum search pattern                # Search for packages
yum info package_name             # Show package information
yum list installed                # List installed packages
yum history                       # Show transaction history
dnf update                        # DNF equivalent (newer systems)
dnf install package_name          # DNF install
```

## Advanced File Operations

### `find` - Search for Files and Directories
```bash
find /path -name "filename"       # Find by name
find /path -iname "filename"      # Case-insensitive name search
find /path -type f                # Find files only
find /path -type d                # Find directories only
find /path -size +100M            # Find files larger than 100MB
find /path -size -1M              # Find files smaller than 1MB
find /path -mtime -7              # Find files modified in last 7 days
find /path -mtime +30             # Find files modified more than 30 days ago
find /path -user username         # Find files owned by user
find /path -group groupname       # Find files owned by group
find /path -perm 755              # Find files with specific permissions
find /path -name "*.log" -delete  # Find and delete .log files
find /path -name "*.txt" -exec grep "pattern" {} \;  # Execute command on found files
find /path -empty                 # Find empty files and directories
```

### `locate` - Fast File Search
```bash
locate filename                   # Find files by name (uses database)
updatedb                          # Update locate database
locate -i filename                # Case-insensitive search
locate -c filename                # Count matches
```

### File Comparison
```bash
diff file1.txt file2.txt          # Compare files line by line
diff -u file1.txt file2.txt       # Unified diff format
diff -r dir1 dir2                 # Compare directories recursively
cmp file1.txt file2.txt           # Compare files byte by byte
comm file1.txt file2.txt          # Compare sorted files
```

## Text Editors (Command Line)

### `vi`/`vim` - Vi/Vim Editor
```bash
vi filename                       # Open file in vi
vim filename                      # Open file in vim

# Vim modes:
# Normal mode (default) - navigation and commands
# Insert mode (i, a, o) - text editing
# Command mode (:) - save, quit, search/replace

# Basic vim commands:
# i - Insert mode
# a - Append mode
# o - Open new line
# Esc - Return to normal mode
# :w - Save file
# :q - Quit
# :wq - Save and quit
# :q! - Quit without saving
# /pattern - Search forward
# ?pattern - Search backward
# n - Next search result
# N - Previous search result
# dd - Delete line
# yy - Copy line
# p - Paste
# u - Undo
# Ctrl+r - Redo
```

### `nano` - Simple Text Editor
```bash
nano filename                     # Open file in nano

# Nano shortcuts:
# Ctrl+O - Save file
# Ctrl+X - Exit
# Ctrl+W - Search
# Ctrl+K - Cut line
# Ctrl+U - Paste
# Ctrl+G - Help
```

## System Administration Tasks

### Cron Jobs - Task Scheduling
```bash
crontab -l                        # List current user's cron jobs
crontab -e                        # Edit current user's cron jobs
crontab -r                        # Remove all cron jobs
crontab -u username -l            # List another user's cron jobs
crontab -u username -e            # Edit another user's cron jobs

# Cron format: minute hour day month day_of_week command
# Examples:
# 0 2 * * * /backup/script.sh     # Daily at 2 AM
# */15 * * * * /check/script.sh    # Every 15 minutes
# 0 0 1 * * /monthly/script.sh     # Monthly on 1st day
# 0 9-17 * * 1-5 /work/script.sh   # Weekdays 9 AM to 5 PM
```

### System Services and Daemons
```bash
service --status-all              # List all services (SysV)
chkconfig --list                  # List services and run levels (SysV)
systemctl list-unit-files         # List all systemd units
systemctl list-units --type=service  # List active services
systemctl is-enabled service_name # Check if service is enabled
systemctl is-active service_name  # Check if service is running
```

### System Resources and Limits
```bash
ulimit -a                         # Show all limits
ulimit -n                         # Show file descriptor limit
ulimit -n 65536                   # Set file descriptor limit
ulimit -u                         # Show process limit
ulimit -f                         # Show file size limit
```

## Troubleshooting Commands

### System Diagnostics
```bash
dmesg                             # Kernel ring buffer messages
dmesg | tail                      # Recent kernel messages
dmesg | grep -i error             # Kernel error messages
lsmod                             # List loaded kernel modules
modinfo module_name               # Show module information
```

### Process Debugging
```bash
strace command                    # Trace system calls
strace -p PID                     # Trace running process
ltrace command                    # Trace library calls
gdb program                       # GNU debugger
gdb -p PID                        # Attach debugger to running process
```

### Network Troubleshooting
```bash
ping -c 4 8.8.8.8                # Test internet connectivity
nslookup domain.com               # DNS lookup
dig domain.com                    # DNS lookup (more detailed)
host domain.com                   # DNS lookup (simple)
route -n                          # Show routing table
arp -a                            # Show ARP table
tcpdump -i eth0                   # Capture network packets
tcpdump -i eth0 port 80           # Capture HTTP traffic
```

This comprehensive reference covers the essential Linux commands that every sysadmin, DevOps, and DevSecOps engineer should master. Each command includes practical examples and common use cases encountered in production environments.