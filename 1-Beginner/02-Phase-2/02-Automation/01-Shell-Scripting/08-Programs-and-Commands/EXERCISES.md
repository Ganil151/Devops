# 🎯 Hands-On Exercises: Programs and Commands

## Exercise 1: Type Investigation (Beginner)
**Objective**: Identify command types using `type`.

**Tasks**:
1. Check if cd is built-in: `type cd`
2. Check ls: `type ls`
3. Check echo: `type echo`
4. Check grep: `type grep`
5. Check alias (if any): `type ll`

**Fill the Table**:
| Command | Type | Path (if external) |
|---------|------|-------------------|
| `cd` | builtin | N/A |
| `ls` | file | /usr/bin/ls |
| `echo` | builtin | N/A |
| `grep` | file | /usr/bin/grep |

---

## Exercise 2: Which vs Type (Intermediate)
**Objective**: Understand the difference between `which` and `type`.

**Tasks**:
1. Run `which cd` - what happens?
2. Run `type cd` - what's different?
3. Check python: `which python3` and `type python3`
4. Create an alias: `alias ll='ls -lah'`
5. Check it: `which ll` vs `type ll`

**Lesson**: `which` only finds executables in $PATH, `type` finds everything!

---

## Exercise 3: PATH Exploration (Practical)
**Objective**: Understand command resolution order.

**Tasks**:
1. View your PATH: `echo $PATH | tr ':' '\n'`
2. Find where grep lives: `which grep`
3. List all executables in `/usr/bin`: `ls /usr/bin | head -20`
4. Add custom bin to PATH:
   ```bash
   mkdir -p ~/my-scripts
   export PATH="$HOME/my-scripts:$PATH"
   ```
5. Verify: `echo $PATH`
6. Create test script there and run it

---

## Exercise 4: The DevOps Power Toolkit (Essential)
**Objective**: Master the five essential DevOps commands.

**Setup**:
```bash
cat > config.yaml << 'EOF'
database:
  host: localhost
  port: 5432
  user: admin
EOF

cat > data.json << 'EOF'
{
  "users": [
    {"name": "Alice", "role": "dev"},
    {"name": "Bob", "role": "ops"}
  ]
}
EOF
```

**Tasks**:
1. **grep**: Find database lines: `grep database config.yaml`
2. **sed**: Change localhost to prod: `sed 's/localhost/prod-db/g' config.yaml`
3. **awk**: Extract just names: `jq -r '.users[].name' data.json`
4. **curl**: Test API: `curl -s https://api.github.com/users/github`
5. **jq**: Parse JSON: `curl -s https://api.github.com/users/github | jq '.name'`

---

## Exercise 5: Hash Cache Investigation (Advanced)
**Objective**: Understand command caching and hash tables.

**Tasks**:
1. Run a command: `ls`
2. Check hash table: `hash`
3. See cached location: `hash -t ls`
4. Clear one entry: `hash -d ls`
5. Clear all: `hash -r`
6. Verify: `hash`

**Scenario**: Installed new version of tool but old one still runs?
**Solution**: `hash -r` to rebuild cache!

---

## Exercise 6: Built-in vs External Performance (Benchmark)
**Objective**: Measure execution speed difference.

**Tasks**:
1. Time built-in echo:
   ```bash
   time for i in {1..1000}; do echo "test" > /dev/null; done
   ```
2. Time external /usr/bin/echo:
   ```bash
   time for i in {1..1000}; do /usr/bin/echo "test" > /dev/null; done
   ```
3. Compare results - which is faster?

**Expected**: Built-in is ~10x faster (no process creation overhead)!

---

## Exercise 7: Custom Tool Installation (Real-World)
**Objective**: Install a custom command in user space.

**Tasks**:
1. Create custom script:
   ```bash
   mkdir -p ~/bin
   cat > ~/bin/devops-info << 'EOF'
   #!/bin/bash
   echo "=== DevOps Environment Info ==="
   echo "User: $(whoami)"
   echo "Host: $(hostname)"
   echo "Shell: $SHELL"
   echo "PATH entries: $(echo $PATH | tr ':' '\n' | wc -l)"
   EOF
   chmod +x ~/bin/devops-info
   ```
2. Add to PATH: `export PATH="$HOME/bin:$PATH"`
3. Add to .bashrc for permanence
4. Test: `devops-info`

---

## Exercise 8: Command Resolution Debug (Troubleshooting)
**Objective**: Debug command execution issues.

**Scenario**: You have two versions of a tool installed.

**Setup**:
```bash
mkdir -p ~/old-tools ~/new-tools
echo '#!/bin/bash\necho "Old version 1.0"' > ~/old-tools/deploy
echo '#!/bin/bash\necho "New version 2.0"' > ~/new-tools/deploy
chmod +x ~/old-tools/deploy ~/new-tools/deploy
```

**Debug Tasks**:
1. Add both to PATH:
   ```bash
   export PATH="$HOME/old-tools:$HOME/new-tools:$PATH"
   ```
2. Which runs first? `which deploy`
3. Check type: `type deploy`
4. Run it: `deploy`
5. Force new version: `~/new-tools/deploy`
6. Fix PATH order: Put new-tools first

**Lesson**: PATH order matters! First match wins.

---

## Exercise 9: Platform-Specific Commands (Cross-Platform)
**Objective**: Handle differences between Linux/Mac/Windows.

**Tasks**:
Create `platform-check.sh`:
```bash
#!/bin/bash

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
    PKG_MGR="apt"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
    PKG_MGR="brew"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    OS="Windows"
    PKG_MGR="choco"
fi

echo "Operating System: $OS"
echo "Package Manager: $PKG_MGR"

# Check for Docker
if command -v docker &> /dev/null; then
    echo "✅ Docker: $(docker --version)"
else
    echo "❌ Docker: Not installed"
fi

# Check for kubectl
if command -v kubectl &> /dev/null; then
    echo "✅ Kubernetes: $(kubectl version --client --short 2>/dev/null)"
else
    echo "❌ Kubernetes: Not installed"
fi
```

---

## Exercise 10: The Ultimate Command Finder (Expert)
**Objective**: Build a comprehensive command discovery tool.

**Requirements**:
Create `findcmd.sh`:
```bash
#!/bin/bash

SEARCH_TERM="${1:?Usage: $0 <pattern>}"

echo "=== SEARCHING FOR: $SEARCH_TERM ==="
echo ""

# 1. Check if it's an alias
echo "🔍 Aliases:"
alias | grep -i "$SEARCH_TERM" || echo "None found"
echo ""

# 2. Check if it's a built-in
echo "🔧 Built-ins:"
help -d | grep -i "$SEARCH_TERM" || echo "None found"
echo ""

# 3. Search in PATH
echo "📦 Executables in PATH:"
compgen -c | grep -i "$SEARCH_TERM" | head -10
echo ""

# 4. Man page search
echo "📖 Man pages:"
apropos "$SEARCH_TERM" 2>/dev/null | head -5
echo ""

# 5. Check specific locations
if [ -z "$result" ]; then
    echo "💡 Try: apt search $SEARCH_TERM"
fi
```

**Test**:
```bash
./findcmd.sh docker
./findcmd.sh python
./findcmd.sh network
```

---

## Verification Checklist
- [ ] Understand difference between built-ins and external commands
- [ ] Can use `type` to identify command types
- [ ] Know how to check `$PATH` variable
- [ ] Understand command resolution order
- [ ] Master the DevOps toolkit (grep, sed, awk, curl, jq)
- [ ] Know about hash cache and when to clear it
- [ ] Can install custom commands in user space
- [ ] Understand performance difference (built-in vs external)

## Command Resolution Order
1. **Aliases** (checked first)
2. **Keywords** (if, for, while, etc.)
3. **Functions** (user-defined)
4. **Built-ins** (cd, echo, export)
5. **Hash table** (cached locations)
6. **$PATH search** (first match wins)

## DevOps Power Toolkit Reference
| Tool | Purpose | Example |
|------|---------|---------|
| `grep` | Search text | `grep ERROR logs/*.log` |
| `sed` | Stream edit | `sed 's/old/new/g' file` |
| `awk` | Field processing | `awk '{print $1}' data` |
| `curl` | HTTP requests | `curl api.example.com` |
| `jq` | JSON processing | `jq '.name' data.json` |

## Real-World Application
**DevOps Scenario**: Debugging deployment script
```bash
# Script fails - which version of kubectl?
type kubectl
which kubectl

# Check all versions
compgen -c | grep kubectl

# Clear cache if updated
hash -r

# Verify PATH priority
echo $PATH | tr ':' '\n' | nl
```

## Next Steps
Complete these exercises, then proceed to **[Basic Variables](../09-Basic-Variables/EXERCISES.md)** →
