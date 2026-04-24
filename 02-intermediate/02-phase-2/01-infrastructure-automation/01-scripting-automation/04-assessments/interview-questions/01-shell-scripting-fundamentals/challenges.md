# 🛠️ Shell Interview Tasks

## Challenge 1: Log Rotator
**Objective**: Write a script that archives logs.
1.  Source Dir: `/var/log/myapp`.
2.  Action: If a file is larger than 1MB, compress it using `gzip`.
3.  Verification: Ensure the exit code of `gzip` is checked.

## Challenge 2: User Audit
**Objective**: Parse `/etc/passwd`.
1.  Print all users who have a custom shell (not `/bin/false` or `/usr/sbin/nologin`).
2.  Use `awk`.

## Challenge 3: Parallel Pinger
**Objective**: Ping 10 servers in parallel.
1.  Input: `ips.txt`.
2.  Tool: `xargs -P 5`.
3.  Expected: A report showing which IPs are UP and which are DOWN.
