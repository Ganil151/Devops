# 🛠️ Fundamentals Challenges

## Challenge 1: The Ping Test
**Objective**: Verify connectivity to "localhost".
1.  Create a simple inventory file `hosts`:
    ```ini
    [local]
    localhost ansible_connection=local
    ```
2.  Run the ad-hoc command to ping:
    ```bash
    ansible all -i hosts -m ping
    ```
3.  **Success Condition**: You see `"ping": "pong"`.

## Challenge 2: Ad-Hoc Command
**Objective**: Check disk space without a playbook.
1.  Use the `command` or `shell` module.
2.  Run `df -h` on your localhost.
3.  Command: `ansible local -i hosts -m command -a "df -h"`

## Challenge 3: Configuration Override
**Objective**: Understand `ansible.cfg`.
1.  Run `ansible --version` and note the "config file" path.
2.  Create a local `ansible.cfg` that sets `forks = 20`.
3.  Run `ansible --version` again to verify it picked up the local config.
