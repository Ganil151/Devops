#!/usr/bin/env python3
"""
Project Cleanup Utility
=======================
A robust utility for auditing and cleaning project directories by removing
specified file patterns. Supports dry-run mode, recursive search, backup
functionality, and comprehensive error handling.
@TRINITY: Project Cleaner | python 00-Resources/01-Scripts-Code/Maintenance/project_clean.py
"""

import os
import sys
import glob
import shutil
import logging
import argparse
from pathlib import Path
from typing import List, Dict, Optional, Tuple
from datetime import datetime
from dataclasses import dataclass, field


@dataclass
class CleanupStats:
    """Statistics for cleanup operations."""
    files_found: int = 0
    files_removed: int = 0
    files_backed_up: int = 0
    files_failed: int = 0
    total_size_freed: int = 0
    errors: List[str] = field(default_factory=list)


class ProjectCleaner:
    """
    A comprehensive project cleanup utility with error handling and logging.
    
    Attributes:
        target_dir: Directory to search for files
        patterns: List of file patterns to match
        recursive: Whether to search recursively
        backup_dir: Optional directory for backing up files before deletion
        logger: Logger instance for operation logging
    """
    
    # Predefined pattern groups for common cleanup scenarios
    PATTERN_GROUPS = {
        "documentation": {
            "description": "Documentation files (AUDIT_REPORT, ENHANCEMENT_SUMMARY, etc.)",
            "patterns": [
                "AUDIT_REPORT.md",
                "ENHANCEMENT_SUMMARY.md",
                "NAVIGATION_GUIDE.md",
                "GO_AUTOMATION_*.md",
                "CHANGELOG.md",
                "SIMPLIFICATION_SUMMARY.md"
                "SUMMARY.txt"
            ]
        },
        "temporary": {
            "description": "Temporary and cache files",
            "patterns": [
                "*.tmp",
                "*.temp",
                "*.cache",
                "*.swp",
                "*.swo",
                "*~",
                ".DS_Store",
                "Thumbs.db",
            ]
        },
        "build": {
            "description": "Build artifacts and compiled files",
            "patterns": [
                "*.pyc",
                "*.pyo",
                "*.pyd",
                "__pycache__",
                "*.class",
                "*.o",
                "*.so",
                "*.dll",
                "*.exe",
                "*.out",
                "*.log",
            ]
        },
        "metadata": {
            "description": "IDE and editor metadata files",
            "patterns": [
                ".vscode",
                ".idea",
                "*.sublime-*",
                ".project",
                ".classpath",
            ]
        },
        "node": {
            "description": "Node.js files (logs, coverage, etc.)",
            "patterns": [
                "npm-debug.log*",
                "yarn-debug.log*",
                "yarn-error.log*",
                "coverage",
                ".nyc_output",
            ]
        },
    }
    
    def __init__(
        self,
        target_dir: str,
        patterns: Optional[List[str]] = None,
        recursive: bool = False,
        backup_dir: Optional[str] = None,
        log_level: str = "INFO"
    ):
        """
        Initialize the ProjectCleaner.
        
        Args:
            target_dir: Directory to search for files
            patterns: List of file patterns to match (uses defaults if None)
            recursive: Whether to search recursively through subdirectories
            backup_dir: Optional directory for backing up files before deletion
            log_level: Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
        
        Raises:
            ValueError: If target_dir doesn't exist or is not a directory
        """
        self.target_dir = Path(target_dir).resolve()
        self.patterns = patterns or []
        self.recursive = recursive
        self.backup_dir = Path(backup_dir).resolve() if backup_dir else None
        self.stats = CleanupStats()
        
        # Setup logging
        self.logger = self._setup_logger(log_level)
        
        # Validate inputs
        self._validate_configuration()
    
    def _setup_logger(self, log_level: str) -> logging.Logger:
        """
        Configure and return a logger instance.
        
        Args:
            log_level: Desired logging level
            
        Returns:
            Configured logger instance
        """
        logger = logging.getLogger(__name__)
        logger.setLevel(getattr(logging, log_level.upper(), logging.INFO))
        
        # Console handler with formatting
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setLevel(logging.DEBUG)
        
        formatter = logging.Formatter(
            '%(asctime)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        console_handler.setFormatter(formatter)
        
        logger.addHandler(console_handler)
        return logger
    
    def _validate_configuration(self) -> None:
        """
        Validate the configuration parameters.
        
        Raises:
            ValueError: If configuration is invalid
            PermissionError: If directories are not accessible
        """
        # Validate target directory
        if not self.target_dir.exists():
            raise ValueError(f"Target directory does not exist: {self.target_dir}")
        
        if not self.target_dir.is_dir():
            raise ValueError(f"Target path is not a directory: {self.target_dir}")
        
        if not os.access(self.target_dir, os.R_OK):
            raise PermissionError(f"No read permission for directory: {self.target_dir}")
        
        # Validate backup directory if specified
        if self.backup_dir:
            try:
                self.backup_dir.mkdir(parents=True, exist_ok=True)
                if not os.access(self.backup_dir, os.W_OK):
                    raise PermissionError(f"No write permission for backup directory: {self.backup_dir}")
            except Exception as e:
                raise ValueError(f"Cannot create backup directory: {e}")
        
        # Validate patterns
        if not self.patterns:
            raise ValueError(
                "At least one file pattern must be specified. "
                "Use -p/--patterns for custom patterns or -g/--group to select a predefined pattern group."
            )
        
        self.logger.debug(f"Configuration validated successfully")
        self.logger.debug(f"Target directory: {self.target_dir}")
        self.logger.debug(f"Patterns: {self.patterns}")
        self.logger.debug(f"Recursive: {self.recursive}")
        self.logger.debug(f"Backup directory: {self.backup_dir}")
    
    @classmethod
    def get_patterns_from_group(cls, group_name: str) -> List[str]:
        """
        Get patterns from a predefined group.
        
        Args:
            group_name: Name of the pattern group
            
        Returns:
            List of patterns for the specified group
            
        Raises:
            ValueError: If group name is not found
        """
        group_name = group_name.lower()
        if group_name not in cls.PATTERN_GROUPS:
            available = ", ".join(cls.PATTERN_GROUPS.keys())
            raise ValueError(
                f"Unknown pattern group: '{group_name}'. "
                f"Available groups: {available}"
            )
        return cls.PATTERN_GROUPS[group_name]["patterns"]
    
    @classmethod
    def get_patterns_from_groups(cls, group_names: List[str]) -> List[str]:
        """
        Get patterns from multiple predefined groups.
        
        Args:
            group_names: List of pattern group names
            
        Returns:
            Combined list of patterns from all specified groups
        """
        all_patterns = []
        for group_name in group_names:
            patterns = cls.get_patterns_from_group(group_name)
            all_patterns.extend(patterns)
        # Remove duplicates while preserving order
        return list(dict.fromkeys(all_patterns))
    
    @classmethod
    def list_pattern_groups(cls) -> None:
        """Print available pattern groups and their descriptions."""
        print("\n📋 Available Pattern Groups:\n")
        for group_name, group_info in cls.PATTERN_GROUPS.items():
            print(f"  {group_name:15} - {group_info['description']}")
            print(f"                    Patterns: {', '.join(group_info['patterns'][:3])}", end="")
            if len(group_info['patterns']) > 3:
                print(f", ... ({len(group_info['patterns'])} total)")
            else:
                print()
        print()
    
    @classmethod
    def interactive_select_groups(cls) -> List[str]:
        """
        Interactively select pattern groups.
        
        Returns:
            List of patterns from selected groups
        """
        print("\n🎯 Interactive Pattern Group Selection")
        print("=" * 70)
        
        # Display available groups
        groups = list(cls.PATTERN_GROUPS.keys())
        for idx, group_name in enumerate(groups, 1):
            group_info = cls.PATTERN_GROUPS[group_name]
            print(f"  {idx}. [{group_name}] - {group_info['description']}")
        
        print("\n" + "=" * 70)
        print("Enter group numbers separated by commas (e.g., 1,2,3)")
        print("Or press Enter to cancel")
        
        try:
            selection = input("\nYour selection: ").strip()
            
            if not selection:
                print("❌ No selection made. Exiting.")
                sys.exit(0)
            
            # Parse selection
            selected_indices = [int(s.strip()) for s in selection.split(",")]
            selected_groups = []
            
            for idx in selected_indices:
                if 1 <= idx <= len(groups):
                    selected_groups.append(groups[idx - 1])
                else:
                    print(f"⚠️  Warning: Invalid selection {idx}, skipping...")
            
            if not selected_groups:
                print("❌ No valid groups selected. Exiting.")
                sys.exit(0)
            
            # Get patterns from selected groups
            patterns = cls.get_patterns_from_groups(selected_groups)
            
            print(f"\n✅ Selected groups: {', '.join(selected_groups)}")
            print(f"📦 Total patterns: {len(patterns)}")
            
            return patterns
            
        except (ValueError, KeyboardInterrupt) as e:
            print("\n❌ Invalid input or cancelled. Exiting.")
            sys.exit(0)
    
    def find_files(self) -> List[Path]:
        """
        Find all files matching the specified patterns.
        
        Returns:
            List of Path objects for matching files
            
        Raises:
            OSError: If there's an error accessing the filesystem
        """
        found_files = []
        
        try:
            for pattern in self.patterns:
                if self.recursive:
                    # Recursive search using **/ glob pattern
                    search_pattern = str(self.target_dir / "**" / pattern)
                    matches = glob.glob(search_pattern, recursive=True)
                else:
                    # Non-recursive search
                    search_pattern = str(self.target_dir / pattern)
                    matches = glob.glob(search_pattern)
                
                # Convert to Path objects and filter out directories
                for match in matches:
                    path = Path(match)
                    if path.is_file():
                        found_files.append(path)
                        self.logger.debug(f"Found file: {path}")
            
            # Remove duplicates while preserving order
            found_files = list(dict.fromkeys(found_files))
            self.stats.files_found = len(found_files)
            
            self.logger.info(f"Found {len(found_files)} file(s) matching patterns")
            return found_files
            
        except Exception as e:
            self.logger.error(f"Error during file search: {e}")
            raise OSError(f"Failed to search for files: {e}")
    
    def _get_file_size(self, file_path: Path) -> int:
        """
        Safely get file size.
        
        Args:
            file_path: Path to the file
            
        Returns:
            File size in bytes, or 0 if unable to determine
        """
        try:
            return file_path.stat().st_size
        except Exception as e:
            self.logger.warning(f"Could not get size for {file_path}: {e}")
            return 0
    
    def _backup_file(self, file_path: Path) -> bool:
        """
        Create a backup of the specified file.
        
        Args:
            file_path: Path to the file to backup
            
        Returns:
            True if backup successful, False otherwise
        """
        if not self.backup_dir:
            return True  # No backup requested
        
        try:
            # Create timestamped backup filename
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            backup_name = f"{file_path.stem}_{timestamp}{file_path.suffix}"
            backup_path = self.backup_dir / backup_name
            
            # Copy file to backup location
            shutil.copy2(file_path, backup_path)
            self.stats.files_backed_up += 1
            self.logger.debug(f"Backed up: {file_path} -> {backup_path}")
            return True
            
        except Exception as e:
            error_msg = f"Failed to backup {file_path}: {e}"
            self.logger.error(error_msg)
            self.stats.errors.append(error_msg)
            return False
    
    def _remove_file(self, file_path: Path) -> bool:
        """
        Remove the specified file.
        
        Args:
            file_path: Path to the file to remove
            
        Returns:
            True if removal successful, False otherwise
        """
        try:
            file_size = self._get_file_size(file_path)
            file_path.unlink()
            self.stats.files_removed += 1
            self.stats.total_size_freed += file_size
            self.logger.info(f"✓ Removed: {file_path.relative_to(self.target_dir)}")
            return True
            
        except PermissionError as e:
            error_msg = f"Permission denied: {file_path}"
            self.logger.error(error_msg)
            self.stats.errors.append(error_msg)
            self.stats.files_failed += 1
            return False
            
        except FileNotFoundError:
            error_msg = f"File not found (may have been deleted): {file_path}"
            self.logger.warning(error_msg)
            self.stats.errors.append(error_msg)
            self.stats.files_failed += 1
            return False
            
        except Exception as e:
            error_msg = f"Failed to remove {file_path}: {e}"
            self.logger.error(error_msg)
            self.stats.errors.append(error_msg)
            self.stats.files_failed += 1
            return False
    
    def audit(self) -> CleanupStats:
        """
        Perform an audit (dry-run) of files that would be removed.
        
        Returns:
            CleanupStats object with audit results
        """
        self.logger.info("🔍 AUDIT MODE - No files will be deleted")
        self.logger.info(f"Target Directory: {self.target_dir}")
        self.logger.info("=" * 70)
        
        try:
            files = self.find_files()
            
            if not files:
                self.logger.info("✨ No matching files found")
                return self.stats
            
            total_size = 0
            for file_path in files:
                file_size = self._get_file_size(file_path)
                total_size += file_size
                rel_path = file_path.relative_to(self.target_dir)
                size_str = self._format_size(file_size)
                self.logger.info(f"  → {rel_path} ({size_str})")
            
            self.stats.total_size_freed = total_size
            
            self.logger.info("=" * 70)
            self.logger.info(f"Total files identified: {len(files)}")
            self.logger.info(f"Total size: {self._format_size(total_size)}")
            self.logger.info("\n💡 Run with --execute flag to perform actual cleanup")
            
        except Exception as e:
            self.logger.error(f"Audit failed: {e}")
            self.stats.errors.append(str(e))
        
        return self.stats
    
    def cleanup(self) -> CleanupStats:
        """
        Perform actual cleanup by removing matched files.
        
        Returns:
            CleanupStats object with cleanup results
        """
        self.logger.info("🔥 CLEANUP MODE - Files will be deleted")
        self.logger.info(f"Target Directory: {self.target_dir}")
        if self.backup_dir:
            self.logger.info(f"Backup Directory: {self.backup_dir}")
        self.logger.info("=" * 70)
        
        try:
            files = self.find_files()
            
            if not files:
                self.logger.info("✨ No matching files found")
                return self.stats
            
            for file_path in files:
                # Backup if requested
                if self.backup_dir:
                    if not self._backup_file(file_path):
                        self.logger.warning(f"Skipping deletion of {file_path} due to backup failure")
                        continue
                
                # Remove the file
                self._remove_file(file_path)
            
            self.logger.info("=" * 70)
            self._print_summary()
            
        except Exception as e:
            self.logger.error(f"Cleanup failed: {e}")
            self.stats.errors.append(str(e))
        
        return self.stats
    
    def _format_size(self, size_bytes: int) -> str:
        """
        Format file size in human-readable format.
        
        Args:
            size_bytes: Size in bytes
            
        Returns:
            Formatted size string
        """
        for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
            if size_bytes < 1024.0:
                return f"{size_bytes:.2f} {unit}"
            size_bytes /= 1024.0
        return f"{size_bytes:.2f} PB"
    
    def _print_summary(self) -> None:
        """Print a summary of the cleanup operation."""
        self.logger.info("\n📊 CLEANUP SUMMARY")
        self.logger.info(f"  Files found:     {self.stats.files_found}")
        self.logger.info(f"  Files removed:   {self.stats.files_removed}")
        if self.backup_dir:
            self.logger.info(f"  Files backed up: {self.stats.files_backed_up}")
        self.logger.info(f"  Files failed:    {self.stats.files_failed}")
        self.logger.info(f"  Space freed:     {self._format_size(self.stats.total_size_freed)}")
        
        if self.stats.errors:
            self.logger.warning(f"\n⚠️  {len(self.stats.errors)} error(s) occurred:")
            for error in self.stats.errors[:5]:  # Show first 5 errors
                self.logger.warning(f"  • {error}")
            if len(self.stats.errors) > 5:
                self.logger.warning(f"  ... and {len(self.stats.errors) - 5} more")


def parse_arguments() -> argparse.Namespace:
    """
    Parse command-line arguments.
    
    Returns:
        Parsed arguments namespace
    """
    parser = argparse.ArgumentParser(
        description="Project Cleanup Utility - Audit and clean project directories",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # List available pattern groups
  %(prog)s --list-groups
  
  # Interactive mode (searches entire Devops directory)
  %(prog)s -i
  
  # Audit documentation files in Devops directory
  %(prog)s -g documentation
  
  # Audit multiple groups
  %(prog)s -g documentation temporary
  
  # Execute cleanup with backup
  %(prog)s -g documentation --execute --backup ./backups
  
  # Search specific directory instead of default
  %(prog)s -g build -d /path/to/project
  
  # Custom patterns
  %(prog)s -p "*.tmp" "*.log"
        """
    )
    
    parser.add_argument(
        "-d", "--directory",
        default="/home/gsmash/Documents/Devops",
        help="Target directory to search (default: ~/Documents/Devops)"
    )
    
    parser.add_argument(
        "-p", "--patterns",
        nargs="+",
        help="File patterns to match (e.g., '*.tmp' '*.log'). Cannot be used with -g/--group."
    )
    
    parser.add_argument(
        "-g", "--group",
        nargs="+",
        choices=list(ProjectCleaner.PATTERN_GROUPS.keys()),
        metavar="GROUP",
        help=f"Select predefined pattern group(s). Available: {', '.join(ProjectCleaner.PATTERN_GROUPS.keys())}. Cannot be used with -p/--patterns."
    )
    
    parser.add_argument(
        "-i", "--interactive",
        action="store_true",
        help="Interactively select pattern groups"
    )
    
    parser.add_argument(
        "--list-groups",
        action="store_true",
        help="List available pattern groups and exit"
    )
    
    parser.add_argument(
        "--no-recursive",
        action="store_true",
        help="Disable recursive search (searches recursively by default)"
    )
    
    parser.add_argument(
        "--execute",
        action="store_true",
        help="Execute cleanup (default is dry-run/audit mode)"
    )
    
    parser.add_argument(
        "-b", "--backup",
        metavar="DIR",
        help="Backup directory for files before deletion"
    )
    
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Enable verbose output (DEBUG level)"
    )
    
    parser.add_argument(
        "-q", "--quiet",
        action="store_true",
        help="Minimal output (WARNING level only)"
    )
    
    parser.add_argument(
        "--version",
        action="version",
        version="%(prog)s 2.0.0"
    )
    
    return parser.parse_args()


def main() -> int:
    """
    Main entry point for the script.
    
    Returns:
        Exit code (0 for success, 1 for failure)
    """
    args = parse_arguments()
    
    # Handle list-groups command
    if args.list_groups:
        ProjectCleaner.list_pattern_groups()
        return 0
    
    # Handle interactive mode
    if args.interactive:
        patterns = ProjectCleaner.interactive_select_groups()
    elif args.group:
        # Get patterns from specified groups
        try:
            patterns = ProjectCleaner.get_patterns_from_groups(args.group)
        except ValueError as e:
            logging.error(str(e))
            return 1
    elif args.patterns:
        # Use custom patterns
        patterns = args.patterns
    else:
        # No patterns specified - show help
        logging.error(
            "No patterns specified. Use one of the following:\n"
            "  -p/--patterns     : Specify custom patterns\n"
            "  -g/--group        : Select predefined pattern group(s)\n"
            "  -i/--interactive  : Interactive group selection\n"
            "  --list-groups     : List available groups"
        )
        return 1
    
    # Validate mutually exclusive options
    if args.patterns and args.group:
        logging.error("Cannot use both --patterns and --group options simultaneously")
        return 1
    
    if args.interactive and (args.patterns or args.group):
        logging.error("Cannot use --interactive with --patterns or --group options")
        return 1
    
    # Determine log level
    if args.verbose:
        log_level = "DEBUG"
    elif args.quiet:
        log_level = "WARNING"
    else:
        log_level = "INFO"
    
    try:
        # Initialize cleaner (recursive by default unless --no-recursive is specified)
        cleaner = ProjectCleaner(
            target_dir=args.directory,
            patterns=patterns,
            recursive=not args.no_recursive,  # Default is True
            backup_dir=args.backup,
            log_level=log_level
        )
        
        # Perform operation
        if args.execute:
            stats = cleaner.cleanup()
        else:
            stats = cleaner.audit()
        
        # Return appropriate exit code
        return 0 if stats.files_failed == 0 else 1
        
    except ValueError as e:
        logging.error(f"Configuration error: {e}")
        return 1
    except PermissionError as e:
        logging.error(f"Permission error: {e}")
        return 1
    except KeyboardInterrupt:
        logging.warning("\n⚠️  Operation cancelled by user")
        return 130
    except Exception as e:
        logging.error(f"Unexpected error: {e}", exc_info=True)
        return 1


if __name__ == "__main__":
    sys.exit(main())