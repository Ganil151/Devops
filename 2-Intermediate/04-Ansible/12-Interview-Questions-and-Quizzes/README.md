# Ansible Interview Questions & Quiz

Prepare for your DevOps interviews and test your Ansible mastery with these questions and a comprehensive quiz.

---

## 🎤 Top 20 Ansible Interview Questions

### 🔰 Basic Questions
1. **What is Ansible and what is its primary architecture?**
   - *Answer:* Ansible is an open-source automation tool for configuration management, application deployment, and task automation. It follows an **agentless** architecture, using SSH to communicate with managed nodes.
2. **What does "Idempotence" mean in Ansible?**
   - *Answer:* It means that running the same task multiple times will result in the same state, and Ansible only makes changes if the system is not already in the desired state.
3. **What is an "Inventory" file?**
   - *Answer:* A file (usually `hosts.ini` or YAML) that lists the managed nodes, their IP addresses, and the groups they belong to.
4. **What is a "Playbook"?**
   - *Answer:* A YAML file that defines a series of "plays," each containing a set of tasks to be executed on a specific group of hosts.
5. **What is the difference between a Module and a Task?**
   - *Answer:* A module is the actual "tool" (code) that performs the work (e.g., `apt`, `copy`, `service`), while a task is the execution of a module with specific parameters.

### ⚙️ Intermediate Questions
6. **What are "Handlers" and when do they run?**
   - *Answer:* Handlers are special tasks that only run when "notified" by another task. They typically run at the end of a play and are used for actions like restarting services after a config change.
7. **Explain the purpose of "Ansible Roles".**
   - *Answer:* Roles provide a way to group variables, tasks, files, templates, and handlers into a reusable structure, making large-scale automation manageable and modular.
8. **What is "Ansible Vault"?**
   - *Answer:* A feature that allows you to encrypt sensitive data (like passwords or API keys) within variables or entire files, so they can be safely stored in version control.
9. **How do you handle loops in Ansible?**
   - *Answer:* Using the `loop` keyword (which replaced the older `with_items`), allowing you to iterate over a list of items and execute a task for each.
10. **What is the "Gathering Facts" stage?**
    - *Answer:* The first thing Ansible does when running a play is collect system information (facts) from the managed nodes (e.g., OS version, IP addresses, disk space) using the `setup` module.

### 🚀 Advanced-ish Questions
11. **How do you perform error handling in Ansible?**
    - *Answer:* Using `ignore_errors: yes`, `failed_when` to define custom failure criteria, or `block/rescue/always` for try-catch style logic.
12. **What is the `become` keyword used for?**
    - *Answer:* It allows Ansible to execute tasks with elevated privileges (usually `sudo`) on the managed node.
13. **How do you use "Variables" across different scopes?**
    - *Answer:* Variables can be defined in playbooks, roles (`vars` or `defaults`), inventory (`group_vars`, `host_vars`), or passed via the command line (`-e`).
14. **What is a "Template" and which engine does Ansible use?**
    - *Answer:* A dynamic file that contains variables and logic. Ansible uses the **Jinja2** templating engine.
15. **How do you run a task on the Control Node instead of the managed node?**
    - *Answer:* Using `delegate_to: localhost` or `local_action`.
16. **Explain the difference between `vars` and `defaults` in a role.**
    - *Answer:* `defaults` have the lowest priority and are intended to be easily overridden. `vars` have a higher priority and are intended for central role logic.
17. **How do you limit a playbook run to a specific host?**
    - *Answer:* Use the `--limit` flag: `ansible-playbook site.yml --limit host-01`.
18. **What is "Check Mode" and how do you use it?**
    - *Answer:* Running Ansible with the `--check` flag. It simulates the playbook execution and shows what *would* change without actually making any changes.
19. **What is a "Dynamic Inventory"?**
    - *Answer:* A script or plugin that pulls the list of managed hosts from an external source (like AWS EC2, Azure, or GCP) in real-time.
20. **How do you force a task to run even if a previous task failed?**
    - *Answer:* Use the `ignore_errors: yes` attribute on the failing task, or put the subsequent task in an `always` block.

---

## 🧠 Ansible Knowledge Quiz (20+ Questions)

**1. Which command is used to ping all hosts in the default inventory?**
- A) `ansible-ping all`
- B) `ansible all -m ping`
- C) `ansible-playbook ping.yml`
- D) `ansible-inventory ping`
*Answer: B*

**2. What is the default port for SSH, which Ansible uses?**
- A) 80
- B) 443
- C) 22
- D) 21
*Answer: C*

**3. In a playbook, which keyword is used to escalate privileges?**
- A) `sudo: yes`
- B) `root: true`
- C) `become: yes`
- D) `elevate: true`
*Answer: C*

**4. Which directory in a role typically contains the main execution logic?**
- A) `vars/`
- B) `tasks/`
- C) `meta/`
- D) `files/`
*Answer: B*

**5. How do you trigger a handler?**
- A) Using the `trigger` keyword
- B) Using the `notify` keyword in a task
- C) Handlers run automatically after every task
- D) Using the `call` keyword
*Answer: B*

**6. Which module is used to ensure a service is running?**
- A) `run`
- B) `systemd`
- C) `shell`
- D) `service`
*Answer: D*

**7. How do you encrypt a file with Ansible Vault?**
- A) `ansible-vault secure file.yml`
- B) `ansible-vault encrypt file.yml`
- C) `ansible-vault lock file.yml`
- D) `ansible-vault hidden file.yml`
*Answer: B*

**8. Which of these is NOT a valid Ansible variable name?**
- A) `my_var`
- B) `Var123`
- C) `my-var` (Hyphens are generally not allowed in HCL/YAML variable names for Ansible)
- D) `_var`
*Answer: C*

**9. What character is used to denote the start of an Ansible playbook?**
- A) `###`
- B) `---`
- C) `...`
- D) `***`
*Answer: B*

**10. Which module would you use to copy a file from the control node to a managed node?**
- A) `move`
- B) `fetch`
- C) `copy`
- D) `transfer`
*Answer: C*

**11. What is the command to check a playbook's syntax?**
- A) `ansible-playbook --check-syntax site.yml`
- B) `ansible-playbook site.yml --syntax-check`
- C) `ansible-check site.yml`
- D) `ansible-lint site.yml`
*Answer: B*

**12. Which loop keyword is the modern standard in Ansible?**
- A) `with_items`
- B) `foreach`
- C) `loop`
- D) `iterate`
*Answer: C*

**13. What happens if you run a playbook in `--check` mode?**
- A) It deletes the state file
- B) It reports changes that would be made without actually making any
- C) It only checks for syntax errors
- D) It runs only the handlers
*Answer: B*

**14. Which file is used to configure Ansible's behavior (like the path to the inventory)?**
- A) `ansible.xml`
- B) `setup.json`
- C) `ansible.cfg`
- D) `global.yml`
*Answer: C*

**15. How do you ignore an error in a specific task?**
- A) `force: yes`
- B) `ignore_errors: yes`
- C) `skip_on_fail: true`
- D) `continue: true`
*Answer: B*

**16. What does the `stat` module do?**
- A) Prints system statistics
- B) Checks the status/existence of a file or directory
- C) Restarts the server
- D) Shows active connections
*Answer: B*

**17. Which module allows you to run a raw shell command on the target?**
- A) `command`
- B) `shell`
- C) `raw`
- D) All of the above
*Answer: D*

**18. What is the difference between `command` and `shell` modules?**
- A) They are identical
- B) `shell` supports environment variables and pipes; `command` does not
- C) `command` is faster
- D) `shell` is more secure
*Answer: B*

**19. How do you pull a file FROM a managed node to the control node?**
- A) `copy`
- B) `fetch`
- C) `pull`
- D) `get`
*Answer: B*

**20. Which directory in a role contains variable definitions with the LOWEST priority?**
- A) `vars/`
- B) `defaults/`
- C) `meta/`
- D) `env/`
*Answer: B*

---

## 🔝 Summary
These questions and quiz cover the essential pillars of Ansible. Use them to solidify your foundations as you move toward advanced automation!
