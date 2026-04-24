# 🛡️ Robust Execution Challenges

## Challenge 1: The Crash Test
Create a script that:
1.  Creates a temporary file.
2.  Starts a background `sleep 100` process.
3.  **Fails intentionally** on line 5 (e.g., `ls /nonexistent`).
4.  **Requirement**: use a `trap` to ensure the temporary file is deleted AND the background sleep process is killed when the script crashes.

## Challenge 2: The Double-Start Preventer
Write a script that attempts to run for 10 seconds.
1.  Use `flock` to ensure only one instance runs.
2.  Open two terminals.
3.  Run the script in Terminal 1.
4.  Immediately run it in Terminal 2.
5.  Terminal 2 should exit immediately with an error message.

## Challenge 3: Checksum Idempotency
Write a deployment function `deploy_file Source Dest`.
1.  It should check if `Dest` exists.
2.  If it exists, compare `md5sum` or `sha256sum`.
3.  If hashes match, print "No Change" and return.
4.  If they differ, copy and print "Updated".
