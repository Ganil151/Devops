import psutil
from psutil import cpu_percent


cpu_percent = psutil.cpu_percent(interval=1)
memory = psutil.virtual_memory()

# Print CPU and Memory usage statistics
print("CPU and Memory Usage Statistics:")
# CPU Usage
print(f"CPU Usage: {cpu_percent}%")
# Memory Usage
print(f"Memory Usage: {memory.percent}%")
# Detailed Memory Information
print(f"Total Memory: {memory.total / (1024 ** 3):.2f} GB")
# Available Memory
print(f"Available Memory: {memory.available / (1024 ** 3):.2f} GB")
# Used Memory
print(f"Used Memory: {memory.used / (1024 ** 3):.2f} GB")
# Free Memory
print(f"Memory Free: {memory.free / (1024 ** 3):.2f} GB") 
# Active, Inactive, Buffers, Cached, Shared, Slab
print(f"Memory Active: {memory.active / (1024 ** 3):.2f} GB")
print(f"Memory Inactive: {memory.inactive / (1024 ** 3):.2f} GB")
print(f"Memory Buffers: {memory.buffers / (1024 ** 3):.2f} GB")
print(f"Memory Cached: {memory.cached / (1024 ** 3):.2f} GB")
print(f"Memory Shared: {memory.shared / (1024 ** 3):.2f} GB")
print(f"Memory Slab: {memory.slab / (1024 ** 3):.2f} GB")
print(f"Memory Percent Used: {memory.percent}%")