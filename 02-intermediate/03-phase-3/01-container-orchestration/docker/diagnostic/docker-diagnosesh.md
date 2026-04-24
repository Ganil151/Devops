```bash
#!/bin/bash

echo "=== Docker System Info ==="
docker info | grep -E 'Server Version|Storage Driver|Logging Driver|Cgroup Driver|Kernel Version'

echo -e "\n=== Disk Usage ==="
docker system df

echo -e "\n=== Running Containers ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo -e "\n=== Container Resource Usage ==="
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

echo -e "\n=== Docker Networks ==="
docker network ls

echo -e "\n=== Recent Container Logs (Errors) ==="
for container in $(docker ps -q); do
    name=$(docker inspect -f '{{.Name}}' $container | sed 's/\///')
    echo "--- $name ---"
    docker logs --tail 20 $container 2>&1 | grep -i "error\|exception\|fatal" | head -5
done

echo -e "\n=== Container Health Status ==="
for container in $(docker ps -q); do
    name=$(docker inspect -f '{{.Name}}' $container | sed 's/\///')
    health=$(docker inspect -f '{{.State.Health.Status}}' $container 2>/dev/null || echo "no healthcheck")
    echo "$name: $health"
done
```