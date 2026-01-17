# 📡 I/O Challenges

## Challenge 1: The Automator
Create a script that generates a Python script (`hello.py`) using a **Here Document**.
1.  The Python script should contain: `print("Hello from generated code")`.
2.  Your Bash script should:
    - Create the file.
    - Make it executable (`chmod +x`).
    - Run it.

## Challenge 2: The Log Merger
You have two log files with timestamps.
1.  Use **Process Substitution** to sort both files and merge them into a single stream.
2.  Hint: `sort -m <(sort file1) <(sort file2)`
