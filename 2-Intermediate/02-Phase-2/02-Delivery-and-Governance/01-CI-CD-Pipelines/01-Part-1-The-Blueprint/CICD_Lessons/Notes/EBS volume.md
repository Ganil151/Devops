- Go to **AWS Console → EC2 → Volumes**.    
- Find the EBS volume attached to your instance.    
- Modify it: increase from 8 GiB → e.g. 30 GiB.    
- On the instance, run:
```bash
lsblk   # confirm the new size
sudo growpart /dev/nvme0n1 1
sudo xfs_growfs -d /
```
> This resizes the root partition live without reboot.
#### Option 2: Attach a new EBS volume and mount it**

1. Create a new EBS volume (e.g. 20 GiB) in the same AZ.    
2. Attach it to the instance.    
3. Format and mount it (say, for Docker storage):
```bash
sudo mkfs.xfs /dev/nvme1n1
sudo mkdir -p /var/lib/docker
sudo mount /dev/nvme1n1 /var/lib/docker
```
Update `/etc/fstab`:
```bash
/dev/nvme1n1 /var/lib/docker xfs defaults,noatime 0 2
```
Restart Docker:
```bash
sudo systemctl restart docker
```

#### Option 3: Clean up space temporarily (quick fix)
- Remove old Docker images/containers:
```bash
docker system prune -af --volumes
```
Clean yum cache:
```bash
sudo yum clean all
```
Check large files:
```bash
sudo du -sh /* | sort -h

```
