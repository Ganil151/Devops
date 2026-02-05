# Project Cleanup Utility

A robust, production-grade Python utility for auditing and cleaning project directories by removing specified file patterns. Features comprehensive error handling, logging, backup functionality, and flexible CLI interface.

## Features

✨ **Core Functionality**
- 🔍 **Audit Mode (Dry-Run)**: Preview files that would be deleted without making changes
- 🔥 **Cleanup Mode**: Execute actual file deletion with comprehensive error handling
- 📊 **Detailed Statistics**: Track files found, removed, failed, and space freed
- 🎯 **Pattern Matching**: Support for glob patterns including wildcards

🛡️ **Safety & Reliability**
- 💾 **Backup Support**: Optional backup of files before deletion with timestamps
- 🔒 **Permission Validation**: Checks read/write permissions before operations
- ⚠️ **Error Recovery**: Graceful handling of permission errors, missing files, etc.
- 🚫 **Duplicate Prevention**: Automatically removes duplicate matches

🔧 **Advanced Features**
- 🌳 **Recursive Search**: Optional deep directory traversal
- 📝 **Professional Logging**: Timestamped logs with configurable verbosity
- 🎨 **Rich Output**: Color-coded, emoji-enhanced terminal output
- 📏 **Human-Readable Sizes**: Automatic formatting of file sizes (B, KB, MB, GB)
- ⌨️ **CLI Interface**: Full argument parsing with help and examples

## Installation

No external dependencies required! Uses only Python standard library.

```bash
# Make the script executable
chmod +x project_clean.py

# Optionally, create a symlink for easy access
ln -s $(pwd)/project_clean.py ~/.local/bin/project-clean
```

## Usage

### Basic Examples

```bash
# 1. Audit mode (default - safe, no deletion)
./project_clean.py

# 2. Audit a specific directory
./project_clean.py -d /path/to/project

# 3. Execute cleanup (actually delete files)
./project_clean.py --execute

# 4. Execute with backup
./project_clean.py --execute --backup ./backups

# 5. Recursive search through all subdirectories
./project_clean.py -r

# 6. Custom file patterns
./project_clean.py -p "*.tmp" "*.log" "*.cache"

# 7. Verbose output for debugging
./project_clean.py -v

# 8. Quiet mode (errors only)
./project_clean.py -q
```

### Advanced Examples

```bash
# Recursive cleanup with backup and verbose logging
./project_clean.py -d ~/projects -r --execute --backup ~/backups/$(date +%Y%m%d) -v

# Clean specific patterns recursively
./project_clean.py -d /var/log -r -p "*.log.1" "*.log.2" --execute

# Audit with custom patterns
./project_clean.py -d . -r -p "AUDIT_*.md" "TEMP_*.txt" "*.bak"
```

## Command-Line Options

| Option | Short | Description |
|--------|-------|-------------|
| `--directory DIR` | `-d` | Target directory to search (default: `Devops`) |
| `--patterns PATTERN [PATTERN ...]` | `-p` | File patterns to match (supports wildcards) |
| `--recursive` | `-r` | Search recursively through subdirectories |
| `--execute` | | Execute cleanup (default is audit/dry-run) |
| `--backup DIR` | `-b` | Backup directory for files before deletion |
| `--verbose` | `-v` | Enable verbose output (DEBUG level) |
| `--quiet` | `-q` | Minimal output (WARNING level only) |
| `--version` | | Show version information |
| `--help` | `-h` | Show help message and examples |

## Default Patterns

If no patterns are specified, the script searches for:
- `AUDIT_REPORT.md`
- `ENHANCEMENT_SUMMARY.md`
- `NAVIGATION_GUIDE.md`
- `GO_AUTOMATION_*.md`

## Output Examples

### Audit Mode Output
```
2026-02-02 05:35:54 - INFO - 🔍 AUDIT MODE - No files will be deleted
2026-02-02 05:35:54 - INFO - Target Directory: /home/user/Devops
2026-02-02 05:35:54 - INFO - ======================================================================
2026-02-02 05:35:54 - INFO - Found 3 file(s) matching patterns
2026-02-02 05:35:54 - INFO -   → AUDIT_REPORT.md (15.23 KB)
2026-02-02 05:35:54 - INFO -   → ENHANCEMENT_SUMMARY.md (8.45 KB)
2026-02-02 05:35:54 - INFO -   → NAVIGATION_GUIDE.md (12.67 KB)
2026-02-02 05:35:54 - INFO - ======================================================================
2026-02-02 05:35:54 - INFO - Total files identified: 3
2026-02-02 05:35:54 - INFO - Total size: 36.35 KB
2026-02-02 05:35:54 - INFO - 
💡 Run with --execute flag to perform actual cleanup
```

### Cleanup Mode Output
```
2026-02-02 05:36:12 - INFO - 🔥 CLEANUP MODE - Files will be deleted
2026-02-02 05:36:12 - INFO - Target Directory: /home/user/Devops
2026-02-02 05:36:12 - INFO - Backup Directory: /home/user/backups
2026-02-02 05:36:12 - INFO - ======================================================================
2026-02-02 05:36:12 - INFO - Found 3 file(s) matching patterns
2026-02-02 05:36:12 - INFO - ✓ Removed: AUDIT_REPORT.md
2026-02-02 05:36:12 - INFO - ✓ Removed: ENHANCEMENT_SUMMARY.md
2026-02-02 05:36:12 - INFO - ✓ Removed: NAVIGATION_GUIDE.md
2026-02-02 05:36:12 - INFO - ======================================================================
2026-02-02 05:36:12 - INFO - 
📊 CLEANUP SUMMARY
2026-02-02 05:36:12 - INFO -   Files found:     3
2026-02-02 05:36:12 - INFO -   Files removed:   3
2026-02-02 05:36:12 - INFO -   Files backed up: 3
2026-02-02 05:36:12 - INFO -   Files failed:    0
2026-02-02 05:36:12 - INFO -   Space freed:     36.35 KB
```

## Error Handling

The script handles various error scenarios gracefully:

### Permission Errors
```
2026-02-02 05:36:15 - ERROR - Permission denied: /protected/file.md
```

### Missing Files
```
2026-02-02 05:36:16 - WARNING - File not found (may have been deleted): /tmp/file.md
```

### Backup Failures
```
2026-02-02 05:36:17 - ERROR - Failed to backup /path/to/file.md: [Errno 28] No space left on device
2026-02-02 05:36:17 - WARNING - Skipping deletion of /path/to/file.md due to backup failure
```

### Invalid Configuration
```
2026-02-02 05:36:18 - ERROR - Configuration error: Target directory does not exist: /nonexistent
```

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success - all operations completed without errors |
| `1` | Failure - one or more files failed to process or configuration error |
| `130` | Interrupted - user cancelled operation (Ctrl+C) |

## Architecture

### Class Structure

```
ProjectCleaner
├── __init__()           # Initialize with validation
├── audit()              # Dry-run mode
├── cleanup()            # Execute deletion
├── find_files()         # Pattern matching
├── _backup_file()       # Backup functionality
├── _remove_file()       # Safe deletion
├── _validate_configuration()  # Input validation
├── _setup_logger()      # Logging configuration
├── _get_file_size()     # Size calculation
├── _format_size()       # Human-readable formatting
└── _print_summary()     # Statistics reporting

CleanupStats (dataclass)
├── files_found          # Count of matched files
├── files_removed        # Count of deleted files
├── files_backed_up      # Count of backed up files
├── files_failed         # Count of failed operations
├── total_size_freed     # Total bytes freed
└── errors               # List of error messages
```

### Error Handling Strategy

1. **Validation Phase**: Check all inputs before operations
2. **Per-File Handling**: Isolated error handling for each file
3. **Graceful Degradation**: Continue processing remaining files on errors
4. **Detailed Reporting**: Track and report all errors in summary
5. **Safe Defaults**: Audit mode by default, explicit flag for deletion

## Best Practices

### Before Running Cleanup

1. **Always audit first**: Run without `--execute` to preview changes
2. **Use backups**: Add `--backup` flag for important files
3. **Test patterns**: Verify patterns match intended files
4. **Check permissions**: Ensure you have necessary access rights

### Production Usage

```bash
# Recommended workflow
# Step 1: Audit
./project_clean.py -d /production/path -r -v

# Step 2: Review output carefully

# Step 3: Execute with backup
./project_clean.py -d /production/path -r --execute --backup /backups/$(date +%Y%m%d_%H%M%S)
```

### Integration with CI/CD

```yaml
# Example GitHub Actions workflow
- name: Clean project artifacts
  run: |
    python project_clean.py \
      -d ${{ github.workspace }} \
      -r \
      -p "*.tmp" "*.cache" \
      --execute
```

## Troubleshooting

### No files found
- Verify the target directory path is correct
- Check if patterns match your file naming convention
- Try using `-v` for verbose output to see search patterns
- Use `-r` if files are in subdirectories

### Permission denied errors
- Ensure you have read access to the target directory
- Check write permissions if using `--backup`
- Run with appropriate user permissions (may need `sudo`)

### Backup failures
- Verify backup directory has sufficient space
- Check write permissions on backup directory
- Ensure backup path is valid and accessible

## Development

### Type Hints
The script uses comprehensive type hints for better IDE support and code clarity:
```python
def find_files(self) -> List[Path]:
    """Find all files matching the specified patterns."""
```

### Testing
```bash
# Test with dry-run
./project_clean.py -d /tmp/test -v

# Test with actual cleanup in safe directory
mkdir -p /tmp/test_cleanup
touch /tmp/test_cleanup/AUDIT_REPORT.md
./project_clean.py -d /tmp/test_cleanup --execute -v
```

## Version History

### v2.0.0 (2026-02-02)
- Complete rewrite with OOP design
- Added comprehensive error handling
- Implemented backup functionality
- Added CLI argument parsing
- Professional logging system
- Type hints throughout
- Recursive search support
- Detailed statistics reporting
- Human-readable file sizes
- Exit code support

### v1.0.0 (Original)
- Basic audit and cleanup functionality
- Simple pattern matching
- Minimal error handling

## License

Internal DevOps tool - For team use only.

## Support

For issues or feature requests, contact the DevOps team.
