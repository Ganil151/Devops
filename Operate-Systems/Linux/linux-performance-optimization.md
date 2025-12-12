# Linux Performance Optimization Guide for DevOps Engineers

## Performance Monitoring and Analysis

### System Performance Overview

#### Key Performance Indicators (KPIs)
```bash
# CPU utilization
top                             # Real-time CPU usage
htop                            # Enhanced process viewer
sar -u 1 10                     # CPU usage every second for 10 times
mpstat 1                        # Multi-processor statistics
iostat -c 1                     # CPU statistics with I/O wait

# Memory utilization
free -h                         # Memory usage summary
vmstat 1                        # Virtual memory statistics
sar -r 1 10                     # Memory usage statistics
pmap -x PID                     # Process memory mapping

# Disk I/O performance
iostat -x 1                     # Extended I/O statistics
iotop                           # I/O usage by process
sar -d 1 10                     # Disk activity statistics

# Network performance
sar -n DEV 1 10                 # Network interface statistics
ss -i                           # Socket statistics with details
iftop                           # Network bandwidth usage
```

#### Performance Baseline Script
```bash
#!/bin/bash
# System performance baseline collection script

BASELINE_DIR="/var/log/performance"
DATE=$(date +%Y%m%d_%H%M%S)
BASELINE_FILE="$BASELINE_DIR/baseline_$DATE.txt"

mkdir -p "$BASELINE_DIR"

echo "=== SYSTEM PERFORMANCE BASELINE ===" > "$BASELINE_FILE"
echo "Timestamp: $(date)" >> "$BASELINE_FILE"
echo "Hostname: $(hostname)" >> "$BASELINE_FILE"
echo "Uptime: $(uptime)" >> "$BASELINE_FILE"
echo "" >> "$BASELINE_FILE"

# CPU Information
echo "=== CPU INFORMATION ===" >> "$BASELINE_FILE"
lscpu >> "$BASELINE_FILE"
echo "" >> "$BASELINE_FILE"

# Memory Information
echo "=== MEMORY INFORMATION ===" >> "$BASELINE_FILE"
free -h >> "$BASELINE_FILE"
echo "" >> "$BASELINE_FILE"
cat /proc/meminfo >> "$BASELINE_FILE"
echo "" >> "$BASELINE_FILE"

# Disk Information
echo "=== DISK INFORMATION ===" >> "$BASELINE_FILE"
df -h >> "$BASELINE_FILE"
echo "" >> "$BASELINE_FILE"
lsblk >> "$BASELINE_FILE"
echo "" >> "$BASELINE_FILE"

# Network Information
echo "=== NETWORK INFORMATION ===" >> "$BASELINE_FILE"
ip addr show >> "$BASELINE_FILE"
echo "" >> "$BASELINE_FILE"

# Process Information
echo "=== TOP PROCESSES ===" >> "$BASELINE_FILE"
ps aux --sort=-%cpu | head -20 >> "$BASELINE_FILE"
echo "" >> "$BASELINE_FILE"
ps aux --sort=-%mem | head -20 >> "$BASELINE_FILE"
echo "" >> "$BASELINE_FILE"

# System Load
echo "=== SYSTEM LOAD ===" >> "$BASELINE_FILE"
cat /proc/loadavg >> "$BASELINE_FILE"
echo "" >> "$BASELINE_FILE"

echo "Baseline collected: $BASELINE_FILE"
```

### Advanced Performance Monitoring

#### CPU Performance Analysis
```bash
# CPU frequency and governor information
cpufreq-info                    # CPU frequency information
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Set CPU governor for performance
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# CPU cache information
lscpu | grep -i cache
cat /proc/cpuinfo | grep cache

# CPU utilization by core
mpstat -P ALL 1                 # Per-CPU statistics
sar -P ALL -u 1 10              # Per-CPU utilization

# Process CPU affinity
taskset -c 0,1 command          # Run command on CPUs 0 and 1
taskset -p PID                  # Show process CPU affinity
taskset -cp 0,1 PID             # Set process CPU affinity

# CPU performance counters (requires perf)
perf stat -e cycles,instructions,cache-references,cache-misses command
perf top                        # Real-time performance profiling
perf record -g command          # Record performance data
perf report                     # Analyze recorded data
```

#### Memory Performance Analysis
```bash
# Detailed memory analysis
cat /proc/meminfo               # Comprehensive memory information
slabtop                         # Kernel slab allocator information
vmstat -s                       # Memory statistics summary

# Memory bandwidth testing
mbw 100                         # Memory bandwidth benchmark
stream                          # STREAM memory benchmark

# Page fault analysis
sar -B 1 10                     # Paging statistics
vmstat -f                       # Fork statistics

# Memory mapping analysis
pmap -x PID                     # Process memory map
cat /proc/PID/smaps             # Detailed memory mapping
cat /proc/PID/status | grep Vm  # Virtual memory usage

# NUMA analysis (on NUMA systems)
numactl --hardware              # NUMA topology
numastat                        # NUMA statistics
numactl --show                  # Current NUMA policy
```

#### Disk I/O Performance Analysis
```bash
# Disk I/O monitoring
iostat -x 1                     # Extended I/O statistics
iotop -o                        # Only show processes doing I/O
pidstat -d 1                    # Per-process I/O statistics

# Disk performance testing
dd if=/dev/zero of=/tmp/testfile bs=1G count=1 oflag=direct
hdparm -tT /dev/sda             # Disk read performance test
fio --name=random-write --ioengine=posixaio --rw=randwrite --bs=4k --size=4g --numjobs=1 --iodepth=1 --runtime=60 --time_based --end_fsync=1

# File system performance
tune2fs -l /dev/sda1            # ext2/3/4 filesystem parameters
xfs_info /mount/point           # XFS filesystem information

# I/O scheduler optimization
cat /sys/block/sda/queue/scheduler
echo deadline > /sys/block/sda/queue/scheduler  # Set I/O scheduler

# Block device queue settings
cat /sys/block/sda/queue/read_ahead_kb
echo 4096 > /sys/block/sda/queue/read_ahead_kb  # Set read-ahead
```

## CPU Optimization

### CPU Tuning and Configuration

#### CPU Governor and Frequency Scaling
```bash
# Install CPU frequency utilities
sudo apt install cpufrequtils   # Debian/Ubuntu
sudo yum install cpupowerutils  # Red Hat/CentOS

# Check current CPU governor
cpufreq-info -g

# Available governors
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

# Set performance governor (maximum performance)
sudo cpufreq-set -g performance

# Set powersave governor (power efficiency)
sudo cpufreq-set -g powersave

# Set ondemand governor (dynamic scaling)
sudo cpufreq-set -g ondemand

# Persistent governor setting
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
sudo systemctl restart cpufrequtils
```

#### Process Priority and Scheduling
```bash
# Process nice values (-20 to 19, lower = higher priority)
nice -n -10 important_process   # High priority
nice -n 10 background_process   # Low priority
renice -n 5 -p PID             # Change priority of running process

# Real-time scheduling (use with caution)
chrt -f 99 critical_process     # FIFO real-time scheduling
chrt -r 50 realtime_process     # Round-robin real-time scheduling

# CPU affinity (bind processes to specific CPUs)
taskset -c 0,1 process          # Run on CPUs 0 and 1
taskset -cp 2,3 PID            # Move running process to CPUs 2 and 3

# cgroups for CPU control
# Create CPU cgroup
sudo mkdir /sys/fs/cgroup/cpu/high_priority
echo 80000 | sudo tee /sys/fs/cgroup/cpu/high_priority/cpu.cfs_quota_us
echo $PID | sudo tee /sys/fs/cgroup/cpu/high_priority/cgroup.procs
```

#### CPU Performance Tuning Script
```bash
#!/bin/bash
# CPU performance optimization script

# Set performance governor
echo "Setting CPU governor to performance..."
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Disable CPU idle states for maximum performance
echo "Disabling CPU idle states..."
for state in /sys/devices/system/cpu/cpu*/cpuidle/state*/disable; do
    echo 1 | sudo tee "$state" 2>/dev/null
done

# Set CPU frequency to maximum
echo "Setting CPU frequency to maximum..."
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_setspeed; do
    if [ -f "$cpu" ]; then
        max_freq=$(cat "${cpu%/*}/cpuinfo_max_freq")
        echo "$max_freq" | sudo tee "$cpu"
    fi
done

# Optimize kernel scheduler
echo "Optimizing kernel scheduler..."
echo 1 | sudo tee /proc/sys/kernel/sched_migration_cost_ns
echo 0 | sudo tee /proc/sys/kernel/sched_autogroup_enabled

# Set CPU affinity for interrupt handling
echo "Optimizing interrupt handling..."
for irq in /proc/irq/*/smp_affinity; do
    echo f | sudo tee "$irq" 2>/dev/null
done

echo "CPU optimization completed"
```

## Memory Optimization

### Memory Management and Tuning

#### Virtual Memory Tuning
```bash
# /etc/sysctl.d/99-memory.conf

# Swappiness (0-100, lower = less swapping)
vm.swappiness = 10              # Reduce swap usage

# Dirty page handling
vm.dirty_ratio = 15             # Percentage of memory for dirty pages
vm.dirty_background_ratio = 5   # Background writeback threshold
vm.dirty_expire_centisecs = 3000 # Dirty page expiration time
vm.dirty_writeback_centisecs = 500 # Writeback interval

# Memory overcommit
vm.overcommit_memory = 1        # Always overcommit
vm.overcommit_ratio = 50        # Overcommit ratio

# Kernel memory management
vm.min_free_kbytes = 65536      # Minimum free memory
vm.vfs_cache_pressure = 50      # VFS cache pressure

# Transparent Huge Pages
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag

# Apply settings
sudo sysctl -p /etc/sysctl.d/99-memory.conf
```

#### Memory Monitoring and Analysis
```bash
# Memory usage analysis
free -h                         # Basic memory information
vmstat 1                        # Virtual memory statistics
sar -r 1 10                     # Memory utilization over time

# Process memory analysis
ps aux --sort=-%mem | head -10  # Top memory consumers
pmap -x PID                     # Process memory mapping
smem -t                         # Memory usage with totals

# Memory leak detection
valgrind --tool=memcheck --leak-check=full program
valgrind --tool=massif program  # Memory profiling

# Kernel memory analysis
slabtop                         # Kernel slab allocator
cat /proc/slabinfo              # Slab information
cat /proc/buddyinfo             # Buddy allocator information
```

#### Memory Optimization Script
```bash
#!/bin/bash
# Memory optimization script

optimize_memory() {
    echo "Starting memory optimization..."
    
    # Clear page cache, dentries, and inodes
    sync
    echo 3 > /proc/sys/vm/drop_caches
    
    # Optimize swappiness
    echo 10 > /proc/sys/vm/swappiness
    
    # Optimize dirty page handling
    echo 15 > /proc/sys/vm/dirty_ratio
    echo 5 > /proc/sys/vm/dirty_background_ratio
    
    # Set minimum free memory
    total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    min_free=$((total_mem / 16))  # 1/16 of total memory
    echo $min_free > /proc/sys/vm/min_free_kbytes
    
    # Disable transparent huge pages for databases
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
    echo never > /sys/kernel/mm/transparent_hugepage/defrag
    
    echo "Memory optimization completed"
}

monitor_memory() {
    echo "Memory usage before optimization:"
    free -h
    
    optimize_memory
    
    echo "Memory usage after optimization:"
    free -h
}

case "$1" in
    optimize)
        optimize_memory
        ;;
    monitor)
        monitor_memory
        ;;
    *)
        echo "Usage: $0 {optimize|monitor}"
        exit 1
        ;;
esac
```

## Disk I/O Optimization

### File System Optimization

#### File System Selection and Tuning
```bash
# ext4 optimization
tune2fs -o journal_data_writeback /dev/sda1  # Writeback journaling
tune2fs -O ^has_journal /dev/sda1            # Disable journaling (risky)
mount -o noatime,nodiratime /dev/sda1 /mnt   # Disable access time updates

# XFS optimization
mount -o noatime,nodiratime,logbufs=8,logbsize=256k /dev/sda1 /mnt
xfs_fsr /mount/point                          # Defragment XFS filesystem

# Btrfs optimization
mount -o noatime,compress=lzo,space_cache /dev/sda1 /mnt
btrfs filesystem defragment -r /mount/point   # Defragment Btrfs

# File system mount options for performance
# /etc/fstab
/dev/sda1 /data ext4 defaults,noatime,nodiratime,data=writeback 0 2
/dev/sdb1 /logs xfs defaults,noatime,logbufs=8,logbsize=256k 0 2
```

#### I/O Scheduler Optimization
```bash
# Check current I/O scheduler
cat /sys/block/sda/queue/scheduler

# Available schedulers: noop, deadline, cfq, bfq, mq-deadline, kyber

# Set I/O scheduler
echo deadline > /sys/block/sda/queue/scheduler     # Good for SSDs
echo cfq > /sys/block/sda/queue/scheduler          # Good for HDDs
echo noop > /sys/block/sda/queue/scheduler         # Good for NVMe/SSDs

# Persistent I/O scheduler setting
echo 'ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="deadline"' > /etc/udev/rules.d/60-ioschedulers.rules

# I/O scheduler tuning parameters
# For deadline scheduler
echo 1 > /sys/block/sda/queue/iosched/front_merges
echo 150 > /sys/block/sda/queue/iosched/read_expire
echo 1500 > /sys/block/sda/queue/iosched/write_expire

# For CFQ scheduler
echo 6 > /sys/block/sda/queue/iosched/quantum
echo 300 > /sys/block/sda/queue/iosched/fifo_expire_sync
echo 1250 > /sys/block/sda/queue/iosched/fifo_expire_async
```

#### Block Device Optimization
```bash
# Read-ahead optimization
blockdev --getra /dev/sda                    # Get current read-ahead
blockdev --setra 4096 /dev/sda               # Set read-ahead to 4MB

# Queue depth optimization
cat /sys/block/sda/queue/nr_requests
echo 128 > /sys/block/sda/queue/nr_requests  # Increase queue depth

# Rotational optimization (for SSDs)
echo 0 > /sys/block/sda/queue/rotational     # Mark as non-rotational

# Maximum sectors per request
cat /sys/block/sda/queue/max_sectors_kb
echo 1024 > /sys/block/sda/queue/max_sectors_kb  # Set to 1MB
```

### Storage Performance Testing

#### Disk Benchmark Scripts
```bash
#!/bin/bash
# Comprehensive disk performance test

DEVICE="/dev/sda"
MOUNT_POINT="/mnt/test"
TEST_FILE="$MOUNT_POINT/testfile"

# Sequential read test
echo "Testing sequential read performance..."
dd if="$DEVICE" of=/dev/null bs=1M count=1000 2>&1 | grep -E "(copied|MB/s)"

# Sequential write test
echo "Testing sequential write performance..."
dd if=/dev/zero of="$TEST_FILE" bs=1M count=1000 oflag=direct 2>&1 | grep -E "(copied|MB/s)"

# Random read/write test with fio
echo "Testing random I/O performance..."
fio --name=random-rw \
    --ioengine=libaio \
    --iodepth=32 \
    --rw=randrw \
    --rwmixread=70 \
    --bs=4k \
    --direct=1 \
    --size=1G \
    --numjobs=4 \
    --runtime=60 \
    --group_reporting \
    --filename="$TEST_FILE"

# IOPS test
echo "Testing IOPS performance..."
fio --name=iops-test \
    --ioengine=libaio \
    --iodepth=32 \
    --rw=randread \
    --bs=4k \
    --direct=1 \
    --size=1G \
    --numjobs=1 \
    --runtime=60 \
    --group_reporting \
    --filename="$TEST_FILE"

# Cleanup
rm -f "$TEST_FILE"
```

## Network Performance Optimization

### Network Stack Tuning

#### TCP/IP Stack Optimization
```bash
# /etc/sysctl.d/99-network.conf

# TCP buffer sizes
net.core.rmem_default = 262144          # Default receive buffer
net.core.rmem_max = 16777216            # Maximum receive buffer
net.core.wmem_default = 262144          # Default send buffer
net.core.wmem_max = 16777216            # Maximum send buffer

# TCP window scaling
net.ipv4.tcp_window_scaling = 1         # Enable window scaling
net.ipv4.tcp_rmem = 4096 87380 16777216 # TCP read buffer sizes
net.ipv4.tcp_wmem = 4096 65536 16777216 # TCP write buffer sizes

# TCP congestion control
net.ipv4.tcp_congestion_control = bbr   # Use BBR congestion control
net.core.default_qdisc = fq             # Fair queuing

# Network device settings
net.core.netdev_max_backlog = 5000      # Network device backlog
net.core.netdev_budget = 600            # Network processing budget

# Connection tracking
net.netfilter.nf_conntrack_max = 1048576 # Connection tracking table size
net.netfilter.nf_conntrack_tcp_timeout_established = 7200

# Apply settings
sudo sysctl -p /etc/sysctl.d/99-network.conf
```

#### Network Interface Optimization
```bash
# Check network interface capabilities
ethtool eth0                            # Interface information
ethtool -k eth0                         # Offload features
ethtool -g eth0                         # Ring buffer sizes
ethtool -c eth0                         # Coalescing settings

# Optimize ring buffer sizes
ethtool -G eth0 rx 4096 tx 4096         # Increase ring buffers

# Enable offload features
ethtool -K eth0 gso on                  # Generic segmentation offload
ethtool -K eth0 tso on                  # TCP segmentation offload
ethtool -K eth0 gro on                  # Generic receive offload
ethtool -K eth0 lro on                  # Large receive offload

# Interrupt coalescing
ethtool -C eth0 rx-usecs 50             # Receive interrupt coalescing
ethtool -C eth0 tx-usecs 50             # Transmit interrupt coalescing

# Multi-queue networking
echo 4 > /sys/class/net/eth0/queues/rx-0/rps_cpus  # Receive packet steering
```

### Application-Level Network Optimization

#### Web Server Optimization (Nginx)
```nginx
# /etc/nginx/nginx.conf

worker_processes auto;                   # One worker per CPU core
worker_rlimit_nofile 65535;             # File descriptor limit

events {
    worker_connections 4096;             # Connections per worker
    use epoll;                           # Use epoll on Linux
    multi_accept on;                     # Accept multiple connections
}

http {
    sendfile on;                         # Use sendfile for static files
    tcp_nopush on;                       # Optimize packet sending
    tcp_nodelay on;                      # Disable Nagle's algorithm
    
    keepalive_timeout 65;                # Keep-alive timeout
    keepalive_requests 1000;             # Requests per keep-alive
    
    gzip on;                             # Enable compression
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript;
    
    # Buffer sizes
    client_body_buffer_size 128k;
    client_max_body_size 10m;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 4k;
    output_buffers 1 32k;
    postpone_output 1460;
}
```

#### Database Network Optimization (MySQL)
```ini
# /etc/mysql/my.cnf

[mysqld]
# Network settings
bind-address = 0.0.0.0
port = 3306
max_connections = 200
max_connect_errors = 10000

# Buffer settings
net_buffer_length = 32K
max_allowed_packet = 1024M
net_read_timeout = 120
net_write_timeout = 120

# Connection pooling
thread_cache_size = 16
table_open_cache = 4096
```

## Application Performance Optimization

### Database Performance Tuning

#### MySQL/MariaDB Optimization
```ini
# /etc/mysql/my.cnf

[mysqld]
# Memory settings
innodb_buffer_pool_size = 8G            # 70-80% of available RAM
innodb_log_buffer_size = 64M
key_buffer_size = 256M
sort_buffer_size = 2M
read_buffer_size = 2M
read_rnd_buffer_size = 8M
myisam_sort_buffer_size = 64M

# InnoDB settings
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit = 2      # Better performance, slight risk
innodb_log_file_size = 512M
innodb_flush_method = O_DIRECT
innodb_io_capacity = 2000               # Adjust based on storage
innodb_read_io_threads = 8
innodb_write_io_threads = 8

# Query cache (MySQL 5.7 and earlier)
query_cache_type = 1
query_cache_size = 256M
query_cache_limit = 2M

# Connection settings
max_connections = 200
thread_cache_size = 16
table_open_cache = 4096
```

#### PostgreSQL Optimization
```ini
# /etc/postgresql/13/main/postgresql.conf

# Memory settings
shared_buffers = 2GB                    # 25% of RAM
effective_cache_size = 6GB              # 75% of RAM
work_mem = 64MB                         # Per-operation memory
maintenance_work_mem = 512MB
wal_buffers = 64MB

# Checkpoint settings
checkpoint_completion_target = 0.9
checkpoint_timeout = 15min
max_wal_size = 4GB
min_wal_size = 1GB

# Connection settings
max_connections = 200
shared_preload_libraries = 'pg_stat_statements'

# Query planner
random_page_cost = 1.1                  # For SSDs
effective_io_concurrency = 200          # For SSDs
```

### Web Application Optimization

#### PHP-FPM Optimization
```ini
# /etc/php/7.4/fpm/pool.d/www.conf

[www]
user = www-data
group = www-data

listen = /run/php/php7.4-fpm.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

# Process management
pm = dynamic
pm.max_children = 50                    # Adjust based on memory
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 15
pm.max_requests = 1000                  # Restart after N requests

# Performance settings
request_terminate_timeout = 300
rlimit_files = 65536
rlimit_core = 0

# PHP settings
php_admin_value[memory_limit] = 256M
php_admin_value[max_execution_time] = 300
php_admin_value[upload_max_filesize] = 100M
php_admin_value[post_max_size] = 100M
```

#### Node.js Optimization
```javascript
// app.js - Node.js performance optimization

const cluster = require('cluster');
const numCPUs = require('os').cpus().length;

if (cluster.isMaster) {
    // Fork workers
    for (let i = 0; i < numCPUs; i++) {
        cluster.fork();
    }
    
    cluster.on('exit', (worker, code, signal) => {
        console.log(`Worker ${worker.process.pid} died`);
        cluster.fork(); // Restart worker
    });
} else {
    // Worker process
    const express = require('express');
    const app = express();
    
    // Performance middleware
    app.use(require('compression')());      // Gzip compression
    app.use(require('helmet')());           // Security headers
    
    // Connection pooling for databases
    const mysql = require('mysql2');
    const pool = mysql.createPool({
        connectionLimit: 10,
        host: 'localhost',
        user: 'user',
        password: 'password',
        database: 'mydb',
        acquireTimeout: 60000,
        timeout: 60000
    });
    
    app.listen(3000, () => {
        console.log(`Worker ${process.pid} started`);
    });
}
```

## Performance Monitoring and Alerting

### Automated Performance Monitoring

#### Performance Monitoring Script
```bash
#!/bin/bash
# Comprehensive performance monitoring script

THRESHOLD_CPU=80
THRESHOLD_MEMORY=85
THRESHOLD_DISK=90
THRESHOLD_LOAD=5.0
LOG_FILE="/var/log/performance-monitor.log"
ALERT_EMAIL="admin@example.com"

log_metric() {
    local metric="$1"
    local value="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp,$metric,$value" >> "$LOG_FILE"
}

check_cpu_usage() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    cpu_usage=${cpu_usage%.*}
    
    log_metric "cpu_usage" "$cpu_usage"
    
    if [ "$cpu_usage" -gt "$THRESHOLD_CPU" ]; then
        echo "ALERT: High CPU usage: ${cpu_usage}%" | \
            mail -s "Performance Alert: High CPU" "$ALERT_EMAIL"
    fi
}

check_memory_usage() {
    local memory_usage=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
    
    log_metric "memory_usage" "$memory_usage"
    
    if [ "$memory_usage" -gt "$THRESHOLD_MEMORY" ]; then
        echo "ALERT: High memory usage: ${memory_usage}%" | \
            mail -s "Performance Alert: High Memory" "$ALERT_EMAIL"
    fi
}

check_disk_usage() {
    df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{print $5 " " $1}' | while read output; do
        usage=$(echo "$output" | awk '{print $1}' | cut -d'%' -f1)
        partition=$(echo "$output" | awk '{print $2}')
        
        log_metric "disk_usage_$partition" "$usage"
        
        if [ "$usage" -gt "$THRESHOLD_DISK" ]; then
            echo "ALERT: High disk usage on $partition: ${usage}%" | \
                mail -s "Performance Alert: High Disk Usage" "$ALERT_EMAIL"
        fi
    done
}

check_load_average() {
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
    
    log_metric "load_average" "$load_avg"
    
    if (( $(echo "$load_avg > $THRESHOLD_LOAD" | bc -l) )); then
        echo "ALERT: High load average: $load_avg" | \
            mail -s "Performance Alert: High Load" "$ALERT_EMAIL"
    fi
}

main() {
    check_cpu_usage
    check_memory_usage
    check_disk_usage
    check_load_average
}

main "$@"
```

This comprehensive performance optimization guide provides DevOps engineers with the knowledge and tools needed to optimize Linux systems for maximum performance across CPU, memory, disk I/O, network, and application layers.