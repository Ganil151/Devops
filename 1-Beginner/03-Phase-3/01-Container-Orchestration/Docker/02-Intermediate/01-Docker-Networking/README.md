# Docker Networking

Docker networking enables containers to communicate with each other and with external networks. Understanding Docker networking is crucial for building multi-container applications.

## Network Types Overview
Docker provides several network drivers, each suited for different use cases:

```mermaid
graph TB
    subgraph "Docker Host"
        subgraph "Bridge Network default"
            C1[Container 1<br/>172.17.0.2] <--> C2[Container 2<br/>172.17.0.3]
        end

subgraph "Custom Bridge Network"
            C3[Container 3] <--> C4[Container 4]
        end

subgraph "Host Network"
            C5[Container 5<br/>Uses Host IP]
        end

C6[Container 6<br/>None Network<br/>No Network]
    end

Bridge --> Router[Host Network Interface]
    Host --> Router
    Router <--> Internet[External Network]

style Bridge fill:#e3f2fd,color:#000000
    style Host fill:#f3e5f5,color:#000000
    style C6 fill:#ffcdd2,color:#000000
```

### Network Driver Types

| Driver | Use Case | Container Communication | External Access |
|--------|----------|------------------------|-----------------|
| **bridge** | Default, isolated containers on single host | Via container names (custom bridge) | Port mapping required |
| **host** | No network isolation, container uses host network | N/A | Direct access |
| **overlay** | Multi-host, Swarm/Kubernetes | Cross-host communication | Yes |
| **macvlan** | Legacy apps needing MAC address | Direct L2 network | Direct access |
| **none** | Complete network isolation | No communication | No access |

## Bridge Network (Default)

The **bridge** network is the default network for containers. Each container gets its own IP address in a private subnet.

### Default Bridge Network

```bash
# Run container (uses default bridge)
docker run -d --name web1 nginx

# Inspect network
docker network inspect bridge

# Container can access internet but containers must use IP
docker exec web1 ping 172.17.0.3  # Works
docker exec web1 ping web2         # Doesn't work
```

**Limitations of default bridge:**
- No automatic DNS resolution between containers
- Must use IP addresses to communicate
- All containers can see each other
- Less secure

### Custom Bridge Network (Recommended)
Custom bridge networks provide:
- ✅ Automatic DNS resolution
- ✅ Better isolation
- ✅ On-demand connectivity
- ✅ More secure

```bash
# Create custom bridge network
docker network create my-network

# Run containers on custom network
docker run -d --name web --network my-network nginx
docker run -d --name app --network my-network python:3.11

# Containers can communicate by name
docker exec app ping web  # Works!

# List networks
docker network ls

# Inspect network
docker network inspect my-network

# Remove network
docker network rm my-network
```

### Practical Example: Web App + Database
```bash
# Create network
docker network create app-network

# Run database
docker run -d \
  --name postgres-db \
  --network app-network \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=myapp \
  postgres:15

# Run application
docker run -d \
  --name web-app \
  --network app-network \
  -e DATABASE_URL=postgresql://postgres:secret@postgres-db:5432/myapp \
  -p 8080:8080 \
  my-web-app

# App can connect to database using hostname 'postgres-db'
```

## Host Network
Container shares the host's network namespace. No network isolation.

```bash
# Run with host network
docker run -d --network host nginx

# Container uses host's IP and ports directly
# No need for -p flag
curl http://localhost:80
```

**Use cases:**
- Maximum network performance needed
- Container needs to handle lots of ports
- Network configuration is complex

**Drawbacks:**
- No network isolation
- Port conflicts possible
- Less portable
- Security concerns

> [!WARNING]
> Host network mode doesn't work on Docker Desktop for Mac/Windows. It's Linux-only.
>
> **Firewall Note**: When using `--network host`, Docker does not manage `iptables` rules for you. You may need to manually open ports:
> ```bash
> iptables -I INPUT 5 -p tcp -m tcp --dport <service-port> -j ACCEPT
> ```

___

## Container Port Publishing
Expose container ports to the host or external network:

```bash
# Publish single port
docker run -d -p 8080:80 nginx
# Host:Container

# Publish to specific host interface
docker run -d -p 127.0.0.1:8080:80 nginx

# Publish all exposed ports to random ports
docker run -d -P nginx

# Multiple ports
docker run -d \
  -p 8080:80 \
  -p 8443:443 \
  nginx

# UDP port
docker run -d -p 53:53/udp dns-server

# Find published ports
docker port <container-name>
```

___

## Network Communication Patterns

### Pattern 1: Frontend + Backend + Database
![App Network Pattern](../../../Images/docker_network_pattern_1.png)

```bash
# Create network
docker network create app-network

# Database (no exposed ports)
docker run -d \
  --name db \
  --network app-network \
  postgres:15

# Backend (no exposed ports)
docker run -d \
  --name backend \
  --network app-network \
  -e DB_HOST=db \
  my-backend-api

# Frontend (public port)
docker run -d \
  --name frontend \
  --network app-network \
  -p 80:80 \
  -e API_URL=http://backend:3000 \
  my-frontend
```

### Pattern 2: Multiple Networks

Containers can connect to multiple networks:
```bash
# Create networks
docker network create frontend-network
docker network create backend-network

# Database on backend network only
docker run -d \
  --name db \
  --network backend-network \
  postgres:15

# API on both networks
docker run -d \
  --name api \
  --network backend-network \
  my-api

docker network connect frontend-network api

# Frontend on frontend network only
docker run -d \
  --name web \
  --network frontend-network \
  -p 80:80 \
  nginx
```

![Multiple Networks Architecture](../../../Images/docker_network_pattern_2.png)
___

## Managing Networks

### Create Networks

```bash
# Basic network
docker network create my-network

# With subnet
docker network create \
  --subnet=172.20.0.0/16 \
  my-network

# With gateway
docker network create \
  --subnet=172.20.0.0/16 \
  --gateway=172.20.0.1 \
  my-network

# With IP range for containers
docker network create \
  --subnet=172.20.0.0/16 \
  --ip-range=172.20.240.0/20 \
  my-network

# With driver options
docker network create \
  --driver=bridge \
  --opt com.docker.network.bridge.name=br-custom \
  my-network
```

### Connect/Disconnect Containers

```bash
# Connect container to network
docker network connect my-network container1

# Connect with specific IP
docker network connect --ip 172.20.0.10 my-network container1

# Connect with alias
docker network connect --alias api my-network container1

# Disconnect
docker network disconnect my-network container1
```

### Inspect and List

```bash
# List networks
docker network ls

# Filter networks
docker network ls --filter driver=bridge

# Inspect network
docker network inspect my-network

# Show containers in network
docker network inspect -f '{{range .Containers}}{{.Name}} {{end}}' my-network
```

### Remove Networks

```bash
# Remove network
docker network rm my-network

# Remove all unused networks
docker network prune

# Remove specific networks
docker network rm network1 network2 network3
```
___

## DNS and Service Discovery
In custom bridge networks, Docker provides automatic DNS resolution:

```bash
# Create network
docker network create app-net

# Run containers
docker run -d --name db --network app-net postgres
docker run -d --name cache --network app-net redis
docker run -d --name api --network app-net my-api

# Containers can resolve each other by name
docker exec api ping db     # Works!
docker exec api ping cache  # Works!
```

### DNS Round Robin (Multiple Containers, Same Alias)

```bash
# Create network
docker network create loadbalanced

# Run 3 web servers with same alias
docker run -d --network loadbalanced --network-alias web nginx
docker run -d --network loadbalanced --network-alias web nginx
docker run -d --network loadbalanced --network-alias web nginx

# Client resolves 'web' to all 3 IPs (round-robin)
docker run --network loadbalanced alpine nslookup web
```
___

## Network Security

### Isolate with Multiple Networks

![Multiple Networks Architecture](../../../Images/docker_network_pattern_3.png)

```bash
# Public network (exposed services)
docker network create public

# Private network (internal services)
docker network create private

# Frontend in public
docker run -d --name frontend --network public -p 80:80 nginx

# Backend in both networks
docker run -d --name backend my-api
docker network connect public backend
docker network connect private backend

# Database in private only
docker run -d --name db --network private postgres
```

### Restrict Container Communication
```bash
# Create isolated network
docker network create \
  --internal \
  secure-network

# Containers can't reach external internet
docker run -d \
  --name isolated-app \
  --network secure-network \
  my-app

# Can communicate internally but not externally
```
___

## Overlay Networks (Swarm/Multi-Host)
![Overlay Network Architecture](../../../Images/docker_network_pattern_4.png)

Overlay networks enable multi-host communication in Docker Swarm:

```bash
# Initialize swarm
docker swarm init

# Create overlay network
docker network create \
  --driver overlay \
  --attachable \
  my-overlay

# Deploy services
docker service create \
  --name web \
  --network my-overlay \
  --replicas 3 \
  nginx
```

> [!NOTE]
> Overlay networks are primarily used in Docker Swarm or Kubernetes environments for multi-host container communication.

## Macvlan Network

Assign MAC address to containers, making them appear as physical devices:

```bash
# Create macvlan network
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  macvlan-net

# Run container with macvlan
docker run -d \
  --network macvlan-net \
  --ip=192.168.1.100 \
  nginx
```

![Macvlan Network Architecture](../../../Images/docker_network_pattern_5.png)

**Use cases:**
- Legacy applications requiring MAC addresses
- Network monitoring applications
- Applications that need direct Layer 2 access
___

## Troubleshooting

### Check Container Network Settings
```bash
# Inspect container network
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container-name

# Show all network details
docker inspect container-name

# View container interfaces
docker exec container-name ip addr show

# Check routing
docker exec container-name ip route
```

### Test Connectivity

```bash
# Ping between containers
docker exec container1 ping container2

# DNS resolution
docker exec container1 nslookup container2

# Check port connectivity
docker exec container1 nc -zv container2 80

# Trace route
docker exec container1 traceroute container2
```

### Common Issues

#### Containers Can't Communicate

```bash
# Check if on same network
docker network inspect my-network

# Verify DNS resolution
docker exec container1 ping container2

# Check firewall rules
sudo iptables -L
```

#### Port Already in Use

```bash
# Find process using port
sudo lsof -i :8080
sudo netstat -tulpn | grep 8080

# Use different host port
docker run -d -p 8081:80 nginx
```

#### Network Performance Issues

```bash
# Check stats
docker stats

# Use host network for better performance
docker run --network host my-app

# Check MTU settings
docker network inspect bridge -f '{{.Options}}'
```

## Best Practices

1. **Use Custom Bridge Networks**: Better isolation and DNS resolution
2. **One Network Per Application Stack**: Group related containers
3. **Don't Expose Unnecessary Ports**: Only publish what's needed
4. **Use Network Aliases**: For load balancing and flexibility
5. **Name Your Networks**: Descriptive names for clarity
6. **Clean Up Unused Networks**: Regular pruning
7. **Document Network Architecture**: Clear diagrams and documentation
8. **Use Internal Networks**: For databases and internal services

## Network Commands Cheat Sheet
```bash
# Network Management
docker network create <name>              # Create network
docker network ls                         # List networks
docker network inspect <name>             # Inspect network
docker network rm <name>                  # Remove network
docker network prune                      # Remove unused networks

# Container Network Operations
docker network connect <net> <container>  # Connect container
docker network disconnect <net> <container> # Disconnect container
docker run --network <name> <image>       # Run on network
docker run -p 8080:80 <image>            # Publish port

# Inspection
docker port <container>                   # Show port mappings
docker inspect <container>                # Full container details
docker exec <container> ip addr           # Container IP
```
___

## Real-Life Scenarios

### Scenario 1: Legacy Application Migration
**Context**: You are migrating a legacy application that requires direct access to the physical network layer and has hardcoded IP dependencies.
**Solution**: Use the **Macvlan** driver.
1.  Verify the host network interface complies with promiscuous mode (if required).
2.  Create a macvlan network assigned to the host's physical interface (e.g., `eth0`).
3.  Assign specific static IPs to the containers that match the legacy configuration.
**Benefit**: The application perceives it is on the physical network, removing the need for code refactoring.

### Scenario 2: Secure Internal Microservices
**Context**: You have a sensitive database that must only be accessed by the backend API, never by the frontend or external world.
**Solution**: Use **Internal Bridge Networks**.
1.  Create `frontend_net` (public-facing) and `backend_net` (internal).
2.  Connect the Frontend container to `frontend_net`.
3.  Connect the Backend container to both `frontend_net` and `backend_net`.
4.  Connect the Database container *only* to `backend_net`.
**Benefit**: The database is visibly isolated. Even if the frontend is compromised, the attacker has no direct network route to the database.

### Scenario 3: High-Frequency Trading Platform
**Context**: You are building a system where microseconds matter, and the overhead of NAT/Bridge networking is unacceptable.
**Solution**: Use **Host Networking**.
1.  Run containers with `--network host`.
2.  Manage port conflicts manually ensuring no two services listen on the same port.
**Benefit**: Removes the Docker network bridge overhead, providing bare-metal network performance.

### Scenario 4: Debugging Intermittent Connectivity
**Context**: Service A intermittently fails to connect to Service B in a microservices architecture.
**Solution**: Use `docker network inspect` to verify both containers are on the same network. Check the embedded DNS (`127.0.0.11`) inside the container.
1.  Run `docker exec -it serviceA nslookup serviceB`.
2.  If it fails, check if the container was restarted and assigned a new IP (if hardcoded).
3.  Switch to using Docker Service Discovery (container names) instead of IPs.
**Benefit**: Ensures reliable service-to-service communication without IP dependency.

## Common Interview Questions

1.  **Q: What is the default network driver in Docker, and what are its limitations?**
    *   **A:** The default is the `bridge` driver. Limitations include lack of automatic DNS resolution (containers must communicate by IP) and lower security (all containers on the default bridge can talk to each other).

2.  **Q: How do containers on different hosts communicate?**
    *   **A:** They use the `overlay` network driver, which creates a distributed network across multiple Docker daemon hosts. This enables swarm services to communicate securely.

3.  **Q: Explain the difference between `EXPOSE` and `-p` (publish).**
    *   **A:** `EXPOSE` in a Dockerfile functions as documentation, indicating which ports the application listens on. `-p` in `docker run` actually maps the port from the host to the container, making it accessible from outside.

4.  **Q: What is the "Host" network driver?**
    *   **A:** It removes network isolation between the container and the Docker host. The container shares the host's networking namespace, using the host's IP and ports directly.

5.  **Q: How does Docker handle DNS resolution?**
    *   **A:** Docker runs an embedded DNS server at `127.0.0.11`. On custom bridge networks, containers can resolve each other by container name or service name. on the default bridge, this features is disabled.

6.  **Q: What is the difference between `macvlan` and `ipvlan`?**
    *   **A:** `macvlan` assigns a unique MAC address to each container, making it appear as a physical device on the network. `ipvlan` shares the host's MAC address but assigns unique IP addresses, which is useful when the network switch blocks multiple MAC addresses on a single port.

7.  **Q: How do you secure Docker overlay networks?**
    *   **A:** You can enable data plane encryption when creating the overlay network using the `--opt encrypted` flag. This encrypts the traffic between containers on different nodes using IPsec.

## Comprehensive Knowledge Quiz

1.  Which network driver is used by default if none is specified?
    *   a) host
    *   b) overlay
    *   c) bridge
    *   d) none

2.  Which command lists all Docker networks?
    *   a) `docker network show`
    *   b) `docker network list`
    *   c) `docker network ls`
    *   d) `docker ls network`

3.  How do you connect a running container to a network?
    *   a) `docker network join`
    *   b) `docker network connect`
    *   c) `docker attach`
    *   d) `docker link`

4.  Which network driver allows a container to appear as a physical device on your network?
    *   a) bridge
    *   b) host
    *   c) macvlan
    *   d) overlay

5.  What explains why `ping container_name` fails on the default bridge network?
    *   a) ICMP is disabled
    *   b) Automatic DNS resolution is not supported on default bridge
    *   c) The containers are on different subnets
    *   d) Port 53 is blocked

6.  Which flag runs a container on the host's network stack?
    *   a) `--network host`
    *   b) `--net-stack host`
    *   c) `--expose host`
    *   d) `--driver host`

7.  To facilitate communication between containers on multiple Docker hosts (e.g., Swarm), you use:
    *   a) macvlan
    *   b) overlay
    *   c) bridge
    *   d) none

8.  Where does Docker's embedded DNS server listen inside a container?
    *   a) 8.8.8.8
    *   b) 127.0.0.1
    *   c) 127.0.0.11
    *   d) 192.168.0.1

9.  What happens if you run two containers with `-p 80:80` on the same host?
    *   a) Docker load balances them
    *   b) The second container fails to start (Port already allocated)
    *   c) Both start but only one works
    *   d) Docker assigns a random port to the second one

10. Which command removes all unused networks?
    *   a) `docker network clean`
    *   b) `docker network rm --all`
    *   c) `docker network prune`
    *   d) `docker network purge`

11. If you want a container to have NO network interface, which driver do you use?
    *   a) null
    *   b) empty
    *   c) void
    *   d) none

12. In a custom bridge network, what happens if a container name is distinct but the network alias is the same for multiple containers?
    *   a) Network Error
    *   b) DNS Round Robin load balancing
    *   c) Address Conflict
    *   d) Only the first container responds

13. Which command shows detailed information about a network, including connected containers?
    *   a) `docker network describe`
    *   b) `docker network inspect`
    *   c) `docker network details`
    *   d) `docker network show`

14. True or False: You can link containers on the default bridge using `--link` (legacy), but it is deprecated.
    *   a) True
    *   b) False

15. When using `--network host`, does the `-p` (publish) flag have any effect?
    *   a) Yes, it still maps ports
    *   b) No, it is ignored
    *   c) It causes an error
    *   d) Only for UDP ports

16. Which network driver offers a dedicated Layer 2 network for containers?
    *   a) bridge
    *   b) macvlan
    *   c) overlay
    *   d) host

17. How can you isolate a container from the internet but allow it to talk to other containers?
    *   a) Block port 80
    *   b) Use an `--internal` network
    *   c) Use `--network none`
    *   d) Delete the default gateway manually

18. What is the format for mapping a host port to a container port?
    *   a) `-p container:host`
    *   b) `-p host:container`
    *   c) `-p host->container`
    *   d) `-p container->host`

19. Which command creates a network with a specific subnet?
    *   a) `docker network create --subnet 192.168.1.0/24 mynet`
    *   b) `docker network add --ip-range 192.168.1.0/24 mynet`
    *   c) `docker create network --net 192.168.1.0/24 mynet`
    *   d) `docker network new --subnet 192.168.1.0/24 mynet`

20. Can a container be connected to multiple networks simultaneously?
    *   a) No, only one network per container
    *   b) Yes, enabling multi-tier architecture
    *   c) Only if they are of the same driver type
    *   d) Only in Docker Swarm mode

21. Which command disconnects a container from a network?
    *   a) `docker network leave`
    *   b) `docker network disconnect`
    *   c) `docker disconnect`
    *   d) `docker network drop`

22. What is the purpose of the `--link` flag?
    *   a) It is the modern way to connect containers
    *   b) It is deprecated and should be replaced by custom networks
    *   c) It creates a VPN tunnel
    *   d) It links the container to the host

23. Which network driver supports encryption of traffic between containers?
    *   a) bridge
    *   b) host
    *   c) overlay
    *   d) macvlan

24. How do you map a UDP port?
    *   a) `-p 80:80/udp`
    *   b) `-p 80:80:udp`
    *   c) `--udp 80:80`
    *   d) `-u 80:80`

25. Which command displays the network configuration of a container?
    *   a) `docker config show`
    *   b) `docker inspect`
    *   c) `docker network view`
    *   d) `docker ipconfig`

### Quiz Answer Key

1.  **c) bridge** - It is the default driver.
2.  **c) docker network ls** - Lists networks.
3.  **b) docker network connect** - Connects a running container.
4.  **c) macvlan** - Allows assignment of MAC addresses.
5.  **b) Automatic DNS resolution is not supported** - Default bridge relies on links or IPs.
6.  **a) --network host** - Uses host stack.
7.  **b) overlay** - Used for multi-host networking.
8.  **c) 127.0.0.11** - Docker's embedded DNS.
9.  **b) The second container fails to start** - Port conflict exists.
10. **c) docker network prune** - Removes unused objects.
11. **d) none** - No networking.
12. **b) DNS Round Robin load balancing** - Docker resolves the alias to multiple IPs.
13. **b) docker network inspect** - JSON output of details.
14. **a) True** - Links are legacy; custom networks are preferred.
15. **b) No, it is ignored** - Ports are already "exposed" directly on the host interface.
16. **b) macvlan** - Direct interaction with physical network.
17. **b) Use an --internal network** - Restricts external access.
18. **b) -p host:container** - Host port comes first.
19. **a) docker network create --subnet...** - Correct syntax.
20. **b) Yes** - Containers can join multiple networks.
21. **b) docker network disconnect** - Removes a container from a network.
22. **b) It is deprecated** - Use user-defined bridges instead.
23. **c) overlay** - Supports `--opt encrypted`.
24. **a) -p 80:80/udp** - Specify protocol after port.
25. **b) docker inspect** - Shows full configuration including networks.

## Next Steps

- Continue to [Docker Volumes](../02-Docker-Volumes/README.md)
- Learn about [Multi-Stage Builds](../03-Multi-Stage-Builds/README.md)
- Explore [Docker Compose for Multi-Container Apps](../../Docker-Compose/Beginner/01-Basics/README.md)

## Resources

- [Docker Networking Documentation](https://docs.docker.com/network/)
- [Network Drivers](https://docs.docker.com/network/drivers/)
- [Overlay Networks](https://docs.docker.com/network/overlay/)
- [Container Networking Tutorial](https://docs.docker.com/config/containers/container-networking/)

---

**[← Previous: Dockerfile Basics](../../Beginner/03-Dockerfile-Basics/README.md)** | **[Next: Docker Volumes →](../02-Docker-Volumes/README.md)**