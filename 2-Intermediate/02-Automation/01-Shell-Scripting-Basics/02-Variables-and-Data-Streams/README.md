# Variables and Data Streams

In Bash, data is handled through variables and standard streams. Understanding how to manipulate these is crucial for building dynamic automation.

## 📦 Variables and Scope

### Definition and Access
Variables are defined without spaces around the `=` sign. Use double quotes when accessing them to prevent "Word Splitting" and "Globbing".

```bash
NAME="DevOps"
echo "Hello, $NAME"   # Use quotes!
```

-   **User-defined Variables**: `APP_PORT=8080`
-   **Environment Variables**: `export DB_URL="jdbc:mysql://..."` (Available to child processes).
-   **Special Variables**:
    -   `$?`: Exit status of the last command (0 for success).
    -   `$$`: Process ID (PID) of the current shell.
    -   `$#`: Number of arguments passed to the script.

## 🌊 Standard Streams & Redirection

Bash manages three primary data streams for every process.

| Stream | Name | File Descriptor | Description |
| :--- | :--- | :--- | :--- |
| **stdin** | Standard Input | 0 | Data sent to the program (e.g., keyboard). |
| **stdout** | Standard Output | 1 | Normal output from the program. |
| **stderr** | Standard Error | 2 | Error messages or diagnostic info. |

### Redirection Operators
-   **Overwrite stdout**: `ls > files.txt`
-   **Append stdout**: `echo "new log" >> app.log`
-   **Redirect stderr**: `command 2> error.log`
-   **Redirect both to same file**: `command &> all.log`
-   **Discard output**: `command > /dev/null 2>&1` (The "Black Hole").

## 🔗 Pipes and Command Substitution

-   **Pipes (`|`)**: Send the output of one command as the input to another.
    -   `cat logs.txt | grep "ERROR" | wc -l`
-   **Command Substitution (`$()`)**: Capture the output of a command into a variable.
    -   `CURRENT_DIR=$(pwd)`

---

## 📖 Stories from the Field: The Silent Failure

**Scenario**: A script was designed to backup a database and then send an email. The backup command failed due to disk space, but the script still sent an "Email: Backup Successful" message.
**Discovery**: The developer used `backup_cmd > backup.log`. Since only `stdout` was redirected, the errors (which go to `stderr`) appeared on the console but weren't captured or checked. The script continued blindly.
**Resolution**: Modified the script to capture `stderr` and check the exit code:
```bash
backup_cmd > backup.log 2>&1
if [ $? -ne 0 ]; then
    echo "Backup failed!" | mail -s "Critical Failure" admin@example.com
    exit 1
fi
```
**Prevention**: Always redirect `stdout` and `stderr` appropriately in automated tasks and *always* check `$?`.

---

## ❓ Interview Questions

1.  **What is the difference between `VARIABLE="v"` and `export VARIABLE="v"`?**
    *   *Answer*: The first is a local shell variable, available only in the current process. `export` makes it an environment variable, available to any child processes or scripts started from that shell.
2.  **How do you redirect standard error to standard output?**
    *   *Answer*: Use `2>&1`.
3.  **What is `/dev/null`?**
    *   *Answer*: A special "null device" file that discards all data written to it (like a black hole).
4.  **What happens if you use single quotes `'` instead of double quotes `"` for a variable?**
    *   *Answer*: Single quotes are literal; variables inside them are not expanded (e.g., `'$NAME'` prints the literal characters `$NAME`).
5.  **How do you find the PID of the last backgrounded process?**
    *   *Answer*: Check the variable `$!`.

---

## 🧠 Quiz

1.  **Which file descriptor represents `stderr`?** `(2)`
2.  **How do you append the output of a command to an existing file?** `(>>)`
3.  **What special variable holds the exit status of the last command?** `($?)`
4.  **True/False: Spaces are allowed around the `=` when defining a variable.** `(False)`
5.  **Which operator is used to send output from one command to another?** `(| - pipe)`
