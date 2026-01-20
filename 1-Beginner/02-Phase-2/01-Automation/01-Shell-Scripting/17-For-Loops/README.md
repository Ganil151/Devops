# 🔁 Loops: The Engine of Repetitive Automation

> **"If you do it more than 3 times, write a loop. If you do it more than 10 times, rewrite the loop to be parallel."**

![Iteration Control](./iteration_mechanics.png)

## 📚 Overview

Automation is the art of repeating a task perfectly a thousand times. **Loops** are the engine of bulk processing in the shell. Whether you are checking the health of 500 microservices, renaming 10,000 log files, or waiting for a database to come online, loops give you the power of scale.

### Historical Context
In early Bourne Shells, looping was limited to simple word splitting lists. As systems grew, the need for arithmetic logic (`for ((...))`) and safe file handling (`while read`) drove the evolution of Bash. Unlike higher-level languages like Python where loops are objects, Shell loops are text-processors at heart. Dealing with spaces, newlines, and buffering is the primary challenge that separates novices from experts.

## 🎓 Learning Objectives

By the end of this module, you will:

1.  ✅ **Master For-In Loops for collections and shell globbing.**
    *   **Why**: To safely iterate over files without parsing `ls`.
    *   **Use Case**: Batch renaming `*.jpg` files to `*.png`.
2.  ✅ **Implement While-Read loops for high-performance line processing.**
    *   **Why**: It's the only memory-safe way to process massive CSVs or logs.
    *   **Use Case**: Parsing a 5GB `access.log` to find 404 errors.
3.  ✅ **Avoid the "Parse LS" Trap which crashes scripts with spaces in filenames.**
    *   **Why**: "Word Splitting" makes `$(ls)` unreliable for file iteration.
    *   **Use Case**: Handling filenames like `User Data (Backup).txt` correctly.
4.  ✅ **Orchestrate Until Loops for service readiness probes.**
    *   **Why**: Waiting for resources (DB, API) is critical in cloud-init scripts.
    *   **Use Case**: Pausing a startup script until `localhost:5432` accepts connections.
5.  ✅ **Manage flow with Break (exit) and Continue (skip) keywords.**
    *   **Why**: To handle exceptions or jump over invalid data items.
    *   **Use Case**: Skipping a loop iteration if a `user` is "root" or "nobody".
6.  ✅ **Explore C-Style Loops and basic Parallelism patterns.**
    *   **Why**: Sequential processing is too slow for 1000+ servers.
    *   **Use Case**: Pinging a subnet of IPs concurrently using background jobs `&`.

---

## 🏗️ Iteration Architecture: Choosing the Right Engine

### 1. The `for` Loop (Collection Processing)

The `for` loop is the workhorse of shell automation when you have a **defined set** of items to process, but its simplicity masks a complex expansion mechanism.

-   **Expansion Mechanism**: Before execution, the shell performs **Word Splitting** on the list provided. It uses the Internal Field Separator (`$IFS`)—typically space, tab, and newline—to break the list into individual tokens. This is why quoting is critical.
-   **Fixed Lists & Arrays**: `for server in "${SERVERS[@]}"; do ... done`. Using `"${ARRAY[@]}"` ensures that items with spaces remain as single tokens.
-   **Brace & Sequence Expansion**: `for i in {1..100}; do ... done`. This expansion happens *before* any other processing, making it more efficient than calling the external `seq` binary in modern shells.
-   **Shell Globbing (The Safe Way)**: `for file in *.log; do ... done`. Globbing is performed by the shell itself. It is the **gold standard** for file processing because it never splits filenames on spaces.
-   **The `$(ls)` Trap**: **NEVER** use `for i in $(ls)`. This creates a "subshell ghost" where the output of `ls` is treated as a single string and then re-split by the shell. If a file is named `Project Alpha.txt`, the loop will treat it as two separate files: `Project` and `Alpha.txt`.

### 2. The `while` Loop (Dynamic Polling)

The `while` loop is the engine for **state-based** automation where the finish line isn't fixed.

-   **Status Evaluation**: It evaluates the exit status of the command following the `while` keyword. As long as that command returns `0` (Success), the loop body executes.
-   **Readiness Probes (Polling)**: In enterprise orchestration, `while` is indispensable for polling.

```bash
# Polling a health endpoint with a timeout
while [[ $(curl -L -s -o /dev/null -w "%{http_code}" localhost:8080) != "200" ]]; do
    echo "Server not ready... retrying."
    sleep 5
done
```

-   **The High-Performance `read` Pattern**: In shell scripting, the `while read` loop is the most memory-efficient way to process text files.

```bash
while read -r line; do
    process_log_line "$line"
done < "/var/log/syslog"
```

-   **Memory Efficiency**: Unlike a `for` loop, which loads the entire dataset into RAM as a list of words, `while read` buffers the file line-by-line, allowing you to process gigabyte-sized logs safely.
-   **Flags Matter**: Always use `read -r`. The `-r` flag prevents the shell from misinterpreting backslashes (escaping), ensuring data integrity.

### 3. The `until` Loop (Wait-Until Logic)

The `until` loop is the semantic "inverse" of `while`, designed specifically for **waiting for a state change**.

-   **Semantic Logic**: It runs as long as the condition returns a **non-zero** (Failure) exit status. It terminates when the condition finally succeeds.
-   **Human Readability**: While logically equivalent to `while ! condition`, `until` is preferred in professional scripts for "Readiness Checks." It explicitly signals to other engineers: *"This script is paused until a dependency is satisfied."*
-   **Common DevOps Scenario**: Waiting for an Infrastructure as Code (IaC) resource to move from a `PENDING` to a `READY` state.

```bash
# Wait for RDS instance to be available
until aws rds describe-db-instances --db-instance-identifier prod-db | grep -q "available"; do
    echo "Waiting for RDS availability..."
    sleep 30
done
```

---

## 🚀 Professional Patterns for Automation

### Pattern A: The "While-Read" Performance Pattern

In enterprise logging, processing speed and variable scope are paramount. This pattern solves the two biggest flaws of the `for` loop.

-   **The Subshell Problem**: Avoid `cat log.txt | while read`. Piping creates a **Subshell**. Variables modified inside a piped loop (like a counter) are lost once the loop ends. Using redirection (`done < log.txt`) ensures the loop runs in the **current shell process**, preserving variable state.
-   **Field Splitting (`IFS`)**: By setting `IFS` locally for the `read` command, you can parse structured data (CSV, logs) without using slow external tools like `awk` or `cut`.
-   **The `-r` Guard**: Prevents the shell from mangling backslashes in pathnames or configuration strings.

```bash
# Efficient, scope-safe CSV processing
while IFS=',' read -r timestamp level service message; do
    # Logic is executed in the parent shell context
    [[ "$level" == "CRITICAL" ]] && ((critical_count++))
    echo "[$timestamp] Alert for $service: $message"
done < "system_events.csv"

echo "Total Critical Failures: $critical_count"
```

### Pattern B: The C-Style Loop (Index Awareness)

While `for x in list` is common, the C-style loop provides precise arithmetic control over iteration.

-   **Syntax**: `for (( init ; condition ; step ))`.
-   **Use Case: Batching**: Ideal when you need to process infrastructure in specific numerical batches or skip every N-th item.
-   **Index Access**: Unlike collection-based loops, you always have a numerical index available for progress tracking or generating sequential IDs (e.g., `web-server-01`, `web-server-02`).

```bash
# Provisioning 10 servers with sequential IDs
for ((i=1; i<=10; i++)); do
    printf -v server_id "app-%02d" $i
    echo "Provisioning $server_id in us-east-1..."
    # AWS/Terraform triggering logic here
done
```

### Pattern C: Background Parallelism (Throughput)

The shell is single-threaded by default, which is a bottleneck when dealing with 1,000 servers. This pattern introduces "Shell Concurrency."

-   **The `&` Operator**: Forks the loop body into a background process, allowing the loop to continue to the next item immediately.
-   **The `wait` Barrier**: A critical command that pauses the main script until **all** background child processes (jobs) have completed. Without it, your script might report "Success" while background tasks are still failing.
-   **Resource Safety**: Launching 1000 jobs at once will crash your system. For unlimited lists, use `xargs -P` (Search "GNU Parallel Patterns").

```bash
# Parallel Health Check Cluster-wide
for node in $(get_cluster_nodes); do
    {
        if curl -s --fail "http://$node/health"; then
            echo "$node: HEALTHY"
        else
            echo "$node: UNHEALTHY" >> failure.log
        fi
    } &
done

wait # Barrier: Ensures all checks finish before generating the final report
echo "Cluster scan complete."
```

### Pattern D: The Retry Loop (Exponential Backoff)

In distributed systems, transient network failures are inevitable. A "Loop with Backoff" makes your automation resilient.

-   **Mechanism**: Use a `while` loop combined with a counter and an increasing `sleep` timer.
-   **Purpose**: Prevents "Thundering Herd" problems where a script hammers a failing API, potentially making the failure worse.

```bash
local max_retries=5
local attempt=1
local delay=2

until cloud_api_call || [[ $attempt -eq $max_retries ]]; do
    echo "Call failed. Attempt $attempt/$max_retries. Retrying in ${delay}s..."
    sleep $delay
    ((attempt++))
    ((delay *= 2)) # Exponential Backoff
done
```

---

## 🏆 Real-World DevOps Story: The Space-in-Filename Nightmare

**The Scenario**: A junior engineer used `for f in $(ls *.conf)` to update Nginx configuration files. One configuration was named `Backup Site.conf`.

**The Discovery**: Because of the word-splitting behavior, the shell treated the output as two separate items: `Backup` and `Site.conf`. Neither existed, so the configuration was never updated, causing a site outage during the next reload.

**The Fix**: Always use **Globbing**. `for f in *.conf; do ...`. Shell globbing treats the entire filename as a single token, preserving spaces and special characters perfectly.

---

## ❓ Interview Preparation (Shell Loops)

1. **Q: Why is `for i in $(ls)` considered bad practice?**
   *A: It fails on filenames with spaces, it doesn't handle hidden files correctly unless explicitly asked, and it spawns an unnecessary subshell. Globbing (`for i in *`) is superior in every way.*

2. **Q: How do you read a CSV file line-by-line in a script?**
   *A: Use a `while IFS=',' read -r col1 col2` loop. Setting `IFS` (Internal Field Separator) allows for easy column splitting.*

3. **Q: What is the difference between `break` and `continue`?**
   *A: `break` exits the entire loop immediately. `continue` only skips the remaining code in the current iteration and jumps to the start of the next one.*

4. **Q: How do you create an infinite loop for a monitoring script?**
   *A: Use `while true; do ... sleep 60; done`. This is often used for sidecar containers or status monitors.*

5. **Q: How can you limit the execution time of a loop?**
   *A: Use a counter inside a `while` loop or combined with a `timeout` command. Example: `while [[ $count -lt 10 ]] && ! check_status; do ((count++)); sleep 1; done`.*

---

## 📝 Knowledge Check

1. **Which loop type is inherently designed for "Polling" until a status changes?**
   - [ ] a) `for`
   - [x] b) `while`
   - [ ] c) `select`
   *Explanation: `while` loops run as long as a command succeeds/fails, making them ideal for checking live status (e.g., waiting for ping).*

2. **What happens if you use `for f in *` and there are no files?**
   - [ ] a) The script crashes
   - [x] b) It literally iterates over the string `*` (standard shell behavior)
   - [ ] c) It skips the loop automatically
   *Explanation: By default, if a glob matches nothing, Bash passes the literal asterisk character to the loop. Use `shopt -s nullglob` to change this.*

3. **How do you accurately count from 1 to 10 in a loop?**
   - [ ] a) `for i in 10`
   - [x] b) `for i in {1..10}` or `for ((i=1; i<=10; i++))`
   - [ ] c) `while [ 1..10 ]`
   *Explanation: Brace expansion `{1..10}` or C-style arithmetic loops are the standard ways to generate sequences.*

4. **Which variable determines how the shell splits strings in a loop?**
   - [ ] a) `$PATH`
   - [x] b) `$IFS`
   - [ ] c) `$SPLIT`
   *Explanation: The Internal Field Separator (`IFS`) controls word splitting. It defaults to Space, Tab, Newline.*

5. **True or False: Using `&` inside a loop runs the code in the background.**
   - [x] a) True
   - [ ] b) False
   *Explanation: The ampersand forks the process. Remember to use `wait` to synchronize before the script exits.*

---

## 🔗 Next Steps

Ready to handle data streams?

Directly to: **[Input/Output](../18-Input-Output/README.md)** →
