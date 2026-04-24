# 🛠️ Failure Handling Challenges

## Challenge 1: Pre-flight Resource Check
**Objective**: Build a "Safety Guard" for an installation script.
1.  Check if current user is Root (`os.getuid() == 0`).
2.  Check if the system has at least 500MB free disk space.
3.  Check if `git` is installed (`shutil.which('git')`).
4.  If any check fails, print exactly which one failed and exit with code 1.

## Challenge 2: The Manual Rollback
**Objective**: Undo changes if a task fails.
1.  Task: Rename a directory `data` to `data_old`.
2.  Task: Create a new directory `data`.
3.  Simulate a failure in Task 3 (e.g., creating a file inside `data` fails).
4.  **Rescue**: If failure occurs, delete the new `data` and rename `data_old` back to `data`.
5.  Print "Rollback complete".

## Challenge 3: Timeout Guard
**Objective**: Prevent a script from hanging forever.
1.  Use the `subprocess.run(..., timeout=5)` feature.
2.  Try running a command that sleeps for 10 seconds (`sleep 10`).
3.  Catch the `subprocess.TimeoutExpired` exception.
4.  Log "Process took too long, killing it" and exit cleanly.
