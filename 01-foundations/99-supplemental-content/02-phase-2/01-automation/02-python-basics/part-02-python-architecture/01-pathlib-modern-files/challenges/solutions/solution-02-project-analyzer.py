"""
Solution: Project File Analyzer
"""
from pathlib import Path
from collections import defaultdict

def analyze_project(project_dir):
    """Analyze a project directory structure."""
    root = Path(project_dir)
    if not root.exists():
        return {}
        
    # defaultdict for extensions logic
    ext_data = defaultdict(lambda: {"count": 0, "size_kb": 0.0})
    empty_dirs = []
    
    for item in root.rglob("*"):
        if item.is_file():
            ext = item.suffix.lower() or "(no extension)"
            ext_data[ext]["count"] += 1
            ext_data[ext]["size_kb"] += item.stat().st_size / 1024
        elif item.is_dir():
            # Check if directory is empty
            if not any(item.iterdir()):
                empty_dirs.append(str(item.relative_to(root)))
                
    return {
        "extensions": dict(ext_data),
        "empty_dirs": empty_dirs
    }

if __name__ == "__main__":
    import json
    print(json.dumps(analyze_project("."), indent=2))
