# 🛠️ Sed & Awk Challenges

## Challenge 1: Log Miner

**Objective**: Extract specific data from a messy log file using `sed` and `awk`.

**Step 1: Create Dummy Log**
```bash
cat <<EOF > data.log
ERROR 2023-10-01 DB_TIMEOUT (500ms)
INFO  2023-10-01 STARTUP
ERROR 2023-10-02 CONNECTION_REFUSED (100ms)
DEBUG 2023-10-02 VAR_A=1
ERROR 2023-10-03 DB_TIMEOUT (600ms)
EOF
```

**Step 2: Clean and Filter**
Use `sed` to remove the parentheses around the duration.

**Step 3: Analyze with Awk**
Pipe the clean output to `awk` to find the **average** time of errors.
*Expected Result*: `Avg Error Time: 400 ms`

## Challenge 2: Config Patcher
Create a generic script `patch_config.sh key value file`.
It should use `sed` to find `key = ...` in the file and replace it with `key = value`.
It should create a backup of the file (`.bak`) before editing.
