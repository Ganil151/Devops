# 🛠️ Roles Challenges

## Challenge 1: The "Apache" Role
**Objective**: Refactor a playbook into a role.
1.  Create `roles/apache`.
2.  Move installation tasks to `roles/apache/tasks/main.yml`.
3.  Move handlers to `roles/apache/handlers/main.yml`.
4.  Run it via `site.yml`.

## Challenge 2: Role Variables
**Objective**: Override defaults.
1.  In `roles/apache/defaults/main.yml`, set `http_port: 80`.
2.  In `site.yml`, call the role but pass `http_port: 8080`.
3.  Verify which port is used (Dry run or check template).

## Challenge 3: Ansible Galaxy
**Objective**: Use a community role.
1.  Run `ansible-galaxy install geerlingguy.docker`.
2.  Create a playbook to use it.
3.  (Optional) Run it to install Docker on your lab node.
