# Ansible Real-Life Scenarios

Gain practical experience by understanding how to solve common operational challenges using Ansible.

---

## 🛠️ Scenario 1: Zero-Downtime Fleet Patching
**Setting:** You have a cluster of 10 web servers behind a load balancer. You need to apply OS security updates and restart the servers if necessary, but you must keep the application running during the process.

**The Strategy:**
1. Use `serial: 1` in your playbook header. This tells Ansible to process only one server at a time.
2. **Tasks:**
   - Remove the current server from the Load Balancer (using a local action or LB module).
   - Run `apt update` and `apt upgrade`.
   - Check if a reboot is needed (using the `reboot` module).
   - Run a smoke test to ensure Nginx is back up.
   - Add the server back to the Load Balancer.
3. Ansible moves to the next server only after the current one is successfully updated and re-added.

---

## 🏗️ Scenario 2: Multi-Environment LAMP Stack
**Setting:** You need to deploy a LAMP (Linux, Apache, MySQL, PHP) stack to `Dev`, `Staging`, and `Prod`. Each environment has different database passwords and memory limits.

**The Strategy:**
1. Create a `group_vars` directory.
2. Create separate files: `dev.yml`, `staging.yml`, `prod.yml`.
3. Use **Ansible Vault** to encrypt the database passwords in each file.
4. Use templates (`vhost.conf.j2`) to manage Apache configurations with variables like `{{ web_port }}` and `{{ memory_limit }}`.
5. Apply the playbook using the environment inventory: `ansible-playbook site.yml -i inventory/prod`.

---

## 🕵️ Scenario 3: Investigating "UNREACHABLE" Hosts
**Setting:** Your weekly automation script fails on 5 out of 50 servers with the error `UNREACHABLE! => {"msg": "Failed to connect to the host via ssh"}`.

**The Investigation:**
1. **Manual Check:** Can you manually `ssh user@ip`? If not, it's a network or key issue.
2. **Key Scan:** Ensure the target's public key is in your `known_hosts` (batch run `ssh-keyscan`).
3. **User Sync:** Are you using the correct `ansible_user`? Some cloud images use `ubuntu`, some `ec2-user`, some `admin`.
4. **Permissions:** Does the user have `sudo` access without a password, or did you provide the `become_pass`?

**Real-world tool:** Use `ansible all -m ping -v` (verbose mode) to see the exact SSH command Ansible is trying to execute.

---

## 🔄 Scenario 4: Rolling Back a Failed Deployment
**Setting:** You just deployed a new version of your application code using the `git` module, but the application is failing health checks.

**The Strategy:**
1. Always tag your releases or use specific git commits/branches in your variables.
2. Create a "Rollback" playbook (or a variable-driven one).
3. **Tasks:**
   - Switch the `version` variable back to the previous stable git hash.
   - Run the deploy playbook again.
   - Because Ansible is **idempotent**, it will see that the files are different from the "current" (broken) version and overwrite them with the stable version.
   - Restart the service and verify health.

---

## 🌩️ Scenario 5: Managing Dynamic Cloud Assets
**Setting:** Your AWS Auto Scaling group just spawned 5 new instances. You need to configure them immediately.

**The Strategy:**
1. Stop using static `hosts.ini` files.
2. Configure the **AWS EC2 Dynamic Inventory plugin** (`aws_ec2.yml`).
3. Filter your hosts by tags: `keyed_groups: - prefix: tag key: Environment`.
4. Run your playbook against the tag-group: `ansible-playbook web.yml -l tag_Environment_prod`.
5. Ansible automatically stays in sync with your infrastructure as it grows and shrinks.

---

## 💡 Key Takeaway
Ansible is most powerful when it handles the **lifecycle** of a server, not just the initial setup. Mastering error handling, dynamic inventories, and serial execution is what separates a beginner from an intermediate engineer.
