#!/bin/bash

set -e

echo "=== Fixing /tmp Space Issue ==="
echo ""

# Step 1: Check if /tmp directory exists, create if missing
if [ ! -d "/tmp" ]; then
    echo "WARNING: /tmp directory does not exist! Creating it..."
    sudo mkdir -p /tmp
    echo "✓ /tmp directory created"
else
    echo "✓ /tmp directory exists"
fi

# Step 2: Set proper permissions (1777 = sticky bit + rwxrwxrwx)
echo "Setting proper permissions on /tmp..."
sudo chmod 1777 /tmp
echo "✓ Permissions set to 1777 (drwxrwxrwt)"
echo ""

# Verify /tmp status
echo "Current /tmp status:"
ls -ld /tmp
echo ""

# Check current /tmp usage (if mounted)
echo "Current /tmp usage:"
df -h /tmp 2>/dev/null || echo "  /tmp not mounted yet"
echo ""

# Step 3: Clean up old temporary files
echo "Step 3: Cleaning up old temporary files..."
sudo find /tmp -type f -atime +1 -delete 2>/dev/null || true
sudo find /tmp -type d -empty -delete 2>/dev/null || true
echo "✓ Cleanup complete"

echo "After cleanup:"
df -h /tmp 2>/dev/null || echo "  /tmp not mounted yet"
echo ""

# Step 4: Increase /tmp size persistently in /etc/fstab
echo "Step 4: Configuring /tmp in /etc/fstab for 2.0 GB size..."
if ! grep -q "tmpfs[[:space:]]/tmp[[:space:]]tmpfs" /etc/fstab; then
    echo "Adding tmpfs entry to /etc/fstab..."
    echo "tmpfs /tmp tmpfs defaults,size=2000M 0 0" | sudo tee -a /etc/fstab
    echo "✓ Added to /etc/fstab"
else
    echo "✓ /tmp tmpfs entry already exists in /etc/fstab"
fi

# Step 5: Mount /tmp as tmpfs
echo ""
echo "Step 5: Mounting /tmp with new size..."
if mount | grep -q "on /tmp type tmpfs"; then
    echo "/tmp is already mounted as tmpfs, remounting with new size..."
    if sudo mount -o remount /tmp; then
        echo "✓ /tmp remounted successfully"
    else
        echo "⚠ Warning: Failed to remount /tmp immediately"
        echo "  The change will take effect after reboot"
    fi
else
    echo "/tmp is not mounted as tmpfs, mounting it now..."
    if sudo mount /tmp 2>/dev/null; then
        echo "✓ /tmp mounted successfully"
    else
        echo "⚠ Warning: Failed to mount /tmp immediately"
        echo "  The change will take effect after reboot"
    fi
fi

echo ""
echo "Final /tmp status:"
echo "===================="
ls -ld /tmp
df -h /tmp

echo ""
echo "=== Fix Complete ==="
echo "Reboot the system to apply the changes."
