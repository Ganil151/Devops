# 🛠️ Custom Module Challenges

## Challenge 1: The "Hello World" Module
**Objective**: Build a module that simply returns a greeting.
1.  Create `library/hello.py`.
2.  The module should take one argument: `name`.
3.  It should return `{"message": "Hello, <name>!"}`.
4.  Test it using a playbook:
    ```yaml
    - hosts: localhost
      tasks:
        - hello:
            name: "DevOps Engineer"
          register: res
        - debug: var=res.message
    ```

## Challenge 2: System Info Tool
**Objective**: Create a module that returns the current system load.
1.  Import `os`.
2.  Use `os.getloadavg()`.
3.  Return the 1, 5, and 15 minute loads as a dictionary.
4.  Ensure `changed` is always `false` (since it's a read-only check).

## Challenge 3: Fail Gracefully
**Objective**: Add validation to your module.
1.  In your `my_custom_module.py`, check if the provided `path` is an absolute path (starts with `/`).
2.  If not, use `module.fail_json(msg="Path must be absolute!")`.
3.  Test the failure by passing a relative path from your playbook.
