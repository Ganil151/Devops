# 🛠️ Variables Challenges

## Challenge 1: The Fact Finder
**Objective**: Only run a task if the OS is Ubuntu.
1.  Create `facts.yml`.
2.  Use the `debug` module to print `ansible_distribution`.
3.  Add a `when` condition: `when: ansible_distribution == "Ubuntu"`.
4.  Run it on various hosts (or simulate by manually setting facts).

## Challenge 2: Local vs Global
**Objective**: Understand precedence.
1.  Define `my_var: global` in `group_vars/all.yml`.
2.  Define `my_var: playbook` in the Playbook `vars` section.
3.  Define `my_var: task` in the task itself.
4.  Print the variable. Which one wins? (Hint: Task > Playbook > Group Vars).

## Challenge 3: Registered Variables
**Objective**: Capture command output.
1.  Run `command: whoami`.
2.  Use `register: current_user`.
3.  Debug print: `"The user is {{ current_user.stdout }}"`.
