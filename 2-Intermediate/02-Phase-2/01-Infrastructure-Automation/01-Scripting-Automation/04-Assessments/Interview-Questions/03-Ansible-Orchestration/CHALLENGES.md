# 🛠️ Ansible Interview Tasks

## Challenge 1: The Multi-tier Playbook
**Objective**: Targeting groups.
1.  Play 1: Install `haproxy` on `loadbalancers`.
2.  Play 2: Install `apache2` on `webservers`.
3.  Play 3: Install `mysql-server` on `dbservers`.

## Challenge 2: Sensitive Deployment
**Objective**: Secrets.
1.  Use `ansible-vault` to encrypt a variable file.
2.  Write a playbook that reads the password from the vault to configure a database.
3.  Ensure `no_log: true` is used.

## Challenge 3: Conditional Logic
**Objective**: Efficiency.
1.  Install `htop`.
2.  Only if the OS is a Debian variant (`ansible_os_family == "Debian"`).
3.  Add a `debug` statement that prints the server memory.
