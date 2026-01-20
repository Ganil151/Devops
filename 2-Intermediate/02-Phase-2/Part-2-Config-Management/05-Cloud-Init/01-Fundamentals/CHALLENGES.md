# 🛠️ Cloud-Init Challenges

## Challenge 1: The Multi-User System
**Objective**: Setup distinct users.
1.  Create `users.yaml`.
2.  Add two users: `deploy` (has sudo) and `viewer` (no sudo, shell restricted to `/bin/rbash`).
3.  Add SSH keys for both.

## Challenge 2: Network Configuration
**Objective**: Set hostname.
1.  Use the `hostname` module.
2.  Set the hostname to `web-server-01`.
3.  Set the `fqdn` to `web-server-01.dev.local`.

## Challenge 3: Disk Partitioning
**Objective**: Prepare storage.
1.  Research the `disk_setup` and `fs_setup` modules.
2.  Write a cloud-config that formats an attached disk (`/dev/sdb`) with `ext4` and mounts it to `/data`.
