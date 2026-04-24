"""
Challenge: Git Status Checker
Scenario: You want to automate your development workflow by checking if 
your current repository has uncommitted changes before performing a task.

TODO: Implement `check_git_status(repo_path)`.
1. Use `subprocess.run` to execute `git status --porcelain`.
2. Ensure the command is run inside the `repo_path` (use `cwd`).
3. If the output is empty, the repository is 'clean'.
4. If there is output, the repository has 'uncommitted changes'.
5. Handle the case where the directory is not a git repository.
"""
import subprocess
from pathlib import Path

def check_git_status(repo_path):
    """
    Checks if a git repository has uncommitted changes.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test on the current directory
    status = check_git_status(".")
    if "error" in status:
        print(f"Error: {status['error']}")
    else:
        print(f"Repository is clean: {status['clean']}")
        if not status['clean']:
            print(f"Changes found: {status['total_changes']}")
Ref: challenge_02_git_checker.py
"""
