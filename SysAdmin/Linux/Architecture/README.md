# Linux System Architecture

Complete guide to Linux system architecture, file hierarchy, and core components.

## Linux File System Hierarchy

### Root Directory Structure
```bash
/                   # Root directory
├── bin/           # Essential user binaries
├── boot/          # Boot loader files
├── dev/           # Device files
├── etc/           # System configuration files
├── home/          # User home directories
├── lib/           # Essential shared libraries
├── media/         # Removable media mount points
├── mnt/           # Temporary mount points
├── opt/           # Optional software packages
├── proc/          # Process and kernel information
├── root/          # Root user home directory
├── run/           # Runtime data
├── sbin/          # System binaries
├── srv/           # Service data
├── sys/           # System information
├── tmp/           # Temporary files
├── usr/           # User programs and data
└── var/           # Variable data files
```

### Key Directories Explained
```bash
# /etc - Configuration Files
/etc/passwd        # User account information
/etc/group         # Group information
/etc/shadow        # Encrypted passwords
/etc/fstab         # File system mount table
/etc/hosts         # Host name to IP address mappings
/etc/resolv.conf   # DNS resolver configuration
/etc/crontab       # System cron jobs

# /var - Variable Data
/var/log/          # Log files
/var/spool/        # Spool directories
/var/cache/        # Cache data
/var/lib/          # State information
/var/run/          # Runtime data (symlink to /run)

# /usr - User Programs
/usr/bin/          # User binaries
/usr/sbin/         # System binaries
/usr/lib/          # Libraries
/usr/share/        # Shared data
/usr/local/        # Local software
```

## Process Management

### Process States
```bash
# Process States
R - Running or runnable
S - Interruptible sleep
D - Uninterruptible sleep
T - Stopped
Z - Zombie
X - Dead

# Process Information
ps aux             # All processes
ps -ef             # Full format listing
pstree             # Process tree
top                # Real-time process viewer
htop               # Enhanced process viewer
```

### Process Control
```bash
# Signal Management
kill -l            # List all signals
kill -9 PID        # SIGKILL (force terminate)
kill -15 PID       # SIGTERM (graceful terminate)
kill -1 PID        # SIGHUP (reload configuration)
killall process    # Kill by process name
pkill -f pattern   # Kill by pattern

# Job Control
command &          # Run in background
jobs               # List active jobs
fg %1              # Bring job to foreground
bg %1              # Send job to background
nohup command &    # Run immune to hangups
disown %1          # Remove job from shell
```

## Memory Management

### Virtual Memory System
```bash
# Memory Information
free -h            # Memory usage summary
cat /proc/meminfo  # Detailed memory information
vmstat 1 5         # Virtual memory statistics
pmap PID           # Process memory map

# Memory Types
Physical Memory    # RAM
Virtual Memory     # Physical + Swap
Swap Space        # Disk-based virtual memory
Buffer Cache      # File system buffers
Page Cache        # File content cache
```

### Memory Monitoring
```bash
# Memory Usage by Process
ps aux --sort=-%mem | head -10
top -o %MEM
smem -r            # Memory usage with shared memory

# System Memory Pressure
cat /proc/pressure/memory
dmesg | grep -i "killed process"  # OOM killer messages
```

## I/O and Storage

### Block Devices
```bash
# Device Information
lsblk              # List block devices
fdisk -l           # Partition information
blkid              # Block device attributes
df -h              # File system usage
du -sh /path       # Directory usage

# Device Files
/dev/sda           # First SCSI/SATA drive
/dev/nvme0n1       # First NVMe drive
/dev/mapper/       # Device mapper devices (LVM, LUKS)
/dev/md0           # Software RAID device
```

### File Systems
```bash
# File System Types
ext4               # Fourth extended file system
xfs                # XFS file system
btrfs              # B-tree file system
zfs                # ZFS file system
tmpfs              # Temporary file system in RAM

# File System Operations
mkfs.ext4 /dev/sdb1        # Create ext4 file system
mount /dev/sdb1 /mnt       # Mount file system
umount /mnt                # Unmount file system
fsck /dev/sdb1             # Check file system
tune2fs -l /dev/sdb1       # File system information
```

## Network Architecture

### Network Stack
```bash
# OSI Model in Linux
Application Layer  # User applications (HTTP, SSH, FTP)
Transport Layer    # TCP/UDP protocols
Network Layer      # IP routing
Data Link Layer    # Ethernet, WiFi
Physical Layer     # Hardware interfaces

# Network Configuration
ip addr show       # Show IP addresses
ip route show      # Show routing table
ip link show       # Show network interfaces
ss -tuln           # Socket statistics
netstat -i         # Interface statistics
```

### Network Namespaces
```bash
# Network Namespace Management
ip netns list                    # List namespaces
ip netns add myns               # Create namespace
ip netns exec myns ip addr     # Execute in namespace
ip netns delete myns            # Delete namespace

# Container Networking
docker network ls               # Docker networks
kubectl get pods -o wide       # Kubernetes pod IPs
```

## System Services

### systemd Architecture
```bash
# systemd Components
systemd            # Init system and service manager
systemctl          # Service control command
journalctl         # Log viewer
systemd-analyze    # Boot performance analysis

# Service Management
systemctl status service       # Service status
systemctl start service        # Start service
systemctl stop service         # Stop service
systemctl enable service       # Enable at boot
systemctl disable service      # Disable at boot
systemctl reload service       # Reload configuration
```

### Service Units
```bash
# Unit Types
.service           # Service units
.socket            # Socket units
.target            # Target units (runlevels)
.timer             # Timer units (cron-like)
.mount             # Mount units
.device            # Device units

# Unit Locations
/etc/systemd/system/           # Local configuration
/usr/lib/systemd/system/       # Package units
/run/systemd/system/           # Runtime units
```

## Kernel Architecture

### Kernel Components
```bash
# Kernel Information
uname -a           # Kernel version and architecture
cat /proc/version  # Detailed kernel information
lsmod              # Loaded kernel modules
modinfo module     # Module information
dmesg              # Kernel messages

# Kernel Parameters
sysctl -a          # All kernel parameters
sysctl vm.swappiness        # Specific parameter
echo 10 > /proc/sys/vm/swappiness  # Set parameter
```

### Kernel Modules
```bash
# Module Management
lsmod                      # List loaded modules
modprobe module_name       # Load module
modprobe -r module_name    # Remove module
insmod /path/to/module.ko  # Insert module
rmmod module_name          # Remove module

# Module Configuration
/etc/modules               # Modules to load at boot
/etc/modprobe.d/          # Module configuration
/lib/modules/$(uname -r)/ # Module files
```

## Security Architecture

### Access Control
```bash
# Discretionary Access Control (DAC)
chmod 755 file             # File permissions
chown user:group file      # File ownership
umask 022                  # Default permissions

# Mandatory Access Control (MAC)
# SELinux
getenforce                 # SELinux status
sestatus                   # SELinux information
ls -Z file                 # SELinux context

# AppArmor
aa-status                  # AppArmor status
aa-enforce profile         # Enforce profile
aa-complain profile        # Complain mode
```

### Capabilities
```bash
# Linux Capabilities
getcap /usr/bin/ping       # Get file capabilities
setcap cap_net_raw+ep /usr/bin/ping  # Set capabilities
capsh --print              # Current capabilities

# Common Capabilities
CAP_NET_ADMIN             # Network administration
CAP_SYS_ADMIN             # System administration
CAP_DAC_OVERRIDE          # Override file permissions
CAP_SETUID                # Set user ID
```