# Linux Commands Reference

Essential Linux commands for system administration and DevOps operations.

## File and Directory Operations
```bash
# Navigation
ls -la                  # List files with details
cd /path/to/directory   # Change directory
pwd                     # Print working directory
find /path -name "*.log" # Find files by pattern

# File Operations
cp source destination   # Copy files
mv old_name new_name   # Move/rename files
rm -rf directory       # Remove directory recursively
chmod 755 file.sh      # Change permissions
chown user:group file  # Change ownership
```

## System Information
```bash
# System Status
uname -a               # System information
uptime                 # System uptime
df -h                  # Disk usage
free -h                # Memory usage
top                    # Process monitor
ps aux                 # Process list
```

## Network Commands
```bash
# Network Configuration
ip addr show           # Show IP addresses
netstat -tuln          # Network connections
ss -tuln               # Socket statistics
ping google.com        # Test connectivity
curl -I example.com    # HTTP headers
```

## Process Management
```bash
# Process Control
kill PID               # Terminate process
killall process_name   # Kill by name
nohup command &        # Run in background
jobs                   # List active jobs
bg %1                  # Background job
fg %1                  # Foreground job
```