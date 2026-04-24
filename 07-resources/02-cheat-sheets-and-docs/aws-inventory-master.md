# AWS Inventory Master Toolkit

## 1. Audit Findings
**Scope**: Analyzed `/home/gsmash/Documents/Devops/` for AWS CLI usage.

**Summary**:
- **Existing Maturity**: High. Your `cheatsheet.md` already contains several "Senior-Level" commands using `--query` and `--output table` for VPCs and Security Groups.
- **Key Discovery**: 
  - `aws/cheatsheet.md` contains excellent VPC/Subnet parsers but lacks a comprehensive *Instance* inventory command.
  - Scripts like `master.sh` use `text` output for automation variables (correct usage), but don't provide human-readable dashboards.
  - **Gap**: No single "God View" command exists for running instances that combines Cost (Type), Identity (Name/ID), and Security (SG) context in one view.

## 2. The Master Inventory Command
This command is your "Single Source of Truth" for active infrastructure.

### The Command
```bash
aws ec2 describe-instances \
  --region us-east-1 \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key==`Name`].Value|[0],Type:InstanceType,PrivIP:PrivateIpAddress,PubIP:PublicIpAddress,Launched:LaunchTime,SecGroup:SecurityGroups[0].GroupName}' \
  --output table
```

### Breakdown
| Component | Purpose |
|-----------|---------|
| `--filters "Name=instance-state-name,Values=running"` | **Noise Reduction**. Hides terminated/stopped instances so you only see what you are paying for *right now*. |
| `Type:InstanceType` | **Cost Awareness**. Immediately spots if someone spun up a `c5.4xlarge` instead of a `t3.micro`. |
| `Launched:LaunchTime` | **Uptime Audit**. quickly spots instances that have been running longer than expected (zombies). |
| `SecGroup:SecurityGroups[0].GroupName` | **Security Context**. Verifies the instance is in the expected isolation tier (e.g., `web-tier-sg` vs `default`). |

## 3. Bash Aliases
Add these to your `~/.bashrc` or `~/.zshrc` for instant access.

```bash
# === AWS Inventory Aliases ===

# 1. Quick Listing (The Master Command)
alias ec2-ls='aws ec2 describe-instances --region us-east-1 --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key==\`Name\`].Value|[0],Type:InstanceType,IP:PrivateIpAddress,SG:SecurityGroups[0].GroupName}" --output table'

# 2. Detailed Audit (Includes Launch Time & Public IP)
alias ec2-audit='aws ec2 describe-instances --region us-east-1 --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key==\`Name\`].Value|[0],Type:InstanceType,PubIP:PublicIpAddress,PrivIP:PrivateIpAddress,Launched:LaunchTime,SG:SecurityGroups[0].GroupName}" --output table'

# 3. Cost Watch (Just Type & State)
alias ec2-cost='aws ec2 describe-instances --region us-east-1 --query "Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key==\`Name\`].Value|[0],Type:InstanceType,State:State.Name}" --output table'
```

## 4. Ansible Integration
Use this task in your playbooks to verify inventory state before/after operations.

```yaml
- name: "AUDIT | Gather Instance Facts"
  community.aws.aws_ec2_instance_info:
    region: us-east-1
    filters:
      instance-state-name: running
  register: ec2_facts

- name: "AUDIT | Display Inventory Table"
  debug:
    msg: 
      - "INSTANCE          | TYPE         | IP              | SECURITY GROUP"
      - "------------------------------------------------------------------"
      - "{{ item.tags.Name | default('None') | format('%-17s') }} | {{ item.instance_type | format('%-12s') }} | {{ item.private_ip_address | format('%-15s') }} | {{ item.security_groups[0].group_name | default('None') }}"
  loop: "{{ ec2_facts.instances }}"
  loop_control:
    label: "{{ item.instance_id }}"
```

## 5. Theory: Client-Side vs. Server-Side Filtering

**Why `--query` (Server-Side) Wins:**

1.  **Speed**: 
    - **Server-Side (`--query`)**: AWS filters the JSON *before* sending it over the network. You download 2KB of data.
    - **Client-Side (`grep/jq`)**: AWS sends the full 5MB JSON blob describing every hard drive, network interface, and tag. Your laptop filters it.
2.  **Formatting**: 
    - `--output table` calculates column widths dynamically based on the data. `grep` cannot align columns.
3.  **Accuracy**: 
    - JMESPath (`--query`) understands the JSON object structure. `grep` just matches text lines, which can lead to false positives (e.g., matching a "Name" tag in a description field instead of the actual Name tag).

**Rule of Thumb**: If you are piping `aws` output to `grep`, you are doing it wrong. Use `--filters` to narrow the scope and `--query` to select the fields.
