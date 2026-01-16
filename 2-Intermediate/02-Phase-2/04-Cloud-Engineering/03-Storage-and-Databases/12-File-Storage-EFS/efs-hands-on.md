# Hands-on EFS Guide: Console & CLI

Learn how to create an AWS EFS file system, configure network access, and mount it to multiple EC2 instances.

## 1. Creating an EFS File System

### Using the Management Console
1. Navigate to the **EFS Console**.
2. Click **Create file system**.
3. **Name**: `my-shared-efs`.
4. **VPC**: Select your target VPC.
5. **Storage Class**: Choose **Standard** (for Multi-AZ redundancy).
6. Click **Customized** to configure performance modes (optional) or click **Create** for a quick setup.

### Using the AWS CLI
```bash
# 1. Create the File System
FILE_SYSTEM_ID=$(aws efs create-file-system \
    --performance-mode generalPurpose \
    --throughput-mode elastic \
    --tags Key=Name,Value=my-shared-efs \
    --query 'FileSystemId' --output text)

echo "File System ID: $FILE_SYSTEM_ID"
```

## 2. Configuring Network Access (Mount Targets)

For an instance to connect to EFS, it must reach the **Mount Target** within its subnet.

1. **Security Group**: Create a security group for the EFS mount targets that allows inbound **NFS (Port 2049)** from your EC2 security group.
2. **Mount Targets**: Create a mount target in each Availability Zone where your EC2 instances reside.

```bash
# Create mount target in a specific subnet
aws efs create-mount-target \
    --file-system-id $FILE_SYSTEM_ID \
    --subnet-id [SUBNET_ID] \
    --security-groups [EFS_SG_ID]
```

## 3. Mounting EFS on EC2

The easiest way to mount EFS is using the `amazon-efs-utils` tool.

### Step 1: Install the EFS Helper
```bash
sudo yum install -y amazon-efs-utils  # For Amazon Linux
# OR
sudo apt-get install -y binutils      # For Ubuntu/Debian
git clone https://github.com/aws/efs-utils
cd efs-utils && ./build-deb.sh && sudo apt-get install ./build/amazon-efs-utils*deb
```

### Step 2: Create a Mount Point and Mount
```bash
sudo mkdir -p /mnt/efs
sudo mount -t efs $FILE_SYSTEM_ID:/ /mnt/efs
```

### Step 3: Automating Mount on Reboot (`/etc/fstab`)
Add the following line to ensure the drive persists after a restart:
```text
fs-XXXXXXXX:/ /mnt/efs efs _netdev,tls 0 0
```

## 4. Managing Permissions & Ownership

By default, only `root` can write to the mount. 
```bash
# Give ownership to the ec2-user
sudo chown ec2-user:ec2-user /mnt/efs
```

## 5. Cleaning Up
```bash
# 1. Unmount the file system
sudo umount /mnt/efs

# 2. Delete mount targets (find IDs via list-mount-targets)
aws efs delete-mount-target --mount-target-id [MOUNT_TARGET_ID]

# 3. Delete file system
aws efs delete-file-system --file-system-id $FILE_SYSTEM_ID
```

---
**Next Step**: Explore [Advanced EFS Patterns & Troubleshooting](../../../../../3-Advanced/02-Phase-2/11-Enterprise-Cloud/13-File-Storage-EFS/efs-advanced-patterns.md)
