# 🛠️ Templates Challenges

## Challenge 1: The Login Banner
**Objective**: Dynamically generate `/etc/motd`.
1.  Create `motd.j2`.
2.  Content: "Welcome to {{ inventory_hostname }}. OS: {{ ansible_distribution }}".
3.  Deploy using `template` module.
4.  Verify content on remote host.

## Challenge 2: Config Looping
**Objective**: Generate a `hosts` file from inventory.
1.  Create `hosts.j2`.
2.  Loop through `groups['all']`.
3.  Line format: `{{ hostvars[item]['ansible_host'] }} {{ item }}`.
4.  Deploy to `/tmp/my_hosts`.

## Challenge 3: Conditional Config
**Objective**: Enable features based on RAM.
1.  In `app_config.j2`:
    ```
    {% if ansible_memtotal_mb > 2000 %}
    cache_size = 512M
    {% else %}
    cache_size = 64M
    {% endif %}
    ```
2.  Deploy and check the result based on your VM's RAM.
