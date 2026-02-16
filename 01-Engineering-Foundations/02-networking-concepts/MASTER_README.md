# 🌐 Networking Concepts: Master Index

> **Navigation index — links to every granular file. No content is merged; each file is independent.**

---

## 📂 Core Modules

### 01-network-fundamentals/
- [readme.md](./01-network-fundamentals/readme.md) — Networking basics

### 02-network-models/
- [readme.md](./02-network-models/readme.md) — Overview of OSI and TCP/IP

#### OSI Model (Layer-by-Layer — Each File Independent)

| Layer | File | Description |
|:---|:---|:---|
| 1 - Physical | [readme.md](./02-network-models/osi-model/01-physical/readme.md) | Cables, NICs, hubs |
| 2 - Data Link | [readme.md](./02-network-models/osi-model/02-data-link/readme.md) | MAC addresses, switches |
| 3 - Network | [readme.md](./02-network-models/osi-model/03-network/readme.md) | IP addressing, routing |
| 4 - Transport | [readme.md](./02-network-models/osi-model/04-transport/readme.md) | TCP/UDP, ports |
| 5 - Session | [readme.md](./02-network-models/osi-model/05-session/readme.md) | Session management |
| 6 - Presentation | [readme.md](./02-network-models/osi-model/06-presentation/readme.md) | Encoding, encryption |
| 7 - Application | [readme.md](./02-network-models/osi-model/07-application/readme.md) | HTTP, DNS, FTP |

#### Physical Layer Deep-Dive Files

**Cables & Connectors** (each is its own file):
- [10-base-t.md](./02-network-models/osi-model/01-physical/cables-and-connectors/10-base-t.md)
- [100base-t.md](./02-network-models/osi-model/01-physical/cables-and-connectors/100base-t.md)
- [1000base-t.md](./02-network-models/osi-model/01-physical/cables-and-connectors/1000base-t.md)
- [types.md](./02-network-models/osi-model/01-physical/cables-and-connectors/types.md)
- [wiring.md](./02-network-models/osi-model/01-physical/cables-and-connectors/wiring.md)

**Devices** (each is its own file):
- [computer-network-components.md](./02-network-models/osi-model/01-physical/devices/computer-network-components.md)
- [hub.md](./02-network-models/osi-model/01-physical/devices/hub.md)
- [nic.md](./02-network-models/osi-model/01-physical/devices/nic.md)
- [router-main.md](./02-network-models/osi-model/01-physical/devices/router/router-main.md)

**Router Components** (each is its own file):
- [1841-cisco-router.md](./02-network-models/osi-model/01-physical/devices/router/components/1841-cisco-router.md)
- [modem.md](./02-network-models/osi-model/01-physical/devices/router/components/modem.md)
- [router-devices-and-wic-modules.md](./02-network-models/osi-model/01-physical/devices/router/components/router-devices-and-wic-modules.md)

**Router Protocols** (each is its own file):
- [loop-back-interface.md](./02-network-models/osi-model/01-physical/devices/router/protocols/loop-back-interface.md)
- [ospf.md](./02-network-models/osi-model/01-physical/devices/router/protocols/ospf.md)
- [route-aggregation.md](./02-network-models/osi-model/01-physical/devices/router/protocols/route-aggregation.md)
- [routing-alogrithms.md](./02-network-models/osi-model/01-physical/devices/router/protocols/routing-alogrithms.md)
- [routing-concepts.md](./02-network-models/osi-model/01-physical/devices/router/protocols/routing-concepts.md)
- [routing-loops.md](./02-network-models/osi-model/01-physical/devices/router/protocols/routing-loops.md)
- [routing-protocol-metrics.md](./02-network-models/osi-model/01-physical/devices/router/protocols/routing-protocol-metrics.md)

#### OSI Supporting Materials
- [computer-network-models.md](./02-network-models/osi-model/computer-network-models.md)
- [quiz.md](./02-network-models/osi-model/quiz.md)
- [real-life-scenarios.md](./02-network-models/osi-model/real-life-scenarios.md)

#### OSI Images & Slides
- [network-layer.png](./02-network-models/osi-model/images/network-layer.png)
- [osi-7-layersjpg.webp](./02-network-models/osi-model/images/osi-7-layersjpg.webp)
- [osimodel.png](./02-network-models/osi-model/images/osimodel.png)
- [osi-vs-tcpip-modelsjpg.webp](./02-network-models/osi-model/images/osi-vs-tcpip-modelsjpg.webp)
- 11 slide images in [slides/](./02-network-models/osi-model/slides/)

---

### 03-ip-addressing/
- [readme.md](./03-ip-addressing/readme.md) — IP addresses and subnetting
- [challenges.md](./03-ip-addressing/challenges.md)

### 04-basic-protocols/
- [readme.md](./04-basic-protocols/readme.md) — DNS, DHCP, HTTP, etc.

### 05-network-devices/
- [readme.md](./05-network-devices/readme.md) — Routers, switches, firewalls

### 06-basic-troubleshooting/
- [readme.md](./06-basic-troubleshooting/readme.md) — ping, traceroute, nslookup

---

## 📂 Troubleshooting Labs (`07-network-troubleshooting-labs/`)
- [lab-01-telnet-test.py](./07-network-troubleshooting-labs/lab-01-telnet-test.py)
- [lab-02-dns-resolver.py](./07-network-troubleshooting-labs/lab-02-dns-resolver.py)

---

## 📂 PowerShell Network Scripts (`scripts/`)
- [get-networkinventory.ps1](./scripts/get-networkinventory.ps1)
- [measure-networklatency.ps1](./scripts/measure-networklatency.ps1)
- [resolve-dnsissues.ps1](./scripts/resolve-dnsissues.ps1)
- [test-networkdiagnostics.ps1](./scripts/test-networkdiagnostics.ps1)
- [test-portconnectivity.ps1](./scripts/test-portconnectivity.ps1)

---

## 📂 Reference Library (`reference/`)
- [ip-addressing-subnetting-ref.md](./reference/ip-addressing-subnetting-ref.md)
- [network-devices-hardware-ref.md](./reference/network-devices-hardware-ref.md)
- [networking-best-practices-ref.md](./reference/networking-best-practices-ref.md)
- [network-models-ref.md](./reference/network-models-ref.md)
- [network-protocols-ref.md](./reference/network-protocols-ref.md)
- [network-troubleshooting-ref.md](./reference/network-troubleshooting-ref.md)

---

## 📂 Resources (`resources/`)
- [computer-networking.pdf](./resources/computer-networking.pdf)
- [network-security-bible.pdf](./resources/network-security-bible.pdf)
- [nmap-cheat-sheet.pdf](./resources/nmap-cheat-sheet.pdf)
- [nmap.pdf](./resources/nmap.pdf)
- [wireshark.pdf](./resources/wireshark.pdf)

---

## 📂 Root Files
- [readme.md](./readme.md) — Pillar overview
- [dhcp-dora-process.png](./dhcp-dora-process.png)
- [dns-hierarchy.png](./dns-hierarchy.png)

---

*This index was auto-generated from tree.txt. All files are independent entities — no content has been merged.*
