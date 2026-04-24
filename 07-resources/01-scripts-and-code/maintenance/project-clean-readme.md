# Project Cleanup Utility

A robust, professional-grade Python utility for auditing and cleaning project directories by removing specified file patterns. Designed with DevOps best practices, comprehensive error handling, and flexible pattern matching.

## 🚀 Features

### Core Capabilities
- ✅ **Dry-Run Mode**: Audit files before deletion (default behavior)
- ✅ **Recursive Search**: Scan through entire directory trees
- ✅ **Backup Functionality**: Automatically backup files before deletion
- ✅ **Pattern Groups**: Predefined sets of patterns for common cleanup scenarios
- ✅ **Interactive Mode**: Menu-driven pattern group selection
- ✅ **Custom Patterns**: Support for glob-style pattern matching
- ✅ **Comprehensive Logging**: Configurable verbosity levels
- ✅ **Error Handling**: Graceful handling of permission errors and edge cases
- ✅ **Statistics Reporting**: Detailed summary of operations performed

### Pattern Groups

The script includes predefined pattern groups for common cleanup scenarios:

| Group | Description | Example Patterns |
|-------|-------------|------------------|
| `documentation` | Documentation files | `AUDIT_REPORT.md`, `ENHANCEMENT_SUMMARY.md`, `CHANGELOG.md` |
| `temporary` | Temporary and cache files | `*.tmp`, `*.cache`, `*.swp`, `.DS_Store` |
| `build` | Build artifacts and compiled files | `*.pyc`, `__pycache__`, `*.o`, `*.class` |
| `metadata` | IDE and editor metadata | `.vscode`, `.idea`, `*.sublime-*` |
| `node` | Node.js specific files | `npm-debug.log*`, `coverage`, `.nyc_output` |

## 📦 Installation

### Requirements
- Python 3.7 or higher
- Standard library only (no external dependencies)

### Setup
```bash
# Clone or download the script
cd /path/to/scripts

# Make it executable
chmod +x project_clean.py

# Optional: Create symlink for easy access
sudo ln -s $(pwd)/project_clean.py /usr/local/bin/project-clean
```

## 🎯 Usage

### Quick Start

```bash
# List available pattern groups
python3 project_clean.py --list-groups

# Interactive mode - select patterns from menu
python3 project_clean.py -i -d /path/to/project

# Use predefined pattern group (dry-run)
python3 project_clean.py -g documentation -d /path/to/project -r

# Execute actual cleanup with backup
python3 project_clean.py -g build -d /path/to/project --execute --backup ./backups -r
```

### Command-Line Options

```
Options:
  -h, --help                    Show help message and exit
  -d, --directory DIRECTORY     Target directory to search (default: current directory)
  -p, --patterns PATTERN [...]  Custom file patterns to match (e.g., '*.tmp' '*.log')
  -g, --group GROUP [...]       Select predefined pattern group(s)
  -i, --interactive             Interactive pattern group selection
  --list-groups                 List available pattern groups and exit
  -r, --recursive               Search recursively through subdirectories
  --execute                     Execute cleanup (default is dry-run mode)
  -b, --backup DIR              Backup directory for files before deletion
  -v, --verbose                 Enable verbose output (DEBUG level)
  -q, --quiet                   Minimal output (WARNING level only)
  --version                     Show version number and exit
```

### Usage Examples

#### 1. List Available Pattern Groups
```bash
python3 project_clean.py --list-groups
```

**Output:**
```
📋 Available Pattern Groups:

  documentation   - Documentation files (AUDIT_REPORT, ENHANCEMENT_SUMMARY, etc.)
  temporary       - Temporary and cache files
  build           - Build artifacts and compiled files
  metadata        - IDE and editor metadata files
  node            - Node.js files (logs, coverage, etc.)
```

#### 2. Interactive Mode
```bash
python3 project_clean.py -i -d ~/projects/myapp
```

**Interactive Menu:**
```
🎯 Interactive Pattern Group Selection
======================================================================
  1. [documentation] - Documentation files (AUDIT_REPORT, ENHANCEMENT_SUMMARY, etc.)
  2. [temporary] - Temporary and cache files
  3. [build] - Build artifacts and compiled files
  4. [metadata] - IDE and editor metadata files
  5. [node] - Node.js files (logs, coverage, etc.)

======================================================================
Enter group numbers separated by commas (e.g., 1,2,3)
Or press Enter to cancel

Your selection: 2,3
```

#### 3. Use Single Pattern Group (Audit Mode)
```bash
python3 project_clean.py -g documentation -d ~/projects -r
```

**Output:**
```
2026-02-02 05:53:29 - INFO - 🔍 AUDIT MODE - No files will be deleted
2026-02-02 05:53:29 - INFO - Target Directory: /home/user/projects
2026-02-02 05:53:29 - INFO - ======================================================================
2026-02-02 05:53:29 - INFO - Found 16 file(s) matching patterns
2026-02-02 05:53:29 - INFO -   → project1/AUDIT_REPORT.md (6.89 KB)
2026-02-02 05:53:29 - INFO -   → project2/ENHANCEMENT_SUMMARY.md (22.99 KB)
...
2026-02-02 05:53:29 - INFO - ======================================================================
2026-02-02 05:53:29 - INFO - Total files identified: 16
2026-02-02 05:53:29 - INFO - Total size: 105.87 KB
2026-02-02 05:53:29 - INFO - 
💡 Run with --execute flag to perform actual cleanup
```

#### 4. Use Multiple Pattern Groups
```bash
python3 project_clean.py -g temporary build -d ~/projects -r -v
```

This will search for all patterns from both the `temporary` and `build` groups.

#### 5. Custom Patterns
```bash
python3 project_clean.py -p "*.tmp" "*.log" "*.bak" -d ~/projects -r
```

#### 6. Execute Cleanup with Backup
```bash
python3 project_clean.py -g build -d ~/projects --execute --backup ~/project-backups -r
```

**Output:**
```
2026-02-02 05:55:00 - INFO - 🔥 CLEANUP MODE - Files will be deleted
2026-02-02 05:55:00 - INFO - Target Directory: /home/user/projects
2026-02-02 05:55:00 - INFO - Backup Directory: /home/user/project-backups
2026-02-02 05:55:00 - INFO - ======================================================================
2026-02-02 05:55:00 - INFO - Found 42 file(s) matching patterns
2026-02-02 05:55:00 - INFO - ✓ Removed: project1/__pycache__ (2.34 KB)
2026-02-02 05:55:00 - INFO - ✓ Removed: project1/app.pyc (1.12 KB)
...
2026-02-02 05:55:01 - INFO - ======================================================================

📊 CLEANUP SUMMARY
  Files found:     42
  Files removed:   42
  Files backed up: 42
  Files failed:    0
  Space freed:     15.67 MB
```

#### 7. Verbose Debugging
```bash
python3 project_clean.py -g documentation -d ~/projects -r -v
```

This will show DEBUG level messages including each file found and configuration details.

#### 8. Quiet Mode (Warnings Only)
```bash
python3 project_clean.py -g temporary -d ~/projects -r --execute -q
```

## 🔧 Advanced Usage

### Creating Custom Pattern Groups

You can modify the script to add your own pattern groups:

```python
PATTERN_GROUPS = {
    "mygroup": {
        "description": "My custom cleanup patterns",
        "patterns": [
            "*.custom",
            "temp_*",
            ".myapp",
        ]
    },
    # ... existing groups
}
```

### Integration with CI/CD

```yaml
# Example GitHub Actions workflow
- name: Cleanup Build Artifacts
  run: |
    python3 project_clean.py \
      -g build temporary \
      -d ./workspace \
      --execute \
      --backup ./artifacts \
      -r
```

### Cron Job for Regular Cleanup

```bash
# Add to crontab for weekly cleanup
0 2 * * 0 cd /path/to/projects && python3 /path/to/project_clean.py -g temporary build -d . -r --execute -q
```

## 🛡️ Safety Features

### Dry-Run by Default
The script **always runs in audit mode unless** you explicitly use `--execute`. This prevents accidental deletions.

### Backup Before Delete
Using the `--backup` flag ensures all files are copied to a safe location before deletion.

### Permission Handling
The script gracefully handles:
- Read permission errors
- Write permission errors
- Missing files (deleted between scan and cleanup)

### Statistics & Reporting
After every operation, you get a detailed summary:
- Total files found
- Files successfully removed
- Files backed up
- Failed operations
- Total space freed

## 📊 Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success - no errors |
| `1` | Error - configuration, permission, or operational error |
| `130` | User cancelled (Ctrl+C) |

## 🐛 Troubleshooting

### No Files Found
```bash
# Use verbose mode to see what patterns are being searched
python3 project_clean.py -g mygroup -d /path -r -v
```

### Permission Denied
```bash
# Check directory permissions
ls -la /path/to/directory

# Run with elevated privileges if needed (use with caution!)
sudo python3 project_clean.py -g build -d /protected/path --execute
```

### Invalid Pattern Group
```bash
# List available groups
python3 project_clean.py --list-groups
```

## 📚 Best Practices

1. **Always audit first**: Run without `--execute` to see what would be deleted
2. **Use backups**: For important cleanups, always use `--backup`
3. **Start small**: Test patterns on a small directory first
4. **Use pattern groups**: Leverage predefined groups for common scenarios
5. **Check verbosity**: Use `-v` for debugging, `-q` for scripts
6. **Recursive carefully**: Be cautious with `-r` on large directory trees

## 🔄 Version History

### Version 2.0.0 (Current)
- ✨ Added predefined pattern groups
- ✨ Added interactive mode
- ✨ Removed hardcoded default patterns
- ✨ Enhanced CLI with more options
- ✨ Improved error messages and validation

### Version 1.0.0
- Initial release with basic cleanup functionality
- Dry-run and execute modes
- Backup functionality
- Recursive search
- Basic error handling

## 📝 License

This script is provided as-is for use in DevOps and system administration tasks.

## 🤝 Contributing

To add new pattern groups or features:
1. Test thoroughly in dry-run mode
2. Document your changes
3. Update examples and help text

## 📧 Support

For issues or questions, refer to the inline code documentation or run:
```bash
python3 project_clean.py --help
```

---

**Remember**: With great power comes great responsibility. Always verify what you're deleting! 🚨
