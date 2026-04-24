# 🎯 Hands-On Challenges: Man Pages

## Challenge 1: Man Page Basics (Beginner)
**Objective**: Navigate and understand man page structure.

**Tasks**:
1. Open the ls manual: `man ls`
2. Navigate through sections using Space/b
3. Find the `-a` flag description: `/

-a`
4. Jump to EXAMPLES section: Type `/EXAMPLES`
5. Quit: Press `q`
6. Get one-line summary: `whatis ls`

**Question**: What section number is `ls` in? (Hint: Look at top of man page)

---

## Challenge 2: Section Navigation (Intermediate)
**Objective**: Access different manual sections.

**Tasks**:
1. View printf command (section 1): `man 1 printf`
2. View printf C function (section 3): `man 3 printf`
3. List all printf entries: `man -f printf` or `whatis printf`
4. View passwd command: `man 1 passwd`
5. View passwd file format: `man 5 passwd`

**Challenge**: Find which section contains information about `/etc/hosts` file format.

**Answer**: `man 5 hosts`

---

## Challenge 3: Keyword Search with Apropos (Practical)
**Objective**: Find commands when you don't know their names.

**Tasks**:
1. Find all network-related commands:
   ```bash
   apropos network
   ```
2. Find commands for file compression:
   ```bash
   apropos compress
   ```
3. Find commands with "user" in description:
   ```bash
   apropos user
   ```
4. Case-insensitive search:
   ```bash
   apropos -i NETWORK
   ```

**Challenge**: Find the command to change file permissions using apropos.

---

## Challenge 4: Man vs Help vs Info (Comparison)
**Objective**: Understand when to use each documentation tool.

**Tasks**:
1. Try `man cd` - what happens?
2. Use `help cd` instead (built-in command)
3. Try `man tar` vs `info tar`
4. Compare output lengths and depth

**Fill the Table**:
| Command | man | help | info |
|---------|-----|------|------|
| `cd` | ❌ | ✅ | ❌ |
| `ls` | ✅ | ❌ | ✅ |
| `export` | ❌ | ✅ | ❌ |

**Rule**: Use `help` for shell built-ins, `man` for external commands!

---

## Challenge 5: Synopsis Decoder (Advanced)
**Objective**: Read and understand command syntax notation.

**Task**: Decode this synopsis from `man cp`:
```
cp [OPTION]... SOURCE DEST
cp [OPTION]... SOURCE... DIRECTORY
```

**Questions**:
1. What does `[OPTION]` mean? (Answer: Optional)
2. What does `...` mean? (Answer: Can be repeated)
3. What does `SOURCE DEST` mean? (Answer: Required arguments)

**Practice**: Decode `man tar` synopsis and explain each part.

---

## Challenge 6: Flag Hunting Mission (Skill Builder)
**Objective**: Quickly find specific flags in man pages.

**Challenges** (Time yourself!):
1. What does `ls -lh` do? Find in man page in under 30 seconds
2. What's the flag to make `grep` case-insensitive?
3. How do you make `rm` interactive?
4. What flag makes `mkdir` create parent directories?

**Pro Tip**: Use `/` to search within man pages!

**Answers**:
1. `-l` = long listing, `-h` = human-readable sizes
2. `-i`
3. `-i`
4. `-p`

---

## Challenge 7: Version Mismatch Detective (Real-World)
**Objective**: Verify command behavior matches your system.

**Scenario**: An online tutorial says `grep --perl-regexp` works, but fails on your system.

**Investigation**:
1. Check grep version: `grep --version`
2. Read man page: `man grep`
3. Search for perl support: `/perl`
4. Check if -P flag exists
5. Document: Does your version support it?

**Alternative**: Use `grep -E` for extended regex instead.

---

## Challenge 8: Custom Documentation Script (Automation)
**Objective**: Build a command

 reference helper.

**Requirements**:
Create `cmdref.sh`:
```bash
#!/bin/bash

CMD="${1:?Usage: $0 <command>}"

echo "=== COMMAND REFERENCE: $CMD ==="
echo ""

# Check if it exists
if ! command -v "$CMD" &> /dev/null; then
    echo "❌ Command not found"
    exit 1
fi

# Show one-liner
echo "📝 Description:"
whatis "$CMD" 2>/dev/null || echo "No description available"
echo ""

# Show location
echo "📍 Location:"
which "$CMD"
echo ""

# Show version
echo "🔢 Version:"
"$CMD" --version 2>/dev/null || "$CMD" -v 2>/dev/null || echo "No version info"
echo ""

# Man page check
if man "$CMD" &> /dev/null; then
    echo "📖 Manual available: man $CMD"
else
    echo "ℹ️  Try: help $CMD (if it's a built-in)"
fi
```

**Test**:
```bash
chmod +x cmdref.sh
./cmdref.sh ls
./cmdref.sh cd
./cmdref.sh docker
```

---

## Challenge 9: The RTFM Challenge (Competition)
**Objective**: Answer questions using ONLY man pages.

**Rules**: No Google, no AI, just `man` and `apropos`.

**Questions** (15 minutes total):
1. How do you copy a file preserving all attributes?
2. What command shows disk usage?
3. How do you search for files by name?
4. What's the difference between `rm -r` and `rm -rf`?
5. How do you change file ownership?
6. What command shows running processes?
7. How do you compress a directory with tar?
8. What flag makes `cp` interactive?
9. How do you view the first 20 lines of a file?
10. What command shows network connections?

**Hints**:
- Use `apropos` for commands you don't know
- Use `/` to search within man pages
- Read SYNOPSIS and DESCRIPTION sections

---

## Challenge 10: Build a Man Page Navigator (Expert)
**Objective**: Create an interactive man page browser.

**Requirements**:
Create `manx.sh` (man explorer):
```bash
#!/bin/bash

while true; do
    echo ""
    echo "=== MAN PAGE EXPLORER ==="
    echo "1. Search by keyword (apropos)"
    echo "2. View specific man page"
    echo "3. List section"
    echo "4. Exit"
    echo -n "Choice: "
    read -r choice
    
    case $choice in
        1)
            echo -n "Keyword: "
            read -r keyword
            apropos "$keyword" | less
            ;;
        2)
            echo -n "Command: "
            read -r cmd
            man "$cmd" 2>/dev/null || echo "Not found"
            ;;
        3)
            echo -n "Section (1-8): "
            read -r sect
            man -s "$sect" -k . | less
            ;;
        4)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
done
```

---

## Verification Checklist
- [ ] Can navigate man pages efficiently
- [ ] Understand manual section numbers (1-8)
- [ ] Know when to use `man` vs `help` vs `info`
- [ ] Can search for commands with `apropos`
- [ ] Understand synopsis notation `[]`, `<>`, `...`
- [ ] Can quickly find specific flags
- [ ] Use `whatis` for quick summaries
- [ ] Read man pages before searching online

## Manual Section Reference
| Section | Content |
|---------|---------|
| 1 | User commands (ls, grep, etc.) |
| 2 | System calls (programming) |
| 3 | Library functions (C libraries) |
| 4 | Device files (/dev/*) |
| 5 | File formats (/etc/passwd) |
| 6 | Games |
| 7 | Miscellaneous |
| 8 | System administration (reboot, iptables) |

## Pro Tips
✅ **Before running a new command**, read its man page  
✅ **Learn to love** the EXAMPLES section  
✅ **Bookmark** frequently-used commands in your notes  
✅ **Practice offline** - man pages work without internet  

## Common Man Page Sections
- **NAME**: Command name and brief description
- **SYNOPSIS**: How to use the command
- **DESCRIPTION**: Detailed explanation
- **OPTIONS**: All available flags
- **EXAMPLES**: Practical usage
- **SEE ALSO**: Related commands

## Real-World Application
**DevOps Scenario**: Learning a new deployment tool
```bash
# First check if installed
which kubectl

# Get quick summary
whatis kubectl

# Read full manual
man kubectl

# Find specific task
man kubectl | grep -A 5 "get pods"

# Check available subcommands
kubectl --help
```

## Next Steps
Complete these challenges, then proceed to **[Programs and Commands](../08-programs-and-commands/challenges.md)** →
