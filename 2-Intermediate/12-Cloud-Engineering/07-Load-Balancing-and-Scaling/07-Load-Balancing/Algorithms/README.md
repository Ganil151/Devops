# Load Balancing Algorithms

Complete guide to load balancing algorithms, their characteristics, and implementation strategies.

## Round Robin
```bash
# Simple rotation through server list
# Equal distribution assumption
# No server health consideration

Algorithm:
Server1 → Server2 → Server3 → Server1 → ...

Implementation:
servers = ['server1', 'server2', 'server3']
current = 0

def get_next_server():
    global current
    server = servers[current]
    current = (current + 1) % len(servers)
    return server
```

## Weighted Round Robin
```bash
# Assigns weights based on server capacity
# Higher weight = more requests
# Proportional distribution

Configuration:
Server1: Weight 3
Server2: Weight 2  
Server3: Weight 1

Distribution Pattern:
S1 → S1 → S1 → S2 → S2 → S3 → (repeat)

Nginx Configuration:
upstream backend {
    server server1.example.com weight=3;
    server server2.example.com weight=2;
    server server3.example.com weight=1;
}
```

## Least Connections
```bash
# Routes to server with fewest active connections
# Dynamic load consideration
# Better for long-running requests

HAProxy Configuration:
backend webservers
    balance leastconn
    server web1 192.168.1.10:80 check
    server web2 192.168.1.11:80 check
    server web3 192.168.1.12:80 check

Algorithm Logic:
1. Count active connections per server
2. Select server with minimum connections
3. Route request to selected server
4. Update connection count
```

## Weighted Least Connections
```bash
# Combines least connections with server weights
# Considers both capacity and current load
# Formula: connections/weight

AWS ALB Target Group:
{
  "TargetGroupArn": "arn:aws:elasticloadbalancing:...",
  "TargetType": "instance",
  "Protocol": "HTTP",
  "Port": 80,
  "Algorithm": "least_outstanding_requests"
}
```

## IP Hash
```bash
# Uses client IP to determine server
# Ensures session persistence
# Consistent routing for same client

Nginx Configuration:
upstream backend {
    ip_hash;
    server server1.example.com;
    server server2.example.com;
    server server3.example.com;
}

Algorithm:
hash = hash_function(client_ip)
server_index = hash % number_of_servers
selected_server = servers[server_index]
```

## Least Response Time
```bash
# Routes to server with fastest response
# Considers both response time and active connections
# Dynamic performance-based routing

F5 BIG-IP Configuration:
ltm pool web_pool {
    load-balancing-mode fastest-response-time
    members {
        192.168.1.10:80 { }
        192.168.1.11:80 { }
        192.168.1.12:80 { }
    }
}
```

## Resource Based
```bash
# Routes based on server resource utilization
# CPU, memory, disk usage consideration
# Requires monitoring agents

Metrics Considered:
- CPU utilization
- Memory usage
- Disk I/O
- Network bandwidth
- Custom metrics

Implementation:
def select_server_by_resources():
    min_load = float('inf')
    selected_server = None
    
    for server in servers:
        load_score = calculate_load_score(server)
        if load_score < min_load:
            min_load = load_score
            selected_server = server
    
    return selected_server
```