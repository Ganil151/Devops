# 🎯 Hands-On Challenges: Paging Files

## Challenge 1: Less Basics (Beginner)
**Objective**: Master the `less` pager for log file navigation.

**Setup**:
```bash
# Create a large log file
for i in {1..1000}; do
    echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] Processing request $i"
done > large.log
```

**Tasks**:
1. Open file with less: `less large.log`
2. Navigate down: Press `Space` or `Page Down`
3. Navigate up: Press `b` or `Page Up`
4. Jump to start: Press `g`
5. Jump to end: Press `G`
6. Search forward for "500": Type `/500` and press Enter
7. Next match: Press `n`
8. Quit: Press `q`

**Pro Tip**: Use `less -N` to show line numbers!

---

## Challenge 2: Head and Tail Mastery (Intermediate)
**Objective**: Extract specific portions of files efficiently.

**Setup**:
```bash
seq 1 100 > numbers.txt
```

**Tasks**:
1. View first 10 lines: `head numbers.txt`
2. View first 5 lines: `head -n 5 numbers.txt`
3. View last 10 lines: `tail numbers.txt`
4. View last 3 lines: `tail -n 3 numbers.txt`
5. View lines 20-30: `head -n 30 numbers.txt | tail -n 11`
6. Skip first 10 lines: `tail -n +11 numbers.txt`

**Challenge**: Extract lines 50-60 in ONE pipeline.

---

## Challenge 3: Real-Time Log Monitoring (Practical)
**Objective**: Monitor live log files.

**Setup**:
```bash
# Terminal 1: Create continuous log
while true; do
    echo "$(date +'%H:%M:%S') Event $(($RANDOM % 100))"
    sleep 1
done > live.log &
LOG_PID=$!
```

**Tasks**:
1. Follow log in real-time: `tail -f live.log`
2. Stop with `Ctrl+C`
3. Follow last 5 lines: `tail -n 5 -f live.log`
4. Use -F for rotating logs: `tail -F live.log`
5. Stop the log generator: `kill $LOG_PID`

**Real-World**: This is how you monitor deployments in production!

---

## Challenge 4: Memory-Efficient File Preview (Advanced)
**Objective**: View huge files without loading into memory.

**Setup**:
```bash
# Create 100MB file
dd if=/dev/zero of=huge.bin bs=1M count=100
```

**Tasks**:
1. Try `cat huge.bin` - watch memory spike!
2. Use `less huge.bin` - instant load!
3. Check memory usage: `ps aux | grep less`
4. View binary file safely: `less -f huge.bin`

**Analysis**: Why doesn't less crash with huge files?

---

## Challenge 5: Multi-File Paging (Power User)
**Objective**: Navigate between multiple files in less.

**Setup**:
```bash
echo "File 1 content" > file1.txt
echo "File 2 content" > file2.txt
echo "File 3 content" > file3.txt
```

**Tasks**:
1. Open multiple files: `less file*.txt`
2. See current file: Type `:f` in less
3. Next file: Type `:n`
4. Previous file: Type `:p`
5. Jump to specific file: Type `:e file2.txt`

---

## Challenge 6: Search Within Less (Expert)
**Objective**: Master advanced search capabilities.

**Setup**:
```bash
cat > search_demo.txt << 'EOF'
ERROR: Connection failed
INFO: Retrying connection
WARN: Slow response
ERROR: Timeout occurred
INFO: Success
ERROR: Database unavailable
EOF
```

**Tasks**:
1. Open file: `less search_demo.txt`
2. Search for "ERROR": `/ERROR`
3. Next occurrence: `n`
4. Previous occurrence: `N`
5. Backward search: `?INFO`
6. Case-insensitive: `/-i error`
7. Highlight all matches: Use `less -i` flag when opening

---

## Challenge 7: Production Log Analysis (Real-World)
**Objective**: Analyze production logs efficiently.

**Scenario**: You're debugging a production incident.

**Setup**:
```bash
cat > production.log << 'EOF'
[00:00] System startup
[00:15] User login: admin
[00:30] Database connection established
[01:00] Processing batch job
[01:30] ERROR: Out of memory
[01:31] ERROR: Service crashed
[01:35] System restart initiated
[02:00] System healthy
EOF
```

**Investigation Tasks**:
1. Open log: `less production.log`
2. Jump to end (latest events): `G`
3. Search backward for first ERROR: `?ERROR`
4. Mark the line: `m` + letter (e.g., `ma`)
5. Return to mark: `'` + letter (e.g., `'a`)
6. View surrounding context by scrolling

**Document**: What time did the incident start?

---

## Challenge 8: Tail Performance Comparison (Benchmark)
**Objective**: Understand tail's efficiency versus other methods.

**Setup**:
```bash
# Create 1GB log file
dd if=/dev/urandom of=giant.log bs=1M count=1000
```

**Tasks**:
1. Time traditional method:
   ```bash
   time cat giant.log | tail -n 100 > /dev/null
   ```
2. Time direct tail:
   ```bash
   time tail -n 100 giant.log > /dev/null
   ```
3. Compare results - which is faster and why?

**Answer**: Tail is instant because it reads from the END of file!

---

## Challenge 9: Custom Log Monitor Script (Automation)
**Objective**: Build a production-ready log monitoring script.

**Requirements**:
Create `log_monitor.sh`:
```bash
#!/bin/bash
set -euo pipefail

LOG_FILE="${1:-/var/log/syslog}"
ALERT_PATTERN="${2:-ERROR|CRITICAL|FATAL}"
CHECK_INTERVAL=5

echo "Monitoring $LOG_FILE for pattern: $ALERT_PATTERN"

tail -F "$LOG_FILE" | grep --line-buffered -E "$ALERT_PATTERN" | \
while read -r line; do
    echo "[ALERT] $(date): $line"
    # In production: send to monitoring system
done
```

**Test**:
```bash
# Terminal 1
./log_monitor.sh test.log "ERROR"

# Terminal 2
echo "INFO: Normal operation" >> test.log
echo "ERROR: Something failed!" >> test.log
```

---

## Challenge 10: The Less Survival Challenge (Competition)
**Objective**: Master less navigation at professional speed.

**Setup**:
```bash
# Create challenge file
seq 1 10000 | sed 's/500/TARGET-500/; s/2500/TARGET-2500/; s/7500/TARGET-7500/' > challenge.txt
```

**Speed Challenge** (Complete in under 60 seconds):
1. Open file
2. Find first TARGET line
3. Mark it
4. Find second TARGET line
5. Count lines between them
6. Jump to end of file
7. Find third TARGET from bottom
8. Return to first marked TARGET
9. Quit

**Pro Commands**:
- `1G` - Jump to line 1
- `500G` - Jump to line 500
- `ma` - Mark position as 'a'
- `'a` - Return to mark 'a'
- `:.=` - Show current line number

---

## Verification Checklist
- [ ] Comfortable navigating in less (g, G, Space, b)
- [ ] Can search forward (/) and backward (?)
- [ ] Master head and tail for file slicing
- [ ] Know difference between -f and -F for tail
- [ ] Can monitor logs in real-time
- [ ] Understand marks in less
- [ ] Built log monitoring scripts
- [ ] Grasp why pagers are memory-efficient

## Common Less Commands Reference
| Key | Action |
|-----|--------|
| `Space` | Page down |
| `b` | Page up |
| `g` | Go to start |
| `G` | Go to end |
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` | Next match |
| `N` | Previous match |
| `q` | Quit |
| `h` | Help |

## Real-World Application
**DevOps Scenario**: Debug a crashed microservice
```bash
# SSH to production server
ssh production-server

# Check latest errors
tail -100 /var/log/app/service.log | grep ERROR

# Monitor live
tail -f /var/log/app/service.log | grep --line-buffered ERROR

# Detailed analysis
less +G /var/log/app/service.log  # Opens at end
```

## Next Steps
Complete these challenges, then proceed to **[Man Pages](challenges.md)** →
