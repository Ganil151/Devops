# Blockchain Infrastructure Challenges ⛓️

Learn to deploy and manage the decentralized nodes that build the Web3 world.

---

## 🏆 Challenge 01: The Node Architect
**Objective**: Differentiate between Node Types for appropriate infrastructure scaling.

1.  **Task**: Define the resource requirements (CPU/RAM/Storage) for three node types:
    *   **Full Node**
    *   **Light Node**
    *   **Archive Node**
2.  **Question**: Which node type is critical for a "DeFi Dashboard" that needs to look up account history from 2 years ago?
3.  **DevOps Context**: Why is "Sync Speed" a critical KPI (Key Performance Indicator) for Blockchain DevOps?

---

## 🏆 Challenge 02: Initializing the Network
**Objective**: Spin up a private local blockchain node.

1.  **Requirement**: Use the `geth-node-compose.yml` boilerplate.
2.  **Steps**:
    *   Run `docker-compose up -d`.
    *   Research how to check the "Sync Status" using the JSON-RPC interface.
    *   **Command**: Use `curl` to call the `eth_blockNumber` method.
3.  **Verification**: Confirm you are receiving a block number (it will be `0` if it's a new private chain).

---

## 🏆 Challenge 03: The Persistence Problem
**Objective**: Manage large-scale blockchain data.

1.  **Simulation**: Your Full Node has reached 2TB in size.
2.  **Task**: Research and document a "Pruning" strategy for the Geth client.
3.  **Action**: Draft a shell script snippet that stops the node, runs the `prune-state` command, and restarts the node.

---

## 📁 Solutions
Infrastructure templates are found in the `Boilerplates/` directory.
