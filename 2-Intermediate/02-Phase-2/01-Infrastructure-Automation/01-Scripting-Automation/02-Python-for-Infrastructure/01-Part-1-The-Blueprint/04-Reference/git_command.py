import subprocess
import time


def run_git_command():
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
          

        subprocess.run(
            ["git", "add", "."],
            capture_output=True,
            text=True,
            check=True,
            timeout=10,
        )

        commit_message = input("Input your commit message: ")

        subprocess.run(
            ["git", "commit", "-m", commit_message],
            capture_output=True,
            text=True,
            check=True,
            timeout=10,
        )

        time.sleep(1)

        subprocess.run(
            ["git", "push"],
            capture_output=True,
            text=True,
            check=True,
            timeout=10,
        )

        return res.stdout.strip()
    except FileNotFoundError:
        print("Error: 'git' command not found. Is it installed?")
    except subprocess.CalledProcessError as e:
        print(f"Git Failed: {e.stderr}")
    except subprocess.TimeoutExpired:
        print("Git timed out")


if __name__ == "__main__":
    print(run_git_command())
