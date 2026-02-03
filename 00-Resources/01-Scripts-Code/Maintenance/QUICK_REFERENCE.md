# Project Clean - Quick Reference

## 🚀 Super Simple Usage

The script now searches **~/Documents/Devops** recursively by default!

### View What's Available
```bash
# List all pattern groups
python3 project_clean.py --list-groups
```

### Most Common Commands

```bash
# Audit documentation files (entire Devops directory)
python3 project_clean.py -g documentation

# Clean up build artifacts (dry-run)
python3 project_clean.py -g build

# Clean temporary files (dry-run)
python3 project_clean.py -g temporary

# Interactive mode - choose groups from menu
python3 project_clean.py -i
```

### Execute Actual Cleanup

```bash
# Execute cleanup with backup (SAFE!)
python3 project_clean.py -g documentation --execute --backup ~/cleanup-backups

# Execute without backup (use with caution!)
python3 project_clean.py -g temporary --execute
```

## 📋 Pattern Groups

| Group | What It Finds |
|-------|---------------|
| `documentation` | AUDIT_REPORT.md, ENHANCEMENT_SUMMARY.md, NAVIGATION_GUIDE.md, GO_AUTOMATION_*.md, CHANGELOG.md |
| `temporary` | *.tmp, *.cache, *.swp, .DS_Store, Thumbs.db, etc. |
| `build` | *.pyc, __pycache__, *.o, *.class, *.log, etc. |
| `metadata` | .vscode, .idea, .sublime-*, etc. |
| `node` | npm-debug.log*, coverage, .nyc_output, etc. |

## 🎯 Advanced Options

### Search Different Directory
```bash
# Search a specific directory instead
python3 project_clean.py -g build -d /path/to/project
```

### Disable Recursive Search
```bash
# Only search top-level (not subdirectories)
python3 project_clean.py -g temporary --no-recursive
```

### Custom Patterns
```bash
# Use your own patterns
python3 project_clean.py -p "*.bak" "*.old" "*.tmp"
```

### Multiple Groups
```bash
# Clean multiple types at once
python3 project_clean.py -g documentation temporary build
```

### Verbose Output
```bash
# See detailed debug information
python3 project_clean.py -g documentation -v
```

## ⚡ Real-World Examples

### Clean up after documentation work
```bash
python3 project_clean.py -g documentation --execute --backup ~/doc-backups
```

### Remove all build artifacts
```bash
python3 project_clean.py -g build --execute
```

### Full cleanup (multiple groups)
```bash
python3 project_clean.py -g temporary build metadata --execute --backup ~/backups
```

### Clean specific project
```bash
python3 project_clean.py -g build -d ~/projects/myapp --execute
```

## ⚠️ Safety First!

1. **Always audit first** - Run without `--execute` to see what will be deleted
2. **Use backups** - Add `--backup ~/backups` when executing
3. **Recursive is default** - It searches all subdirectories automatically
4. **Dry-run is default** - Nothing gets deleted without `--execute`

---

**Quick Tip**: Start with `python3 project_clean.py --list-groups` to see what's available, then use `-g <group>` to audit!
