import subprocess
import sys


def run_git_command(message=None):
    try:
        res = subprocess.run(
            ["git", "status", "--porcelain"],
            capture_output=True,
            text=True,
            check=True,
            timeout=10,
        )

        if not res.stdout.strip():
            print("No changes to commit.")
            return "No changes"

        print("Staging changes...")
        subprocess.run(
            ["git", "add", "."],
            capture_output=True,
            text=True,
            check=True,
            timeout=10,
        )

        if message:
            commit_message = message
        elif len(sys.argv) > 1:
            commit_message = " ".join(sys.argv[1:])
        else:
            commit_message = input("Input your commit message: ")

        subprocess.run(
            ["git", "commit", "-m", commit_message],
            capture_output=True,
            text=True,
            check=True,
            timeout=10,
        )

        print("Pushing changes...")
        push_res = subprocess.run(
            ["git", "push"],
            capture_output=True,
            text=True,
            check=True,
            timeout=30,
        )

        return push_res.stdout.strip() or "Push Successful"
    except FileNotFoundError:
        print("Error: 'git' command not found. Is it installed?")
    except subprocess.CalledProcessError as e:
        print(f"Git Failed: {e.stderr}")
    except subprocess.TimeoutExpired:
        print("Git timed out")


if __name__ == "__main__":
    print(run_git_command())
