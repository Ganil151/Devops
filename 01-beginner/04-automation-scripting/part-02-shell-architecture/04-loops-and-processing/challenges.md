# 🔄 Hands-On Challenges: Loops & Processing

## Target: Batch Processing & Resiliency

Loops are the heavy lifters of DevOps. In these challenges, you will build scripts that perform mass operations (like pinging a subnet) and resilient operations (like waiting for a database to come up).

---

## 🟢 **BEGINNER CHALLENGES (1-3)**

### **Challenge 1: The Server Pinger (For Loop)**
**Mission**: Iterate through a list of servers and check their health immediately.
1. Create a mock list of servers (some good, some bad).
2. Loop through them using `for`.
3. Simulate a connectivity check.

**Steps**:
```bash
cat > ~/server_pinger.sh << 'EOF'
#!/bin/bash

# Array of servers (simulated)
SERVERS=("frontend-01" "backend-db" "broken-cache" "api-gateway")

echo "Starting Health Check..."
echo "------------------------"

for SRV in "${SERVERS[@]}"; do
    # Simulate a check: "broken-cache" will fail
    if [[ "$SRV" == "broken-cache" ]]; then
        STATUS="❌ DOWN"
    else
        STATUS="✅ UP"
    fi
    
    # Prinf for nice alignment
    printf "Server: %-15s Status: %s\n" "$SRV" "$STATUS"
done
EOF

chmod +x ~/server_pinger.sh
./server_pinger.sh
```

**Why**: This is the basis of every inventory management script (Ansible `hosts` loop).

---

### **Challenge 2: The Log Sentinel (While Loop)**
**Mission**: Process a log file line-by-line *as if it were streaming* and alert on errors.
1. Create a dummy log file with lines of text.
2. Use `while read` to process it without loading it all into RAM.
3. Detect "ERROR" lines and count them.

**Steps**:
```bash
cat > ~/log_sentinel.sh << 'EOF'
#!/bin/bash

# Create dummy log with 1000 lines
echo "Generating logs..."
for i in {1..1000}; do
    if (( i % 100 == 0 )); then
        echo "2024-01-01 10:00:$i [ERROR] Connection Dropped" >> app.log
    else
        echo "2024-01-01 10:00:$i [INFO] Keepalive signal" >> app.log
    fi
done

echo "Processing logs..."
ERROR_COUNT=0

# The Loop (Memory Safe)
while IFS= read -r LINE; do
    if [[ "$LINE" == *"[ERROR]"* ]]; then
        ((ERROR_COUNT++))
    fi
done < app.log

echo "------------------------"
echo "Scan Complete."
echo "Total Errors Found: $ERROR_COUNT"
rm app.log
EOF

chmod +x ~/log_sentinel.sh
./log_sentinel.sh
```

**Why**: Using `cat file | while` runs in a subshell (variables lost on exit). `done < file` runs in current shell (variables preserved).

---

### **Challenge 3: The Slow Database (Until Loop)**
**Mission**: Wait for a service to become available before proceeding (Classic "Wait-For-It" script).
1. Loop *until* a file `db.lock` is removed (simulating ready state).
2. Implement a timeout (don't wait forever!).

**Steps**:
```bash
cat > ~/wait_for_db.sh << 'EOF'
#!/bin/bash

# Simulate DB starting (create lock file)
touch db.lock
(sleep 5; rm db.lock) &  # Run in background: delete lock after 5s

echo "Waiting for Database..."
TIMEOUT=10
COUNTER=0

# Loop until lock file is GONE
until [[ ! -f db.lock ]]; do
    if (( COUNTER >= TIMEOUT )); then
        echo "❌ Timeout! DB never came up."
        exit 1
    fi
    
    echo "  ... DB locked. Retrying in 1s ($COUNTER/$TIMEOUT)"
    sleep 1
    ((COUNTER++))
done

echo "✅ Database is UP! Starting application."
EOF

chmod +x ~/wait_for_db.sh
./wait_for_db.sh
```

**Why**: Readiness Probes are essential in Kubernetes and Docker Compose to prevent app crashes on startup.

---

## 🟡 **INTERMEDIATE CHALLENGES (4-5)**

### **Challenge 4: The Batch Renamer**
**Mission**: Rename all `.txt` files to `.bak` using a loop, handling spaces in filenames correctly.
1. Create files like `My Data.txt`.
2. Loop safely.
3. Use parameter expansion `${f%.txt}` to change extension.

**Steps**:
```bash
cat > ~/batch_rename.sh << 'EOF'
#!/bin/bash

# Setup
touch "File One.txt" "File Two.txt" "image.jpg"

echo "Current files:"
ls -1

echo "Renaming .txt -> .bak..."
# SAVE WAY: Globbing (handles spaces automatically)
for FILE in *.txt; do
    # Skip if no match
    [[ -e "$FILE" ]] || continue
    
    NEW_NAME="${FILE%.txt}.bak"
    mv "$FILE" "$NEW_NAME"
    echo "Renamed: '$FILE' -> '$NEW_NAME'"
done

echo "New files:"
ls -1
EOF

chmod +x ~/batch_rename.sh
./batch_rename.sh
```

**Why**: Handling spaces is the #1 way junior scripts break file systems.

---

### **Challenge 5: The Mass User Creator (CSV Parsing)**
**Mission**: Read a CSV file (user,group) and simulate creating users.
1. Use `IFS=,` to parse CSV columns.

**Steps**:
```bash
cat > ~/user_import.sh << 'EOF'
#!/bin/bash

# Create CSV
echo "alice,developers" > users.csv
echo "bob,ops" >> users.csv
echo "charlie,managers" >> users.csv

echo "Importing Users..."
echo "------------------"

while IFS=, read -r USER GROUP; do
    echo "Creating user '$USER' in group '$GROUP'..."
    # useradd -m -G "$GROUP" "$USER" (Simulated)
done < users.csv

rm users.csv
EOF

chmod +x ~/user_import.sh
./user_import.sh
```

**Why**: Reading structured data (CSV/TSV) is a daily task in DevOps.

---

## 🔗 **NEXT STEPS**
Proceed to **[Functions & Scope](../05-functions-and-scope/readme.md)** →
