# 🛠️ Safety Challenges

## Challenge 1: The Guard File
**Objective**: Prevent deletion unless a specific file exists.
1.  Target: `/tmp/data`.
2.  Guard: `/tmp/data/.allow_cleanup`.
3.  Modify the script to fail if `.allow_cleanup` is missing.

## Challenge 2: Disk Space Check
**Objective**: Pre-flight checks.
1.  Check if the root partition has less than 5% free space.
2.  If it does, the cleanup script MUST run.
3.  If it has more than 20%, the script should exit with "No cleanup needed".

## Challenge 3: Dry Run Implementation
**Objective**: Observability.
1.  Add a `-d` or `--dry-run` flag.
2.  If set, the script should print "WOULD DELETE {file}" instead of deleting.
