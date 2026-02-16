total_disk_gb = 500
used_disk_gb = 150

usage_ratio: float = used_disk_gb / total_disk_gb
usage_percent: float = usage_ratio * 100

print(f"Disk Usage: {usage_percent}%")

remaining_blocks: int = 1025 % 512
print(f"Residual data blocks size: {remaining_blocks} bytes")