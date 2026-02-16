# 🛠️ Strict Mode Challenges

## Challenge 1: The Crash Test Dummy
Create a script named `crash_test.sh` that attempts to:
1.  Read a variable that hasn't been defined.
2.  Pipeline a failing command into a success command (e.g., `ls /nonexistent | grep "foo"`).

**Goal**:
- Run it *without* strict mode and observe the output (it likely continues or prints garbage).
- Add `set -euo pipefail` and observe how it fails fast.

## Challenge 2: The Resilient Cleaner
Write a script that:
1.  Accepts a directory path as an argument.
2.  Deleting files in that directory older than 7 days (`find ... -delete`).
3.  **Constraint**: It MUST use `set -u`.
4.  **Test**: Run it without providing an argument. Does it error out safely before running `find`?
