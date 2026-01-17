# 🔄 Loops & Data Processing

Handling lists, files, and data structures is the core of automation.

## 🗄️ Arrays vs. Key-Value Stores

### Indexed Arrays
Standard lists, accessed by number (0, 1, 2...). Good for simple lists of servers or files.

### 🔑 Associative Arrays (Bash 4.0+)
Also known as Maps, Dictionaries, or Hash Tables. They allow you to lookup data by string keys.
**Crucial for**: Mapping IP addresses to Hostnames, Usernames to IDs, etc.

#### Declaration
```bash
declare -A SERVER_IPS
SERVER_IPS["web"]="192.168.1.10"
SERVER_IPS["db"]="192.168.1.20"
```

#### Access
```bash
echo "Web IP is ${SERVER_IPS[web]}"
```

---

## 🔁 Advanced Loops

### C-Style For Loop
When you need counters.
```bash
for ((i=0; i<10; i++)); do
    echo "Count $i"
done
```

### Iterate Over Associative Keys
```bash
for system in "${!SERVER_IPS[@]}"; do
    echo "Hostname: $system, IP: ${SERVER_IPS[$system]}"
done
```
*Note the `!` in `${!ARRAY[@]}` which creates a list of keys.*
