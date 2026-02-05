#!/usr/bin/env python3
"""
🚀 Automated Git Commit & Push Utility
======================================
Automatically generates intelligent commit messages based on file changes.
Supports manual override and provides detailed change summaries.

Usage:
    python3 git_command.py                    # Auto-generate commit message
    python3 git_command.py "Custom message"   # Use custom message
    python3 git_command.py --dry-run          # Preview changes without committing
    python3 git_command.py --watch            # Watch for changes and auto-commit
"""

import subprocess
import sys
import re
import time
from pathlib import Path
from datetime import datetime
from collections import defaultdict
from typing import Dict, List, Tuple, Optional


class GitAutomation:
    def __init__(self, repo_path: str = "."):
        self.repo_path = Path(repo_path)
        self.change_summary = defaultdict(list)
        
    def run_command(self, cmd: List[str], timeout: int = 30) -> Tuple[bool, str, str]:
        """Execute a git command and return success status, stdout, stderr."""
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True,
                timeout=timeout,
                cwd=self.repo_path
            )
            return True, result.stdout, result.stderr
        except subprocess.CalledProcessError as e:
            return False, e.stdout, e.stderr
        except subprocess.TimeoutExpired:
            return False, "", "Command timed out"
        except FileNotFoundError:
            return False, "", f"Command not found: {cmd[0]}"

    def parse_status_line(self, line: str) -> Tuple[str, str]:
        """Parse git status line handling quotes and renames."""
        status = line[:2]
        rest = line[3:]
        
        # Handle renames (R  from -> to)
        if " -> " in rest:
            # extract the 'to' part
            arrow_idx = rest.rfind(" -> ")
            if arrow_idx != -1:
                filepath = rest[arrow_idx + 4:]
            else:
                filepath = rest
        else:
            filepath = rest
            
        # Handle quotes
        if filepath.startswith('"') and filepath.endswith('"'):
            filepath = filepath[1:-1]
            
        return status, filepath

    def get_status(self) -> Dict[str, List[str]]:
        """Get git status and categorize changes."""
        success, stdout, stderr = self.run_command(["git", "status", "--porcelain"])
        
        if not success:
            print(f"❌ Error getting git status: {stderr}")
            return {}
        
        changes = {
            "added": [],
            "modified": [],
            "deleted": [],
            "renamed": [],
            "untracked": []
        }
        
        for line in stdout.splitlines():
            if not line:
                continue
                
            status, filepath = self.parse_status_line(line)
            
            # Parse git status codes
            if status == "??":
                changes["untracked"].append(filepath)
            elif "A" in status:
                changes["added"].append(filepath)
            elif "M" in status:
                changes["modified"].append(filepath)
            elif "D" in status:
                changes["deleted"].append(filepath)
            elif "R" in status:
                changes["renamed"].append(filepath)
        
        return changes

    def analyze_changes(self, changes: Dict[str, List[str]]) -> Dict[str, List[str]]:
        """Analyze changes by file type and category."""
        categories = defaultdict(list)
        
        for change_type, files in changes.items():
            for filepath in files:
                path = Path(filepath)
                
                # Categorize by directory structure
                if "00-Resources" in filepath:
                    categories["Resources"].append(f"{change_type}: {filepath}")
                elif "Script" in filepath or filepath.endswith((".py", ".sh", ".ps1")):
                    categories["Scripts"].append(f"{change_type}: {filepath}")
                elif filepath.endswith(".md"):
                    categories["Documentation"].append(f"{change_type}: {filepath}")
                elif "REFERENCE" in filepath:
                    categories["Reference"].append(f"{change_type}: {filepath}")
                elif any(x in filepath for x in ["Beginner", "Intermediate", "Advanced"]):
                    categories["Curriculum"].append(f"{change_type}: {filepath}")
                else:
                    categories["Other"].append(f"{change_type}: {filepath}")
        
        return categories

    def generate_commit_message(self, changes: Dict[str, List[str]]) -> str:
        """Generate an intelligent commit message based on changes."""
        if not any(changes.values()):
            return "chore: minor updates"
        
        # Count changes by type
        total_added = len(changes.get("added", [])) + len(changes.get("untracked", []))
        total_modified = len(changes.get("modified", []))
        total_deleted = len(changes.get("deleted", []))
        total_renamed = len(changes.get("renamed", []))
        
        # Analyze file categories
        all_files = []
        for file_list in changes.values():
            all_files.extend(file_list)
        
        # Determine primary change type
        is_fix = any("fix" in f.lower() or "bug" in f.lower() for f in all_files)
        categories = self.analyze_changes(changes)
        
        # Determine scope based on most affected category
        if categories:
            primary_category = max(categories.items(), key=lambda x: len(x[1]))[0]
            scope = primary_category.lower()
        else:
            primary_category = "General"
            scope = "general"

        if is_fix:
            prefix = "fix"
            action = "Fix"
        elif primary_category == "Documentation":
             prefix = "docs"
             action = "Update"
        elif total_added >= total_modified and total_added >= total_deleted:
            prefix = "feat"
            action = "Add"
        elif total_deleted > total_added and total_deleted > total_modified:
            prefix = "refactor"
            action = "Remove"
        else:
            prefix = "refactor"
            action = "Update"
        

        
        # Build message
        summary_parts = []
        if total_added > 0:
            summary_parts.append(f"{total_added} added")
        if total_modified > 0:
            summary_parts.append(f"{total_modified} modified")
        if total_deleted > 0:
            summary_parts.append(f"{total_deleted} deleted")
        if total_renamed > 0:
            summary_parts.append(f"{total_renamed} renamed")
        
        summary = ", ".join(summary_parts)
        
        # Get key files (limit to 3 most important)
        key_files = []
        for category in ["Scripts", "Documentation", "Reference", "Curriculum", "Resources"]:
            if category in categories:
                for item in categories[category]:
                    full_path = item.split(": ", 1)[1]
                    path_obj = Path(full_path)
                    
                    # Add parent folder for generic names like README.md
                    if path_obj.name == "README.md" and len(path_obj.parts) > 1:
                        display_name = f"{path_obj.parts[-2]}/{path_obj.name}"
                    else:
                        display_name = path_obj.name
                    
                    if display_name not in key_files:
                        key_files.append(display_name)
                    
                    if len(key_files) >= 3:
                        break
            if len(key_files) >= 3:
                break
        
        # Construct commit message
        if key_files:
            files_str = ", ".join(key_files[:3])
            commit_msg = f"{prefix}({scope}): {action} {files_str}"
        else:
            commit_msg = f"{prefix}({scope}): {action} {summary}"
        
        # Add detailed body
        body_lines = [f"\n\nChanges summary: {summary}"]
        
        for category, items in sorted(categories.items()):
            if items:
                body_lines.append(f"\n{category}:")
                for item in items[:5]:  # Limit to 5 items per category
                    body_lines.append(f"  - {item.split(': ', 1)[1]}")
                if len(items) > 5:
                    body_lines.append(f"  ... and {len(items) - 5} more")
        
        full_message = commit_msg + "".join(body_lines)
        
        return full_message

    def stage_changes(self) -> bool:
        """Stage all changes."""
        print("📦 Staging changes...")
        success, stdout, stderr = self.run_command(["git", "add", "."])
        
        if not success:
            print(f"❌ Failed to stage changes: {stderr}")
            return False
        
        print("✅ Changes staged successfully")
        return True

    def commit_changes(self, message: str) -> bool:
        """Commit staged changes."""
        print(f"\n📝 Committing with message:\n{'-' * 60}\n{message}\n{'-' * 60}")
        
        success, stdout, stderr = self.run_command(["git", "commit", "-m", message])
        
        if not success:
            print(f"❌ Failed to commit: {stderr}")
            return False
        
        print("✅ Changes committed successfully")
        return True

    def pull_changes(self) -> bool:
        """Pull latest changes from remote with rebase."""
        print("📥 Pulling latest changes (with rebase)...")
        success, stdout, stderr = self.run_command(["git", "pull", "--rebase"], timeout=60)
        
        if success:
            print("✅ Pull successful")
            return True
        else:
            print(f"❌ Pull failed: {stderr}")
            if "merging" in stderr or "conflict" in stderr:
                print("⚠️  Merge conflict detected. Manual intervention required.")
            return False

    def push_changes(self, max_retries: int = 3) -> bool:
        """Push commits to remote with retry logic and exponential backoff."""
        print("\n🚀 Pushing to remote...")
        
        for attempt in range(1, max_retries + 1):
            # Increase timeout for potential large pushes or slow connections
            current_timeout = 120 * attempt 
            
            print(f"  Attempt {attempt}/{max_retries} (Timeout: {current_timeout}s)...")
            success, stdout, stderr = self.run_command(["git", "push"], timeout=current_timeout)
            
            if success:
                print("✅ Changes pushed successfully")
                if stdout:
                    print(stdout)
                return True
            
            err_msg = stderr.strip() if stderr else "Command timed out"
            
            # Specialized error handling
            if "non-fast-forward" in err_msg or "fetch first" in err_msg:
                print(f"⚠️  Push rejected: remote has changes I don't have.")
                if self.pull_changes():
                    print("🔄 Retrying push after successful pull...")
                    continue # Retry immediately
                else:
                    return False # Could not resolve via pull
            
            print(f"⚠️  Attempt {attempt} failed: {err_msg}")
            
            if attempt < max_retries:
                wait_time = 2 ** attempt
                print(f"  Retrying in {wait_time}s...")
                time.sleep(wait_time)
        
        print(f"❌ Failed to push after {max_retries} attempts.")
        return False

    def run(self, custom_message: Optional[str] = None, dry_run: bool = False) -> str:
        """Main execution flow."""
        print("🔍 Checking repository status...\n")
        
        # Get current status
        changes = self.get_status()
        
        if not any(changes.values()):
            print("✨ No changes to commit")
            return "No changes"
        
        # Display changes
        total_changes = sum(len(files) for files in changes.values())
        print(f"📊 Found {total_changes} file(s) with changes:\n")
        
        for change_type, files in changes.items():
            if files:
                print(f"  {change_type.upper()}: {len(files)} file(s)")
                for f in files[:3]:
                    print(f"    - {f}")
                if len(files) > 3:
                    print(f"    ... and {len(files) - 3} more")
        
        print()
        
        # Generate or use custom commit message
        if custom_message:
            commit_message = custom_message
            print(f"📌 Using custom commit message")
        else:
            commit_message = self.generate_commit_message(changes)
            print(f"🤖 Auto-generated commit message")
        
        if dry_run:
            print(f"\n🔍 DRY RUN MODE - No changes will be committed\n")
            print(f"Generated message:\n{'-' * 60}\n{commit_message}\n{'-' * 60}")
            return "Dry run completed"
        
        # Stage changes
        if not self.stage_changes():
            return "Failed to stage"
        
        # Commit changes
        if not self.commit_changes(commit_message):
            return "Failed to commit"
        
        # Push changes
        if not self.push_changes():
            return "Failed to push"
        
        print("\n✨ All operations completed successfully!")
        return "Success"

    def watch(self, interval: int = 5):
        """Watch for changes and auto-commit."""
        print(f"👀 Watching for changes (polling every {interval}s)...")
        print("Press Ctrl+C to stop.")
        
        try:
            while True:
                # Check for changes silently first
                changes = self.get_status()
                
                if any(changes.values()):
                    print(f"\n⚡ Changes detected at {datetime.now().strftime('%H:%M:%S')}")
                    # Debounce: wait a bit to ensure file writes are finished
                    time.sleep(2)
                    
                    # Double check changes
                    changes = self.get_status()
                    if any(changes.values()):
                        self.run()
                        print(f"\n👀 Resuming watch (polling every {interval}s)...")
                
                time.sleep(interval)
                
        except KeyboardInterrupt:
            print("\n👋 Watch stopped by user.")
            return "Stopped"
        except Exception as e:
            print(f"\n❌ Error in watch loop: {e}")
            return "Error"


def main():
    """Main entry point."""
    # Parse arguments
    dry_run = "--dry-run" in sys.argv
    watch_mode = "--watch" in sys.argv
    custom_message = None
    
    # Remove flags from argv
    args = [arg for arg in sys.argv[1:] if not arg.startswith("--")]
    
    if args:
        custom_message = " ".join(args)
    
    # Run automation
    git_auto = GitAutomation()
    
    if watch_mode:
        git_auto.watch()
        result = "Success"
    else:
        result = git_auto.run(custom_message=custom_message, dry_run=dry_run)
    
    return 0 if result in ["Success", "No changes", "Dry run completed", "Stopped"] else 1


if __name__ == "__main__":
    sys.exit(main())
