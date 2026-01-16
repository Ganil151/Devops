# 🎯 Hands-On Challenges: Basic File Manipulation

## Challenge 1: CRUD Basics (Beginner)

**Objective**: Master create, read, update, delete operations.

**Tasks**:

1. Create an empty file: `touch test.txt`
2. Create a directory: `mkdir my-app`
3. Copy the file: `cp test.txt test-backup.txt`
4. Rename the file: `mv test-backup.txt backup.txt`
5. Delete the original: `rm test.txt`
6. Verify what remains: `ls -l`

**Expected Result**: You should have `backup.txt` and `my-app` directory.

---

## Challenge 2: The Folder Factory (Intermediate)

**Objective**: Create complex directory structures efficiently.

**Tasks**:

1. Create this entire structure in ONE command:

```
   devops-project/
   ├── src/
   │   ├── frontend/
   │   └── backend/
   ├── docs/
   ├── tests/
   └── deploy/
       ├── staging/
       └── production/
```

**Command**:

```bash
mkdir -p devops-project/{src/{frontend,backend},docs,tests,deploy/{staging,production}}
```

1. Verify structure: `tree devops-project` or `find devops-project -type d`
2. Create a `README.md` in each directory using a loop (bonus)

---

## Challenge 3: File Backup Strategy (Practical)

**Objective**: Implement a safe backup workflow.
**Scenario**: You're editing a critical configuration file.

**Tasks**:

1. Create a sample config:

   ```bash
   cat > app.conf << EOF
   database=localhost
   port=5432
   debug=false
   EOF
   ```

2. Create a timestamped backup:

   ```bash
   cp app.conf app.conf.$(date +%Y%m%d-%H%M%S)
   ```

3. Edit the original: `echo "version=2.0" >> app.conf`
4. Verify both files exist
5. Compare them: `diff app.conf app.conf.2026*`

**Question**: Why use timestamps instead of simple `.bak` extensions?

---

## Challenge 4: The Recursive Copy Challenge (Advanced)

**Objective**: Safely copy entire directory trees with permissions.

**Setup**:

```bash
mkdir -p source/{data,config,logs}
echo "sensitive" > source/data/database.conf
chmod 600 source/data/database.conf
echo "info" > source/logs/app.log
```

**Tasks**:

1. Copy with basic `cp -r source/ dest1/`
2. Check permissions in dest1: `ls -l dest1/data/`
3. Copy preserving attributes: `cp -rp source/ dest2/`
4. Check permissions in dest2: `ls -l dest2/data/`
5. Compare: `stat source/data/database.conf dest1/data/database.conf dest2/data/database.conf`

**Critical Question**: Why did the permissions differ?

---

## Challenge 5: The Safe Delete Protocol (Critical)

**Objective**: Develop habits that prevent catastrophic data loss.

**Setup**:

```bash
mkdir -p /tmp/delete-practice/{keep,temp,archive}
touch /tmp/delete-practice/keep/important.txt
touch /tmp/delete-practice/temp/cache.{1..5}.tmp
touch /tmp/delete-practice/archive/old-{a..e}.log
```

**SAFE DELETE CHECKLIST**:

1. **Always** `pwd` first
2. **Always** `ls` what you're about to delete
3. Use `-i` for interactive mode initially
4. Test with `echo` first

**Tasks**:

```bash
# Navigate safely
cd /tmp/delete-practice/temp
pwd  # Verify

# Preview what will be deleted
ls *.tmp

# Delete interactively
rm -i *.tmp  # Answer 'y' for each

# Verify
ls
```

**Challenge**: Write a

 `safe_rm` function that always confirms before deleting.

---

## Challenge 6: The Mass Rename Mission (Scripting)

**Objective**: Rename multiple files programmatically.

**Setup**:

```bash
mkdir -p rename-test
cd rename-test
touch IMG-{001..010}.jpg
```

**Task**: Rename all `IMG-*.jpg` to `photo-*.jpg`

**Solution**:

```bash
for file in IMG-*.jpg; do
    mv "$file" "${file/IMG/photo}"
done
```

**Verify**: `ls photo-*.jpg`

**Bonus**: Rename to lowercase and change extension to `.jpeg`

---

## Challenge 7: The DevOps Artifact Manager (Real-World)

**Objective**: Create a script to manage deployment artifacts.

**Requirements**:
Create `artifact_manager.sh` that:

1. Creates a timestamped artifact directory
2. Copies application files to it
3. Creates a checksum file
4. Archives it as `.tar.gz`
5. Cleans up old artifacts (keep last 5)

**Sample Structure**:

```bash
#!/bin/bash
set -e

ARTIFACT_DIR="artifacts/deploy-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$ARTIFACT_DIR"

# Copy application files
cp -r src/ "$ARTIFACT_DIR/"

# Create checksum
find "$ARTIFACT_DIR" -type f -exec md5sum {} \; > "$ARTIFACT_DIR/checksums.md5"

# Archive
tar -czf "${ARTIFACT_DIR}.tar.gz" "$ARTIFACT_DIR"

# Cleanup - keep last 5
ls -t artifacts/*.tar.gz | tail -n +6 | xargs -r rm

echo "✓ Artifact created: ${ARTIFACT_DIR}.tar.gz"
```

---

## Challenge 8: The Wildcard Wizard (Pattern Matching)

**Objective**: Master glob patterns for file operations.

**Setup**:

```bash
mkdir -p glob-lab
cd glob-lab
touch file{1..9}.txt file{10..15}.txt
touch document-a.txt document-b.txt
touch script.sh config.conf README.md
```

**Challenges**:

1. List only single-digit files: `ls file?.txt`
2. List two-digit files: `ls file??.txt`
3. Copy all .txt files to backup/: `mkdir backup && cp *.txt backup/`
4. Delete files 1-5: `rm file[1-5].txt`
5. List files NOT matching a pattern: `ls !(*.txt)` (requires extglob)

**Question**: What's the difference between `*`, `?`, and `[...]`?

---

## Challenge 9: The Disaster Recovery Drill (Critical Thinking)

**Objective**: Recover from common mistakes safely.

**Scenario 1** - Accidental Overwrite:

```bash
cp important.txt backup.txt
# ... do work ...
cp backup.txt important.txt  # Oops! Overwrote important.txt
```

**Solution**: Always use `-i` flag for confirmation, or `-n` for no-clobber.

**Scenario 2** - Wrong Directory Deletion:

```bash
cd /tmp/project
rm -rf ../project  # Deleted wrong directory!
```

**Prevention**: Always use `pwd` and relative paths starting with `./`

**Drill**:

1. Create test environment
2. Intentionally make common mistakes
3. Practice recovery procedures
4. Document lessons learned

---

## Challenge 10: Speed & Efficiency Competition (Mastery)

**Objective**: Complete file operations at professional speed.

**Challenge**: Complete these tasks in under 60 seconds:

1. Create directory `speed-test` with subdirs `a`, `b`, `c`
2. Create 10 files in `a`
3. Copy all files from `a` to `b` preserving permissions
4. Move 5 files from `b` to `c`
5. Archive `c` as `c.tar.gz`
6. Delete `a` and `b`
7. Extract archive to verify

**Pro Solution**:

```bash
mkdir -p speed-test/{a,b,c} && \
touch speed-test/a/file{1..10}.txt && \
cp -p speed-test/a/* speed-test/b/ && \
mv speed-test/b/file{1..5}.txt speed-test/c/ && \
tar -czf speed-test/c.tar.gz -C speed-test c && \
rm -rf speed-test/{a,b} && \
tar -xzf speed-test/c.tar.gz -C speed-test/extracted &&\
echo "✓ Complete"
```

---

## Verification Checklist

- [ ] Can create files and directories
- [ ] Understand difference between `cp` and `cp -p`
- [ ] Know when to use `-r` flag
- [ ] Can rename files with `mv`
- [ ] Practice safe deletion habits
- [ ] Can use wildcards effectively
- [ ] Understand brace expansion `{a,b,c}`
- [ ] Always verify location before destructive operations

## Common Pitfalls to Avoid

❌ `rm -rf /` (Never do this!)  
❌ `mv * ../` without checking `pwd`  
❌ `cp -r` without `-p` for sensitive files  
❌ Using `rm -f` without verification  

## Next Steps

Complete these challenges, then proceed to **[Hidden Files](../04-Hidden-Files/CHALLENGES.md)** →
