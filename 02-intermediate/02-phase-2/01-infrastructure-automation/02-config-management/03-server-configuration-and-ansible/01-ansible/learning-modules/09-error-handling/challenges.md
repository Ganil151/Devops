# 🛠️ Error Handling Challenges

## Challenge 1: Ignore Errors
**Objective**: Run a command but don't stop if it fails.
1.  Task: `command: /bin/false`.
2.  Add `ignore_errors: yes`.
3.  Add a debug task after it ("I am still running").
4.  Verify the playbook continues.

## Challenge 2: The Rescue Mission
**Objective**: Implement a fallback.
1.  Block: Try to `git clone` from a fake URL.
2.  Rescue: `git clone` from a backup URL (use a real one like a public repo).
3.  Verify the playbook succeeds using the backup.

## Challenge 3: Force Failure
**Objective**: Fail if output is wrong.
1.  Run `command: echo "error"`.
2.  Register: `res`.
3.  Add `failed_when: "'error' in res.stdout"`.
