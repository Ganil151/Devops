# 04: Network Stack Tuning

## 📊 Core Metric: `Bytes Total/sec` & `Average Latency (ms)`
This module focuses on the optimization of the Windows TCP/IP kernel to maximize packet throughput and eliminate serialization jitter (Nagle's Algorithm).

## 🚀 DevOps Impact
- **Container Networking**: Significantly reduces the latency of internal Docker/WSL2 network bridges.
- **Artifact Downloads**: Maximizes pipe utilization for pulling large container images or Maven/NPM dependencies.
- **RDP/SSH Responsiveness**: Disabling delayed ACKs ensures that character-stream protocols remain buttery smooth over high-latency WAN links.

## 🗺️ Architecture
```mermaid
graph LR
    APP[Dev App] --> TCP[TCP Stack Tuning]
    TCP -->|CUBIC| BW[Bandwidth Management]
    BW --> NIC[Hardware Interface]
    NIC -->|ECN/DCA| NET[Physical Network]
    style TCP fill:#0078D4,stroke:#fff
```

## ⚠️ Risk Assessment
- **Caution**: Disabling TCP timestamps and enabling ECN can occasionally cause issues with very old corporate firewalls that do not strictly adhere to modern RFC standards. 
- **Backup**: This script performs a mandatory backup of the `Tcpip` registry hive before execution.
