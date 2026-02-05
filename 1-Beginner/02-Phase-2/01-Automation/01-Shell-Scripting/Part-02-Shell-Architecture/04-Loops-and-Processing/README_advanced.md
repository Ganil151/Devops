# 🔄 Loops & Data Processing

Handling lists, files, and data structures is the core of automation. This advanced section explores complex iteration patterns, data structure selection, and performance optimization for production scripts.

## 🗄️ Arrays vs. Key-Value Stores

### Indexed Arrays

Standard lists, accessed by number (0, 1, 2...). Good for simple lists of servers or files.

**Characteristics:**
- Sequential access by numeric index
- Preserves insertion order
- Memory efficient for large datasets
- Best for: lists of files, ordered server names, sequential processing

```bash
servers=("web-01" "web-02" "db-01")
for server in "${servers[@]}"; do
  provision "$server"
done
```

### 🔑 Associative Arrays (Bash 4.0+)

Also known as Maps, Dictionaries, or Hash Tables. They allow you to lookup data by string keys instead of numeric indices.

**Characteristics:**
- Key-value pair storage
- O(1) lookup time by key
- Unordered (in most shells)
- Best for: IP-to-hostname mappings, configuration lookups, metadata stores

#### Declaration

```bash
declare -A SERVER_IPS
SERVER_IPS["web"]="192.168.1.10"
SERVER_IPS["db"]="192.168.1.20"
SERVER_IPS["cache"]="192.168.1.30"
```

#### Access by Key

```bash
echo "Web IP is ${SERVER_IPS[web]}"
```

#### Safe Access Pattern

Always check if a key exists before accessing to avoid empty strings masking missing data:

```bash
if [[ -v SERVER_IPS["web"] ]]; then
  echo "Found: ${SERVER_IPS[web]}"
else
  echo "ERROR: 'web' key not found"
fi
```

#### Iterate Over Keys and Values

```bash
# Iterate over keys only
for system in "${!SERVER_IPS[@]}"; do
  echo "System: $system"
done

# Iterate over values only
for ip in "${SERVER_IPS[@]}"; do
  echo "IP: $ip"
done

# Iterate over key-value pairs
for system in "${!SERVER_IPS[@]}"; do
  echo "Hostname: $system, IP: ${SERVER_IPS[$system]}"
done
```

#### Real-World Example: Configuration Lookup

```bash
declare -A ENV_CONFIG
ENV_CONFIG["dev.db_host"]="localhost"
ENV_CONFIG["dev.db_port"]="5432"
ENV_CONFIG["prod.db_host"]="prod-db.internal"
ENV_CONFIG["prod.db_port"]="5432"

get_config() {
  local key="$1"
  if [[ -v ENV_CONFIG["$key"] ]]; then
    echo "${ENV_CONFIG[$key]}"
  else
    echo "ERROR: Config key '$key' not found" >&2
    return 1
  fi
}

db_host=$(get_config "prod.db_host")
db_port=$(get_config "prod.db_port")
```

---

## 🔁 Advanced Loops

### C-Style For Loop

When you need counters, arithmetic progression, or precise index control.

**Syntax:**
```bash
for (( init ; condition ; increment )); do
  # body
done
```

**Use Cases:**
- Batching operations (e.g., process 10 items at a time)
- Counting down or stepping by non-unit values
- Index-based access to arrays
- Generating sequential identifiers

**Examples:**

```bash
# Simple countdown
for ((i=10; i>0; i--)); do
  echo "Launching in $i seconds..."
  sleep 1
done

# Step by 5
for ((i=0; i<=100; i+=5)); do
  echo "Value: $i"
done

# Batching: process 10 items per request
declare -a items=("item1" "item2" "item3" ... "item500")
for ((i=0; i<${#items[@]}; i+=10)); do
  # Get batch of 10 items
  batch=("${items[@]:$i:10}")
  submit_batch "${batch[@]}"
done
```

### Iterate Over Associative Keys

Extract and process only the keys (not values) from an associative array using the `!` parameter expansion:

```bash
declare -A SERVICES
SERVICES["nginx"]="enabled"
SERVICES["postgres"]="enabled"
SERVICES["redis"]="disabled"

# Iterate keys only
for service in "${!SERVICES[@]}"; do
  echo "Service: $service (Status: ${SERVICES[$service]})"
done
```

**Note:** The `!` in `${!ARRAY[@]}` creates a list of keys. Similarly, `${!ARRAY[*]}` also works but behaves slightly differently with word splitting.

---

## 🎯 Advanced Loop Patterns

### Pattern: Safe Loop with Error Handling

Always include trap handlers in long-running loops to handle signals gracefully:

```bash
cleanup() {
  echo "Caught signal; cleaning up..."
  # Kill background jobs
  jobs -p | xargs -r kill 2>/dev/null
  exit 0
}

trap cleanup SIGINT SIGTERM

for item in "${items[@]}"; do
  process_item "$item" &
  
  # Avoid runaway process spawning
  if (( $(jobs -r -p | wc -l) >= 10 )); then
    wait -n  # Wait for next job to finish
  fi
done

wait  # Wait for all remaining jobs
```

### Pattern: Loop with Progress Tracking

Track loop progress and log intermediate results:

```bash
total=${#servers[@]}
processed=0

while IFS= read -r server; do
  ((processed++))
  percent=$(( (processed * 100) / total ))
  
  if process_server "$server"; then
    echo "[$percent%] ✓ $server"
  else
    echo "[$percent%] ✗ $server (FAILED)" >&2
  fi
done < <(printf '%s\n' "${servers[@]}")

echo "Processed $processed/$total servers"
```

### Pattern: Nested Loops with Optimization

When iterating nested structures, use associative arrays to avoid O(n²) operations:

```bash
# ❌ Inefficient: O(n²) lookup
declare -a allowed_users=("alice" "bob" "charlie")
for user in "${input_users[@]}"; do
  for allowed in "${allowed_users[@]}"; do
    if [[ "$user" == "$allowed" ]]; then
      process_user "$user"
      break
    fi
  done
done

# ✅ Efficient: O(n) with associative array
declare -A allowed
for u in alice bob charlie; do
  allowed[$u]=1
done
for user in "${input_users[@]}"; do
  if [[ -v allowed[$user] ]]; then
    process_user "$user"
  fi
done
```

### Pattern: Streaming Large Files with State

Maintain state across loop iterations for complex processing:

```bash
declare -A state
state[line_count]=0
state[error_count]=0
state[last_timestamp]=""

while IFS='|' read -r timestamp level message; do
  ((state[line_count]++))
  
  if [[ "$level" == "ERROR" ]]; then
    ((state[error_count]++))
    state[last_timestamp]="$timestamp"
  fi
done < large_logfile.txt

echo "Processed ${state[line_count]} lines with ${state[error_count]} errors"
echo "Last error at: ${state[last_timestamp]}"
```

---

## 🚀 Performance Optimization in Loops

### Avoiding Common Performance Pitfalls

**Pitfall 1: Spawning Processes Unnecessarily**
```bash
# ❌ Slow: spawns basename for every file
for file in *.txt; do
  name=$(basename "$file")
  echo "$name"
done

# ✅ Fast: use bash string manipulation
for file in *.txt; do
  name="${file%.txt}"
  echo "$name"
done
```

**Pitfall 2: Repeated Subshells in Conditions**
```bash
# ❌ Slow: subshell created each iteration
for item in "${items[@]}"; do
  if [[ $(check_status "$item") == "ready" ]]; then
    process "$item"
  fi
done

# ✅ Fast: capture result once
for item in "${items[@]}"; do
  status=$(check_status "$item")
  if [[ "$status" == "ready" ]]; then
    process "$item"
  fi
done
```

**Pitfall 3: Writing to Files in a Loop**
```bash
# ❌ Slow: opens/closes file each iteration
for line in "${lines[@]}"; do
  echo "$line" >> output.txt
done

# ✅ Fast: write once using process substitution
while IFS= read -r line; do
  echo "Processed: $line"
done < <(printf '%s\n' "${lines[@]}") > output.txt
```

### Memory Considerations

For very large datasets, choose the right approach:

```bash
# Large file (millions of lines): use while read streaming
while IFS= read -r line; do
  process_line "$line"
done < huge_file.txt

# Moderate dataset (thousands): use arrays
declare -a items=()
while IFS= read -r item; do
  items+=("$item")
done < input.txt
# Now can iterate multiple times safely
for item in "${items[@]}"; do
  process "$item"
done

# Small dataset: load fully into memory
mapfile -t small_array < small_file.txt
```

---

## 🔍 Debugging Loops

### Enable Trace Mode for Loop Inspection

```bash
set -x  # Enable debug mode
for item in "${items[@]}"; do
  process "$item"
done
set +x  # Disable debug mode
```

### Log Loop State Checkpoints

```bash
debug_log() {
  [[ "${DEBUG:-0}" == "1" ]] && echo "[DEBUG] $*" >&2
}

for server in "${servers[@]}"; do
  debug_log "Processing server: $server"
  
  if ! ping -c 1 "$server" &>/dev/null; then
    debug_log "Ping failed for $server"
    continue
  fi
  
  if ! ssh "$server" "systemctl status myservice" &>/dev/null; then
    debug_log "Service not running on $server"
    continue
  fi
  
  debug_log "All checks passed; proceeding with deployment"
  deploy_to "$server"
done
```

### Checkpoint/Resume Pattern for Long-Running Loops

```bash
STATE_FILE=".loop_state"

# Load state
if [[ -f "$STATE_FILE" ]]; then
  source "$STATE_FILE"
fi

# Default starting point
LAST_PROCESSED="${LAST_PROCESSED:-0}"

for ((i=LAST_PROCESSED; i<${#items[@]}; i++)); do
  item="${items[$i]}"
  
  if ! process "$item"; then
    echo "LAST_PROCESSED=$i" > "$STATE_FILE"
    echo "ERROR: Failed to process $item at index $i" >&2
    exit 1
  fi
  
  echo "LAST_PROCESSED=$((i+1))" > "$STATE_FILE"
done

rm -f "$STATE_FILE"  # Cleanup on success
echo "All items processed successfully"
```

---

## 📊 Associative Array vs. Indexed Array Decision Matrix

| Factor | Indexed Array | Associative Array |
|--------|---------------|-------------------|
| **Lookup Speed** | O(n) — must iterate | O(1) — direct key access |
| **Memory** | Lower overhead | Slightly higher |
| **Use Case** | Lists, sequences | Key-value mappings, configs |
| **Bash Version** | 3.0+ | 4.0+ required |
| **Iteration Order** | Guaranteed sequential | Unordered |
| **Existence Check** | Difficult | Easy with `[[ -v array[key] ]]` |

---

## ❓ Advanced Interview Questions

1. **Q: When would you use an associative array instead of grepping a config file repeatedly?**
   - A: Load the config once into an associative array for O(1) lookups per query, vs. spawning grep processes. Load at script start if the config is stable.

2. **Q: How do you safely iterate an associative array when keys contain special characters or spaces?**
   - A: Use printf '%s\n' with "${!array[@]}" to iterate keys safely, or use mapfile for line-based data.

3. **Q: Why is C-style `for ((...))` preferred for batching operations?**
   - A: It provides precise arithmetic control without spawning subshells, making it faster and more readable for index-based operations.

4. **Q: How do you handle a loop that modifies the array it's iterating over?**
   - A: Iterate over a copy or extract indices first. Modifying during iteration can cause items to be skipped or processed twice.

---

## 🏆 Production Checklist for Advanced Loops

- ✅ Use associative arrays for O(1) key lookups instead of linear search
- ✅ Check key existence with `[[ -v array[key] ]]` before access
- ✅ Implement signal traps (SIGINT, SIGTERM) for graceful shutdown
- ✅ Log progress and state checkpoints for long-running operations
- ✅ Use `mapfile` or process substitution to avoid subshells
- ✅ Profile loop performance; avoid repeated subshell spawning
- ✅ For large files, stream with `while read` rather than loading into memory
- ✅ Validate loop exit conditions to prevent infinite loops
- ✅ Test edge cases: empty arrays, single items, special characters in keys/values

---

## 🔗 Next Steps

Proceed to: **[Signal Handling & Trap Mechanisms](README.md)** →
