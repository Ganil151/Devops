## **Jenkins CLI Commands**

### **Installation & Setup**
```bash
# Download Jenkins CLI JAR
wget http://localhost:8080/jnlpJars/jenkins-cli.jar

# Or with authentication
curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar

# Basic CLI usage
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth username:password <command>

# Using API token (recommended)
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth username:API_TOKEN <command>

# Set up alias for convenience
alias jenkins-cli='java -jar /path/to/jenkins-cli.jar -s http://localhost:8080/ -auth user:token'
```

---

## **Jenkins Service Management**

### **SystemD (Amazon Linux 2/3, RHEL, CentOS)**

```bash
# Start Jenkins
sudo systemctl start jenkins

# Stop Jenkins
sudo systemctl stop jenkins

# Restart Jenkins
sudo systemctl restart jenkins

# Reload configuration
sudo systemctl reload jenkins

# Check status
sudo systemctl status jenkins

# Enable at boot
sudo systemctl enable jenkins

# Disable at boot
sudo systemctl disable jenkins

# View logs
sudo journalctl -u jenkins -f
sudo journalctl -u jenkins --since today
sudo journalctl -u jenkins -n 100
```

### **Direct Service Commands**

```bash
# Check if Jenkins is running
ps aux | grep jenkins

# Check Jenkins port
sudo netstat -tuln | grep 8080
sudo ss -tuln | grep 8080

# Check Jenkins process
pgrep -f jenkins

# Kill Jenkins process (if hung)
sudo pkill -9 -f jenkins

# Check Jenkins home directory
ls -la /var/lib/jenkins/

# Check Jenkins logs
tail -f /var/log/jenkins/jenkins.log
sudo cat /var/log/jenkins/jenkins.log | grep ERROR
```

---

## **Jenkins CLI Commands**

### **Job Management**

```bash
# List all jobs
jenkins-cli list-jobs

# Get job configuration
jenkins-cli get-job <job-name>

# Create job from XML
jenkins-cli create-job <job-name> < job-config.xml

# Update job configuration
jenkins-cli update-job <job-name> < job-config.xml

# Copy job
jenkins-cli copy-job <source-job> <destination-job>

# Delete job
jenkins-cli delete-job <job-name>

# Enable job
jenkins-cli enable-job <job-name>

# Disable job
jenkins-cli disable-job <job-name>

# Build job
jenkins-cli build <job-name>

# Build with parameters
jenkins-cli build <job-name> -p PARAM1=value1 -p PARAM2=value2

# Build and wait for completion
jenkins-cli build <job-name> -s

# Build and follow console output
jenkins-cli build <job-name> -s -v

# Get build information
jenkins-cli get-build <job-name> <build-number>

# Stop build
jenkins-cli stop-builds <job-name> <build-number>
```

### **Node Management**

```bash
# List nodes
jenkins-cli list-nodes

# Get node info
jenkins-cli get-node <node-name>

# Create node
jenkins-cli create-node <node-name> < node-config.xml

# Update node
jenkins-cli update-node <node-name> < node-config.xml

# Delete node
jenkins-cli delete-node <node-name>

# Take node offline
jenkins-cli offline-node <node-name> -m "Maintenance"

# Bring node online
jenkins-cli online-node <node-name>

# Connect node
jenkins-cli connect-node <node-name>

# Disconnect node
jenkins-cli disconnect-node <node-name>

# Wait for node to be online
jenkins-cli wait-node-online <node-name>
```

### **Plugin Management**

```bash
# List installed plugins
jenkins-cli list-plugins

# Install plugin
jenkins-cli install-plugin <plugin-name>

# Install specific version
jenkins-cli install-plugin <plugin-name>@<version>

# Install from file
jenkins-cli install-plugin /path/to/plugin.hpi

# Uninstall plugin
jenkins-cli uninstall-plugin <plugin-name>

# Update plugins
jenkins-cli update-plugin <plugin-name>

# List available updates
jenkins-cli list-plugins | grep -i update

# Safe restart (wait for jobs to finish)
jenkins-cli safe-restart

# Force restart
jenkins-cli restart

# Reload configuration
jenkins-cli reload-configuration
```

### **User Management**

```bash
# List users
jenkins-cli list-users

# Create user
jenkins-cli create-user <username> --password <password> --email <email>

# Delete user
jenkins-cli delete-user <username>

# Get user info
jenkins-cli get-user <username>
```

### **View Management**

```bash
# List views
jenkins-cli list-views

# Get view configuration
jenkins-cli get-view <view-name>

# Create view
jenkins-cli create-view <view-name> < view-config.xml

# Update view
jenkins-cli update-view <view-name> < view-config.xml

# Delete view
jenkins-cli delete-view <view-name>
```

### **System Commands**

```bash
# Get version
jenkins-cli version

# Who am I (current user)
jenkins-cli who-am-i

# Reload configuration from disk
jenkins-cli reload-configuration

# Safe restart
jenkins-cli safe-restart

# Force restart
jenkins-cli restart

# Quiet down (prepare for shutdown)
jenkins-cli quiet-down

# Cancel quiet down
jenkins-cli cancel-quiet-down

# Execute Groovy script
jenkins-cli groovy = < script.groovy

# Run health check
jenkins-cli check-url http://localhost:8080/
```

---

## **Jenkins Configuration Files**

### **Important File Locations**

```bash
# Jenkins home directory
/var/lib/jenkins/

# Configuration file
/var/lib/jenkins/config.xml

# Jobs directory
/var/lib/jenkins/jobs/

# Plugins directory
/var/lib/jenkins/plugins/

# Workspace directory
/var/lib/jenkins/workspace/

# Log file
/var/log/jenkins/jenkins.log

# Service file
/etc/systemd/system/jenkins.service
/usr/lib/systemd/system/jenkins.service

# Default configuration
/etc/sysconfig/jenkins  # RHEL/CentOS
/etc/default/jenkins    # Debian/Ubuntu

# Init script (older systems)
/etc/init.d/jenkins
```

### **Backup Jenkins**

```bash
# Backup entire Jenkins home
sudo tar -czf jenkins-backup-$(date +%Y%m%d).tar.gz /var/lib/jenkins/

# Backup only configuration
sudo tar -czf jenkins-config-backup-$(date +%Y%m%d).tar.gz \
  /var/lib/jenkins/*.xml \
  /var/lib/jenkins/jobs/*/config.xml \
  /var/lib/jenkins/users/ \
  /var/lib/jenkins/secrets/

# Backup excluding workspaces (smaller)
sudo tar -czf jenkins-backup-$(date +%Y%m%d).tar.gz \
  --exclude='/var/lib/jenkins/workspace/*' \
  --exclude='/var/lib/jenkins/war/*' \
  /var/lib/jenkins/

# Restore backup
sudo systemctl stop jenkins
sudo tar -xzf jenkins-backup.tar.gz -C /
sudo chown -R jenkins:jenkins /var/lib/jenkins
sudo systemctl start jenkins
```

### **Export/Import Jobs**

```bash
# Export single job
jenkins-cli get-job <job-name> > job-backup.xml

# Import job
jenkins-cli create-job <new-job-name> < job-backup.xml

# Export all jobs
for job in $(jenkins-cli list-jobs); do
  jenkins-cli get-job "$job" > "${job}.xml"
done

# Import all jobs from directory
for file in *.xml; do
  job_name=$(basename "$file" .xml)
  jenkins-cli create-job "$job_name" < "$file"
done

# Copy job directory directly
sudo cp -r /var/lib/jenkins/jobs/old-job /var/lib/jenkins/jobs/new-job
sudo chown -R jenkins:jenkins /var/lib/jenkins/jobs/new-job
jenkins-cli reload-configuration
```

---

## **Jenkins Diagnostics**

### **Health Checks**

```bash
# Check Jenkins is responding
curl -I http://localhost:8080/

# Check with authentication
curl -I -u username:token http://localhost:8080/

# Check system info
curl -u username:token http://localhost:8080/api/json?pretty=true

# Check node status
curl -u username:token http://localhost:8080/computer/api/json?pretty=true

# Check job status
curl -u username:token http://localhost:8080/job/<job-name>/api/json?pretty=true

# Check build status
curl -u username:token http://localhost:8080/job/<job-name>/<build-number>/api/json?pretty=true

# Check queue
curl -u username:token http://localhost:8080/queue/api/json?pretty=true

# Get metrics
curl -u username:token http://localhost:8080/metrics/<key>/api/json?pretty=true
```

### **Log Analysis**

```bash
# View Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# Search for errors
sudo grep -i error /var/log/jenkins/jenkins.log

# Search for specific job
sudo grep "job-name" /var/log/jenkins/jenkins.log

# Count errors
sudo grep -c ERROR /var/log/jenkins/jenkins.log

# Show last 100 lines with errors
sudo tail -1000 /var/log/jenkins/jenkins.log | grep ERROR

# View logs with timestamp
sudo journalctl -u jenkins --since "1 hour ago"

# Export logs to file
sudo journalctl -u jenkins --since today > jenkins-logs-$(date +%Y%m%d).log

# View build logs
cat /var/lib/jenkins/jobs/<job-name>/builds/<build-number>/log

# Search build log for errors
grep -i error /var/lib/jenkins/jobs/<job-name>/builds/<build-number>/log

# View console output via CLI
jenkins-cli console <job-name> <build-number>
```

### **Performance Diagnostics**

```bash
# Check Jenkins memory usage
ps aux | grep jenkins
top -p $(pgrep -f jenkins)

# Check disk usage
df -h /var/lib/jenkins
du -sh /var/lib/jenkins/*
du -sh /var/lib/jenkins/workspace/*

# Find largest files
find /var/lib/jenkins -type f -size +100M -exec ls -lh {} \;

# Check workspace sizes
du -sh /var/lib/jenkins/workspace/* | sort -h

# Check build history size
du -sh /var/lib/jenkins/jobs/*/builds

# Clean old builds (keep last 10)
find /var/lib/jenkins/jobs/*/builds -mindepth 1 -maxdepth 1 -type d | \
  sort -r | tail -n +11 | xargs rm -rf

# Check open files
sudo lsof -u jenkins | wc -l
sudo lsof -u jenkins | head -20

# Check Jenkins Java heap
jmap -heap $(pgrep -f jenkins)

# Thread dump
jstack $(pgrep -f jenkins) > jenkins-threaddump-$(date +%Y%m%d-%H%M%S).txt

# Check for memory leaks
jmap -dump:format=b,file=jenkins-heap-$(date +%Y%m%d).hprof $(pgrep -f jenkins)
```

### **Network Diagnostics**

```bash
# Check Jenkins port
sudo netstat -tuln | grep 8080
sudo ss -tuln | grep 8080

# Check listening services
sudo lsof -i :8080

# Test connectivity
telnet localhost 8080
nc -zv localhost 8080

# Check firewall
sudo firewall-cmd --list-all | grep 8080
sudo iptables -L -n | grep 8080

# Test from remote
curl -I http://<jenkins-server-ip>:8080/

# Check reverse proxy (if using nginx/apache)
curl -I http://jenkins.example.com/

# Test webhook connectivity
curl -X POST http://localhost:8080/github-webhook/ -H "Content-Type: application/json"
```

### **Plugin Diagnostics**

```bash
# List installed plugins
jenkins-cli list-plugins

# Check for plugin updates
jenkins-cli list-plugins | grep -i update

# Find plugin directory
ls -la /var/lib/jenkins/plugins/

# Check plugin size
du -sh /var/lib/jenkins/plugins/*

# Find failed plugins
ls -la /var/lib/jenkins/plugins/*.jpi.disabled

# Check plugin dependencies
unzip -p /var/lib/jenkins/plugins/<plugin>.jpi META-INF/MANIFEST.MF

# Disable plugin manually
sudo mv /var/lib/jenkins/plugins/<plugin>.jpi /var/lib/jenkins/plugins/<plugin>.jpi.disabled
sudo systemctl restart jenkins

# Remove plugin
sudo rm -rf /var/lib/jenkins/plugins/<plugin>*
jenkins-cli reload-configuration
```

---

## **Jenkins Groovy Scripts**

### **Run Groovy Script via CLI**

```bash
# Execute Groovy script
jenkins-cli groovy = < script.groovy

# Inline Groovy script
jenkins-cli groovy = <<< "println Jenkins.instance.pluginManager.plugins"
```

### **Useful Groovy Scripts**

**List all jobs:**

```groovy
Jenkins.instance.getAllItems(Job.class).each { job ->
  println job.fullName
}
```

**Get job configuration:**

```groovy
def job = Jenkins.instance.getItemByFullName('job-name')
println job.configFile.asString()
```

**List all nodes:**

```groovy
Jenkins.instance.nodes.each { node ->
  println "${node.name}: ${node.computer.online ? 'online' : 'offline'}"
}
```

**List running builds:**

```groovy
Jenkins.instance.getAllItems(Job.class).each { job ->
  job.builds.findAll { it.isBuilding() }.each { build ->
    println "${job.name} #${build.number}"
  }
}
```

**Clean old builds:**

```groovy
Jenkins.instance.getAllItems(Job.class).each { job ->
  job.builds.findAll { it.number < (job.nextBuildNumber - 10) }.each { build ->
    build.delete()
  }
}
```

**List users:**

```groovy
User.all.each { user ->
  println "${user.id}: ${user.fullName}"
}
```

---

## **Jenkins API (REST)**

### **Authentication**

```bash
# Using username and password
curl -u username:password http://localhost:8080/api/json

# Using API token (recommended)
curl -u username:API_TOKEN http://localhost:8080/api/json

# Using crumb for CSRF protection
CRUMB=$(curl -u username:token http://localhost:8080/crumbIssuer/api/json | jq -r '.crumb')
curl -u username:token -H "Jenkins-Crumb:$CRUMB" -X POST http://localhost:8080/job/myjob/build
```

### **Common API Calls**

```bash
# Get Jenkins version
curl -s -I http://localhost:8080/ | grep "X-Jenkins:"

# Get system information
curl -u user:token http://localhost:8080/api/json?pretty=true

# List all jobs
curl -u user:token http://localhost:8080/api/json?tree=jobs[name,url]

# Get job info
curl -u user:token http://localhost:8080/job/<job-name>/api/json

# Get last build info
curl -u user:token http://localhost:8080/job/<job-name>/lastBuild/api/json

# Get build console output
curl -u user:token http://localhost:8080/job/<job-name>/<build-number>/consoleText

# Trigger build
curl -u user:token -X POST http://localhost:8080/job/<job-name>/build

# Trigger parameterized build
curl -u user:token -X POST http://localhost:8080/job/<job-name>/buildWithParameters?PARAM1=value1&PARAM2=value2

# Stop build
curl -u user:token -X POST http://localhost:8080/job/<job-name>/<build-number>/stop

# Delete build
curl -u user:token -X POST http://localhost:8080/job/<job-name>/<build-number>/doDelete

# Get queue info
curl -u user:token http://localhost:8080/queue/api/json

# Get node info
curl -u user:token http://localhost:8080/computer/api/json

# Take node offline
curl -u user:token -X POST http://localhost:8080/computer/<node-name>/toggleOffline

# Get plugin info
curl -u user:token http://localhost:8080/pluginManager/api/json?depth=1
```

---

## **Jenkins Troubleshooting**

### **Common Issues**

**Issue 1: Jenkins won't start**

```bash
# Check logs
sudo journalctl -u jenkins -n 100

# Check port conflict
sudo netstat -tuln | grep 8080
sudo lsof -i :8080

# Check Java version
java -version

# Check permissions
ls -la /var/lib/jenkins
sudo chown -R jenkins:jenkins /var/lib/jenkins

# Check disk space
df -h /var/lib/jenkins

# Start in debug mode
sudo java -jar /usr/share/java/jenkins.war --httpPort=8080 --debug
```

**Issue 2: Build failing**

```bash
# View console output
jenkins-cli console <job-name> <build-number>

# Check workspace
ls -la /var/lib/jenkins/workspace/<job-name>/

# Check environment variables
jenkins-cli build <job-name> -s -v

# Clear workspace
rm -rf /var/lib/jenkins/workspace/<job-name>/*
```

**Issue 3: Plugin issues**

```bash
# Check plugin logs
grep "plugin" /var/log/jenkins/jenkins.log

# List failed plugins
ls /var/lib/jenkins/plugins/*.jpi.disabled

# Safe restart
jenkins-cli safe-restart

# Disable plugin
sudo mv /var/lib/jenkins/plugins/<plugin>.jpi \
  /var/lib/jenkins/plugins/<plugin>.jpi.disabled
```

**Issue 4: Disk space full**

```bash
# Check disk usage
df -h /var/lib/jenkins
du -sh /var/lib/jenkins/*

# Clean workspaces
rm -rf /var/lib/jenkins/workspace/*

# Clean old builds
find /var/lib/jenkins/jobs/*/builds -mtime +30 -type d -exec rm -rf {} \;

# Archive old logs
gzip /var/log/jenkins/*.log

# Clean artifacts
find /var/lib/jenkins/jobs/*/builds/*/archive -type f -delete
```

**Issue 5: High memory usage**

```bash
# Check Java heap
jmap -heap $(pgrep -f jenkins)

# Increase heap in service file
# Edit /etc/sysconfig/jenkins or /etc/default/jenkins
JAVA_ARGS="-Xmx2048m -Xms1024m"

# Restart Jenkins
sudo systemctl restart jenkins

# Monitor memory
watch -n 1 'ps aux | grep jenkins'
```

---

## **Jenkins Maintenance Scripts**

### **Cleanup Script**

```bash
#!/bin/bash
# jenkins-cleanup.sh

JENKINS_HOME="/var/lib/jenkins"
DAYS_TO_KEEP=30

echo "=== Jenkins Cleanup Script ==="

# Clean old workspaces
echo "Cleaning old workspaces..."
find $JENKINS_HOME/workspace -maxdepth 1 -type d -mtime +$DAYS_TO_KEEP -exec rm -rf {} \;

# Clean old builds
echo "Cleaning old builds..."
find $JENKINS_HOME/jobs/*/builds -maxdepth 1 -type d -mtime +$DAYS_TO_KEEP -exec rm -rf {} \;

# Compress old logs
echo "Compressing old logs..."
find /var/log/jenkins -name "*.log" -mtime +7 -exec gzip {} \;

# Remove old log archives
echo "Removing old log archives..."
find /var/log/jenkins -name "*.gz" -mtime +$DAYS_TO_KEEP -delete

echo "Cleanup complete!"
df -h $JENKINS_HOME
```

### **Backup Script**

```bash
#!/bin/bash
# jenkins-backup.sh

JENKINS_HOME="/var/lib/jenkins"
BACKUP_DIR="/backup/jenkins"
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="jenkins-backup-$DATE.tar.gz"

mkdir -p $BACKUP_DIR

echo "Creating Jenkins backup..."
sudo systemctl stop jenkins

tar -czf $BACKUP_DIR/$BACKUP_FILE \
  --exclude="$JENKINS_HOME/workspace/*" \
  --exclude="$JENKINS_HOME/war/*" \
  --exclude="$JENKINS_HOME/cache/*" \
  $JENKINS_HOME

sudo systemctl start jenkins

echo "Backup created: $BACKUP_DIR/$BACKUP_FILE"

# Remove backups older than 7 days
find $BACKUP_DIR -name "jenkins-backup-*.tar.gz" -mtime +7 -delete
```

### **Health Check Script**

```bash
#!/bin/bash
# jenkins-health-check.sh

JENKINS_URL="http://localhost:8080"

echo "=== Jenkins Health Check ==="

# Check if Jenkins is running
if systemctl is-active --quiet jenkins; then
  echo "✓ Jenkins service is running"
else
  echo "✗ Jenkins service is not running"
  exit 1
fi

# Check HTTP response
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $JENKINS_URL)
if [ "$HTTP_CODE" == "200" ] || [ "$HTTP_CODE" == "403" ]; then
  echo "✓ Jenkins is responding (HTTP $HTTP_CODE)"
else
  echo "✗ Jenkins is not responding (HTTP $HTTP_CODE)"
fi

# Check disk space
DISK_USAGE=$(df -h /var/lib/jenkins | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 90 ]; then
  echo "✓ Disk usage: ${DISK_USAGE}%"
else
  echo "⚠ Disk usage: ${DISK_USAGE}% (high!)"
fi

# Check memory
MEM_USAGE=$(ps aux | grep jenkins | awk '{sum+=$6} END {print sum/1024}')
echo "ℹ Memory usage: ${MEM_USAGE} MB"

# Check build queue
QUEUE_SIZE=$(curl -s -u user:token $JENKINS_URL/queue/api/json | jq '.items | length')
echo "ℹ Build queue: $QUEUE_SIZE items"

echo "Health check complete!"
```

---

This comprehensive guide covers all essential Jenkins commands, diagnostics, and troubleshooting you'll need!