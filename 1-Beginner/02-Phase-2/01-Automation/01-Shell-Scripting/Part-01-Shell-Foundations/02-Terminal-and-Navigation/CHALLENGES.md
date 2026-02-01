# 🎯 Hands-On Challenges: Terminal Navigation

## Challenge 1: The Production Log Inspector (Mission-Based Beginner)

**Objective**: Navigate a production-like filesystem to inspect application logs.

**The Why**: When an app crashes at 2 AM, you need to SSH into the server and find the logs **fast**. No GUI, no mouse click through folders.

**Scenario**: Your team's web application is throwing errors. You need to check the logs.

**Tasks**:

1. **Simulate production filesystem** (create the structure):
   ```bash
   mkdir -p ~/production-sim/var/log/{nginx,app,system}
   mkdir -p ~/production-sim/etc/nginx
   mkdir -p ~/production-sim/var/www/app
   ```

2. **Create sample log files** (with errors):
   ```bash
   cd ~/production-sim/var/log/app
   echo "[2026-02-01 02:45:12] INFO: Application started" > app.log
   echo "[2026-02-01 02:45:15] ERROR: Database connection failed" >> app.log
   echo "[2026-02-01 02:45:16] ERROR: Retry attempt 1/3" >> app.log
   ```

3. **Your Mission** (complete these steps):
   - Start from your home directory (`cd ~`)
   - Navigate to the app logs: `cd ~/production-sim/var/log/app`
   - Verify your location: `pwd`
   - List all log files with sizes: `ls -lh`
   - View the last 10 lines: `tail app.log`
   - Find all ERROR lines: `grep ERROR app.log`

**Expected Output**:
```bash
$ pwd
/home/you/production-sim/var/log/app

$ ls -lh
total 4.0K
-rw-r--r-- 1 you you 180 Feb  1 02:45 app.log

$ grep ERROR app.log
[2026-02-01 02:45:15] ERROR: Database connection failed
[2026-02-01 02:45:16] ERROR: Retry attempt 1/3
```

**What You Learned**:
- ✅ How to navigate to log directories (every server has `/var/log`)
- ✅ `pwd` confirms you're in the right place before running commands
- ✅ `ls -lh` shows file sizes in human-readable format (K, M, G)
- ✅ `grep` finds specific error patterns (critical for debugging)

**Pro Tip**: In real production, you'd use `tail -f app.log` to watch logs in real-time as errors happen!

---
## Challenge 2: Path Detective (Intermediate)
**Objective**: Understand absolute vs relative paths.
**Tasks**:
1. Create this directory structure in `/tmp`:
   ```
   mkdir -p /tmp/devops-lab/{logs,configs,scripts}
   ```
2. Navigate to `/tmp/devops-lab/logs` using an **absolute path**
3. Navigate to `configs` using a **relative path** (from logs)
4. Navigate to `scripts` using `..` notation
5. From `scripts`, navigate to `/tmp` using an absolute path
6. Navigate back to `scripts` using a relative path from `/tmp`
**Challenge**: Write the relative path from `/tmp/devops-lab/scripts` to `/tmp/devops-lab/configs`

**Answer**: `../configs`

---
## Challenge 3: The Lost Files Mission (Practical)
**Objective**: Use `ls` flags to find specific files.

**Setup**:
```bash
cd /tmp/devops-lab
touch logs/error.log logs/access.log
touch configs/.env configs/app.conf
touch scripts/deploy.sh scripts/backup.sh
chmod +x scripts/*.sh
```

**Tasks**:
1. List all files in `logs` showing size and permissions: `ls -lh logs/`
2. List **hidden** files in `configs`: `ls -la configs/`
3. List files sorted by modification time: `ls -lt`
4. List files in reverse order: `ls -lr`
5. List files recursively: `ls -R`

**Questions**:
- What is the difference between `-l` and `-lh`?
- Why didn't `.env` show up with normal `ls`?
- How can you see files sorted by size?

---
## Challenge 4: The Directory Maze (Challenge)
**Objective**: Navigate complex directory structures efficiently.

**Setup**: Create this structure:
```bash
mkdir -p ~/devops-practice/{app/{frontend,backend/{api,db}},infra/{terraform,ansible}}
cd ~/devops-practice
```

**Tasks** (Do these in ONE command each):
1. From `~`, navigate to `backend/api`
2. From `api`, navigate to `frontend`
3. From `frontend`, navigate to `terraform`
4. From `terraform`, navigate back to your home directory
5. From `~`, navigate to `ansible`

**Speed Challenge**: Complete all 5 tasks in under 30 seconds!

---
## Challenge 5: Tab Completion Mastery (Skill Builder)
**Objective**: Master tab completion to increase speed.

**Tasks**:
1. Type `cd ~/de` and press Tab twice - what happens?
2. Navigate to `/usr/local/bin` using only Tab completion
3. List files in `/etc` by typing `ls /e` + Tab
4. Create a file with a long name: `touch super_long_configuration_file.txt`
5. Use Tab to complete the filename when viewing it with `cat`

**Pro Tip**: Double-tap Tab when there are multiple matches.

---
## Challenge 6: The PWD Safety Protocol (Real-World)
**Objective**: Develop defensive navigation habits.

**Scenario**: You're about to run `rm -rf *` to clean up temp files.

**Tasks**:
1. Create test environment:
   ```bash
   mkdir -p /tmp/test-zone
   cd /tmp/test-zone
   touch file1.txt file2.txt important.txt
   ```
2. Before deleting, **always** run `pwd` first
3. Verify you're in `/tmp/test-zone`
4. Run `ls` to confirm what you're about to delete
5. Only then run `rm -rf *.txt`

**Critical Question**: What would happen if you forgot to run `pwd` and were actually in your home directory?

---
## Challenge 7: Build a Deployment Verification Script (Production Mission)

**Objective**: Create a script that verifies deployment success by checking key directories.

**The Why**: After deploying code, you need to verify:
- Files are in the right place
- Permissions are correct
- Logs exist and are writable

This is what real CI/CD pipelines do!

**Requirements**:
Create `verify_deployment.sh` that:
1. Checks if application directory exists
2. Verifies config files are present
3. Shows disk space (deployments can fill disks!)
4. Lists recent logs
5. Exits with proper codes for CI/CD

**Production-Ready Code**:
```bash
#!/usr/bin/env bash
set -euo pipefail

# Configuration
APP_DIR="/var/www/app"
CONFIG_FILE="/etc/nginx/sites-available/app.conf"
LOG_DIR="/var/log/app"

echo "🔍 Deployment Verification Started..."
echo "====================================="

# 1. Verify application directory
echo ""
echo "📁 Checking application directory..."
if [[ -d "$APP_DIR" ]]; then
    echo "✅ App directory exists: $APP_DIR"
    echo "   Size: $(du -sh $APP_DIR | cut -f1)"
else
    echo "❌ ERROR: App directory missing!"
    exit 1
fi

# 2. Verify config file
echo ""
echo "⚙️  Checking configuration..."
if [[ -f "$CONFIG_FILE" ]]; then
    echo "✅ Config file exists: $CONFIG_FILE"
else
    echo "❌ ERROR: Config file missing!"
    exit 1
fi

# 3. Check disk space
echo ""
echo "💾 Checking disk space..."
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [[ $DISK_USAGE -lt 90 ]]; then
    echo "✅ Disk usage OK: ${DISK_USAGE}%"
else
    echo "⚠️  WARNING: Disk usage high: ${DISK_USAGE}%"
fi

# 4. Check logs
echo ""
echo "📜 Recent logs (last 3):"
if [[ -d "$LOG_DIR" ]]; then
    ls -lt "$LOG_DIR" | head -4 | tail -3
else
    echo "⚠️  Log directory not found (may be first deployment)"
fi

echo ""
echo "====================================="
echo "✅ Deployment verification PASSED"
exit 0
```

**Test It**:
```bash
chmod +x verify_deployment.sh
./verify_deployment.sh

# Check exit code
echo "Exit code: $?"
# 0 = success, 1 = failure
```

**What You Learned**:
- ✅ Directory existence checks (`[[ -d ]]`)
- ✅ File existence checks (`[[ -f ]]`)
- ✅ Disk space monitoring (critical for production)
- ✅ Exit codes for CI/CD integration
- ✅ Structured logging with emojis for readability

**Real-World Use**:
```yaml
# In a GitHub Actions workflow:
- name: Verify Deployment
  run: |
    ssh prod-server './verify_deployment.sh'
    # Pipeline fails if exit code != 0
```

---
## Challenge 8: The Fast Navigator Challenge (Competition)
**Objective**: Maximize navigation speed.

**Setup**:
```bash
mkdir -p /tmp/speed-test/{dir1,dir2,dir3,dir4,dir5}
cd /tmp/speed-test
```

**Challenge**: Starting from `/tmp/speed-test`, complete these tasks as fast as possible:
1. Enter `dir3`
2. Go back to parent
3. Enter `dir5`
4. Jump to `/tmp`
5. Return to `speed-test`
6. Enter `dir1`
7. Go to home
8. Return to `/tmp/speed-test/dir1` in ONE command

**Target Time**: Under 15 seconds

**Pro Shortcuts**:
- `cd -` toggles between last two directories
- `pushd` and `popd` for directory stack
- Create aliases for frequent paths

---
## Verification Checklist
- [ ] Can navigate using `cd`, `pwd`, `ls`
- [ ] Understand absolute vs relative paths
- [ ] Know when to use `~`, `/`, `..`, `-`
- [ ] Can use `ls` flags effectively
- [ ] Master Tab completion
- [ ] Always verify location before destructive commands
- [ ] Can navigate complex directory trees efficiently
## Real-World Application
**DevOps Scenario**: You need to check logs on a production server.
```bash
cd /var/log/nginx/
pwd  # Verify location
ls -lt | head  # See recent logs
tail -f access.log  # Monitor live
```
## Next Steps
Complete these challenges, then proceed to **[File Manipulation](../03-Basic-File-Manipulation/CHALLENGES.md)** →
