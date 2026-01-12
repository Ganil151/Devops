# VLANs and Switching for DevOps

Advanced switching technologies and VLAN implementations for network segmentation and performance optimization in DevOps environments.

## 🎯 Learning Objectives

- Master VLAN configuration and management
- Understand spanning tree protocols
- Implement link aggregation and bonding
- Configure inter-VLAN routing
- Design scalable switching architectures

## 🔀 VLAN Fundamentals

### VLAN Benefits
- Network segmentation
- Broadcast domain control
- Security isolation
- Flexible network design
- Simplified management

### VLAN Configuration

**Cisco Switch VLAN Setup:**
```bash
# Create VLANs
vlan 10
 name Sales
vlan 20
 name Engineering
vlan 30
 name Management
vlan 99
 name Native

# Configure access ports
interface fastethernet0/1
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast

# Configure trunk ports
interface gigabitethernet0/1
 switchport mode trunk
 switchport trunk native vlan 99
 switchport trunk allowed vlan 10,20,30
```

**Linux VLAN Configuration:**
```bash
# Create VLAN interfaces
ip link add link eth0 name eth0.10 type vlan id 10
ip link add link eth0 name eth0.20 type vlan id 20

# Configure IP addresses
ip addr add 192.168.10.1/24 dev eth0.10
ip addr add 192.168.20.1/24 dev eth0.20

# Bring interfaces up
ip link set eth0.10 up
ip link set eth0.20 up
```

## 🌳 Spanning Tree Protocol (STP)

### STP Variants
- **STP (802.1D)**: Original standard
- **RSTP (802.1w)**: Rapid convergence
- **MSTP (802.1s)**: Multiple spanning trees
- **PVST+**: Per-VLAN spanning tree

### STP Configuration

**Rapid Spanning Tree:**
```bash
# Enable RSTP globally
spanning-tree mode rapid-pvst

# Configure root bridge
spanning-tree vlan 10 root primary
spanning-tree vlan 20 root secondary

# Port configuration
interface gigabitethernet0/1
 spanning-tree port-priority 128
 spanning-tree cost 4
 spanning-tree guard root
```

**STP Optimization:**
```bash
# PortFast for access ports
interface range fastethernet0/1-24
 spanning-tree portfast

# BPDU Guard
spanning-tree portfast bpduguard default

# Root Guard on uplinks
interface gigabitethernet0/1
 spanning-tree guard root
```

## 🔗 Link Aggregation

### EtherChannel (Cisco)

**LACP Configuration:**
```bash
# Create port-channel
interface port-channel1
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30

# Configure member interfaces
interface range gigabitethernet0/1-2
 channel-group 1 mode active
 switchport mode trunk
```

**PAgP Configuration:**
```bash
interface range gigabitethernet0/3-4
 channel-group 2 mode desirable
 switchport mode trunk
```

### Linux Bonding

**Network Bonding Setup:**
```bash
# /etc/network/interfaces (Debian/Ubuntu)
auto bond0
iface bond0 inet static
    address 192.168.1.10
    netmask 255.255.255.0
    gateway 192.168.1.1
    bond-slaves eth0 eth1
    bond-mode 802.3ad
    bond-miimon 100
    bond-lacp-rate 1

# Load bonding module
modprobe bonding mode=802.3ad miimon=100
```

**Systemd Network Configuration:**
```ini
# /etc/systemd/network/bond0.netdev
[NetDev]
Name=bond0
Kind=bond

[Bond]
Mode=802.3ad
TransmitHashPolicy=layer3+4
MIIMonitorSec=1s
LACPTransmitRate=fast

# /etc/systemd/network/bond0.network
[Match]
Name=bond0

[Network]
DHCP=no
Address=192.168.1.10/24
Gateway=192.168.1.1
```

## 🔄 Inter-VLAN Routing

### Router-on-a-Stick

**Router Configuration:**
```bash
# Configure subinterfaces
interface gigabitethernet0/0.10
 encapsulation dot1Q 10
 ip address 192.168.10.1 255.255.255.0

interface gigabitethernet0/0.20
 encapsulation dot1Q 20
 ip address 192.168.20.1 255.255.255.0

# Enable main interface
interface gigabitethernet0/0
 no shutdown
```

### Layer 3 Switch (SVI)

**Switch Virtual Interfaces:**
```bash
# Enable IP routing
ip routing

# Create SVIs
interface vlan 10
 ip address 192.168.10.1 255.255.255.0
 no shutdown

interface vlan 20
 ip address 192.168.20.1 255.255.255.0
 no shutdown

# Configure default route
ip route 0.0.0.0 0.0.0.0 192.168.1.254
```

## 🔒 Switch Security

### Port Security

**Basic Port Security:**
```bash
interface fastethernet0/1
 switchport mode access
 switchport access vlan 10
 switchport port-security
 switchport port-security maximum 2
 switchport port-security violation restrict
 switchport port-security mac-address sticky
```

**Advanced Security Features:**
```bash
# DHCP Snooping
ip dhcp snooping
ip dhcp snooping vlan 10,20
interface gigabitethernet0/1
 ip dhcp snooping trust

# Dynamic ARP Inspection
ip arp inspection vlan 10,20
interface gigabitethernet0/1
 ip arp inspection trust

# IP Source Guard
interface fastethernet0/1
 ip verify source port-security
```

## 🏗️ VLAN Design Patterns

### Network Segmentation Strategy

**Three-Tier Architecture:**
```
Core Layer (VLAN 1)
├── Distribution Layer
│   ├── Access Layer VLAN 10 (Users)
│   ├── Access Layer VLAN 20 (Servers)
│   └── Access Layer VLAN 30 (Management)
└── DMZ VLAN 100 (Public Services)
```

**Micro-segmentation:**
```bash
# Application-specific VLANs
vlan 110
 name Web-Tier
vlan 120
 name App-Tier
vlan 130
 name DB-Tier
vlan 140
 name Management
```

## 🐳 Container VLAN Integration

### Docker VLAN Networks

**Macvlan Configuration:**
```bash
# Create macvlan network
docker network create -d macvlan \
  --subnet=192.168.10.0/24 \
  --gateway=192.168.10.1 \
  -o parent=eth0.10 \
  vlan10-net

# Run container on VLAN
docker run -d --name web1 \
  --network vlan10-net \
  --ip=192.168.10.100 \
  nginx
```

### Kubernetes VLAN Integration

**Multus CNI Configuration:**
```yaml
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  name: vlan10-conf
spec:
  config: '{
    "cniVersion": "0.3.1",
    "type": "macvlan",
    "master": "eth0.10",
    "mode": "bridge",
    "ipam": {
      "type": "static",
      "addresses": [
        {
          "address": "192.168.10.100/24",
          "gateway": "192.168.10.1"
        }
      ]
    }
  }'
```

## 🧪 Practical Labs

### Lab 1: Multi-VLAN Environment

**Objective:** Configure complete VLAN infrastructure

**Topology:**
```
Switch1 ── Trunk ── Switch2
   │                   │
VLAN10              VLAN20
Users               Servers
```

**Tasks:**
1. Create VLANs on both switches
2. Configure trunk between switches
3. Assign ports to VLANs
4. Configure inter-VLAN routing
5. Test connectivity

### Lab 2: Link Aggregation Setup

**Objective:** Implement EtherChannel for redundancy

**Configuration:**
```bash
# Switch A
interface port-channel1
 switchport mode trunk
 
interface range gi0/1-2
 channel-group 1 mode active
 switchport mode trunk

# Switch B
interface port-channel1
 switchport mode trunk
 
interface range gi0/1-2
 channel-group 1 mode active
 switchport mode trunk
```

## 🔍 Troubleshooting VLANs

### Common Issues

**VLAN Connectivity Problems:**
```bash
# Verify VLAN configuration
show vlan brief
show interfaces trunk

# Check port assignments
show interfaces fastethernet0/1 switchport

# Verify spanning tree
show spanning-tree vlan 10
```

**Trunk Issues:**
```bash
# Check trunk status
show interfaces trunk
show interfaces gigabitethernet0/1 trunk

# Verify allowed VLANs
show running-config interface gi0/1
```

### Diagnostic Commands

**Switch Diagnostics:**
```bash
# MAC address table
show mac address-table
show mac address-table vlan 10

# Port status
show interfaces status
show interfaces description

# EtherChannel status
show etherchannel summary
show port-channel 1 detail
```

## 📊 VLAN Monitoring

### SNMP Monitoring

**VLAN Statistics:**
```bash
# Monitor VLAN traffic
snmpwalk -v2c -c public switch_ip 1.3.6.1.2.1.17.7.1.4.3.1.5

# Port utilization
snmpget -v2c -c public switch_ip 1.3.6.1.2.1.2.2.1.10.1
```

### Automation Scripts

**VLAN Provisioning Script:**
```python
#!/usr/bin/env python3
import paramiko

def configure_vlan(switch_ip, vlan_id, vlan_name, ports):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(switch_ip, username='admin', password='password')
    
    commands = [
        f'vlan {vlan_id}',
        f'name {vlan_name}',
        'exit'
    ]
    
    for port in ports:
        commands.extend([
            f'interface {port}',
            'switchport mode access',
            f'switchport access vlan {vlan_id}',
            'exit'
        ])
    
    for cmd in commands:
        stdin, stdout, stderr = ssh.exec_command(cmd)
    
    ssh.close()

# Usage
configure_vlan('192.168.1.10', 50, 'NewVLAN', ['fa0/10', 'fa0/11'])
```

## ✅ Knowledge Check

- [ ] Configure VLANs and trunk ports
- [ ] Implement spanning tree optimization
- [ ] Set up link aggregation
- [ ] Configure inter-VLAN routing
- [ ] Implement switch security features
- [ ] Troubleshoot VLAN connectivity
- [ ] Design scalable VLAN architectures

## 🔗 Next Steps

- [Network Security](../Network-Security/) - VLAN security policies
- [Advanced Routing](../Advanced-Routing/) - Routing between VLANs
- [Container Networking](../../Advanced-Level/Container-Networking/) - Modern VLAN integration