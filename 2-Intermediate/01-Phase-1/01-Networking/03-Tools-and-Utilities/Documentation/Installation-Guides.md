# 🛠️ Network Tools Installation Guide

## 1. Nmap (Network Mapper)
### Windows
- Download the self-installer from [nmap.org](https://nmap.org/download.html).
- Run the `.exe` and follow the wizard.
- Ensure "Add Nmap to the system PATH" is checked.

### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install nmap -y
```

### macOS
```bash
brew install nmap
```

---

## 2. Wireshark
### Windows/macOS
- Download the installer from [wireshark.org](https://www.wireshark.org/download.html).
- Install "Npcap" (Windows) or "ChmodBPF" (macOS) when prompted to allow packet capture.

### Linux
```bash
sudo apt install wireshark -y
```

---

## 3. Tcpdump
### Linux
```bash
sudo apt install tcpdump -y
```
