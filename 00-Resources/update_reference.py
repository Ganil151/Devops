#!/usr/bin/env python3
"""
🚀 Reference Automator
Automatically updates the root REFERENCE.md based on repository changes.
Maintains the Trinity Suite, Search Index, and Navigation Index.

@TRINITY: Repo Automator | python 00-Resources/update_reference.py
@TRINITY: Project Cleaner | python 00-Resources/01-Scripts-Code/Maintenance/project_clean.py
"""

import os
import re
import time
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Tuple

# Configuration
BASE_DIR = Path("/home/gsmash/Documents/Devops")
ROOT_REF = BASE_DIR / "REFERENCE.md"
RES_DIR = BASE_DIR / "00-Resources"
EXCLUDE_DIRS = {".git", ".github", ".obsidian", "assets", "00-Resources", "node_modules", "__pycache__"}

class ReferenceAutomator:
    def __init__(self, root_ref_path: Path):
        self.root_ref_path = root_ref_path
        self.base_dir = root_ref_path.parent
        self.sections = {}
        self.original_content = ""

    def read_ref(self):
        """Reads the current REFERENCE.md and splits it into sections."""
        if not self.root_ref_path.exists():
            print(f"[ERROR] {self.root_ref_path} not found.")
            return False
        
        with open(self.root_ref_path, "r", encoding="utf-8") as f:
            self.original_content = f.read()
        return True
        # Simple section splitter based on '---' or headers
        # For now, we'll just target specific blocks using markers or headings
        return True

    def get_navigation_index(self) -> str:
        """Scans top-level folders for REFERENCE.md files."""
        items = []
        # Find folders starting with a digit (e.g., 1-Beginner)
        folders = sorted([d for d in self.base_dir.iterdir() if d.is_dir() and d.name[0].isdigit()])
        
        icons = {
            "1": "🌱",
            "2": "⚙️",
            "3": "🏛️",
            "4": "👔",
            "5": "📦",
            "6": "📝",
            "7": "🧪",
            "8": "🚀"
        }

        for folder in folders:
            qr_file = folder / "REFERENCE.md"
            if qr_file.exists():
                # Extract title or first few topics
                topics = self.extract_topics_from_qr(qr_file)
                icon = icons.get(folder.name[0], "📂")
                rel_path = f"./{folder.name}/REFERENCE.md"
                # Clean up folder name for display (e.g., 1-Beginner -> Beginner Fundamentals)
                display_name = folder.name.split("-", 1)[1].replace("-", " ")
                if "Beginner" in display_name: display_name = "Beginner Fundamentals"
                elif "Intermediate" in display_name: display_name = "Intermediate Automation"
                elif "Advanced" in display_name: display_name = "Advanced Enterprise"
                elif "Professional" in display_name: display_name = "Professional Career"
                
                items.append(f"- {icon} **[{display_name}]({rel_path})**: {topics}.")
        
        return "\n".join(items)

    def extract_topics_from_qr(self, qr_path: Path) -> str:
        """Extracts core topics from a sub-REFERENCE.md."""
        with open(qr_path, "r", encoding="utf-8") as f:
            content = f.read()
            # Look for "Phase" headers or specific keywords
            phases = re.findall(r"### Phase \d+: (.*)", content)
            if phases:
                return ", ".join(phases[:3])
            # Fallback: look for bold items in the roadmap
            items = re.findall(r"\d+\. \*\*\[(.*?)\]", content)
            if items:
                return ", ".join(items[:3])
        return "General Reference"

    def get_trinity_suite(self) -> str:
        """Scans for scripts that should be in the Trinity Suite."""
        # Using the existing format from the file
        header = "| Goal | Language | Location | Primary Command |\n| :--- | :--- | :--- | :--- |"
        rows = []
        
        # Search for scripts in all 'scripts' directories
        for script_path in self.base_dir.rglob("scripts/*"):
            if script_path.suffix in [".py", ".sh", ".ps1"]:
                metadata = self.parse_script_metadata(script_path)
                if metadata:
                    rel_dir = f"./{script_path.parent.relative_to(self.base_dir)}/"
                    rows.append(f"| **{metadata['goal']}** | {metadata['lang']} | `{rel_dir}` | `{metadata['cmd']}` |")
        
        if not rows:
            # Fallback to current hardcoded values if no new ones found with metadata
            # For this demo, I'll return the original ones + any new ones
            return "" # Returning empty to indicate no change or manual management for now
        
        return header + "\n" + "\n".join(rows)

    def parse_script_metadata(self, path: Path) -> Dict:
        """Parses script for @TRINITY tags or docstrings."""
        content = ""
        try:
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read(1000) # Read first 1000 chars
        except:
            return None

        # Look for: # @TRINITY: Goal | Command
        match = re.search(r"@TRINITY:\s*(.*?)\s*\|\s*(.*)", content)
        if match:
            goal = match.group(1).strip()
            cmd = match.group(2).strip()
            lang = "Python" if path.suffix == ".py" else "Bash" if path.suffix == ".sh" else "PowerShell"
            return {"goal": goal, "cmd": cmd, "lang": lang}
        
        return None

    def get_recent_activity(self) -> str:
        """Finds most recently modified files."""
        files = []
        for p in self.base_dir.rglob("*"):
            if p.is_file() and p.suffix in [".md", ".py", ".sh", ".ps1"]:
                if any(ex in str(p) for ex in EXCLUDE_DIRS):
                    continue
                if p.name == "REFERENCE.md" or p.name == "tree.txt":
                    continue
                files.append(p)
        
        # Sort by mtime
        files.sort(key=lambda x: x.stat().st_mtime, reverse=True)
        
        activity = ["| File | Last Modified | Path |", "| :--- | :--- | :--- |"]
        for f in files[:5]:
            mtime = datetime.fromtimestamp(f.stat().st_mtime).strftime('%Y-%m-%d %H:%M')
            rel_path = f.relative_to(self.base_dir)
            activity.append(f"| {f.name} | {mtime} | `{rel_path}` |")
        
        return "\n".join(activity)

    def get_search_index(self) -> str:
        """Generates a comprehensive searchable index of important files."""
        index = ["| Resource | Category | Path |", "| :--- | :--- | :--- |"]
        
        # Define categories based on directory structure
        categories = {
            "1-Beginner": "🌱 Beginner",
            "2-Intermediate": "⚙️ Intermediate",
            "3-Advanced": "🏛️ Advanced",
            "4-Professional": "👔 Professional",
            "5-Boilerplates": "📦 Boilerplate",
            "7-Labs": "🧪 Lab",
            "8-Projects": "🚀 Project"
        }

        files_found = 0
        for p in sorted(self.base_dir.rglob("*")):
            if p.is_file() and p.suffix in [".md", ".py", ".sh", ".ps1"]:
                if any(ex in str(p) for ex in EXCLUDE_DIRS):
                    continue
                if p.name in ["REFERENCE.md", "README.md", "tree.txt"]:
                    continue
                
                # Determine category
                rel_parts = p.relative_to(self.base_dir).parts
                category = "Other"
                if rel_parts:
                    for key, val in categories.items():
                        if key in rel_parts[0]:
                            category = val
                            break
                
                # Only include significant files (e.g. not every minor script if there are 1000s)
                if files_found > 500: # Safety cap
                    break
                
                name = p.stem.replace("_", " ").replace("-", " ").title()
                if p.suffix == ".md" and name.lower() == "readme":
                    name = f"README ({rel_parts[-2]})"
                
                index.append(f"| {name} | {category} | `{p.relative_to(self.base_dir)}` |")
                files_found += 1
        
        return "\n".join(index)

    def update_root_ref(self):
        """Orchestrates the update process."""
        print(f"[{datetime.now().strftime('%H:%M:%S')}] 🔍 Auditing repository changes...")
        
        if not self.read_ref():
            return

        new_content = self.original_content

        # 1. Update Navigation Index
        nav_index = self.get_navigation_index()
        # Pattern: Match from header until next header or horizontal rule (on its own line)
        nav_pattern = r"(## 🗺️ Navigation Index\n.*?)(?=\n##|\n---\n|\Z)"
        if re.search(nav_pattern, new_content, re.DOTALL):
            new_content = re.sub(nav_pattern, f"## 🗺️ Navigation Index\n\n{nav_index}\n\n", new_content, flags=re.DOTALL)
        
        # 2. Update Search Index (NEW)
        search_index = self.get_search_index()
        search_section = f"## 🔍 Universal Search Index\n\n<details>\n<summary>Click to expand full file index ({len(search_index.splitlines()) - 2} files)</summary>\n\n{search_index}\n\n</details>\n\n"
        if "## 🔍 Universal Search Index" in new_content:
            new_content = re.sub(r"## 🔍 Universal Search Index.*?(?=\n##|\n---\n|\Z)", search_section, new_content, flags=re.DOTALL)
        else:
            # Insert after Navigation Index or before Recent Activity
            if "## 🕒 Recent Activity" in new_content:
                new_content = new_content.replace("## 🕒 Recent Activity", f"{search_section}---\n\n## 🕒 Recent Activity")
            else:
                new_content += f"\n\n---\n\n{search_section}"

        # 3. Update Trinity Suite (Optional - only if tags found)
        trinity_table = self.get_trinity_suite()
        if trinity_table:
            trinity_pattern = r"## 🛠️ The \"Trinity\" Orchestration Suite\n.*?(?=\n##|\n---\n|\Z)"
            if re.search(trinity_pattern, new_content, re.DOTALL):
                new_content = re.sub(trinity_pattern, f"## 🛠️ The \"Trinity\" Orchestration Suite\nThese master scripts are designed for cross-platform system management.\n\n{trinity_table}\n\n", new_content, flags=re.DOTALL)

        # 4. Update Recent Activity (Auto-Generated)
        recent_activity = self.get_recent_activity()
        activity_section = f"## 🕒 Recent Activity (Auto-Generated)\n\n{recent_activity}\n\n"
        
        if "## 🕒 Recent Activity" in new_content:
            # Replace until next header or rule
            new_content = re.sub(r"## 🕒 Recent Activity.*?(?=\n##|\n---\n|\Z)", activity_section, new_content, flags=re.DOTALL)

        # 5. Update Version/Timestamp
        # Look for Version or Last Updated
        version_pattern = r"\*(Version|Last Updated): (.*?)\*"
        now = datetime.now().strftime("%Y-%m-%d %H:%M")
        if re.search(version_pattern, new_content):
            new_content = re.sub(version_pattern, f"*Last Updated: {now} - Automated Sync*", new_content)

        if new_content != self.original_content:
            with open(self.root_ref_path, "w", encoding="utf-8") as f:
                f.write(new_content)
            print(f"[SUCCESS] 🚀 REFERENCE.md updated.")
        else:
            print("[INFO] No structural changes detected.")

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Reference Automator")
    parser.add_argument("--watch", action="store_true", help="Run in watch mode (polling)")
    parser.add_argument("--interval", type=int, default=60, help="Polling interval in seconds")
    args = parser.parse_args()

    automator = ReferenceAutomator(ROOT_REF)
    
    if args.watch:
        print(f"[*] Starting Reference Automator in WATCH mode (Interval: {args.interval}s)")
        try:
            while True:
                automator.update_root_ref()
                time.sleep(args.interval)
        except KeyboardInterrupt:
            print("\n[*] Stopping Automator...")
    else:
        automator.update_root_ref()

if __name__ == "__main__":
    main()
