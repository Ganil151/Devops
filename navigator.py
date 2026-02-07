#!/usr/bin/env python3
import os
import sys
import json
import re
import subprocess
import time
import webbrowser
from pathlib import Path
from typing import List, Dict, Optional

# Check dependencies
try:
    from rich.console import Console
    from rich.markdown import Markdown
    from rich.panel import Panel
    from prompt_toolkit import Application
    from prompt_toolkit.key_binding import KeyBindings
    from prompt_toolkit.layout.containers import HSplit, Window
    from prompt_toolkit.layout.controls import FormattedTextControl
    from prompt_toolkit.layout.layout import Layout
    from prompt_toolkit.widgets import TextArea
    from prompt_toolkit.styles import Style
    from prompt_toolkit.application.current import get_app
except ImportError:
    print("Missing dependencies. Please run: pip install -r navigator_requirements.txt")
    sys.exit(1)

# --- Configuration ---
BASE_DIR = Path("/home/gsmash/Documents/Devops")
CACHE_FILE = BASE_DIR / ".nav_cache"
IGNORE_DIRS = {".git", "__pycache__", "node_modules", ".idea", ".vscode", "venv", "env"}

console = Console()


# --- Module Scanner ---
class ModuleScanner:
    def __init__(self, root_dir: Path):
        self.root_dir = root_dir

    def scan(self, use_cache: bool = True) -> List[Dict]:
        """Recursively scans for README.md files and extracts metadata."""
        if use_cache and CACHE_FILE.exists():
            try:
                with open(CACHE_FILE, "r") as f:
                    data = json.load(f)
                    if isinstance(data, list) and len(data) > 0:
                        # Ensure cache has new fields
                        if "links" not in data[0]:
                            raise ValueError("Stale cache")
                        return data
            except Exception:
                pass  # Fallback to fresh scan

        modules = []
        for root, dirs, files in os.walk(self.root_dir):
            # Filter ignored directories in-place
            dirs[:] = [d for d in dirs if d not in IGNORE_DIRS]

            if "README.md" in files:
                readme_path = Path(root) / "README.md"
                info = self._parse_readme(readme_path)
                if info:
                    modules.append(info)

        # Save to cache
        try:
            with open(CACHE_FILE, "w") as f:
                json.dump(modules, f)
        except Exception:
            pass

        return modules

    def _parse_readme(self, path: Path) -> Optional[Dict]:
        """Extracts title and tags from README.md."""
        title = path.parent.name
        tags = []
        phase = "Unknown"
        links = []

        # Detect Phase from path
        path_str = str(path).lower()
        if "phase-1" in path_str or "phase_1" in path_str:
            phase = "Phase 1"
        elif "phase-2" in path_str or "phase_2" in path_str:
            phase = "Phase 2"
        elif "phase-3" in path_str or "phase_3" in path_str:
            phase = "Phase 3"

        try:
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()

            # Extract Title (First H1)
            for line in content.splitlines():
                if line.strip().startswith("# "):
                    title = line.strip()[2:].strip()
                    break

            # Extract Tags (looks for #tags: or tags:)
            tag_match = re.search(
                r"(?:^|\s)#?tags:\s*(.*)", content, re.IGNORECASE | re.MULTILINE
            )
            if tag_match:
                found_tags = re.findall(r"#?([\w-]+)", tag_match.group(1))
                tags = [t for t in found_tags]

            # Extract Links
            raw_links = re.findall(r'(https?://[^\s\)]+)', content)
            links = list(dict.fromkeys(raw_links))

        except Exception:
            pass

        return {
            "path": str(path.parent),
            "readme": str(path),
            "title": title,
            "tags": tags,
            "phase": phase,
            "links": links,
        }


# --- Interactive Navigator ---
class Navigator:
    def __init__(self, modules: List[Dict]):
        self.modules = modules
        self.filtered_modules = modules
        self.selected_index = 0
        self.active_phase = "All"

        self.bindings = KeyBindings()
        self.setup_bindings()

        self.search_field = TextArea(
            prompt="Search: ",
            style="class:search-field",
            multiline=False,
            search_field=True,
        )
        # Hook into buffer change for real-time filtering
        self.search_field.buffer.on_text_changed += self.on_search_change
        self.search_field.accept_handler = self.on_enter

    def setup_bindings(self):
        @self.bindings.add("c-c")
        @self.bindings.add("c-q")
        def _(event):
            event.app.exit()

        @self.bindings.add("up")
        def _(event):
            self.selected_index = max(0, self.selected_index - 1)

        @self.bindings.add("down")
        def _(event):
            self.selected_index = min(
                len(self.filtered_modules) - 1, self.selected_index + 1
            )

        for key, phase in [
            ("f1", "Phase 1"),
            ("f2", "Phase 2"),
            ("f3", "Phase 3"),
            ("f4", "All"),
        ]:

            @self.bindings.add(key)
            def _(event, p=phase):
                self.active_phase = p
                self.update_filter()

    def update_filter(self):
        query = self.search_field.text.lower()

        def match(m):
            if self.active_phase != "All" and m["phase"] != self.active_phase:
                return False
            if not query:
                return True
            searchable = f"{m['title']} {m['path']} {' '.join(m['tags'])}".lower()
            return query in searchable

        self.filtered_modules = [m for m in self.modules if match(m)]
        self.selected_index = 0

    def on_search_change(self, _):
        self.update_filter()

    def on_enter(self, buffer):
        if not self.filtered_modules:
            return

        selected = self.filtered_modules[self.selected_index]

        def run_action():
            console.clear()
            console.print(
                Panel(
                    f"[bold cyan]{selected['title']}[/bold cyan]\n[dim]{selected['path']}[/dim]",
                    title="Selected Module",
                )
            )
            console.print("\n[bold]Actions:[/bold]")
            console.print("[green][O][/green] Open in VS Code")
            console.print("[yellow][V][/yellow] View in Terminal (cat/markdown)")
            console.print("[blue][C][/blue] Copy Path")
            console.print("[magenta][W][/magenta] Open Documentation Links")
            console.print("[red][B][/red] Back")

            choice = input("\nSelect action [O/V/C/B]: ").strip().upper()
            choice = input("\nSelect action [O/V/C/W/B]: ").strip().upper()

            if choice == "O":
                subprocess.run(["code", selected["path"]])
            elif choice == "V":
                try:
                    with open(selected["readme"], "r") as f:
                        md = Markdown(f.read())
                    console.print(md)
                    input("\nPress Enter to continue...")
                except Exception as e:
                    print(f"Error: {e}")
                    time.sleep(2)
            elif choice == "C":
                # Try xclip for Linux
                try:
                    p = subprocess.Popen(
                        ["xclip", "-selection", "clipboard"], stdin=subprocess.PIPE
                    )
                    p.communicate(input=selected["path"].encode("utf-8"))
                    print("Path copied to clipboard!")
                except FileNotFoundError:
                    print("xclip not found. Path printed below:\n" + selected["path"])
                time.sleep(1)
            elif choice == "W":
                links = selected.get("links", [])
                if not links:
                    print("No links found in README.")
                    time.sleep(1)
                else:
                    print("\nFound Links:")
                    for i, link in enumerate(links):
                        print(f"[{i+1}] {link}")
                    
                    link_choice = input("\nSelect link to open (number) or Enter to cancel: ").strip()
                    if link_choice.isdigit():
                        idx = int(link_choice) - 1
                        if 0 <= idx < len(links):
                            try:
                                webbrowser.open(links[idx])
                                print(f"Opening {links[idx]}...")
                            except Exception as e:
                                print(f"Failed to open browser: {e}")
                            time.sleep(1)

        get_app().suspend_to_background(run_action)

    def get_formatted_list(self):
        lines = []
        max_h = 20
        start = max(0, self.selected_index - (max_h // 2))
        end = start + max_h

        for i, m in enumerate(self.filtered_modules[start:end]):
            idx = start + i
            style = "reverse" if idx == self.selected_index else ""

            p_color = "white"
            if m["phase"] == "Phase 1":
                p_color = "blue"
            elif m["phase"] == "Phase 2":
                p_color = "green"
            elif m["phase"] == "Phase 3":
                p_color = "yellow"

            tags = f"[{', '.join(m['tags'])}]" if m["tags"] else ""
            lines.append((f"{style} fg:{p_color}", f" {m['phase'][:7]} "))
            lines.append((f"{style}", f" {m['title']:<50} "))
            lines.append((f"{style} fg:gray", f" {tags} \n"))

        return lines

    def run(self):
        root = HSplit(
            [
                Window(
                    FormattedTextControl(
                        lambda: (
                            f" DevOps Navigator | Filter: {self.active_phase} (F1-F3, F4=All) | Found: {len(self.filtered_modules)} "
                        )
                    ),
                    height=1,
                    style="class:header",
                ),
                self.search_field,
                Window(FormattedTextControl(self.get_formatted_list)),
            ]
        )

        style = Style.from_dict(
            {"header": "bg:#333333 #ffffff bold", "search-field": "bg:#222222 #ffffff"}
        )
        Application(
            layout=Layout(root),
            key_bindings=self.bindings,
            style=style,
            full_screen=True,
        ).run()


if __name__ == "__main__":
    print("Scanning directory...")
    scanner = ModuleScanner(BASE_DIR)
    Navigator(scanner.scan()).run()
