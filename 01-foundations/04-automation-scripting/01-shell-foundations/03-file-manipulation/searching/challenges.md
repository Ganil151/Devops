# 🎯 Hands-On Challenges: Searching in Files (Grep Mastery)

## Challenge 1: Basic Grep Operations (Beginner)
**Objective**: Master fundamental grep syntax.

**Setup**:
```bash
cat > sample.log << 'EOF'
2026-01-11 10:00:01 INFO Server started successfully
2026-01-11 10:00:05 DEBUG Loading configuration
2026-01-11 10:00:10 WARN Deprecated API usage
2026-01-11 10:00:15 ERROR Connection timeout
2026-01-11 10:00:20 INFO Request processed
2026-01-11 10:00:25 ERROR Database connection failed
2026-01-11 10:00:30 INFO Shutdown initiated
EOF
```

**Tasks**:
1. Find all ERROR lines: `grep "ERROR" sample.log`
2. Find case-insensitive "info": `grep -i "info" sample.log`
3. Count ERROR occurrences: `grep -c "ERROR" sample.log`
4. Show line numbers: `grep -n "ERROR" sample.log`
5. Find lines WITHOUT ERROR: `grep -v "ERROR" sample.log`

**Expected Answers**:
- How many ERROR lines? **2**
- How many non-ERROR lines? **5**

---

## Challenge 2: Context Searching (Intermediate)
**Objective**: Use context flags to debug issues.

**Setup**:
```bash
cat > app.log << 'EOF'
Starting application...
Loading modules...
Connecting to database...
Database connection established
Processing user requests
ERROR: Null pointer exception at line 42
Stack trace:
  at UserController.processRequest(UserController.java:42)
  at ServletHandler.handle(ServletHandler.java:123)
Attempting recovery...
Recovery successful
Resuming normal operation
EOF
```

**Tasks**:
1. Find ERROR with 2 lines after: `grep -A 2 "ERROR" app.log`
2. Find ERROR with 2 lines before: `grep -B 2 "ERROR" app.log`
3. Find ERROR with 2 lines context: `grep -C 2 "ERROR" app.log`

**Analysis**: What caused the error based on context?

---

## Challenge 3: Recursive Directory Search (Practical)
**Objective**: Search across multiple files.

**Setup**:
```bash
mkdir -p logs/{app,db,web}
echo "ERROR: App crashed" > logs/app/service.log
echo "INFO: Database ready" > logs/db/status.log
echo "ERROR: 404 Not Found" > logs/web/access.log
echo "WARN: High memory usage" > logs/app/metrics.log
```

**Tasks**:
1. Find all files with ERROR: `grep -r "ERROR" logs/`
2. Show only filenames: `grep -rl "ERROR" logs/`
3. Search with line numbers: `grep -rn "ERROR" logs/`
4. Case-insensitive recursive: `grep -ri "error" logs/`

**Challenge**: Count total ERROR lines across all files.

---

## Challenge 4: Regular Expression Patterns (Advanced)
**Objective**: Master regex for complex searches.

**Setup**:
```bash
cat > users.txt << 'EOF'
john@example.com
admin@localhost
jane_doe@company.org
support@test
webmaster@site.co.uk
EOF
```

**Tasks**:
1. Find emails: `grep -E '\w+@\w+\.\w+' users.txt`
2. Find .com emails: `grep '\.com$' users.txt`
3. Find emails starting with 'j': `grep '^j' users.txt`
4. Find multi-dotted domains: `grep -E '@\w+\.\w+\.\w+' users.txt`

**Bonus**: Extract just the usernames (before @):
```bash
grep -oE '\w+@' users.txt | sed 's/@//'
```

---

## Challenge 5: Log Analysis Mission (Real-World)
**Objective**: Analyze production logs for incidents.

**Setup**:
```bash
cat > production.log << 'EOF'
2026-01-11 08:00:00 [INFO] Service healthy - 200 OK
2026-01-11 08:15:32 [WARN] Slow response time: 2.3s
2026-01-11 08:30:45 [ERROR] Payment gateway timeout
2026-01-11 08:30:46 [ERROR] Transaction ID: TXN-12345 failed
2026-01-11 08:45:12 [INFO] Retry successful
2026-01-11 09:00:00 [ERROR] Database connection pool exhausted
2026-01-11 09:00:01 [CRITICAL] System unavailable
2026-01-11 09:15:33 [INFO] Database connection restored
EOF
```

**Incident Response Tasks**:
1. Find all ERROR and CRITICAL lines:
   ```bash
   grep -E "ERROR|CRITICAL" production.log
   ```
2. Extract failure timestamps:
   ```bash
   grep "ERROR\|CRITICAL" production.log | cut -d' ' -f1-2
   ```
3. Find failed transactions:
   ```bash
   grep "TXN-" production.log
   ```
4. Count incidents by severity:
   ```bash
   grep -o "\[ERROR\]" production.log | wc -l
   grep -o "\[CRITICAL\]" production.log | wc -l
   ```

---

## Challenge 6: Security Audit with Grep (Critical)
**Objective**: Search for security vulnerabilities.

**Tasks**:
1. Find hardcoded passwords:
   ```bash
   grep -rn "password\s*=\s*['\"]" ./src
   ```
2. Find AWS Access Keys (pattern):
   ```bash
   grep -rE "AKIA[0-9A-Z]{16}" ./
   ```
3. Find API tokens:
   ```bash
   grep -riE "(api_key|token|secret).*=.*['\"]" ./config
   ```
4. Find SQL injection risks:
   ```bash
   grep -rn "query.*+.*request\|query.*\$_GET" ./
   ```

**Remediation**: Document all findings!

---

## Challenge 7: Grep vs RipGrep Performance Test (Comparison)
**Objective**: Compare search tool performance.

**Setup**:
```bash
# Create large test file
for i in {1..100000}; do
    echo "Line $i: Some random text here ERROR might appear"
done > large.log
```

**Tasks**:
1. Time standard grep:
   ```bash
   time grep "ERROR" large.log > /dev/null
   ```
2. Time ripgrep (if installed):
   ```bash
   time rg "ERROR" large.log > /dev/null
   ```
3. Compare results and document speed difference

**Question**: Why is ripgrep faster?

---

## Challenge 8: Advanced Pattern Matching (Expert)
**Objective**: Master complex regex patterns.

**Setup**:
```bash
cat > access.log << 'EOF'
192.168.1.1 - - [11/Jan/2026:10:00:01] "GET /api/users HTTP/1.1" 200
10.0.0.15 - - [11/Jan/2026:10:00:05] "POST /login HTTP/1.1" 401
172.16.0.100 - - [11/Jan/2026:10:00:10] "GET /api/data HTTP/1.1" 500
192.168.1.1 - - [11/Jan/2026:10:00:15] "DELETE /user/123 HTTP/1.1" 204
EOF
```

**Tasks**:
1. Extract all IP addresses:
   ```bash
   grep -oE '\b[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b' access.log
   ```
2. Find failed requests (4xx, 5xx):
   ```bash
   grep -E ' [45][0-9]{2}$' access.log
   ```
3. Extract request methods:
   ```bash
   grep -oE '"[A-Z]+ ' access.log | tr -d '"'
   ```
4. Find API endpoints:
   ```bash
   grep -oE '/api/\w+' access.log
   ```

---

## Challenge 9: Grep Pipelines (Power User)
**Objective**: Chain grep with other commands.

**Tasks**:
1. Find and sort unique IPs:
   ```bash
   grep -oE '\b[0-9]{1,3}(\.[0-9]{1,3}){3}\b' access.log | sort | uniq
   ```
2. Count requests per IP:
   ```bash
   grep -oE '^\S+' access.log | sort | uniq -c | sort -rn
   ```
3. Find top 5 error-producing IPs:
   ```bash
   grep " [45][0-9]{2}$" access.log | grep -oE '^\S+' | sort | uniq -c | sort -rn | head -5
   ```

---

## Challenge 10: Custom Grep Alert Script (Automation)
**Objective**: Create monitoring script using grep.

**Requirements**:
Create `log_monitor.sh` that:
1. Watches a log file for ERROR/CRITICAL
2. Sends alert when threshold exceeded
3. Includes context in alert

**Solution**:
```bash
#!/bin/bash

LOG_FILE="/var/log/app.log"
THRESHOLD=5
EMAIL="admin@example.com"

ERROR_COUNT=$(grep -c "ERROR\|CRITICAL" "$LOG_FILE")

if [ $ERROR_COUNT -gt $THRESHOLD ]; then
    echo "ALERT: $ERROR_COUNT errors found in $LOG_FILE"
    grep -C 3 "ERROR\|CRITICAL" "$LOG_FILE" | tail -20
    # In production: | mail -s "Error Alert" $EMAIL
fi
```

---

## Verification Checklist
- [ ] Can use basic grep flags (-i, -n, -v, -c)
- [ ] Understand context searching (-A, -B, -C)
- [ ] Can perform recursive searches (-r)
- [ ] Know basic regex patterns
- [ ] Can extract data with `-o`
- [ ] Understand when to use `-E` for extended regex
- [ ] Can chain grep with pipes
- [ ] Built monitoring scripts with grep

## Grep Cheat Sheet
| Pattern | Meaning |
|---------|---------|
| `^` | Start of line |
| `$` | End of line |
| `.` | Any character |
| `*` | Zero or more |
| `+` | One or more (with -E) |
| `?` | Zero or one (with -E) |
| `[abc]` | Any of a, b, c |
| `[^abc]` | NOT a, b, or c |
| `\|` | OR (with -E) |

## Next Steps
Complete these challenges, then proceed to **[Paging Files](challenges.md)** →
