# í³Š Network Topologies

## Star Topology
The most common topology in modern LANs. All devices connect to a central hub (Switch).

```mermaid
graph TD
    Switch((Central Switch))
    Switch --- PC1[PC 1]
    Switch --- PC2[PC 2]
    Switch --- Server[Server]
    Switch --- Printer[Printer]
```

## Mesh Topology
Used in high-availability environments where every node connects to every other node.

```mermaid
graph LR
    A --- B
    A --- C
    A --- D
    B --- C
    B --- D
    C --- D
```
