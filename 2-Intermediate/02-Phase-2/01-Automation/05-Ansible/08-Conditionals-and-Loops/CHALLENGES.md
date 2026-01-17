# 🛠️ Logic Challenges

## Challenge 1: The Loop Reformer
**Objective**: Replace repeated tasks with a loop.
1.  Original Code:
    ```yaml
    - apt: name=git
    - apt: name=curl
    - apt: name=vim
    ```
2.  Task: Rewrite using `loop`.

## Challenge 2: OS Selector
**Objective**: Install `apache2` on Debian and `httpd` on RedHat.
1.  Use `ansible_os_family` fact.
2.  Use two tasks with `when` clauses.
3.  Task 1: Install `apache2` when Debian.
4.  Task 2: Install `httpd` when RedHat.

## Challenge 3: Until Loop (Retries)
**Objective**: Wait for a file to appear.
1.  Use `stat` module on `/tmp/wait_for_me`.
2.  Use `register`.
3.  Add `until: result.stat.exists`
4.  Add `retries: 5` and `delay: 2`.
