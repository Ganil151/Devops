
import os
import re

infra_types = {
    "Type 1: Enterprise": ["enterprise", "active-directory", "corporate"],
    "Type 2: Cloud-Native": ["cloud-native", "eks", "gke", "aks", "kubernetes-native"],
    "Type 3: Hybrid": ["hybrid", "vpn", "direct-connect", "on-prem-to-cloud"],
    "Type 4: Multi-Cloud": ["multi-cloud", "cross-cloud", "aws-and-azure", "terraform-cloud"],
    "Type 5: Edge": ["edge", "cloudfront", "lambda@edge", "iot-greengrass"],
    "Type 6: Serverless": ["serverless", "lambda", "fargate", "api-gateway", "event-driven"],
    "Type 7: On-Premise": ["on-premise", "on-prem", "data-center", "colocation"],
    "Type 8: Containerized": ["docker", "container", "kubernetes", "k8s", "ecs"],
    "Type 9: Monolithic": ["monolith", "monolithic", "three-tier", "傳統架構"],
    "Type 10: Microservices": ["microservice", "service-mesh", "api-first"],
    "Type 11: Event-Driven": ["event-driven", "sqs", "sns", "eventbridge", "kafka"],
    "Type 12: Bare Metal": ["bare-metal", "physical-server", "dedicated-host"],
    "Type 13: Virtualized": ["virtualization", "vmware", "vsphere", "ec2-instance"],
    "Type 14: Software-Defined": ["software-defined", "sdn", "iac", "programmable"],
    "Type 15: Immutable": ["immutable", "blue-green", "canary", "packer"],
    "Type 16: Dynamic": ["dynamic", "autoscaling", "elastic"],
    "Type 17: Legacy": ["legacy", "migration", "rehosting", "refactoring"]
}

base_dir = "/home/gsmash/Documents/Devops/"
mapping = {k: [] for k in infra_types}

for root, dirs, files in os.walk(base_dir):
    if ".git" in root or ".terraform" in root or "node_modules" in root:
        continue
    for file in files:
        if file.endswith("README.md") or file.endswith("readme.md") or file.endswith("Lab.md"):
            path = os.path.join(root, file)
            try:
                with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read().lower()
                    for type_name, keywords in infra_types.items():
                        if any(keyword in content for keyword in keywords):
                            rel_path = os.path.relpath(root, base_dir)
                            if rel_path not in mapping[type_name]:
                                mapping[type_name].append(rel_path)
            except Exception as e:
                pass

print("| Infrastructure Type | Directories Found |")
print("|---------------------|-------------------|")
for type_name, dirs in mapping.items():
    if dirs:
        print(f"| {type_name} | {', '.join(dirs)} |")
    else:
        print(f"| {type_name} | **NONE** |")
