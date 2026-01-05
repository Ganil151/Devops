# Advanced Routing for DevOps

Enterprise routing protocols and techniques for complex network infrastructures. This section covers OSPF, BGP, EIGRP, and advanced routing concepts essential for large-scale deployments.

## 🎯 Learning Objectives

- Master OSPF configuration and troubleshooting
- Understand BGP for internet routing
- Implement EIGRP for Cisco environments
- Configure route redistribution and filtering
- Design redundant routing architectures

## 🔄 OSPF (Open Shortest Path First)

### OSPF Fundamentals

**Key Concepts:**
- Link-state routing protocol
- Uses Dijkstra's algorithm
- Hierarchical design with areas
- Fast convergence
- Supports VLSM and CIDR

### Basic OSPF Configuration

**Cisco Router Configuration:**
```bash
# Enable OSPF
router ospf 1
router-id 1.1.1.1
network 192.168.1.0 0.0.0.255 area 0
network 10.0.0.0 0.0.0.255 area 1

# Configure area types
area 1 stub
area 2 nssa

# Passive interfaces
passive-interface default
no passive-interface gigabitethernet0/0
```

**Linux with FRRouting:**
```bash
# /etc/frr/ospfd.conf
router ospf
 ospf router-id 1.1.1.1
 network 192.168.1.0/24 area 0.0.0.0
 network 10.0.0.0/24 area 0.0.0.1
 area 0.0.0.1 stub
```

## 🌐 BGP (Border Gateway Protocol)

### BGP Basics

**eBGP Configuration:**
```bash
# Cisco BGP
router bgp 65001
bgp router-id 1.1.1.1
neighbor 203.0.113.1 remote-as 65002
neighbor 203.0.113.1 description "ISP Connection"
network 192.168.0.0 mask 255.255.0.0
```

**iBGP Configuration:**
```bash
router bgp 65001
neighbor 10.0.0.2 remote-as 65001
neighbor 10.0.0.2 update-source loopback0
neighbor 10.0.0.2 next-hop-self
```

## ⚡ EIGRP (Enhanced Interior Gateway Routing Protocol)

### EIGRP Configuration

**Basic Setup:**
```bash
router eigrp 100
network 192.168.1.0 0.0.0.255
network 10.0.0.0 0.0.0.255
no auto-summary
```

**Advanced Features:**
```bash
# Unequal cost load balancing
variance 2

# Authentication
key chain EIGRP_KEY
 key 1
  key-string cisco123

interface gigabitethernet0/0
 ip authentication mode eigrp 100 md5
 ip authentication key-chain eigrp 100 EIGRP_KEY
```

## 🔀 Route Redistribution

### Redistribution Between Protocols

**OSPF to BGP:**
```bash
router bgp 65001
redistribute ospf 1 metric 100

router ospf 1
redistribute bgp 65001 subnets
```

**Route Filtering:**
```bash
# Prefix lists
ip prefix-list ALLOW_NETWORKS seq 10 permit 192.168.0.0/16 le 24
ip prefix-list DENY_DEFAULT seq 10 deny 0.0.0.0/0

# Route maps
route-map FILTER_ROUTES permit 10
 match ip address prefix-list ALLOW_NETWORKS
 set metric 50

router bgp 65001
neighbor 203.0.113.1 route-map FILTER_ROUTES out
```

## 🛠️ Practical Labs

### Lab 1: Multi-Area OSPF

**Topology:**
```
Area 0 (Backbone)
    │
┌───┴───┐
│Router1│ ── Area 1 ── Router2
└───────┘              │
                    Area 2
```

**Configuration:**
```bash
# Router1 (ABR)
router ospf 1
network 10.0.0.0 0.0.0.255 area 0
network 192.168.1.0 0.0.0.255 area 1
area 1 stub
```

### Lab 2: BGP Route Filtering

**Objective:** Filter routes using prefix lists and route maps

**Tasks:**
1. Configure eBGP peering
2. Create prefix lists for filtering
3. Apply route maps
4. Verify route advertisement

## ✅ Knowledge Check

- [ ] Configure OSPF areas and authentication
- [ ] Implement BGP path selection
- [ ] Set up route redistribution
- [ ] Troubleshoot routing loops
- [ ] Design redundant routing

## 🔗 Next Steps

- [VLANs & Switching](../VLANs-Switching/) - Layer 2 technologies
- [Network Security](../Network-Security/) - Routing security
- [Advanced Level](../../Advanced-Level/) - SDN and automation