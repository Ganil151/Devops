# 🛠️ Remote Execution Challenges

## Challenge 1: Remote Uptime Checker
**Objective**: Check uptime of a list of servers.
1.  List: `["server1", "server2"]`.
2.  Loop through them.
3.  Use Paramiko to run `uptime`.
4.  Capture stdout.
5.  If connection fails, log "Host Down".

## Challenge 2: Secure SFTP Uploader
**Objective**: Upload a config file.
1.  Connect using `paramiko.Transport` or `client.open_sftp()`.
2.  Use `sftp.put(local_path, remote_path)`.
3.  Verify the file exists remotely using `sftp.stat(remote_path)`.
4.  Handle `PermissionError`.

## Challenge 3: Agentless Patcher
**Objective**: Run updates.
1.  Command: `sudo apt-get update`.
2.  Wait for it to finish.
3.  Print the last 5 lines of output.
