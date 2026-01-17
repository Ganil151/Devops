# Shell Scripting Interview Prep

Basic shell scripting is the foundation of DevOps. You are expected to know Bash strict mode, redirection, and text processing.

## 🎤 Top 10 Questions

1.  **What is the difference between `set -e` and `set -u`?**
    - *Answer*: `set -e` exits on any command error. `set -u` exits if you try to use an undefined variable (preventing `rm -rf $VAR/` from deleting root if VAR is empty).
2.  **How do you find the exit code of the last command?**
    - *Answer*: Using `$?`.
3.  **Explain the importance of the Shebang.**
    - *Answer*: `#!/bin/bash` ensures the script is executed by the correct shell, regardless of the user's current shell.
4.  **How do you capture the output of a command into a variable?**
    - *Answer*: Using backticks `` `cmd` `` or modern command substitution `$(cmd)`.
5.  **What is the purpose of `2>&1`?**
    - *Answer*: It redirects stderr (2) to the same location as stdout (1).
6.  **How do you loop through a list of files?**
    - *Answer*: `for file in *.txt; do ... done`.
7.  **What does `xargs` do?**
    - *Answer*: It converts standard input into arguments for another command, allowing for parallelization or batch processing.
8.  **Explain `grep` vs `sed` vs `awk`.**
    - *Answer*: `grep` is for filtering lines; `sed` is for stream editing (search/replace); `awk` is for field-based processing (columns).
9.  **How do you check if a file exists in a script?**
    - *Answer*: `[[ -f "filename" ]]`.
10. **What is a "Here Document" (EOF)?**
    - *Answer*: A way to pass multiple lines of input to a command directly within the script.

---

## 🛠️ Performance Task
**Task**: Build a script that finds all `.log` files in `/tmp` and moves them to `/tmp/backup` only if they are older than 7 days.

[Check challenges for more tasks.](./CHALLENGES.md)
