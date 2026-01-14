# 🔐 File Permissions - Hands-On Challenges

## 📚 **Challenge Overview**
Master Linux file permissions through 10 progressive challenges that simulate real-world DevOps scenarios.

---

## 🟢 **BEGINNER CHALLENGES (1-3)**

### **Challenge 1: Permission Basics**
**Scenario**: You're setting up a new web server and need to understand current file permissions.

**Task**: 
```bash
# Create a test directory structure
mkdir -p ~/permissions-lab/{web,scripts,logs}
touch ~/permissions-lab/web/index.html
touch ~/permissions-lab/scripts/deploy.sh
touch ~/permissions-lab/logs/access.log

# Check permissions
ls -la ~/permissions-lab/
ls -la ~/permissions-lab/web/
ls -la ~/permissions-lab/scripts/
ls -la ~/permissions-lab/logs/
```

**Expected Output**:
```
drwxr-xr-x 5 user user 4096 Jan 11 10:00 .
drwxr-xr-x 3 user user 4096 Jan 11 10:00 ..
drwxr-xr-x 2 user user 4096 Jan 11 10:00 logs
drwxr-xr-x 2 user user 4096 Jan 11 10:00 scripts
drwxr-xr-x 2 user user 4096 Jan 11 10:00 web
```

**Real-World Application**: Understanding default permissions helps prevent security vulnerabilities in web applications.

**Troubleshooting**: If permissions look different, check your umask setting with `umask`.

---

### **Challenge 2: Changing Basic Permissions**
**Scenario**: Your deployment script needs execute permissions, and log files should be write-protected.

**Task**:
```bash
# Make script executable
chmod +x ~/permissions-lab/scripts/deploy.sh

# Make log file read-only
chmod 444 ~/permissions-lab/logs/access.log

# Verify changes
ls -la ~/permissions-lab/scripts/deploy.sh
ls -la ~/permissions-lab/logs/access.log
```

**Expected Output**:
```
-rwxr-xr-x 1 user user 0 Jan 11 10:00 deploy.sh
-r--r--r-- 1 user user 0 Jan 11 10:00 access.log
```

**Real-World Application**: Executable scripts and protected log files are fundamental security practices.

---

### **Challenge 3: Octal Notation Mastery**
**Scenario**: You need to set specific permissions using numeric notation for automation scripts.

**Task**:
```bash
# Set permissions using octal notation
chmod 755 ~/permissions-lab/scripts/deploy.sh  # rwxr-xr-x
chmod 644 ~/permissions-lab/web/index.html     # rw-r--r--
chmod 600 ~/permissions-lab/logs/access.log    # rw-------

# Verify with stat command
stat -c "%a %n" ~/permissions-lab/scripts/deploy.sh
stat -c "%a %n" ~/permissions-lab/web/index.html
stat -c "%a %n" ~/permissions-lab/logs/access.log
```

**Expected Output**:
```
755 /home/user/permissions-lab/scripts/deploy.sh
644 /home/user/permissions-lab/web/index.html
600 /home/user/permissions-lab/logs/access.log
```

**Real-World Application**: Octal notation is essential for Infrastructure as Code tools like Ansible and Terraform.

---

## 🟡 **INTERMEDIATE CHALLENGES (4-6)**

### **Challenge 4: Group Permissions for Team Collaboration**
**Scenario**: Your DevOps team needs shared access to deployment scripts while maintaining security.

**Task**:
```bash
# Create a devops group (simulation)
echo "Simulating: sudo groupadd devops"
echo "Simulating: sudo usermod -a -G devops $USER"

# Set group ownership and permissions
chgrp devops ~/permissions-lab/scripts/deploy.sh 2>/dev/null || echo "Group simulation - would set devops group"
chmod 775 ~/permissions-lab/scripts/deploy.sh

# Create team-writable directory
mkdir ~/permissions-lab/shared
chmod 775 ~/permissions-lab/shared

# Verify permissions
ls -la ~/permissions-lab/scripts/deploy.sh
ls -ld ~/permissions-lab/shared
```

**Expected Output**:
```
-rwxrwxr-x 1 user devops 0 Jan 11 10:00 deploy.sh
drwxrwxr-x 2 user user 4096 Jan 11 10:00 shared
```

**Real-World Application**: Team collaboration requires careful group permission management to balance access and security.

---

### **Challenge 5: Special Permissions - Sticky Bit and SUID**
**Scenario**: Configure a shared directory where users can only delete their own files, and create a monitoring script with elevated privileges.

**Task**:
```bash
# Set sticky bit on shared directory
chmod +t ~/permissions-lab/shared
ls -ld ~/permissions-lab/shared

# Create a monitoring script (SUID simulation)
touch ~/permissions-lab/scripts/monitor.sh
chmod 4755 ~/permissions-lab/scripts/monitor.sh
ls -la ~/permissions-lab/scripts/monitor.sh

# Test sticky bit behavior
touch ~/permissions-lab/shared/user1_file
touch ~/permissions-lab/shared/user2_file
ls -la ~/permissions-lab/shared/
```

**Expected Output**:
```
drwxrwxr-t 2 user user 4096 Jan 11 10:00 shared
-rwsr-xr-x 1 user user 0 Jan 11 10:00 monitor.sh
```

**Real-World Application**: Sticky bits prevent accidental file deletion in shared directories like /tmp. SUID allows scripts to run with elevated privileges.

**Troubleshooting**: If SUID doesn't show 's', check if the file has execute permission first.

---

### **Challenge 6: ACL (Access Control Lists) Basics**
**Scenario**: You need granular permissions for different team members on the same files.

**Task**:
```bash
# Check if ACL is supported
touch ~/permissions-lab/acl-test
getfacl ~/permissions-lab/acl-test 2>/dev/null || echo "ACL not available - would show extended permissions"

# Set ACL permissions (simulation)
echo "Simulating ACL commands:"
echo "setfacl -m u:developer:rw- ~/permissions-lab/web/index.html"
echo "setfacl -m g:qa:r-- ~/permissions-lab/web/index.html"

# Show what ACL output would look like
echo "Expected getfacl output:"
echo "# file: index.html"
echo "# owner: user"
echo "# group: user"
echo "user::rw-"
echo "user:developer:rw-"
echo "group::r--"
echo "group:qa:r--"
echo "mask::rw-"
echo "other::r--"
```

**Real-World Application**: ACLs provide fine-grained access control essential for complex enterprise environments.

---

## 🔴 **ADVANCED CHALLENGES (7-8)**

### **Challenge 7: Security Audit and Remediation**
**Scenario**: Perform a security audit of file permissions and fix vulnerabilities.

**Task**:
```bash
# Create files with various permission issues
mkdir -p ~/permissions-lab/audit
touch ~/permissions-lab/audit/config.txt
touch ~/permissions-lab/audit/secret.key
touch ~/permissions-lab/audit/public.html
chmod 777 ~/permissions-lab/audit/config.txt    # Too permissive
chmod 644 ~/permissions-lab/audit/secret.key    # Secret file readable by others
chmod 600 ~/permissions-lab/audit/public.html   # Public file too restrictive

# Audit script
cat > ~/permissions-lab/audit_script.sh << 'EOF'
#!/bin/bash
echo "=== SECURITY AUDIT ==="
echo "Files with world-writable permissions:"
find ~/permissions-lab -type f -perm -002 2>/dev/null

echo "Files readable by others that might contain secrets:"
find ~/permissions-lab -name "*secret*" -o -name "*key*" -o -name "*password*" | xargs ls -la 2>/dev/null

echo "Executable files owned by others:"
find ~/permissions-lab -type f -perm -111 ! -user $USER 2>/dev/null || echo "None found"

echo "=== RECOMMENDED FIXES ==="
echo "chmod 644 ~/permissions-lab/audit/config.txt"
echo "chmod 600 ~/permissions-lab/audit/secret.key"
echo "chmod 644 ~/permissions-lab/audit/public.html"
EOF

chmod +x ~/permissions-lab/audit_script.sh
~/permissions-lab/audit_script.sh
```

**Expected Output**:
```
=== SECURITY AUDIT ===
Files with world-writable permissions:
/home/user/permissions-lab/audit/config.txt
Files readable by others that might contain secrets:
-rw-r--r-- 1 user user 0 Jan 11 10:00 secret.key
=== RECOMMENDED FIXES ===
chmod 644 ~/permissions-lab/audit/config.txt
chmod 600 ~/permissions-lab/audit/secret.key
chmod 644 ~/permissions-lab/audit/public.html
```

**Real-World Application**: Regular permission audits prevent security breaches and ensure compliance with security policies.

---

### **Challenge 8: Automated Permission Management**
**Scenario**: Create a script that automatically sets correct permissions for a web application deployment.

**Task**:
```bash
# Create web application structure
mkdir -p ~/permissions-lab/webapp/{public,private,scripts,logs,config}
touch ~/permissions-lab/webapp/public/{index.html,style.css,app.js}
touch ~/permissions-lab/webapp/private/{database.conf,api.key}
touch ~/permissions-lab/webapp/scripts/{deploy.sh,backup.sh}
touch ~/permissions-lab/webapp/logs/app.log
touch ~/permissions-lab/webapp/config/settings.ini

# Create permission management script
cat > ~/permissions-lab/set_webapp_permissions.sh << 'EOF'
#!/bin/bash
WEBAPP_DIR="$HOME/permissions-lab/webapp"

echo "Setting web application permissions..."

# Public files - readable by all
find "$WEBAPP_DIR/public" -type f -exec chmod 644 {} \;
find "$WEBAPP_DIR/public" -type d -exec chmod 755 {} \;

# Private files - owner only
find "$WEBAPP_DIR/private" -type f -exec chmod 600 {} \;
find "$WEBAPP_DIR/private" -type d -exec chmod 700 {} \;

# Scripts - executable by owner and group
find "$WEBAPP_DIR/scripts" -type f -exec chmod 750 {} \;

# Logs - writable by owner, readable by group
find "$WEBAPP_DIR/logs" -type f -exec chmod 640 {} \;

# Config - readable by owner and group
find "$WEBAPP_DIR/config" -type f -exec chmod 640 {} \;

echo "Permissions set successfully!"
echo "Verification:"
ls -la "$WEBAPP_DIR"/*
EOF

chmod +x ~/permissions-lab/set_webapp_permissions.sh
~/permissions-lab/set_webapp_permissions.sh
```

**Expected Output**:
```
Setting web application permissions...
Permissions set successfully!
Verification:
-rw-r--r-- 1 user user 0 Jan 11 10:00 index.html
-rw------- 1 user user 0 Jan 11 10:00 database.conf
-rwxr-x--- 1 user user 0 Jan 11 10:00 deploy.sh
-rw-r----- 1 user user 0 Jan 11 10:00 app.log
```

**Real-World Application**: Automated permission management ensures consistent security across deployments and reduces human error.

---

## 🏆 **CHALLENGE CHALLENGES (9-10)**

### **Challenge 9: Container Permission Mapping**
**Scenario**: Understand how file permissions work between host and container environments.

**Task**:
```bash
# Create container simulation environment
mkdir -p ~/permissions-lab/container-sim/{host-data,container-data}
echo "host-file-content" > ~/permissions-lab/container-sim/host-data/shared.txt
chmod 644 ~/permissions-lab/container-sim/host-data/shared.txt

# Simulate container user mapping
echo "=== HOST PERMISSIONS ==="
ls -la ~/permissions-lab/container-sim/host-data/shared.txt
stat -c "UID: %u, GID: %g, Permissions: %a" ~/permissions-lab/container-sim/host-data/shared.txt

# Create script to simulate container behavior
cat > ~/permissions-lab/container_permission_demo.sh << 'EOF'
#!/bin/bash
echo "=== CONTAINER PERMISSION SIMULATION ==="
echo "Host UID: $(id -u)"
echo "Host GID: $(id -g)"
echo ""
echo "Simulating container with UID 1000, GID 1000:"
echo "If host file is owned by UID 1001, container user (1000) cannot write"
echo "If host file is owned by UID 1000, container user (1000) can write"
echo ""
echo "Docker volume mount simulation:"
echo "Host: /home/user/data -> Container: /app/data"
echo "Permissions are preserved but user mapping may differ"
echo ""
echo "Best practices:"
echo "1. Use consistent UIDs between host and container"
echo "2. Set appropriate permissions before mounting"
echo "3. Use Docker user namespace mapping for security"
EOF

chmod +x ~/permissions-lab/container_permission_demo.sh
~/permissions-lab/container_permission_demo.sh
```

**Expected Output**:
```
=== HOST PERMISSIONS ===
-rw-r--r-- 1 user user 13 Jan 11 10:00 shared.txt
UID: 1000, GID: 1000, Permissions: 644
=== CONTAINER PERMISSION SIMULATION ===
Host UID: 1000
Host GID: 1000
Best practices:
1. Use consistent UIDs between host and container
2. Set appropriate permissions before mounting
3. Use Docker user namespace mapping for security
```

**Real-World Application**: Container permission mapping is crucial for Docker and Kubernetes deployments where host and container users must align properly.

---

### **Challenge 10: Enterprise Permission Policy Implementation**
**Scenario**: Implement a comprehensive permission policy for a multi-tier application environment.

**Task**:
```bash
# Create enterprise application structure
mkdir -p ~/permissions-lab/enterprise/{frontend,backend,database,monitoring,secrets}

# Create policy implementation script
cat > ~/permissions-lab/enterprise_policy.sh << 'EOF'
#!/bin/bash
BASE_DIR="$HOME/permissions-lab/enterprise"

echo "Implementing Enterprise Permission Policy..."

# Frontend - Public facing, readable by web server
mkdir -p "$BASE_DIR/frontend"/{static,templates}
touch "$BASE_DIR/frontend/static"/{app.js,style.css}
touch "$BASE_DIR/frontend/templates/index.html"
find "$BASE_DIR/frontend" -type f -exec chmod 644 {} \;
find "$BASE_DIR/frontend" -type d -exec chmod 755 {} \;

# Backend - Application code, restricted access
mkdir -p "$BASE_DIR/backend"/{src,config}
touch "$BASE_DIR/backend/src/app.py"
touch "$BASE_DIR/backend/config/settings.py"
find "$BASE_DIR/backend" -type f -exec chmod 640 {} \;
find "$BASE_DIR/backend" -type d -exec chmod 750 {} \;

# Database - Highly restricted
mkdir -p "$BASE_DIR/database"/{data,backups}
touch "$BASE_DIR/database/data/app.db"
touch "$BASE_DIR/database/backups/backup.sql"
find "$BASE_DIR/database" -type f -exec chmod 600 {} \;
find "$BASE_DIR/database" -type d -exec chmod 700 {} \;

# Monitoring - Readable by monitoring systems
mkdir -p "$BASE_DIR/monitoring"/{metrics,logs}
touch "$BASE_DIR/monitoring/metrics/app_metrics.txt"
touch "$BASE_DIR/monitoring/logs/app.log"
find "$BASE_DIR/monitoring" -type f -exec chmod 644 {} \;
find "$BASE_DIR/monitoring" -type d -exec chmod 755 {} \;

# Secrets - Maximum security
mkdir -p "$BASE_DIR/secrets"
touch "$BASE_DIR/secrets"/{api.key,db.password,ssl.cert}
find "$BASE_DIR/secrets" -type f -exec chmod 600 {} \;
find "$BASE_DIR/secrets" -type d -exec chmod 700 {} \;

echo "Policy Implementation Complete!"
echo ""
echo "=== PERMISSION AUDIT ==="
for dir in frontend backend database monitoring secrets; do
    echo "=== $dir ==="
    find "$BASE_DIR/$dir" -type f -exec ls -la {} \; 2>/dev/null | head -3
done

echo ""
echo "=== SECURITY COMPLIANCE CHECK ==="
echo "Checking for overly permissive files..."
find "$BASE_DIR" -type f -perm -044 -path "*/secrets/*" && echo "WARNING: Secrets readable by others!" || echo "✓ Secrets properly protected"
find "$BASE_DIR" -type f -perm -002 && echo "WARNING: World-writable files found!" || echo "✓ No world-writable files"

echo ""
echo "=== POLICY SUMMARY ==="
echo "Frontend: 644/755 - Public readable"
echo "Backend: 640/750 - Group readable"
echo "Database: 600/700 - Owner only"
echo "Monitoring: 644/755 - Public readable"
echo "Secrets: 600/700 - Owner only"
EOF

chmod +x ~/permissions-lab/enterprise_policy.sh
~/permissions-lab/enterprise_policy.sh
```

**Expected Output**:
```
Implementing Enterprise Permission Policy...
Policy Implementation Complete!

=== PERMISSION AUDIT ===
=== frontend ===
-rw-r--r-- 1 user user 0 Jan 11 10:00 app.js
-rw-r--r-- 1 user user 0 Jan 11 10:00 style.css
=== secrets ===
-rw------- 1 user user 0 Jan 11 10:00 api.key

=== SECURITY COMPLIANCE CHECK ===
✓ Secrets properly protected
✓ No world-writable files

=== POLICY SUMMARY ===
Frontend: 644/755 - Public readable
Backend: 640/750 - Group readable
Database: 600/700 - Owner only
Monitoring: 644/755 - Public readable
Secrets: 600/700 - Owner only
```

**Real-World Application**: Enterprise permission policies ensure consistent security across complex multi-tier applications and meet compliance requirements.

---

## 🎯 **VERIFICATION CHECKLIST**

After completing all challenges, verify your understanding:

- [ ] Can explain the difference between user, group, and other permissions
- [ ] Can use both symbolic and octal notation for chmod
- [ ] Understands special permissions (sticky bit, SUID, SGID)
- [ ] Can implement ACLs for granular access control
- [ ] Can perform security audits and remediation
- [ ] Can automate permission management
- [ ] Understands container permission mapping
- [ ] Can implement enterprise-grade permission policies

---

## 🔗 **NEXT STEPS**

Continue to: **[Finally Scripting](../12-Finally-Scripting/README.md)** →

**Prerequisites for Next Module**:
- Understanding of file permissions and security
- Basic command-line proficiency
- Familiarity with text editors

**Related Modules**:
- **[Linux Basics](../../01-Phase-1/02-Linux/README.md)** - Foundation concepts
- **[Security Fundamentals](../../../3-Advanced/01-Phase-1/07-Security/README.md)** - Advanced security topics