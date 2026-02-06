# File Operations - DevOps Challenges

## Challenge 1: Configuration File Manager
**Scenario**: Your DevOps team needs a tool to manage configuration files across environments.

**Requirements:**
1. Create a Go program that:
   - Reads a configuration file (`config.txt`)
   - Backs it up with a timestamp
   - Writes updated configuration
2. Handle all file operation errors properly

**Verification:**
```bash
cd boilerplate
go run main.go
# Should create backup file with timestamp
ls -lh
```

---

## Challenge 2: Log File Rotator
**Scenario**: Build a log rotation tool that keeps log files under control.

**Requirements:**
1. Check if a log file exceeds a size limit (e.g., 1MB)
2. If it does, rename it with a timestamp suffix
3. Create a new empty log file
4. Print rotation status

**Verification:**
```bash
go run rotator.go --file app.log --max-size 1048576
# Expected: Rotates if file > 1MB
```

---

## Challenge 3: Directory Scanner
**Scenario**: Create a tool that scans directories for specific file types (useful for cleanup automation).

**Requirements:**
1. Accept a directory path and file extension as arguments
2. Recursively scan all subdirectories
3. Print all matching files with their sizes
4. Calculate total size of matching files

**Verification:**
```bash
go run scanner.go --dir /var/log --ext .log
# Expected: Lists all .log files with sizes
```

---

## Challenge 4 (Advanced): File Sync Checker
**Scenario**: Build a tool that compares files between two directories (useful for deployment verification).

**Requirements:**
1. Accept two directory paths
2. Compare files by name and checksum (MD5 or SHA256)
3. Report files that are:
   - Missing in destination
   - Modified (different checksums)
   - Identical
4. Use goroutines for parallel checksum calculation

**Verification:**
```bash
go run sync_checker.go --source ./build --dest ./deploy
# Expected: Detailed comparison report
```

---

## Challenge 5 (Expert): Binary File Patcher
**Scenario**: Create a tool that patches configuration files in deployed binaries.

**Requirements:**
1. Read a binary file
2. Search for a specific byte pattern
3. Replace it with new data
4. Write the patched binary
5. Verify the patch was successful

**Verification:**
```bash
go run patcher.go --file app.bin --find "OLD_KEY" --replace "NEW_KEY"
# Expected: Binary file patched successfully
```

**Next Step**: [Working with JSON →](challenges.md)
