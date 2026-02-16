"""
Challenge: Project File Analyzer
Scenario: You want to generate a report of a project's directory structure.

TODO: Implement `analyze_project(project_dir)`.
1. Recursively walk through all files using `rglob("*")`.
2. Categorize files by their extension (`.py`, `.md`, `.json`, etc.).
3. Track the count and total size (in KB) for each extension.
4. Identify any empty directories.
5. Return a summary dictionary.
"""
from pathlib import Path
from collections import defaultdict

def analyze_project(project_dir):
    """
    Analyzes file extensions and sizes in a directory.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    stats = analyze_project(".")
    print("Project Stats:")
    for ext, data in stats.get('extensions', {}).items():
        print(f"  {ext}: {data['count']} files ({data['size_kb']:.2f} KB)")
