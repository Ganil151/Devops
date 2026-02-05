# 🛠️ Inventory Challenges

## Challenge 1: The Group Split
**Objective**: Organize a list of IPs.
1.  IPs: `10.0.0.1` (Web), `10.0.0.2` (Web), `10.0.0.3` (DB).
2.  Create an `hosts.ini` file.
3.  Create groups `[web]` and `[db]`.
4.  Run `ansible web -i hosts.ini -m ping` (You may need to shim connection=local if you don't have real servers).

## Challenge 2: YAML Inventory
**Objective**: Convert INI to YAML.
1.  Take the inventory from Challenge 1.
2.  Rewrite it as `hosts.yml`.
    ```yaml
    all:
      children:
        web:
          hosts: ...
    ```
3.  Verify with `ansible-inventory -i hosts.yml --graph`.

## Challenge 3: Aliases
**Objective**: Use friendly names for IPs.
1.  Map `prod-db` to `192.168.1.50`.
2.  Syntax: `prod-db ansible_host=192.168.1.50`.
3.  Ping it using the alias.
