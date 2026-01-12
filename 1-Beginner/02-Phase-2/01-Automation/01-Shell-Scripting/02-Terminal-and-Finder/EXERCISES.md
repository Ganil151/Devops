# 🎯 Hands-On Exercises: Terminal Navigation

## Exercise 1: Navigation Fundamentals (Beginner)
**Objective**: Master basic directory navigation commands.

**Tasks**:
1. Open a terminal
2. Run `pwd` and note your current location
3. Navigate to your home directory: `cd ~`
4. Navigate to root: `cd /`
5. Navigate back to home: `cd ~`
6. Navigate to the previous directory: `cd -`
7. Go up one level: `cd ..`
8. Return to home using just `cd` (no arguments)

**Document**: Write down the absolute path of your home directory.

---
## Exercise 2: Path Detective (Intermediate)
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
## Exercise 3: The Lost Files Mission (Practical)
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
## Exercise 4: The Directory Maze (Challenge)
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
## Exercise 5: Tab Completion Mastery (Skill Builder)
**Objective**: Master tab completion to increase speed.

**Tasks**:
1. Type `cd ~/de` and press Tab twice - what happens?
2. Navigate to `/usr/local/bin` using only Tab completion
3. List files in `/etc` by typing `ls /e` + Tab
4. Create a file with a long name: `touch super_long_configuration_file.txt`
5. Use Tab to complete the filename when viewing it with `cat`

**Pro Tip**: Double-tap Tab when there are multiple matches.

---
## Exercise 6: The PWD Safety Protocol (Real-World)
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
## Exercise 7: Build a Navigation Helper Script (Advanced)
**Objective**: Create a script that helps with common navigation tasks.

**Requirements**:
Create `nav_helper.sh` that:
1. Shows current location
2. Lists current directory contents
3. Shows disk usage of current directory
4. Displays recently accessed directories (from history)

**Sample Code**:
```bash
#!/bin/bash

echo "📍 Current Location: $(pwd)"
echo ""
echo "📁 Contents:"
ls -lh
echo ""
echo "💾 Disk Usage:"
du -sh .
echo ""
echo "📜 Recent Directories:"
dirs -v
```

---
## Exercise 8: The Fast Navigator Challenge (Competition)
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
Complete these exercises, then proceed to **[File Manipulation](../03-Basic-File-Manipulation/EXERCISES.md)** →
