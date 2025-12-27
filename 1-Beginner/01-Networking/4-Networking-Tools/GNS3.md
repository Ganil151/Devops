# GNS3: Advanced Network Emulation

## Beyond Packet Tracer
While Packet Tracer is a *simulator* (imitates behavior), **GNS3** (Graphical Network Simulator-3) is an *emulator*. It runs the **actual operating systems** (IOS, JunOS) of the devices.

### Packet Tracer vs. GNS3

| Feature | Packet Tracer | GNS3 |
| :--- | :--- | :--- |
| **Type** | Simulator (Programmed behavior) | Emulator (Real OS virtualization) |
| **Complexity** | Low (Ready to go) | High (Need images/ISOs) |
| **Realism** | 80% (Some commands missing) | 100% (Runs real binary) |
| **Resource Usage** | Low (Any laptop) | High (Needs CPU/RAM) |
| **Use Case** | CCNA, Beginners | CCNP, CCIE, Complex Prod Mirrors |

---

## 🛠️ Architecture

GNS3 uses a client-server model.
-   **GUI Client**: What you interact with.
-   **Server VM**: Where the heavy lifting happens (dynamips, QEMU, Docker).

### Integration Power
One of GNS3's superpowers is connecting to the real world.
-   **Docker Integration**: Drag and drop a Linux container (Ultralight Ubuntu/Alpine) directly into the topology.
-   **Wireshark**: Right-click ANY link -> "Start Capture". It pipes the traffic seamlessly to Wireshark on your host.

---

## 🚀 Getting Started Workflow

1.  **Install GNS3 VM**: Don't run local Dynamips if possible; use the GNS3 VM (VMware/VirtualBox) for stability.
2.  **Get Images**: You need legal copies of Cisco IOS (`.bin` or `.image`) or use free alternatives like **VyOS** (Open source router).
3.  **Create a Template**: Import the image and define its RAM/CPU limits.
4.  **Drag and Drop**: Build the topology.

---

## ⚠️ Important Note on Images
GNS3 does **not** come with Cisco IOS images due to copyright. You must provide your own images from your Cisco Service Contract or use open alternatives.
