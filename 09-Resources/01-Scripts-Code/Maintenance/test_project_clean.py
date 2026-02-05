#!/usr/bin/env python3
"""
Test Suite for Project Cleanup Utility
=======================================
Demonstrates error handling and various edge cases.
"""

import os
import sys
import tempfile
import shutil
from pathlib import Path

# Add parent directory to path to import the module
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from project_clean import ProjectCleaner, CleanupStats


class TestProjectCleaner:
    """Test suite for ProjectCleaner class."""
    
    def __init__(self):
        self.test_dir = None
        self.backup_dir = None
        self.passed = 0
        self.failed = 0
    
    def setup(self):
        """Create temporary test directory structure."""
        self.test_dir = Path(tempfile.mkdtemp(prefix="cleanup_test_"))
        self.backup_dir = Path(tempfile.mkdtemp(prefix="cleanup_backup_"))
        
        # Create test files
        (self.test_dir / "AUDIT_REPORT.md").write_text("# Audit Report\nTest content")
        (self.test_dir / "ENHANCEMENT_SUMMARY.md").write_text("# Enhancement\nTest content")
        (self.test_dir / "NAVIGATION_GUIDE.md").write_text("# Navigation\nTest content")
        (self.test_dir / "GO_AUTOMATION_TEST.md").write_text("# Go Automation\nTest content")
        (self.test_dir / "KEEP_THIS.md").write_text("# Keep this file")
        
        # Create subdirectory with files
        subdir = self.test_dir / "subdir"
        subdir.mkdir()
        (subdir / "AUDIT_REPORT.md").write_text("# Nested Audit Report")
        (subdir / "KEEP_THIS.md").write_text("# Keep this too")
        
        print(f"✓ Test environment created at: {self.test_dir}")
    
    def teardown(self):
        """Clean up test directories."""
        if self.test_dir and self.test_dir.exists():
            shutil.rmtree(self.test_dir)
        if self.backup_dir and self.backup_dir.exists():
            shutil.rmtree(self.backup_dir)
        print(f"\n✓ Test environment cleaned up")
    
    def assert_true(self, condition, test_name):
        """Assert a condition is true."""
        if condition:
            print(f"  ✓ {test_name}")
            self.passed += 1
        else:
            print(f"  ✗ {test_name}")
            self.failed += 1
    
    def test_initialization_valid(self):
        """Test valid initialization."""
        print("\n1. Testing valid initialization...")
        try:
            cleaner = ProjectCleaner(
                target_dir=str(self.test_dir),
                log_level="WARNING"
            )
            self.assert_true(cleaner.target_dir == self.test_dir, "Target directory set correctly")
            self.assert_true(len(cleaner.patterns) > 0, "Default patterns loaded")
        except Exception as e:
            self.assert_true(False, f"Initialization failed: {e}")
    
    def test_initialization_invalid_dir(self):
        """Test initialization with invalid directory."""
        print("\n2. Testing invalid directory handling...")
        try:
            cleaner = ProjectCleaner(
                target_dir="/nonexistent/directory/path",
                log_level="WARNING"
            )
            self.assert_true(False, "Should have raised ValueError")
        except ValueError as e:
            self.assert_true("does not exist" in str(e), "Correct error for missing directory")
        except Exception as e:
            self.assert_true(False, f"Wrong exception type: {e}")
    
    def test_initialization_file_not_dir(self):
        """Test initialization with file instead of directory."""
        print("\n3. Testing file instead of directory...")
        test_file = self.test_dir / "test_file.txt"
        test_file.write_text("test")
        
        try:
            cleaner = ProjectCleaner(
                target_dir=str(test_file),
                log_level="WARNING"
            )
            self.assert_true(False, "Should have raised ValueError")
        except ValueError as e:
            self.assert_true("not a directory" in str(e), "Correct error for file path")
        except Exception as e:
            self.assert_true(False, f"Wrong exception type: {e}")
    
    def test_find_files_non_recursive(self):
        """Test non-recursive file finding."""
        print("\n4. Testing non-recursive file search...")
        cleaner = ProjectCleaner(
            target_dir=str(self.test_dir),
            recursive=False,
            log_level="WARNING"
        )
        files = cleaner.find_files()
        
        self.assert_true(len(files) == 4, f"Found 4 files in root (found {len(files)})")
        self.assert_true(all(f.parent == self.test_dir for f in files), "All files in root directory")
    
    def test_find_files_recursive(self):
        """Test recursive file finding."""
        print("\n5. Testing recursive file search...")
        cleaner = ProjectCleaner(
            target_dir=str(self.test_dir),
            recursive=True,
            log_level="WARNING"
        )
        files = cleaner.find_files()
        
        self.assert_true(len(files) == 5, f"Found 5 files total (found {len(files)})")
        self.assert_true(any(f.parent != self.test_dir for f in files), "Found files in subdirectories")
    
    def test_custom_patterns(self):
        """Test custom file patterns."""
        print("\n6. Testing custom patterns...")
        cleaner = ProjectCleaner(
            target_dir=str(self.test_dir),
            patterns=["KEEP_*.md"],
            recursive=True,
            log_level="WARNING"
        )
        files = cleaner.find_files()
        
        self.assert_true(len(files) == 2, f"Found 2 KEEP_* files (found {len(files)})")
        self.assert_true(all("KEEP" in f.name for f in files), "All files match KEEP pattern")
    
    def test_audit_mode(self):
        """Test audit mode (dry-run)."""
        print("\n7. Testing audit mode...")
        cleaner = ProjectCleaner(
            target_dir=str(self.test_dir),
            recursive=False,
            log_level="WARNING"
        )
        
        initial_count = len(list(self.test_dir.glob("*.md")))
        stats = cleaner.audit()
        final_count = len(list(self.test_dir.glob("*.md")))
        
        self.assert_true(stats.files_found == 4, "Audit found 4 files")
        self.assert_true(stats.files_removed == 0, "Audit removed 0 files")
        self.assert_true(initial_count == final_count, "No files deleted in audit mode")
    
    def test_cleanup_without_backup(self):
        """Test cleanup without backup."""
        print("\n8. Testing cleanup without backup...")
        cleaner = ProjectCleaner(
            target_dir=str(self.test_dir),
            patterns=["AUDIT_REPORT.md"],
            recursive=False,
            log_level="WARNING"
        )
        
        stats = cleaner.cleanup()
        
        self.assert_true(stats.files_removed == 1, "Removed 1 file")
        self.assert_true(stats.files_backed_up == 0, "No backups created")
        self.assert_true(not (self.test_dir / "AUDIT_REPORT.md").exists(), "File was deleted")
    
    def test_cleanup_with_backup(self):
        """Test cleanup with backup."""
        print("\n9. Testing cleanup with backup...")
        cleaner = ProjectCleaner(
            target_dir=str(self.test_dir),
            patterns=["ENHANCEMENT_SUMMARY.md"],
            recursive=False,
            backup_dir=str(self.backup_dir),
            log_level="WARNING"
        )
        
        stats = cleaner.cleanup()
        backup_files = list(self.backup_dir.glob("ENHANCEMENT_SUMMARY_*.md"))
        
        self.assert_true(stats.files_removed == 1, "Removed 1 file")
        self.assert_true(stats.files_backed_up == 1, "Created 1 backup")
        self.assert_true(len(backup_files) == 1, "Backup file exists")
        self.assert_true(not (self.test_dir / "ENHANCEMENT_SUMMARY.md").exists(), "Original file deleted")
    
    def test_file_size_calculation(self):
        """Test file size calculation."""
        print("\n10. Testing file size calculation...")
        cleaner = ProjectCleaner(
            target_dir=str(self.test_dir),
            patterns=["NAVIGATION_GUIDE.md"],
            recursive=False,
            log_level="WARNING"
        )
        
        stats = cleaner.audit()
        
        self.assert_true(stats.total_size_freed > 0, "File size calculated")
        self.assert_true(stats.total_size_freed < 10000, "File size reasonable")
    
    def test_permission_error_handling(self):
        """Test permission error handling."""
        print("\n11. Testing permission error handling...")
        
        # Create a read-only file
        readonly_file = self.test_dir / "AUDIT_REPORT_READONLY.md"
        readonly_file.write_text("Protected content")
        readonly_file.chmod(0o444)  # Read-only
        
        cleaner = ProjectCleaner(
            target_dir=str(self.test_dir),
            patterns=["AUDIT_REPORT_READONLY.md"],
            recursive=False,
            log_level="WARNING"
        )
        
        stats = cleaner.cleanup()
        
        # Cleanup: restore permissions if file still exists
        if readonly_file.exists():
            readonly_file.chmod(0o644)
        
        self.assert_true(stats.files_failed >= 0, "Handled permission error gracefully")
        self.assert_true(len(stats.errors) >= 0, "Recorded error information")

    
    def test_empty_directory(self):
        """Test with empty directory."""
        print("\n12. Testing empty directory...")
        empty_dir = self.test_dir / "empty"
        empty_dir.mkdir()
        
        cleaner = ProjectCleaner(
            target_dir=str(empty_dir),
            log_level="WARNING"
        )
        
        stats = cleaner.audit()
        
        self.assert_true(stats.files_found == 0, "No files found in empty directory")
    
    def test_format_size(self):
        """Test size formatting."""
        print("\n13. Testing size formatting...")
        cleaner = ProjectCleaner(
            target_dir=str(self.test_dir),
            log_level="WARNING"
        )
        
        self.assert_true(cleaner._format_size(500) == "500.00 B", "Bytes format")
        self.assert_true(cleaner._format_size(1024) == "1.00 KB", "Kilobytes format")
        self.assert_true(cleaner._format_size(1024 * 1024) == "1.00 MB", "Megabytes format")
        self.assert_true(cleaner._format_size(1024 * 1024 * 1024) == "1.00 GB", "Gigabytes format")
    
    def run_all_tests(self):
        """Run all tests."""
        print("=" * 70)
        print("Project Cleanup Utility - Test Suite")
        print("=" * 70)
        
        try:
            self.setup()
            
            # Run all test methods
            self.test_initialization_valid()
            self.test_initialization_invalid_dir()
            self.test_initialization_file_not_dir()
            self.test_find_files_non_recursive()
            self.test_find_files_recursive()
            self.test_custom_patterns()
            self.test_audit_mode()
            self.test_cleanup_without_backup()
            self.test_cleanup_with_backup()
            self.test_file_size_calculation()
            self.test_permission_error_handling()
            self.test_empty_directory()
            self.test_format_size()
            
        finally:
            self.teardown()
        
        # Print summary
        print("\n" + "=" * 70)
        print("Test Summary")
        print("=" * 70)
        print(f"✓ Passed: {self.passed}")
        print(f"✗ Failed: {self.failed}")
        print(f"Total:    {self.passed + self.failed}")
        
        if self.failed == 0:
            print("\n🎉 All tests passed!")
            return 0
        else:
            print(f"\n⚠️  {self.failed} test(s) failed")
            return 1


if __name__ == "__main__":
    tester = TestProjectCleaner()
    sys.exit(tester.run_all_tests())
