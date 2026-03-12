"""
Solution: Git Status Checker
"""
import subprocess
from pathlib import Path

def check_git_status(repo_path):
    """Check if a git repository has uncommitted changes."""
    repo = Path(repo_path).absolute()
    
    try:
        # Run git status --porcelain (gives machine-readable output)
        result = subprocess.run(
            ["git", "status", "--porcelain"],
            capture_output=True,
            text=True,
            cwd=repo,
            check=True
        )
        
        # If stdout is empty, there are no changes
        lines = result.stdout.strip().split('\n') if result.stdout.strip() else []
        
        return {
            "clean": len(lines) == 0,
            "total_changes": len(lines),
            "output": result.stdout
        }
        
    except subprocess.CalledProcessError as e:
        return {"error": f"Command failed: {e.stderr.strip()}"}
    except FileNotFoundError:
        return {"error": "Git command not found or directory invalid"}

if __name__ == "__main__":
    print(check_git_status("."))
