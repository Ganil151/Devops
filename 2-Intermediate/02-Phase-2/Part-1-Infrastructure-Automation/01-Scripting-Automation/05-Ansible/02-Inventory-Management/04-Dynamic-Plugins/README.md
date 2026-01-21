# 4. Dynamic Inventory Plugins

Cloud environments changes too fast for a text file. **Inventory Plugins** solve this by querying the Cloud API directly.

## Configuration (`aws_ec2.yml`)

Plugins are configured via YAML files ending in strict extensions (e.g., `aws_ec2.yml`).

```yaml
plugin: aws_ec2
regions:
  - us-east-1
filters:
  # Only find running instances
  instance-state-name: running
keyed_groups:
  # Create groups based on Tags
  - key: tags.Environment
    prefix: env  # Creates 'env_prod', 'env_dev'
  - key: tags.Role
    prefix: role # Creates 'role_web', 'role_db'
compose:
  # Set the IP to private IP
  ansible_host: private_ip_address
```

## Inventory Graphing
To see what the plugin "sees", use the graph command.

```bash
$ ansible-inventory -i aws_ec2.yml --graph

@all:
  |--@aws_ec2:
  |  |--ip-10-0-1-50.ec2.internal
  |--@env_prod:
  |  |--ip-10-0-1-50.ec2.internal
  |--@role_web:
  |  |--ip-10-0-1-50.ec2.internal
```

## Real-Life Scenarios

### Scenario: "Auto-Scaling Groups"
**Problem**: An ASG scaled up at 3 AM. The new servers weren't patched because they weren't in `hosts.ini`.
**Solution**: Implemented `aws_ec2` plugin.
*   The scheduled job runs at 4 AM.
*   Ansible queries AWS.
*   It sees the new servers (tagged `Role: Worker`).
*   It patches them instantly.

## ❓ Interview Questions

1.  **What is the difference between a Dynamic Inventory Script and a Plugin?**
    *   **Answer**: Scripts (old) were executables returning JSON. Plugins (new) are core Ansible code configured via YAML. Plugins perform better and are easier to use.

2.  **How do you debug if the plugin is finding hosts?**
    *   **Answer**: `ansible-inventory -i my_plugin.yml --list`.

## 🧠 Quiz

1.  **Which plugin connects to AWS?**
    *   [x] `aws_ec2`.
    *   [ ] `ec2_script`.

2.  **What does `keyed_groups` do?**
    *   [x] Automatically creates groups based on variable values (tags).
    *   [ ] Keys the SSH connection.