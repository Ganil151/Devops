Chef is an Infrastructure as Code (IaC) tool that uses a **Master-Agent (Client-Server)** architecture to manage server configurations at scale.

---

## 🏗️ The Three Pillars of Chef

### 1. The Workstation
Your development machine. You write code here and use the **Knife** tool to communicate with the Chef Server.
- **Chef DK / Workstation**: The suite of tools (Test Kitchen, ChefSpec, InSpec) used for development.
- **Cookbooks**: The modules of configuration you write (in Ruby DSL).

### 2. The Chef Server
The central "Brain."
- **Storage**: Holds all cookbooks, metadata, and node definitions.
- **Search**: Allows you to query information about your infrastructure (e.g., "Find all nodes running Ubuntu").
- **API**: The entry point for workstations and nodes.

### 3. The Nodes
The servers being managed.
- **Chef-client**: The agent that runs on every node.
- **Converge**: The process where the client pulls the latest policy from the server and applies it to the system.

---

## 🛠️ The Setup Workflow

1. **Bootstrap**: Install the `chef-client` on a new server using Knife:
   ```bash
   knife bootstrap [IP_ADDRESS] --ssh-user [USER] --sudo --node-name [NODE_NAME]
   ```
2. **Run List**: Define which cookbooks/recipes a node should run.
3. **Convergence**: The agent runs periodically (e.g., every 30 minutes) to ensure the server stays in the desired state.

---

## 💡 Key Tool: Knife
`knife` is the command-line interface that acts as the "remote control" for your Chef environment.
- `knife cookbook upload [NAME]`
- `knife node list`
- `knife search node "platform:ubuntu"`
