# Docker Troubleshooting

Comprehensive guide to diagnosing and resolving Docker issues.

## Common Container Issues

### Container Won't Start

```bash
# Check container logs
docker logs <container>
docker logs --tail 50 <container>
docker logs --since 2h <container>

# Inspect container configuration
docker inspect <container>
docker inspect <container> | jq '.[0].State'

# Check exit code
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Common exit codes:
# 0: Success
# 1: General error
# 125: Docker daemon error
# 126: Container command not executable
# 127: Container command not found
```

### Container Exits Immediately

```bash
# Debug with interactive shell
docker run -it <image> /bin/sh
docker run -it --entrypoint /bin/sh <image>

# Override command
docker run -it <image> bash
docker run -it --entrypoint "" <image> bash

# Check if command exists
docker run --rm <image> which <command>
docker run --rm <image> ls -la /usr/local/bin/
```

### Permission Issues

```bash
# Check file permissions
docker exec <container> ls -la /app
docker exec <container> id

# Fix ownership issues
docker exec <container> chown -R app:app /app
docker run --user $(id -u):$(id -g) <image>

# SELinux context issues (RHEL/CentOS)
docker run -v /host/path:/container/path:Z <image>
```

## Network Troubleshooting

### Connectivity Issues

```bash
# Test network connectivity
docker exec <container> ping <target>
docker exec <container> telnet <host> <port>
docker exec <container> curl -v <url>

# Check DNS resolution
docker exec <container> nslookup <hostname>
docker exec <container> cat /etc/resolv.conf

# Network inspection
docker network ls
docker network inspect <network>
docker exec <container> ip addr show
docker exec <container> ip route show
```

### Port Binding Issues

```bash
# Check if port is already in use
netstat -tulpn | grep :<port>
lsof -i :<port>
ss -tulpn | grep :<port>

# Check Docker port mappings
docker port <container>
docker ps --format "table {{.Names}}\t{{.Ports}}"

# Test port accessibility
curl -v localhost:<port>
telnet localhost <port>
```

### Network Debugging Tools

```bash
# Use netshoot container for debugging
docker run -it --rm \
  --net container:<target_container> \
  nicolaka/netshoot

# Available tools in netshoot:
# ping, traceroute, nslookup, dig, curl, wget
# tcpdump, netstat, ss, iptables, nmap

# Network packet capture
docker exec <container> tcpdump -i eth0 -w capture.pcap
```

## Storage Issues

### Volume Mount Problems

```bash
# Check volume mounts
docker inspect <container> | jq '.[0].Mounts'
docker exec <container> mount | grep /data

# Volume permissions
docker exec <container> ls -la /data
docker volume inspect <volume>

# Fix volume permissions
docker run --rm -v <volume>:/data alpine chown -R 1000:1000 /data
```

### Disk Space Issues

```bash
# Check Docker disk usage
docker system df
docker system df -v

# Check container disk usage
docker exec <container> df -h
docker exec <container> du -sh /var/log

# Clean up disk space
docker system prune
docker system prune -a --volumes
docker image prune -a
docker container prune
docker volume prune
```

### File System Issues

```bash
# Check file system errors
docker exec <container> dmesg | grep -i error
docker logs <container> | grep -i "no space"

# Check inode usage
docker exec <container> df -i

# Find large files
docker exec <container> find / -type f -size +100M 2>/dev/null
docker exec <container> du -ah /var/log | sort -rh | head -10
```

## Performance Issues

### High CPU Usage

```bash
# Monitor CPU usage
docker stats --no-stream
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Check processes in container
docker exec <container> top
docker exec <container> ps aux --sort=-%cpu

# CPU profiling
docker exec <container> perf top
docker run --pid container:<target> --cap-add SYS_PTRACE debug-tools
```

### Memory Issues

```bash
# Check memory usage
docker stats <container>
docker exec <container> free -h
docker exec <container> cat /proc/meminfo

# Check for memory leaks
docker exec <container> ps aux --sort=-%mem
docker exec <container> pmap <pid>

# Out of Memory (OOM) issues
dmesg | grep -i "killed process"
docker inspect <container> | jq '.[0].State.OOMKilled'
```

### I/O Performance

```bash
# Monitor I/O statistics
docker exec <container> iostat -x 1
docker exec <container> iotop

# Check disk I/O
docker exec <container> dd if=/dev/zero of=/tmp/test bs=1M count=100
docker exec <container> hdparm -tT /dev/sda
```

## Image Issues

### Build Failures

```bash
# Build with verbose output
docker build --no-cache --progress=plain .

# Debug build steps
docker build --target <stage> .
docker run -it <intermediate_image> /bin/sh

# Check build context
docker build --dry-run .
ls -la .dockerignore

# Build argument issues
docker build --build-arg ARG_NAME=value .
```

### Image Size Issues

```bash
# Analyze image layers
docker history <image>
docker history --no-trunc <image>

# Use dive tool for detailed analysis
dive <image>

# Check for large files
docker run --rm <image> find / -type f -size +10M 2>/dev/null
```

### Registry Issues

```bash
# Login issues
docker login <registry>
cat ~/.docker/config.json

# Push/pull failures
docker push <image> --debug
docker pull <image> --debug

# Check registry connectivity
curl -v https://<registry>/v2/
```

## Docker Daemon Issues

### Daemon Won't Start

```bash
# Check daemon status
systemctl status docker
journalctl -u docker.service

# Start daemon manually for debugging
dockerd --debug

# Check daemon configuration
cat /etc/docker/daemon.json
docker info
```

### Daemon Performance

```bash
# Check daemon logs
journalctl -u docker.service -f
tail -f /var/log/docker.log

# Monitor daemon metrics
docker system events
docker system df
docker info | grep -A 10 "Server Version"
```

### Storage Driver Issues

```bash
# Check storage driver
docker info | grep "Storage Driver"

# Storage driver problems
# Switch storage driver in /etc/docker/daemon.json
{
  "storage-driver": "overlay2"
}

# Clean up storage driver data
systemctl stop docker
rm -rf /var/lib/docker
systemctl start docker
```

## Security Issues

### Container Escape Attempts

```bash
# Check for privileged containers
docker ps --format "table {{.Names}}\t{{.Status}}" --filter "label=privileged=true"

# Monitor security events
docker events --filter event=start --filter event=exec
ausearch -m avc -ts recent

# Check capabilities
docker exec <container> capsh --print
```

### Suspicious Activity

```bash
# Check running processes
docker exec <container> ps aux
docker top <container>

# Network connections
docker exec <container> netstat -tulpn
docker exec <container> ss -tulpn

# File system changes
docker diff <container>
```

## Debugging Tools and Techniques

### Essential Debugging Commands

```bash
# Container inspection
docker inspect <container>
docker logs <container>
docker exec -it <container> /bin/sh
docker top <container>
docker stats <container>

# System information
docker info
docker version
docker system events
docker system df
```

### Advanced Debugging

```bash
# Debug with nsenter (access container namespaces)
PID=$(docker inspect -f '{{.State.Pid}}' <container>)
nsenter -t $PID -n -p -i -u -m /bin/sh

# Strace container processes
docker exec <container> strace -p <pid>

# Debug with gdb
docker exec -it <container> gdb -p <pid>
```

### Debugging Containers

```bash
# Debug container with additional tools
docker run -it --rm \
  --pid container:<target> \
  --net container:<target> \
  --cap-add SYS_PTRACE \
  --cap-add SYS_ADMIN \
  debug-tools

# Create debug image
FROM alpine
RUN apk add --no-cache \
  curl wget netcat-openbsd \
  tcpdump strace ltrace \
  htop iotop \
  bind-tools iputils
```

## Log Analysis

### Container Logs

```bash
# View logs with timestamps
docker logs -t <container>

# Follow logs in real-time
docker logs -f <container>

# Filter logs by time
docker logs --since 2h <container>
docker logs --until 2021-01-01T00:00:00 <container>

# Search logs
docker logs <container> 2>&1 | grep ERROR
docker logs <container> | jq '.'  # For JSON logs
```

### System Logs

```bash
# Docker daemon logs
journalctl -u docker.service
journalctl -u docker.service --since "1 hour ago"

# System logs related to Docker
dmesg | grep -i docker
grep -i docker /var/log/syslog
```

## Monitoring and Alerting

### Health Monitoring

```bash
# Container health status
docker ps --format "table {{.Names}}\t{{.Status}}"
docker inspect <container> | jq '.[0].State.Health'

# Custom health checks
docker run --health-cmd="curl -f http://localhost/" \
  --health-interval=30s \
  --health-timeout=3s \
  --health-retries=3 \
  nginx
```

### Resource Monitoring

```bash
# Real-time monitoring
watch docker stats
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

# Historical data collection
# Use monitoring tools like:
# - Prometheus + cAdvisor
# - Grafana
# - ELK Stack
# - DataDog
```

## Recovery Procedures

### Container Recovery

```bash
# Restart failed container
docker restart <container>

# Restore from backup
docker run --rm -v backup-volume:/backup -v target-volume:/data \
  alpine sh -c "cd /data && tar xzf /backup/backup.tar.gz"

# Rollback to previous image
docker stop <container>
docker rm <container>
docker run -d --name <container> <previous_image>
```

### Data Recovery

```bash
# Recover data from stopped container
docker cp <container>:/path/to/data ./recovered-data

# Export container filesystem
docker export <container> > container-backup.tar

# Create image from container
docker commit <container> recovery-image:latest
```

## Prevention Strategies

### Proactive Monitoring

```bash
# Set up monitoring alerts
# - High CPU/memory usage
# - Container restart loops
# - Failed health checks
# - Disk space warnings

# Implement logging strategy
# - Centralized logging
# - Log rotation
# - Log analysis
# - Alert on errors
```

### Best Practices

```bash
# Use health checks
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/health || exit 1

# Set resource limits
docker run --memory=512m --cpus="1" <image>

# Use proper restart policies
docker run --restart unless-stopped <image>

# Implement graceful shutdown
# Handle SIGTERM signals properly in applications
```

## Emergency Procedures

### Critical Issues

```bash
# Stop all containers
docker stop $(docker ps -q)

# Emergency cleanup
docker system prune -a --volumes --force

# Restart Docker daemon
systemctl restart docker

# Factory reset Docker
systemctl stop docker
rm -rf /var/lib/docker
systemctl start docker
```

### Incident Response

```bash
# Collect diagnostic information
docker info > docker-info.txt
docker ps -a > containers.txt
docker images > images.txt
docker network ls > networks.txt
docker volume ls > volumes.txt
docker logs <problematic_container> > container.log

# Create support bundle
docker system events > events.log
journalctl -u docker.service > daemon.log
```