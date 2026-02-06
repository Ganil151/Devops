# 🛠️ SRE Interview Tasks

## Challenge 1: The Atomic Updater
**Objective**: Build an atomic file update script.
1.  Read a config file.
2.  Write a change to a temp file.
3.  Use `os.replace` to commit the change.

## Challenge 2: The Safety Guard
**Objective**: Defensive programming.
1.  Script that deletes a backup folder.
2.  Check for disk space first.
3.  Check if the folder has more than 10 files (Safety guard).
4.  If it has less, fail.

## Challenge 3: Structured Logger
**Objective**: Observability.
1.  Log every action as a JSON object.
2.  Fields: `timestamp`, `level`, `message`, `host`.
3.  Print to a file.
