# 🛠️ System Ops Challenges

## Challenge 1: The Directory Walker
**Objective**: Build a script that recursively scans a directory and finds large files.
1.  Use `pathlib.Path.rglob("*")` to walk the tree.
2.  Find files larger than 1MB.
3.  Print their absolute path and size in MB.
4.  **Bonus**: Ignore hidden directories (starting with `.`).

## Challenge 2: Log Rotator
**Objective**: Simulate a log rotation mechanism.
1.  Create a file `app.log`.
2.  Function `rotate_log(file_path)`:
    - If file exists, rename it to `app.log.1`.
    - If `app.log.1` exists, rename to `app.log.2` (and so on, up to 5).
    - Create a new empty `app.log`.
3.  Use `shutil.move`.

## Challenge 3: Process Killer
**Objective**: Find and kill a process by name (Simulated).
1.  Since we shouldn't kill real processes, just find them.
2.  Use `subprocess.run(["ps", "-aux"], ...)` (Linux) or `tasklist` (Windows).
3.  Parse the output line by line.
4.  Find a process named "python" or "chrome".
5.  Print its PID.
