# Docker Volumes and Data Persistence

Containers are ephemeral by design - when removed, their data is lost. **Docker volumes** solve this problem by providing persistent storage that survives container lifecycle.

## Understanding Container Storage

Docker uses a **layered filesystem** (UnionFS). When you run an image, Docker adds a thin **Read-Write layer** (Container Layer) on top. Any changes made to the container (like writing a file) happen here. However, this layer is deleted when the container is removed.

To solve this, Docker provides three ways to mount data from the host into the container:

![Docker-Storage-Arch](../../../../1-Beginner/Images/dockerStorageArch.png)


### Storage Types Comparison

| Type | Location | Managed By | Use Case | Performance | Portability |
|------|----------|------------|----------|-------------|-------------|
| **Container Layer** | Container | Docker | Temporary data | Good | N/A |
| **Named Volume** | Docker area | Docker | Database data, persistent state | Best | High |
| **Bind Mount** | Anywhere on host | User | Development, config files | Good | Low |
| **tmpfs Mount** | Host RAM | Docker | Temporary cache, secrets | Fastest | N/A |

## Docker Volumes (Recommended)

Volumes are the preferred mechanism for persisting data. They're managed by Docker and isolated from the host filesystem.

### Creating Volumes

```bash
# Create a named volume
docker volume create my-data

# Create volume with driver options
docker volume create \
  --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.100,rw \
  --opt device=:/path/to/dir \
  nfs-volume

# Create volume with labels
docker volume create \
  --label project=myapp \
  --label env=production \
  prod-data
```

### Using Volumes

```bash
# Run container with named volume
docker run -d \
  --name web \
  -v my-data:/app/data \
  nginx

# Alternative syntax (recommended)
docker run -d \
  --name web \
  --mount source=my-data,target=/app/data \
  nginx

# Anonymous volume (created automatically)
docker run -d -v /app/data nginx

# Multiple volumes
docker run -d \
  -v db-data:/var/lib/mysql \
  -v db-config:/etc/mysql \
  mysql:8.0
```

### Managing Volumes

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect my-data

# Find volume location on host
docker volume inspect -f '{{.Mountpoint}}' my-data

# Remove volume
docker volume rm my-data

# Remove all unused volumes
docker volume prune

# Remove volume with container
docker rm -v container-name
```

### Practical Example: MySQL with Persistent Data

```bash
# Create volume for database
docker volume create mysql-data

# Run MySQL with volume
docker run -d \
  --name mysql-db \
  -e MYSQL_ROOT_PASSWORD=secret \
  -e MYSQL_DATABASE=myapp \
  -v mysql-data:/var/lib/mysql \
  -p 3306:3306 \
  mysql:8.0

# Add data
docker exec -it mysql-db mysql -uroot -psecret -e \
  "USE myapp; CREATE TABLE users (id INT, name VARCHAR(50));"

# Stop and remove container
docker stop mysql-db
docker rm mysql-db

# Data still exists in volume
docker volume ls | grep mysql-data

# Start new container with same volume
docker run -d \
  --name mysql-db-new \
  -e MYSQL_ROOT_PASSWORD=secret \
  -v mysql-data:/var/lib/mysql \
  -p 3306:3306 \
  mysql:8.0

# Data is still there!
docker exec -it mysql-db-new mysql -uroot -psecret -e \
  "USE myapp; SHOW TABLES;"
```

## Bind Mounts

Bind mounts link a host filesystem path to a container path. Changes are reflected immediately in both directions.

### Using Bind Mounts

```bash
# Bind mount using -v
docker run -d \
  -v /path/on/host:/path/in/container \
  nginx

# Bind mount using --mount (more explicit)
docker run -d \
  --mount type=bind,source=/path/on/host,target=/path/in/container \
  nginx

# Read-only bind mount
docker run -d \
  -v /path/on/host:/path/in/container:ro \
  nginx

# Bind mount current directory
docker run -d \
  -v $(pwd):/app \
  my-app
```

### Development Workflow Example

```bash
# Project structure
# myapp/
# ├── src/
# │   └── index.js
# ├── package.json
# └── Dockerfile

# Run with bind mount for development
docker run -d \
  --name dev-app \
  -v $(pwd)/src:/app/src \
  -p 3000:3000 \
  node:18 \
  npm run dev

# Edit files on host → Changes reflected immediately in container
echo "console.log('Updated!');" >> src/index.js

# App auto-reloads with changes
```

### Bind Mount for Configuration

```bash
# Custom NGINX configuration
docker run -d \
  --name web \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v $(pwd)/html:/usr/share/nginx/html:ro \
  -p 80:80 \
  nginx
```

## tmpfs Mounts (Memory Storage)

tmpfs mounts store data in host memory only. Data is lost when container stops.

### Use Cases

- Sensitive data (passwords, keys) that shouldn't touch disk
- Temporary cache
- Session storage
- High-performance temporary storage

```bash
# tmpfs mount
docker run -d \
  --name app \
  --tmpfs /tmp:rw,size=100m,mode=1777 \
  my-app

# Using --mount syntax
docker run -d \
  --mount type=tmpfs,destination=/tmp,tmpfs-size=100m \
  my-app

# Store secrets in memory
docker run -d \
  --tmpfs /run/secrets:noexec,nosuid,size=64k \
  my-app
```

## Volume Drivers

Docker supports plugins for different storage backends:

```bash
# Local driver (default)
docker volume create --driver local my-vol

# NFS driver
docker volume create \
  --driver local \
  --opt type=nfs \
  --opt o=addr=nfs-server,rw \
  --opt device=:/path/to/data \
  nfs-vol

# Third-party drivers
# - AWS EBS
# - Azure Disk
# - GCP Persistent Disk
# - NetApp
# - And many more...
```

## Sharing Data Between Containers

### Pattern 1: Shared Volume

```bash
# Create shared volume
docker volume create shared-data

# Container 1 writes data
docker run -d \
  --name writer \
  -v shared-data:/data \
  alpine \
  sh -c "while true; do date >> /data/log.txt; sleep 1; done"

# Container 2 reads data
docker run -d \
  --name reader \
  -v shared-data:/data:ro \
  alpine \
  sh -c "tail -f /data/log.txt"

# View reader output
docker logs -f reader
```

### Pattern 2: Volumes From Another Container

```bash
# Data container pattern (legacy, but still useful)
docker create -v /data --name data-container alpine

# App containers use data from data-container
docker run -d --volumes-from data-container --name app1 my-app
docker run -d --volumes-from data-container --name app2 my-app
```

### Pattern 3: Multi-Container Development

A common pattern for local development is to bind-mount the source code into multiple containers, allowing them to share the code and reflect host-side edits immediately.

```mermaid
graph LR
    subgraph "Development Environment"
        subgraph "Docker Containers"
            WEB[Frontend Container]
            API[Backend API Container]
            TEST[Test Runner Container]
        end
        
        subgraph "Volumes & Mounts"
            SRC[<b>Source Code</b><br/>Bind Mount]
            DEPS["<b>node_modules</b><br/>Named Volume"]
        end
    end
    
    SRC --- WEB & API & TEST
    DEPS --- WEB & API
    
    style SRC fill:#fff3e0,stroke:#e65100,color:#000000
    style DEPS fill:#e8f5e9,stroke:#1b5e20,color:#000000
    style WEB fill:#e3f2fd,stroke:#1565c0,color:#000000
    style API fill:#f3e5f5,stroke:#7b1fa2,color:#000000
    style TEST fill:#fce4ec,stroke:#c2185b,color:#000000
```


## Backup and Restore

### Backup Volume Data

```bash
# Method 1: Using tar
docker run --rm \
  -v my-data:/data \
  -v $(pwd):/backup \
  alpine \
  tar czf /backup/my-data-backup.tar.gz -C /data .

# Method 2: Copy to host
docker run --rm \
  -v my-data:/data \
  -v $(pwd):/backup \
  alpine \
  sh -c "cp -r /data/* /backup/"
```

### Restore Volume Data

```bash
# Create new volume
docker volume create my-data-restored

# Restore from backup
docker run --rm \
  -v my-data-restored:/data \
  -v $(pwd):/backup \
  alpine \
  tar xzf /backup/my-data-backup.tar.gz -C /data
```

### Automated Backup Script

```bash
#!/bin/bash
# backup-docker-volumes.sh

VOLUME_NAME=$1
BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

docker run --rm \
  -v ${VOLUME_NAME}:/data:ro \
  -v ${BACKUP_DIR}:/backup \
  alpine \
  tar czf /backup/${VOLUME_NAME}_${TIMESTAMP}.tar.gz -C /data .

echo "Backup created: ${VOLUME_NAME}_${TIMESTAMP}.tar.gz"
```

## Volume Migration

### Migrate Between Hosts

```bash
# On source host - export volume
docker run --rm \
  -v source-volume:/data \
  alpine \
  tar cz -C /data . > volume-data.tar.gz

# Transfer to new host
scp volume-data.tar.gz user@newhost:/tmp/

# On destination host - import volume
docker volume create destination-volume
cat /tmp/volume-data.tar.gz | \
  docker run --rm -i \
  -v destination-volume:/data \
  alpine \
  tar xz -C /data
```

### Copy Between Volumes

```bash
# Copy data from one volume to another
docker run --rm \
  -v source-vol:/source:ro \
  -v dest-vol:/dest \
  alpine \
  sh -c "cp -av /source/* /dest/"
```

## Advanced Volume Management

### Volume Permissions

```bash
# Set specific user ownership
docker run --rm \
  -v my-data:/data \
  alpine \
  chown -R 1000:1000 /data

# Run container as specific user
docker run -d \
  --user 1000:1000 \
  -v my-data:/app/data \
  my-app
```

### Read-Only Volumes

```bash
# Mount volume as read-only
docker run -d \
  -v config-data:/app/config:ro \
  my-app

# Application can't modify configuration
```

### Volume Labels

```bash
# Create volume with metadata
docker volume create \
  --label environment=production \
  --label backup=daily \
  --label retention=30days \
  prod-db-data

# Filter volumes by label
docker volume ls --filter label=environment=production

# Find volumes to backup
docker volume ls --filter label=backup=daily
```

## Monitoring Volume Usage

### Check Volume Size

```bash
# Using Docker inspect
docker volume inspect my-data

# Get actual disk usage
sudo du -sh $(docker volume inspect -f '{{.Mountpoint}}' my-data)

# All volumes size
sudo du -sh /var/lib/docker/volumes/*
```

### List Volumes by Size

```bash
#!/bin/bash
# list-volume-sizes.sh

for vol in $(docker volume ls -q); do
  size=$(sudo du -sh $(docker volume inspect -f '{{.Mountpoint}}' $vol) 2>/dev/null | awk '{print $1}')
  echo "$vol: $size"
done | sort -h -k2
```

## Troubleshooting

### Volume Not Persisting Data

```bash
# Check if volume is actually created
docker volume ls

# Inspect container mounts
docker inspect -f '{{json .Mounts}}' container-name | jq

# Verify volume path
docker inspect container-name | grep -A 10 Mounts
```

### Permission Issues

```bash
# Check file ownership in volume
docker run --rm -v my-data:/data alpine ls -la /data

# Fix permissions
docker run --rm -v my-data:/data alpine chown -R 1000:1000 /data

# Run container as root to fix
docker exec -u root container-name chown -R appuser:appuser /data
```

### Volume Is Full

```bash
# Check disk usage
df -h

# Check volume size
sudo du -sh /var/lib/docker/volumes/my-data

# Clean up old data
docker run --rm -v my-data:/data alpine \
  find /data -type f -mtime +30 -delete
```

### Can't Delete Volume

```bash
# Check which containers are using it
docker ps -a --filter volume=my-data

# Remove containers using the volume
docker rm -f $(docker ps -aq --filter volume=my-data)

# Now remove volume
docker volume rm my-data
```

## Best Practices

1. **Use Named Volumes for Databases**: Never use bind mounts for database storage in production
2. **Backup Regularly**: Automate volume backups for critical data
3. **Use Labels**: Organize volumes with metadata
4. **Avoid Anonymous Volumes**: Hard to manage and track
5. **Read-Only When Possible**: Mount configurations as read-only
6. **Set Ownership Correctly**: Match container user UID/GID
7. **Monitor Volume Size**: Set up alerts for disk usage
8. **Document Volume Purpose**: Use labels and naming conventions
9. **Clean Up Unused Volumes**: Regular `docker volume prune`
10. **Test Restore Process**: Ensure backups actually work

## Common Patterns

### Database with Backup

```bash
# Production database setup
docker run -d \
  --name postgres \
  -v postgres-data:/var/lib/postgresql/data \
  -v postgres-backups:/backups \
  -e POSTGRES_PASSWORD=secret \
  postgres:15

# Automated backupscript
docker exec postgres pg_dump -U postgres mydb > /backups/backup.sql
```

### Development Environment

```bash
# Development with live reload
docker run -d \
  --name dev-env \
  -v $(pwd)/src:/app/src:cached \
  -v node_modules:/app/node_modules \
  -p 3000:3000 \
  node:18
```

### Shared Configuration

```bash
# Shared config across multiple containers
docker volume create app-config

# Copy config to volume
docker run --rm \
  -v app-config:/config \
  -v $(pwd)/config:/source \
  alpine cp -r /source/* /config/

# Use in containers
docker run -d -v app-config:/app/config:ro app1
docker run -d -v app-config:/app/config:ro app2
```

## Volume Command Reference

```bash
# Create
docker volume create <name>                    # Create volume
docker volume create --label key=value <name>  # With labels

# List & Inspect
docker volume ls                               # List volumes
docker volume ls --filter label=env=prod       # Filter by label
docker volume inspect <name>                   # Detailed info

# Remove
docker volume rm <name>                        # Remove volume
docker volume prune                            # Remove unused
docker volume prune --filter label=temp=true   # Conditional prune

# Usage
-v volume-name:/path                           # Named volume
-v /host/path:/container/path                  # Bind mount
-v /container/path                             # Anonymous volume
--mount type=volume,src=vol,dst=/path          # Explicit syntax
```

___

## Real-Life Scenarios

### Scenario 1: Database Persistence in Production
**Objective**: Ensure that a PostgreSQL database does not lose data even if the container is upgraded or the host restarts.
**Solution**: Use a **Named Volume**.
```bash
docker volume create pg_prod_data
docker run -d --name db -v pg_prod_data:/var/lib/postgresql/data postgres:15
```
**Why?**: Named volumes are managed by Docker, ensuring they are not accidentally deleted by basic cleanup scripts and are easy to back up using labels.

### Scenario 2: Hot-Reloading for React Development
**Objective**: See code changes in real-time in the browser without rebuilding the Docker image.
**Solution**: Use a **Bind Mount**.
```bash
docker run -v $(pwd):/app -p 3000:3000 my-react-app npm start
```
**Why?**: Bind mounts allow the container to use the files on your host machine. When you save a file in VS Code, the container sees the change instantly.

### Scenario 3: Secure Session Storage (Zero Disk Footprint)
**Objective**: Store user session tokens in a high-performance way that ensures they never touch the physical disk for security compliance.
**Solution**: Use a **tmpfs Mount**.
```bash
docker run -d --mount type=tmpfs,destination=/app/sessions,tmpfs-size=512m my-api
```
**Why?**: tmpfs writes directly to RAM. If the container stops or the machine loses power, the sessions are wiped, ensuring no sensitive data remains on disk.

## Common Interview Questions

1. **Q: What is the difference between a volume and a bind mount?**
   * **A**: Volumes are managed by Docker and stored in a Docker-specific directory. Bind mounts can be anywhere on the host and are managed by the host's filesystem.

2. **Q: How can you share data between two running containers?**
   * **A**: By mounting the same named volume to both containers, or using `--volumes-from` (legacy) to inherit mounts from another container.

3. **Q: What happens to data in a volume when the container is deleted?**
   * **A**: The data persists. Volumes are independent of the container lifecycle. You must explicitly run `docker volume rm` to delete them.

4. **Q: When would you use a `tmpfs` mount instead of a volume?**
   * **A**: When performance is critical (RAM is faster than disk) or when security requires that data is never written to persistent storage.

5. **Q: What is the benefit of the `--mount` flag over `-v`?**
   * **A**: `--mount` is more explicit, follows a key=value format, and is more readable. It is also the only way to specify advanced options like `tmpfs-size` or volume driver options easily.

## Comprehensive Knowledge Quiz

1. Which command creates a Docker volume?
   * a) `docker create volume`
   * b) `docker volume build`
   * c) `docker volume create`
   * d) `docker volume new`

2. Where does Docker store named volumes on a default Linux installation?
   * a) `/etc/docker/volumes`
   * b) `/home/docker/data`
   * c) `/var/lib/docker/volumes`
   * d) `/usr/local/docker`

3. Which mount type is NOT persistent?
   * a) Bind Mount
   * b) Named Volume
   * c) tmpfs Mount
   * d) Anonymous Volume

4. How do you remove all volumes that are not currently used by any container?
   * a) `docker volume rm all`
   * b) `docker volume prune`
   * c) `docker network prune`
   * d) `docker volume purge`

5. What does the `ro` flag do in a mount command?
   * a) Runs Only
   * b) Root Only
   * c) Read-Only
   * d) Remote Only

6. Which flag is used to mount a volume from the command line using the shorthand syntax?
   * a) `-m`
   * b) `-v`
   * c) `-d`
   * d) `-p`

7. True or False: You can mount a single file using a Bind Mount.
   * a) True
   * b) False

8. What happens if you mount a non-empty volume to a container directory that already contains files?
   * a) The container files are deleted
   * b) The volume files are deleted
   * c) The volume files hide the container's original files
   * d) The files are merged

9. Which command allows you to see the exact host path of a volume?
   * a) `docker volume ls`
   * b) `docker volume inspect`
   * c) `docker volume stats`
   * d) `docker inspect container`

10. Which storage type is recommended for production databases?
    * a) Bind Mounts
    * b) tmpfs Mounts
    * c) Named Volumes
    * d) Storage Buckets

11. How do you mount a volume to a container so it is deleted when the container is removed?
    * a) Use an anonymous volume with `docker rm -v`
    * b) Use `--tmpfs`
    * c) Use a bind mount to `/tmp`
    * d) It happens by default

12. What is the default volume driver in Docker?
    * a) nfs
    * b) local
    * c) overlay2
    * d) cloud

13. Which command lists all volumes attached to your Docker host?
    * a) `docker ls volumes`
    * b) `docker volume ps`
    * c) `docker volume ls`
    * d) `docker show volumes`

14. How can you backup a volume?
    * a) Use `docker volume backup`
    * b) Copy files using a temporary container and `tar`
    * c) Use `docker commit`
    * d) It is done automatically

15. What is the limit of a `tmpfs` mount?
    * a) Host Disk space
    * b) 1GB
    * c) Host RAM capacity
    * d) Container Layer size

16. Which command executes a SQL script in a container while persisting data?
    * a) `docker run -v`
    * b) `docker exec`
    * c) `docker build`
    * d) `docker push`

17. Can you use a volume driver to mount an AWS S3 bucket directly?
    * a) Yes, using third-party plugins/drivers
    * b) No, only local disks are supported
    * c) Only in Docker Swarm
    * d) Reserved for Kubernetes

18. What is an 'Anonymous Volume'?
    * a) A volume without a name, identified by a long ID
    * b) A volume with secret data
    * c) A volume that cannot be inspected
    * d) A volume that is not stored on disk

19. Which syntax is more recommended for modern Docker scripts?
    * a) `-v`
    * b) `--volume`
    * c) `--mount`
    * d) `--link`

20. How do you share the exact same volume between 'Container A' and 'Container B'?
    * a) Use different source names
    * b) Define the same source name in both `docker run` commands
    * c) Copy the data manually
    * d) Use the `--share` flag

### Quiz Answer Key

1. **c) docker volume create**
2. **c) /var/lib/docker/volumes**
3. **c) tmpfs Mount**
4. **b) docker volume prune**
5. **c) Read-Only**
6. **b) -v**
7. **a) True**
8. **c) The volume files hide the container's original files**
9. **b) docker volume inspect**
10. **c) Named Volumes**
11. **a) Use an anonymous volume with docker rm -v**
12. **b) local**
13. **c) docker volume ls**
14. **b) Copy files using a temporary container and tar**
15. **c) Host RAM capacity**
16. **b) docker exec**
17. **a) Yes, using third-party plugins/drivers**
18. **a) A volume without a name, identified by a long ID**
19. **c) --mount**
20. **b) Define the same source name**

## Next Steps

- Learn about [Multi-Stage Builds](../03-Multi-Stage-Builds/README.md)
- Explore [Docker Registry](../04-Docker-Registry/README.md)
- Combine with [Docker Compose](../../Docker-Compose/Beginner/01-Basics/README.md)

## Resources

- [Docker Volumes Documentation](https://docs.docker.com/storage/volumes/)
- [Bind Mounts](https://docs.docker.com/storage/bind-mounts/)
- [tmpfs Mounts](https://docs.docker.com/storage/tmpfs/)
- [Volume Drivers](https://docs.docker.com/engine/extend/plugins_volume/)

---

**[← Previous: Docker Networking](../01-Docker-Networking/README.md)** | **[Next: Multi-Stage Builds →](../03-Multi-Stage-Builds/README.md)**
