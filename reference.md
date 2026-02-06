# 🚀 Root REFERENCE: The DevOps Master Logic
> **Unified SRE entry point for Tier 1-3 Operations.**

## [00] Metadata | Version Compatibility & Freshness
| Component | Verified Version | Standard |
| :--- | :--- | :--- |
| **Linux Kernel** | 5.15+ (LTS) | POSIX / GNU |
| **Terraform** | 1.6.x+ | HCL2 |
| **Docker** | 24.0.x+ | Compose V2 Plug-in |
| **Kubernetes** | 1.28.x+ | API v1 |
| **AWS CLI** | 2.13.x+ | V2 |

**Last Technical Audit:** 2026-02-06
**Service Status:** `HEALTHY` (Standardized Kebab-Case Enforced)

---

## [01] Networking Quick-Ref | The Connectivity Layer
> [!TIP]
> Always use `ip -c` for colorized output to quickly distinguish between `UP` and `DOWN` states in high-density logs.

### 🛠️ Common Commands | Flag Reference
| Command | Flag | Description | Example |
| :--- | :--- | :--- | :--- |
| **ip** | `-c` | Colorize output for human readability. | `ip -c addr` |
| **dig** | `+short` | Returns only the IP address (best for scripts). | `dig +short google.com` |
| **curl** | `-IL` | Follow redirects and show headers only. | `curl -IL google.com` |
| **ss** | `-tulpn` | Show all listening TCP/UDP ports with PIDs. | `ss -tulpn` |
| **nc** (netcat) | `-zv` | Zero-I/O mode (used for scanning) + Verbose. | `nc -zv 10.0.0.5 80` |

### 📊 CIDR Math Cheat Sheet
- `/32`: Single Host IP.
- `/24`: 256 IPs (Standard Subnet).
- `/16`: 65,536 IPs (Large VPC).
- `/0`: The whole internet (`0.0.0.0/0`).

### 💻 Code Snippets | Connectivity logic
```bash
# DNS Latency Check: Measure how long a recursive lookup takes.
# Essential for diagnosing "Slow Application" tickets.
time dig +trace @8.8.8.8 google.com

# HTTP Connectivity: Test path MTU and latency without ping (useful for firewalls).
curl -w "Connect: %{time_connect} TTFB: %{time_starttransfer} Total: %{time_total}\n" -o /dev/null -s google.com
```

#networking #dns #linux #troubleshooting #connectivity

---

## [02] Compute & Cloud | The Provisioning Layer
> [!CAUTION] 
> Never run `aws s3 rm --recursive` without a `--dryrun` if the bucket contains more than 1TB of data or lacks versioning.

### 🛠️ AWS CLI V2 | Common Operations
| Action | Command | SRE Note |
| :--- | :--- | :--- |
| **List Instances** | `aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name]'` | Use `--query` to avoid JSON bloat. |
| **Bucket Audit** | `aws s3 ls s3://my-bucket --recursive --summarize` | Calculate total size/count before migrations. |
| **IAM Policy** | `aws iam list-attached-user-policies --user-name <name>` | Verify permissions before running IaC. |

### 🛠️ Multi-Cloud Visibility
```bash
# Azure: List all VMs in a specific resource group with table output
az vm list -g MyResourceGroup -o table

# GCP: List compute instances across all zones
gcloud compute instances list --filter="status=RUNNING"
```

#cloud #aws #azure #gcp #compute #iam

---

## [03] Automation & IaC | The Logic Layer
> [!IMPORTANT]
> Since Terraform 1.0, always use `terraform init -upgrade` after changing provider versions to prevent lock-file corruption.

### 🏗️ Terraform 1.x | The Golden Workflow
```hcl
# 1. Initialize & Upgrade providers
terraform init -upgrade

# 2. Plan and save to a binary file for absolute safety
# This prevents "Side-Effect" changes between plan and apply.
terraform plan -out=tfplan

# 3. Apply the specific plan file
terraform apply "tfplan"
```

### 🤖 Ansible | Idempotent Patterns
| Module | Use Case | Tip |
| :--- | :--- | :--- |
| **apt** | Package management | Use `cache_valid_time: 3600` to avoid redundant updates. |
| **template** | Config files | Always include `validate: '/usr/sbin/nginx -t %s'` for web servers. |
| **copy** | Static files | Use `remote_src: yes` to move files server-side (faster). |

#iac #terraform #ansible #automation #idempotency

---

## [04] Containerization | The Runtime Layer
> [!TIP]
> Use `docker compose` (v2) instead of the legacy `docker-compose` (v1) python script. It is faster and built into the Docker CLI.

### 🐳 Docker | Essential Lifecycle Commands
| Command | Flag | Action | Example |
| :--- | :--- | :--- | :--- |
| **build** | `-t` | Build an image with a specific tag. | `docker build -t my-app:v1 .` |
| **run** | `-d` | Run container in background (detached). | `docker run -d my-app` |
| **exec** | `-it` | Enter a running container with a terminal. | `docker exec -it <id> /bin/bash` |
| **system prune** | `-a` | Deep clean unused images, containers, networks. | `docker system prune -a --volumes` |

### ☸️ Kubernetes | Deployment vs StatefulSet Logic
| Feature | Deployment | StatefulSet | Use Case |
| :--- | :--- | :--- | :--- |
| **Naming** | Random hashes (`pod-abc`) | Predictable index (`pod-0`) | SS for DBs, Dep for APIs. |
| **Storage** | Shared (usually) | Unique Volume per Pod | SS for independent data. |
| **Update Strategy** | RollingUpdate (Default) | OnDelete or RollingUpdate | Dep is safer for stateless. |

### 🛠️ kubectl | SRE Quick-Ref
```bash
# View logs for a specific container in a multi-container pod
kubectl logs <pod_name> -c <container_name> -f

# Temporary debug pod for connectivity testing
kubectl run -i --tty --rm debug --image=busybox --restart=Never -- sh

# View resource usage across all nodes (Requires Metrics Server)
kubectl top nodes
```

#docker #kubernetes #k8s #containers #orchestration

---

## [05] Troubleshooting & Observability | The Recovery Layer
> [!CAUTION] 
> Never run `rm -rf` on a mounted volume or large directory without checking `df -h` and `ls -R` first.

### 🔍 Linux Log Matrix
| Service | Primary Log Path | Target Information |
| :--- | :--- | :--- |
| **System** | `/var/log/syslog` (or `messages`) | General kernel and system events. |
| **Auth** | `/var/log/auth.log` | SSH logins, sudo attempts, security. |
| **Nginx** | `/var/log/nginx/error.log` | HTTP 5xx errors, config failures. |
| **Docker** | `journalctl -u docker.service` | Runtime daemon failures. |

### 🚦 Status Code & Exit Logic
| Code Type | Meaning | Action |
| :--- | :--- | :--- |
| **HTTP 401** | Unauthorized | Check IAM/Token validity. |
| **HTTP 403** | Forbidden | Check Security Group/RBAC. |
| **HTTP 502** | Bad Gateway | Check if backend service is listening. |
| **Exit 127** | Command Not Found | Fix $PATH or check shell aliases. |
| **Exit 137** | OOM Kill | Increase container memory limits. |

### 💻 Code Snippets | Signal Debugging
```bash
# List all running processes sorted by Memory utilization
ps aux --sort=-%mem | head -n 10

# Trace system calls of a failing process
# Use this when "No such file" errors appear despite the file existing.
strace -e open,stat -p <PID>
```

#troubleshooting #sre #observability #logs #debugging

---
## 🗺️ Navigation Index (Root Modules)
- **[Tier 1: Beginner](01-beginner/readme.md)**
- **[Tier 2: Intermediate](02-intermediate/readme.md)**
- **[Tier 3: Advanced](03-advanced/readme.md)**
- **[Projects Showcase](04-projects-showcase/readme.md)**
- **[Labs and Simulations](05-labs/readme.md)**

---
*Last Updated: 2026-02-06 - Optimized for Senior SRE Workflows*