"""
Solution: The Resource Calculator
"""

# Inputs
node_count = 5
node_cpu = 4
node_memory_gb = 16
overhead_percent = 0.10

# Calculations
server_overhead_cpu = node_cpu * overhead_percent
server_overhead_mem = node_memory_gb * overhead_percent

usable_cpu_per_node = node_cpu - server_overhead_cpu
usable_mem_per_node = node_memory_gb - server_overhead_mem

total_cluster_cpu = usable_cpu_per_node * node_count
total_cluster_mem = usable_mem_per_node * node_count

# Report
print(f"--- Cluster Capacity Report ---")
print(f"Nodes: {node_count}")
print(f"Usable Per Node: {usable_cpu_per_node} vCPU / {usable_mem_per_node} GB RAM")
print(f"Total Cluster:   {total_cluster_cpu} vCPU / {total_cluster_mem} GB RAM")
