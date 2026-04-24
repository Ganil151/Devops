"""
🔗 DevOps Link Auditor & Repair Utility (Trinity Edition)
======================================================
Audits and AUTOMATICALLY repairs links and navigation integrity.
Maintains repository standards across the multi-tier structure.

Features:
- 🚀 Multi-threaded directory scanning
- �️ Auto-repair for moved files (Fuzzy matching)
- 🧭 Auto-injection of missing navigation links
- 📏 Path normalization (Absolute to Relative)
- 🧹 Cleaning of dead/empty link references
- 📊 Detailed Markdown report generation

@TRINITY: Link Auditor | python 00-Resources/Script/link_auditor.py
"""

import os
import re
import logging
import argparse
import threading
from pathlib import Path
from datetime import datetime
from collections import defaultdict
from typing import List, Dict, Set, Tuple, Optional
from concurrent.futures import ThreadPoolExecutor

# --- Configuration & Styling ---
LOG_FORMAT = "%(asctime)s - %(levelname)s - %(message)s"
BASE_DIR = Path("/home/gsmash/Documents/Devops")
EXCLUDE_DIRS = {".git", ".github", ".obsidian", "assets", "00-Resources", "node_modules", "__pycache__", ".venv"}
REPORT_PATH = BASE_DIR / "00-Resources" / "LINK_AUDIT_REPORT.md"

class LinkAuditor:
    def __init__(self, base_path: Path, verbose: bool = False, auto_repair: bool = False, fix_nav: bool = False):
        self.base_path = base_path
        self.auto_repair = auto_repair or fix_nav # Enable repair if fix_nav is on
        self.fix_nav = fix_nav
        self.setup_logging(verbose)
        
        self.file_map = self._build_file_map()
        self.broken_links = []
        self.repaired_links = []
        self.navigation_updates = []
        self.stats = {
            "scanned": 0,
            "links_found": 0,
            "broken": 0,
            "repaired": 0,
            "nav_fixed": 0,
            "errors": 0
        }
        # Thread-safe locks for concurrent updates
        self.stats_lock = threading.Lock()
        self.lists_lock = threading.Lock()

    def setup_logging(self, verbose: bool):
        level = logging.DEBUG if verbose else logging.INFO
        logging.basicConfig(level=level, format=LOG_FORMAT)
        self.logger = logging.getLogger("LinkAuditor")

    def _build_file_map(self) -> Dict[str, List[Path]]:
        """Maps filenames to absolute paths for fuzzy recovery."""
        self.logger.info("📁 Indexing repository for fuzzy recovery...")
        file_map = defaultdict(list)
        for p in self.base_path.rglob("*"):
            if p.is_file() and not any(ex in p.parts for ex in EXCLUDE_DIRS):
                file_map[p.name].append(p)
        return file_map

    def extract_links(self, content: str) -> List[Tuple[str, str]]:
        """Extracts markdown-style links [(text)](path). Returns list of (full_match, path)."""
        # Matches [label](path) but not http/https/mailto/#
        pattern = r"(\[(?:[^\]]+)\]\((?!http|https|mailto|#)([^)]+)\))"
        return re.findall(pattern, content)

    def find_best_fit(self, current_file: Path, broken_link: str) -> Optional[str]:
        """Tries to find the new location of a moved file by looking for filename matches."""
        target_path_obj = Path(broken_link.split("#")[0])
        target_name = target_path_obj.name
        
        # Strategy 1: Try exact filename match
        matches = self.file_map.get(target_name, [])
        
        # Strategy 2: If no exact match and it's a directory-like link (no extension or ends with /), try README.md
        if not matches and (not target_path_obj.suffix or broken_link.endswith("/")):
            matches = self.file_map.get("README.md", [])
            # Filter to only READMEs in directories that match the target name
            if target_name:
                matches = [m for m in matches if target_name.lower() in str(m.parent).lower()]
        
        # Strategy 3: If still no match, try partial filename matching (for renamed files)
        if not matches and target_name:
            # Extract key words from the target filename (remove common words, split on - and _)
            target_words = set(target_name.lower().replace('.md', '').replace('_', ' ').replace('-', ' ').split())
            target_words.discard('readme')
            target_words.discard('reference')
            
            if target_words:
                partial_matches = []
                for filename, paths in self.file_map.items():
                    file_words = set(filename.lower().replace('.md', '').replace('_', ' ').replace('-', ' ').split())
                    # If at least 50% of target words are in the filename
                    overlap = len(target_words & file_words)
                    if overlap >= len(target_words) * 0.5 and overlap > 0:
                        partial_matches.extend(paths)
                
                if partial_matches:
                    matches = partial_matches
        
        if not matches:
            return None
            
        # Scoring system: prefer matches that share more of the path or are closer to current file
        def calculate_score(match_path: Path) -> float:
            common_parts = 0
            for p1, p2 in zip(current_file.parts, match_path.parts):
                if p1 == p2: common_parts += 1
                else: break
            
            try:
                rel = os.path.relpath(match_path, current_file.parent)
                distance = len(Path(rel).parts)
            except ValueError:
                distance = 100
                
            return common_parts - (distance * 0.1)

        best_match = max(matches, key=calculate_score)
        
        try:
            rel_path = os.path.relpath(best_match, current_file.parent)
            # Ensure we preserve anchors if they existed
            anchor = f"#{broken_link.split('#')[1]}" if "#" in broken_link else ""
            return f"{rel_path}{anchor}"
        except ValueError:
            return None

    def validate_and_repair(self, md_file: Path, content: str) -> str:
        """Validates links and applies repairs if configured."""
        links = self.extract_links(content)
        new_content = content
        
        # Track what we've seen in this file to avoid duplicate repairs
        processed_links = set()
        
        # Local counters for this file (to minimize lock contention)
        local_stats = {"links_found": 0, "broken": 0, "repaired": 0}
        local_broken = []
        local_repaired = []

        for full_match, link_path in links:
            if full_match in processed_links:
                continue
            processed_links.add(full_match)

            local_stats["links_found"] += 1
            clean_link = link_path.split("#")[0]
            
            if not clean_link: continue # Skip anchor-only links
            
            # 1. Check if path is absolute (system path) and convert to relative if it's in the repo
            if clean_link.startswith("/home/") and str(self.base_path) in clean_link:
                try:
                    rel_to_repo = os.path.relpath(clean_link, md_file.parent)
                    anchor = f"#{link_path.split('#')[1]}" if "#" in link_path else ""
                    suggested = f"{rel_to_repo}{anchor}"
                    
                    if self.auto_repair:
                        self.logger.info(f"🔄 Normalizing Path: {link_path} -> {suggested} in {md_file.name}")
                        new_content = new_content.replace(f"({link_path})", f"({suggested})")
                        local_stats["repaired"] += 1
                        local_repaired.append({"file": str(md_file.relative_to(self.base_path)), "old": link_path, "new": suggested, "type": "Normalization"})
                        continue
                except:
                    pass

            # 2. Check for broken relative links
            target_path = (md_file.parent / clean_link).resolve()
            
            if not target_path.exists():
                local_stats["broken"] += 1
                suggestion = self.find_best_fit(md_file, link_path)
                
                if suggestion:
                    self.logger.debug(f"📍 Found suggestion for '{link_path}': {suggestion}")
                
                local_broken.append({
                    "file": str(md_file.relative_to(self.base_path)),
                    "link": link_path,
                    "suggestion": suggestion or "NOT FOUND"
                })
                
                if self.auto_repair and suggestion:
                    self.logger.info(f"🔧 Repairing: {link_path} -> {suggestion} in {md_file.name}")
                    new_content = new_content.replace(f"({link_path})", f"({suggestion})")
                    local_stats["repaired"] += 1
                    local_repaired.append({"file": str(md_file.relative_to(self.base_path)), "old": link_path, "new": suggestion, "type": "Fuzzy Fix"})
                elif suggestion:
                    self.logger.debug(f"⚠️ Suggestion found but auto_repair is disabled: {link_path} -> {suggestion}")
        
        # Update global stats and lists with thread safety
        with self.stats_lock:
            self.stats["links_found"] += local_stats["links_found"]
            self.stats["broken"] += local_stats["broken"]
            self.stats["repaired"] += local_stats["repaired"]
        
        with self.lists_lock:
            self.broken_links.extend(local_broken)
            self.repaired_links.extend(local_repaired)

        return new_content

    def repair_navigation(self, current_file: Path, content: str) -> str:
        """Injects missing sub-module links into README/REFERENCE files."""
        if current_file.name not in ["README.md", "REFERENCE.md"]:
            return content

        new_content = content
        parent_dir = current_file.parent
        missing_here = []

        for item in parent_dir.iterdir():
            if item.is_dir() and item.name not in EXCLUDE_DIRS:
                # Check for critical entry points in subfolders
                for ref_name in ["README.md", "REFERENCE.md", "Quick_Reference.md"]:
                    if (item / ref_name).exists():
                        ref_link = f"{item.name}/{ref_name}"
                        # Check if either the folder name or the specific file is linked
                        if ref_link not in content and f"/{item.name}" not in content and f"({item.name})" not in content:
                            missing_here.append((item.name, ref_link))
                        break
        
        if missing_here and self.fix_nav:
            # Try to find a good spot to inject (Navigation Index or end of file)
            nav_marker = "## 🗺️ Navigation Index"
            if nav_marker in new_content:
                injection = ""
                for name, link in missing_here:
                    link_text = f"\n- 📂 **[{name.replace('-', ' ')}]({link})**"
                    if link_text not in new_content:
                        injection += link_text
                        self.stats["nav_fixed"] += 1
                        self.navigation_updates.append({"file": str(current_file.relative_to(self.base_path)), "subdir": name})
                
                if injection:
                    new_content = new_content.replace(nav_marker, f"{nav_marker}{injection}")
            else:
                # Fallback to end of file if no marker found
                injection = "\n\n---\n## 🧭 Additional Modules\n"
                nav_count = 0
                nav_updates = []
                for name, link in missing_here:
                    injection += f"- [{name.replace('-', ' ')}]({link})\n"
                    nav_count += 1
                    nav_updates.append({"file": str(current_file.relative_to(self.base_path)), "subdir": name})
                new_content += injection
                
                # Update global stats with thread safety
                with self.stats_lock:
                    self.stats["nav_fixed"] += nav_count
                with self.lists_lock:
                    self.navigation_updates.extend(nav_updates)

        return new_content

    def process_file(self, md_file: Path):
        """Main processing unit for a single markdown file."""
        try:
            with self.stats_lock:
                self.stats["scanned"] += 1
            content = md_file.read_text(encoding="utf-8", errors="replace")
            
            # 1. Link Validation & Repair
            new_content = self.validate_and_repair(md_file, content)
            
            # 2. Navigation Repair
            new_content = self.repair_navigation(md_file, new_content)
            
            # 3. Update file if repairs were made
            if new_content != content:
                md_file.write_text(new_content, encoding="utf-8")
                
        except Exception as e:
            self.logger.error(f"❌ Error processing {md_file}: {e}")
            with self.stats_lock:
                self.stats["errors"] += 1

    def run(self):
        """Scans the repository for all markdown files."""
        self.logger.info(f"🚀 Starting Repo-Wide Audit & Repair at: {self.base_path}")
        
        md_files = [p for p in self.base_path.rglob("*.md") 
                   if not any(ex in p.parts for ex in EXCLUDE_DIRS)]
        
        with ThreadPoolExecutor(max_workers=8) as executor:
            executor.map(self.process_file, md_files)

    def generate_report(self):
        """Writes the audit results to a professional report."""
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        report = [
            "# 🔍 DevOps Repository Link Integrity Report",
            f"*Generated on: {now}*",
            "\n## 📊 Summary Statistics",
            f"- **Files Scanned:** `{self.stats['scanned']}`",
            f"- **Total Links Found:** `{self.stats['links_found']}`",
            f"- **Broken Links identified:** `{self.stats['broken']}`",
            f"- **Links Auto-Repaired/Normalized:** `{self.stats['repaired']}`",
            f"- **Navigation Links Injected:** `{self.stats['nav_fixed']}`",
            f"- **Processing Errors:** `{self.stats['errors']}`",
            "\n---\n"
        ]

        if self.repaired_links:
            report.append("## ✅ Repaired & Normalized Links")
            report.append("| File | Type | Old Link | New Link |")
            report.append("| :--- | :--- | :--- | :--- |")
            for item in self.repaired_links:
                report.append(f"| `{item['file']}` | {item['type']} | `{item['old']}` | `{item['new']}` |")
            report.append("\n")

        if self.navigation_updates:
            report.append("## 🧭 Navigation Updates")
            report.append("| Parent File | Injected Sub-module |")
            report.append("| :--- | :--- |")
            for item in self.navigation_updates:
                report.append(f"| `{item['file']}` | `{item['subdir']}` |")
            report.append("\n")

        if self.broken_links:
            report.append("## ❌ Unresolved Broken Links")
            report.append("| File | Broken Link | Suggested Fix | Status |")
            report.append("| :--- | :--- | :--- | :--- |")
            # Only show links that aren't repaired
            repaired_paths = {(r['file'], r['old']) for r in self.repaired_links}
            for item in self.broken_links:
                if (item['file'], item['link']) not in repaired_paths:
                    sug = f"`{item['suggestion']}`" if item['suggestion'] != "NOT FOUND" else "*Manual search required*"
                    report.append(f"| `{item['file']}` | `{item['link']}` | {sug} | ⚠️ Action Required |")
        else:
            report.append("## ✅ All Links Validated\nNo broken links remain in the repository.")

        REPORT_PATH.write_text("\n".join(report), encoding="utf-8")
        self.logger.info(f"✅ Audit complete. Report saved to: {REPORT_PATH}")

def main():
    parser = argparse.ArgumentParser(description="Trinity Link Auditor & Repair Utility")
    parser.add_argument("-d", "--dir", type=Path, default=BASE_DIR, help="Base directory to audit")
    parser.add_argument("-r", "--repair", action="store_true", help="Auto-repair links with high-confidence matches")
    parser.add_argument("-n", "--nav", action="store_true", help="Auto-inject missing navigation links")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable debug logging")
    
    args = parser.parse_args()
    
    if not args.dir.exists():
        print(f"Error: Directory {args.dir} does not exist.")
        return

    auditor = LinkAuditor(args.dir, verbose=args.verbose, auto_repair=args.repair, fix_nav=args.nav)
    auditor.run()
    auditor.generate_report()

if __name__ == "__main__":
    main()
