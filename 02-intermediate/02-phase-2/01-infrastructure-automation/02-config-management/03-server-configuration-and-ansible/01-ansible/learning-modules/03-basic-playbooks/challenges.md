# 🛠️ Playbook Challenges

## Challenge 1: The First Touch
**Objective**: Create a file on the managed node.
1.  Create `touch.yml`.
2.  Target: `localhost`.
3.  Task: Use the `file` module.
4.  Path: `/tmp/ansible_was_here`.
5.  State: `touch`.

## Challenge 2: Package Installer
**Objective**: Install `git`.
1.  Create `install.yml`.
2.  Task: Use `package` module (works on apt/yum).
3.  Name: `git`.
4.  State: `present`.
5.  Run with and without `become: yes` (Observe failure if not root).

## Challenge 3: Multi-Play Playbook
**Objective**: Target different groups in one file.
1.  Play 1: `hosts: web` -> Install Nginx.
2.  Play 2: `hosts: db` -> Install Postgresql-client.
3.  Run the full playbook.
