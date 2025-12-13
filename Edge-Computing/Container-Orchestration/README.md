# Container Orchestration at the Edge

## Overview

Container orchestration at the edge involves managing containerized applications across distributed edge locations with limited resources, intermittent connectivity, and autonomous operation requirements.

## Kubernetes at the Edge

### K3s - Lightweight Kubernetes

```bash
# k3s-edge-installation.sh
#!/bin/bash

# K3s installation for edge devices
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" sh -s - \
  --disable traefik \
  --disable servicelb \
  --disable metrics-server \
  --write-kubeconfig-mode 644 \
  --node-name edge-node-$(hostname) \
  --data-dir /opt/k3s

# Configure for edge environment
mkdir -p /etc/rancher/k3s

cat > /etc/rancher/k3s/registries.yaml << EOF
mirrors:
  docker.io:
    endpoint:
      - "https://registry-1.docker.io"
  localhost:5000:
    endpoint:
      - "http://localhost:5000"
configs:
  "localhost:5000":
    tls:
      insecure_skip_verify: true
EOF

# Enable and start K3s
systemctl enable k3s
systemctl start k3s

# Wait for K3s to be ready
until kubectl get nodes | grep -q Ready; do
  echo "Waiting for K3s to be ready..."
  sleep 5
done

echo "K3s installation completed successfully"
```

### Edge-Optimized Kubernetes Configuration

```yaml
# edge-cluster-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: edge-cluster-config
  namespace: kube-system
data:
  # Edge-specific configurations
  edge-mode: "true"
  resource-constraints: "enabled"
  offline-capability: "true"
  local-storage: "enabled"
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: edge-resource-quota
  namespace: default
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    requests.storage: 20Gi
    limits.cpu: "4"
    limits.memory: 8Gi
    persistentvolumeclaims: "5"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: edge-limit-range
  namespace: default
spec:
  limits:
  - default:
      cpu: "200m"
      memory: "256Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    type: Container
```

### Edge Application Deployment

```python
# edge_k8s_manager.py
import yaml
import subprocess
import json
from typing import Dict, List, Any, Optional
from datetime import datetime

class EdgeKubernetesManager:
    def __init__(self, kubeconfig_path: Optional[str] = None):
        self.kubeconfig_path = kubeconfig_path
        self.kubectl_cmd = ["kubectl"]
        if kubeconfig_path:
            self.kubectl_cmd.extend(["--kubeconfig", kubeconfig_path])
    
    def create_edge_deployment(self, app_name: str, image: str, 
                              edge_config: Dict[str, Any]) -> Dict[str, Any]:
        """Create edge-optimized deployment"""
        
        deployment_manifest = {
            "apiVersion": "apps/v1",
            "kind": "Deployment",
            "metadata": {
                "name": app_name,
                "namespace": edge_config.get("namespace", "default"),
                "labels": {
                    "app": app_name,
                    "edge-deployment": "true"
                }
            },
            "spec": {
                "replicas": edge_config.get("replicas", 1),
                "selector": {
                    "matchLabels": {
                        "app": app_name
                    }
                },
                "template": {
                    "metadata": {
                        "labels": {
                            "app": app_name,
                            "edge-app": "true"
                        }
                    },
                    "spec": {
                        "nodeSelector": edge_config.get("node_selector", {}),
                        "tolerations": [
                            {
                                "key": "edge-node",
                                "operator": "Equal",
                                "value": "true",
                                "effect": "NoSchedule"
                            }
                        ],
                        "containers": [
                            {
                                "name": app_name,
                                "image": image,
                                "imagePullPolicy": "IfNotPresent",
                                "resources": {
                                    "requests": {
                                        "cpu": edge_config.get("cpu_request", "50m"),
                                        "memory": edge_config.get("memory_request", "64Mi")
                                    },
                                    "limits": {
                                        "cpu": edge_config.get("cpu_limit", "200m"),
                                        "memory": edge_config.get("memory_limit", "256Mi")
                                    }
                                },
                                "env": [
                                    {"name": "EDGE_MODE", "value": "true"},
                                    {"name": "NODE_NAME", "valueFrom": {
                                        "fieldRef": {"fieldPath": "spec.nodeName"}
                                    }}
                                ],
                                "volumeMounts": edge_config.get("volume_mounts", [])
                            }
                        ],
                        "volumes": edge_config.get("volumes", []),
                        "restartPolicy": "Always"
                    }
                }
            }
        }
        
        return deployment_manifest
    
    def deploy_application(self, manifest: Dict[str, Any]) -> bool:
        """Deploy application to edge cluster"""
        try:
            # Write manifest to temporary file
            manifest_file = f"/tmp/{manifest['metadata']['name']}-deployment.yaml"
            with open(manifest_file, 'w') as f:
                yaml.dump(manifest, f)
            
            # Apply manifest
            result = subprocess.run(
                self.kubectl_cmd + ["apply", "-f", manifest_file],
                capture_output=True,
                text=True,
                check=True
            )
            
            print(f"Deployment successful: {result.stdout}")
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"Deployment failed: {e.stderr}")
            return False
    
    def create_edge_service(self, app_name: str, port: int, 
                           service_type: str = "ClusterIP") -> Dict[str, Any]:
        """Create service for edge application"""
        
        service_manifest = {
            "apiVersion": "v1",
            "kind": "Service",
            "metadata": {
                "name": f"{app_name}-service",
                "labels": {
                    "app": app_name
                }
            },
            "spec": {
                "selector": {
                    "app": app_name
                },
                "ports": [
                    {
                        "port": port,
                        "targetPort": port,
                        "protocol": "TCP"
                    }
                ],
                "type": service_type
            }
        }
        
        return service_manifest
    
    def setup_local_storage(self, storage_class_name: str = "local-storage"):
        """Setup local storage for edge applications"""
        
        storage_class = {
            "apiVersion": "storage.k8s.io/v1",
            "kind": "StorageClass",
            "metadata": {
                "name": storage_class_name
            },
            "provisioner": "kubernetes.io/no-provisioner",
            "volumeBindingMode": "WaitForFirstConsumer"
        }
        
        # Create persistent volume
        pv_manifest = {
            "apiVersion": "v1",
            "kind": "PersistentVolume",
            "metadata": {
                "name": "edge-local-pv"
            },
            "spec": {
                "capacity": {
                    "storage": "10Gi"
                },
                "accessModes": ["ReadWriteOnce"],
                "persistentVolumeReclaimPolicy": "Retain",
                "storageClassName": storage_class_name,
                "local": {
                    "path": "/opt/edge-storage"
                },
                "nodeAffinity": {
                    "required": {
                        "nodeSelectorTerms": [
                            {
                                "matchExpressions": [
                                    {
                                        "key": "kubernetes.io/hostname",
                                        "operator": "In",
                                        "values": ["edge-node"]
                                    }
                                ]
                            }
                        ]
                    }
                }
            }
        }
        
        return storage_class, pv_manifest
    
    def monitor_edge_pods(self) -> List[Dict[str, Any]]:
        """Monitor edge pod status and resource usage"""
        try:
            # Get pod information
            result = subprocess.run(
                self.kubectl_cmd + ["get", "pods", "-o", "json"],
                capture_output=True,
                text=True,
                check=True
            )
            
            pods_data = json.loads(result.stdout)
            edge_pods = []
            
            for pod in pods_data.get("items", []):
                if pod.get("metadata", {}).get("labels", {}).get("edge-app") == "true":
                    pod_info = {
                        "name": pod["metadata"]["name"],
                        "namespace": pod["metadata"]["namespace"],
                        "status": pod["status"]["phase"],
                        "node": pod["spec"].get("nodeName"),
                        "created": pod["metadata"]["creationTimestamp"],
                        "containers": []
                    }
                    
                    # Get container information
                    for container in pod["spec"]["containers"]:
                        container_info = {
                            "name": container["name"],
                            "image": container["image"],
                            "resources": container.get("resources", {})
                        }
                        pod_info["containers"].append(container_info)
                    
                    edge_pods.append(pod_info)
            
            return edge_pods
            
        except subprocess.CalledProcessError as e:
            print(f"Failed to get pod information: {e.stderr}")
            return []
    
    def scale_edge_application(self, app_name: str, replicas: int) -> bool:
        """Scale edge application"""
        try:
            result = subprocess.run(
                self.kubectl_cmd + ["scale", "deployment", app_name, f"--replicas={replicas}"],
                capture_output=True,
                text=True,
                check=True
            )
            
            print(f"Scaled {app_name} to {replicas} replicas")
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"Scaling failed: {e.stderr}")
            return False
```

## MicroK8s for Edge

### MicroK8s Installation and Configuration

```python
# microk8s_edge_setup.py
import subprocess
import yaml
import time
from typing import List, Dict, Any

class MicroK8sEdgeSetup:
    def __init__(self):
        self.required_addons = [
            "dns",
            "storage",
            "registry",
            "metrics-server"
        ]
        self.optional_addons = [
            "prometheus",
            "grafana",
            "jaeger"
        ]
    
    def install_microk8s(self) -> bool:
        """Install MicroK8s on edge device"""
        try:
            # Install MicroK8s
            subprocess.run([
                "sudo", "snap", "install", "microk8s", "--classic", "--channel=1.28/stable"
            ], check=True)
            
            # Add user to microk8s group
            subprocess.run([
                "sudo", "usermod", "-a", "-G", "microk8s", "$USER"
            ], check=True)
            
            # Wait for MicroK8s to be ready
            self.wait_for_microk8s_ready()
            
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"MicroK8s installation failed: {e}")
            return False
    
    def wait_for_microk8s_ready(self, timeout: int = 300):
        """Wait for MicroK8s to be ready"""
        start_time = time.time()
        
        while time.time() - start_time < timeout:
            try:
                result = subprocess.run([
                    "microk8s", "status", "--wait-ready"
                ], capture_output=True, text=True, timeout=30)
                
                if result.returncode == 0:
                    print("MicroK8s is ready")
                    return True
                    
            except subprocess.TimeoutExpired:
                pass
            
            time.sleep(10)
        
        raise TimeoutError("MicroK8s failed to become ready within timeout")
    
    def enable_addons(self, addons: List[str] = None) -> Dict[str, bool]:
        """Enable MicroK8s addons"""
        if addons is None:
            addons = self.required_addons
        
        results = {}
        
        for addon in addons:
            try:
                subprocess.run([
                    "microk8s", "enable", addon
                ], check=True, capture_output=True)
                
                results[addon] = True
                print(f"Enabled addon: {addon}")
                
            except subprocess.CalledProcessError as e:
                results[addon] = False
                print(f"Failed to enable addon {addon}: {e}")
        
        return results
    
    def configure_edge_settings(self):
        """Configure MicroK8s for edge environment"""
        
        # Create edge configuration
        edge_config = {
            "apiVersion": "v1",
            "kind": "ConfigMap",
            "metadata": {
                "name": "edge-config",
                "namespace": "kube-system"
            },
            "data": {
                "edge-mode": "true",
                "resource-optimization": "enabled",
                "offline-capability": "true",
                "local-registry": "enabled"
            }
        }
        
        # Apply configuration
        config_file = "/tmp/edge-config.yaml"
        with open(config_file, 'w') as f:
            yaml.dump(edge_config, f)
        
        try:
            subprocess.run([
                "microk8s", "kubectl", "apply", "-f", config_file
            ], check=True)
            
            print("Edge configuration applied successfully")
            
        except subprocess.CalledProcessError as e:
            print(f"Failed to apply edge configuration: {e}")
    
    def setup_local_registry(self, registry_port: int = 32000):
        """Setup local container registry"""
        
        registry_deployment = {
            "apiVersion": "apps/v1",
            "kind": "Deployment",
            "metadata": {
                "name": "registry",
                "namespace": "container-registry"
            },
            "spec": {
                "replicas": 1,
                "selector": {
                    "matchLabels": {
                        "app": "registry"
                    }
                },
                "template": {
                    "metadata": {
                        "labels": {
                            "app": "registry"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "name": "registry",
                                "image": "registry:2",
                                "ports": [
                                    {
                                        "containerPort": 5000
                                    }
                                ],
                                "env": [
                                    {
                                        "name": "REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY",
                                        "value": "/var/lib/registry"
                                    }
                                ],
                                "volumeMounts": [
                                    {
                                        "name": "registry-storage",
                                        "mountPath": "/var/lib/registry"
                                    }
                                ]
                            }
                        ],
                        "volumes": [
                            {
                                "name": "registry-storage",
                                "hostPath": {
                                    "path": "/opt/registry-storage",
                                    "type": "DirectoryOrCreate"
                                }
                            }
                        ]
                    }
                }
            }
        }
        
        registry_service = {
            "apiVersion": "v1",
            "kind": "Service",
            "metadata": {
                "name": "registry-service",
                "namespace": "container-registry"
            },
            "spec": {
                "selector": {
                    "app": "registry"
                },
                "ports": [
                    {
                        "port": 5000,
                        "targetPort": 5000,
                        "nodePort": registry_port
                    }
                ],
                "type": "NodePort"
            }
        }
        
        try:
            # Create namespace
            subprocess.run([
                "microk8s", "kubectl", "create", "namespace", "container-registry"
            ], check=True)
            
            # Deploy registry
            registry_file = "/tmp/registry.yaml"
            with open(registry_file, 'w') as f:
                yaml.dump_all([registry_deployment, registry_service], f)
            
            subprocess.run([
                "microk8s", "kubectl", "apply", "-f", registry_file
            ], check=True)
            
            print(f"Local registry deployed on port {registry_port}")
            
        except subprocess.CalledProcessError as e:
            print(f"Failed to setup local registry: {e}")
    
    def configure_resource_limits(self):
        """Configure resource limits for edge environment"""
        
        resource_quota = {
            "apiVersion": "v1",
            "kind": "ResourceQuota",
            "metadata": {
                "name": "edge-resource-quota",
                "namespace": "default"
            },
            "spec": {
                "hard": {
                    "requests.cpu": "1",
                    "requests.memory": "2Gi",
                    "limits.cpu": "2",
                    "limits.memory": "4Gi",
                    "persistentvolumeclaims": "3"
                }
            }
        }
        
        limit_range = {
            "apiVersion": "v1",
            "kind": "LimitRange",
            "metadata": {
                "name": "edge-limit-range",
                "namespace": "default"
            },
            "spec": {
                "limits": [
                    {
                        "default": {
                            "cpu": "100m",
                            "memory": "128Mi"
                        },
                        "defaultRequest": {
                            "cpu": "50m",
                            "memory": "64Mi"
                        },
                        "type": "Container"
                    }
                ]
            }
        }
        
        try:
            limits_file = "/tmp/resource-limits.yaml"
            with open(limits_file, 'w') as f:
                yaml.dump_all([resource_quota, limit_range], f)
            
            subprocess.run([
                "microk8s", "kubectl", "apply", "-f", limits_file
            ], check=True)
            
            print("Resource limits configured successfully")
            
        except subprocess.CalledProcessError as e:
            print(f"Failed to configure resource limits: {e}")
```

## Docker Swarm for Edge

### Docker Swarm Edge Configuration

```python
# docker_swarm_edge.py
import docker
import json
from typing import Dict, List, Any, Optional
from datetime import datetime

class DockerSwarmEdgeManager:
    def __init__(self):
        self.client = docker.from_env()
        self.swarm_initialized = False
    
    def initialize_swarm(self, advertise_addr: str) -> Dict[str, Any]:
        """Initialize Docker Swarm for edge deployment"""
        try:
            # Initialize swarm
            self.client.swarm.init(
                advertise_addr=advertise_addr,
                listen_addr="0.0.0.0:2377"
            )
            
            self.swarm_initialized = True
            
            # Get join tokens
            swarm_info = self.client.swarm.attrs
            
            return {
                "status": "initialized",
                "node_id": swarm_info["ID"],
                "join_tokens": {
                    "worker": swarm_info["JoinTokens"]["Worker"],
                    "manager": swarm_info["JoinTokens"]["Manager"]
                }
            }
            
        except Exception as e:
            return {
                "status": "failed",
                "error": str(e)
            }
    
    def create_edge_service(self, service_name: str, image: str, 
                           edge_config: Dict[str, Any]) -> Dict[str, Any]:
        """Create edge-optimized Docker service"""
        
        # Service configuration for edge deployment
        service_spec = {
            "name": service_name,
            "task_template": {
                "ContainerSpec": {
                    "Image": image,
                    "Env": [
                        "EDGE_MODE=true",
                        f"SERVICE_NAME={service_name}"
                    ],
                    "Resources": {
                        "Limits": {
                            "NanoCPUs": int(edge_config.get("cpu_limit", 0.2) * 1e9),
                            "MemoryBytes": edge_config.get("memory_limit", 256) * 1024 * 1024
                        },
                        "Reservations": {
                            "NanoCPUs": int(edge_config.get("cpu_request", 0.1) * 1e9),
                            "MemoryBytes": edge_config.get("memory_request", 128) * 1024 * 1024
                        }
                    }
                },
                "RestartPolicy": {
                    "Condition": "on-failure",
                    "MaxAttempts": 3
                },
                "Placement": {
                    "Constraints": edge_config.get("placement_constraints", [])
                }
            },
            "Mode": {
                "Replicated": {
                    "Replicas": edge_config.get("replicas", 1)
                }
            },
            "UpdateConfig": {
                "Parallelism": 1,
                "FailureAction": "rollback",
                "Monitor": 30000000000  # 30 seconds in nanoseconds
            },
            "RollbackConfig": {
                "Parallelism": 1,
                "FailureAction": "pause"
            }
        }
        
        try:
            service = self.client.services.create(**service_spec)
            
            return {
                "status": "created",
                "service_id": service.id,
                "service_name": service_name
            }
            
        except Exception as e:
            return {
                "status": "failed",
                "error": str(e)
            }
    
    def create_edge_network(self, network_name: str) -> Dict[str, Any]:
        """Create overlay network for edge services"""
        try:
            network = self.client.networks.create(
                name=network_name,
                driver="overlay",
                options={
                    "encrypted": "true"
                },
                labels={
                    "edge-network": "true"
                }
            )
            
            return {
                "status": "created",
                "network_id": network.id,
                "network_name": network_name
            }
            
        except Exception as e:
            return {
                "status": "failed",
                "error": str(e)
            }
    
    def deploy_edge_stack(self, stack_name: str, compose_config: Dict[str, Any]) -> Dict[str, Any]:
        """Deploy complete edge application stack"""
        
        # Convert compose config to Docker Swarm services
        services_created = []
        
        for service_name, service_config in compose_config.get("services", {}).items():
            
            # Extract edge-specific configuration
            edge_config = {
                "replicas": service_config.get("deploy", {}).get("replicas", 1),
                "cpu_limit": service_config.get("deploy", {}).get("resources", {}).get("limits", {}).get("cpus", 0.2),
                "memory_limit": service_config.get("deploy", {}).get("resources", {}).get("limits", {}).get("memory", "256M"),
                "placement_constraints": service_config.get("deploy", {}).get("placement", {}).get("constraints", [])
            }
            
            # Parse memory limit
            memory_str = edge_config["memory_limit"]
            if isinstance(memory_str, str):
                if memory_str.endswith("M"):
                    edge_config["memory_limit"] = int(memory_str[:-1])
                elif memory_str.endswith("G"):
                    edge_config["memory_limit"] = int(memory_str[:-1]) * 1024
            
            # Create service
            result = self.create_edge_service(
                f"{stack_name}_{service_name}",
                service_config["image"],
                edge_config
            )
            
            services_created.append(result)
        
        return {
            "stack_name": stack_name,
            "services": services_created,
            "status": "deployed" if all(s["status"] == "created" for s in services_created) else "partial"
        }
    
    def monitor_edge_services(self) -> List[Dict[str, Any]]:
        """Monitor edge services status and resource usage"""
        services_info = []
        
        try:
            services = self.client.services.list()
            
            for service in services:
                service_info = {
                    "id": service.id,
                    "name": service.name,
                    "created": service.attrs["CreatedAt"],
                    "updated": service.attrs["UpdatedAt"],
                    "replicas": {
                        "desired": service.attrs["Spec"]["Mode"]["Replicated"]["Replicas"],
                        "running": 0,
                        "ready": 0
                    }
                }
                
                # Get task information
                tasks = service.tasks()
                service_info["replicas"]["running"] = len([t for t in tasks if t["Status"]["State"] == "running"])
                service_info["replicas"]["ready"] = len([t for t in tasks if t["Status"]["State"] == "running"])
                
                # Get resource configuration
                container_spec = service.attrs["Spec"]["TaskTemplate"]["ContainerSpec"]
                if "Resources" in container_spec:
                    resources = container_spec["Resources"]
                    service_info["resources"] = {
                        "cpu_limit": resources.get("Limits", {}).get("NanoCPUs", 0) / 1e9,
                        "memory_limit": resources.get("Limits", {}).get("MemoryBytes", 0) / (1024 * 1024),
                        "cpu_request": resources.get("Reservations", {}).get("NanoCPUs", 0) / 1e9,
                        "memory_request": resources.get("Reservations", {}).get("MemoryBytes", 0) / (1024 * 1024)
                    }
                
                services_info.append(service_info)
            
            return services_info
            
        except Exception as e:
            print(f"Failed to monitor services: {e}")
            return []
    
    def scale_edge_service(self, service_name: str, replicas: int) -> Dict[str, Any]:
        """Scale edge service"""
        try:
            service = self.client.services.get(service_name)
            service.scale(replicas)
            
            return {
                "status": "scaled",
                "service_name": service_name,
                "replicas": replicas
            }
            
        except Exception as e:
            return {
                "status": "failed",
                "error": str(e)
            }
    
    def update_edge_service(self, service_name: str, new_image: str) -> Dict[str, Any]:
        """Update edge service with new image"""
        try:
            service = self.client.services.get(service_name)
            
            # Update service with new image
            service.update(image=new_image)
            
            return {
                "status": "updated",
                "service_name": service_name,
                "new_image": new_image
            }
            
        except Exception as e:
            return {
                "status": "failed",
                "error": str(e)
            }
```

## Edge-Specific Orchestration Patterns

### Resource-Constrained Scheduling

```python
# edge_scheduler.py
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from enum import Enum
import heapq

class ResourceType(Enum):
    CPU = "cpu"
    MEMORY = "memory"
    STORAGE = "storage"
    NETWORK = "network"

@dataclass
class EdgeNode:
    node_id: str
    location: str
    available_resources: Dict[ResourceType, float]
    total_resources: Dict[ResourceType, float]
    workloads: List[str]
    connectivity_score: float  # 0-1, higher is better
    
    def resource_utilization(self, resource_type: ResourceType) -> float:
        """Calculate resource utilization percentage"""
        total = self.total_resources.get(resource_type, 0)
        available = self.available_resources.get(resource_type, 0)
        if total == 0:
            return 0
        return (total - available) / total

@dataclass
class Workload:
    workload_id: str
    resource_requirements: Dict[ResourceType, float]
    priority: int  # Higher number = higher priority
    latency_requirement: float  # Maximum acceptable latency in ms
    location_preference: Optional[str] = None
    
class EdgeScheduler:
    def __init__(self):
        self.nodes: Dict[str, EdgeNode] = {}
        self.workloads: Dict[str, Workload] = {}
        self.placement_history: List[Dict[str, Any]] = []
    
    def register_node(self, node: EdgeNode):
        """Register edge node with scheduler"""
        self.nodes[node.node_id] = node
    
    def schedule_workload(self, workload: Workload) -> Optional[str]:
        """Schedule workload to optimal edge node"""
        
        # Find candidate nodes that can accommodate the workload
        candidates = []
        
        for node_id, node in self.nodes.items():
            if self.can_accommodate_workload(node, workload):
                score = self.calculate_placement_score(node, workload)
                candidates.append((score, node_id))
        
        if not candidates:
            return None  # No suitable node found
        
        # Select node with highest score
        candidates.sort(reverse=True)
        selected_node_id = candidates[0][1]
        
        # Update node resources
        self.allocate_resources(selected_node_id, workload)
        
        # Record placement
        placement_record = {
            "workload_id": workload.workload_id,
            "node_id": selected_node_id,
            "timestamp": "now",  # Would use actual timestamp
            "score": candidates[0][0]
        }
        self.placement_history.append(placement_record)
        
        return selected_node_id
    
    def can_accommodate_workload(self, node: EdgeNode, workload: Workload) -> bool:
        """Check if node can accommodate workload"""
        for resource_type, required in workload.resource_requirements.items():
            available = node.available_resources.get(resource_type, 0)
            if available < required:
                return False
        return True
    
    def calculate_placement_score(self, node: EdgeNode, workload: Workload) -> float:
        """Calculate placement score for workload on node"""
        score = 0.0
        
        # Resource availability score (0-40 points)
        resource_score = 0
        for resource_type in ResourceType:
            utilization = node.resource_utilization(resource_type)
            # Prefer nodes with lower utilization
            resource_score += (1 - utilization) * 10
        
        score += min(40, resource_score)
        
        # Connectivity score (0-20 points)
        score += node.connectivity_score * 20
        
        # Location preference score (0-20 points)
        if workload.location_preference and workload.location_preference == node.location:
            score += 20
        
        # Load balancing score (0-20 points)
        # Prefer nodes with fewer workloads
        workload_count = len(node.workloads)
        max_workloads = 10  # Assumed maximum
        load_balance_score = max(0, (max_workloads - workload_count) / max_workloads * 20)
        score += load_balance_score
        
        return score
    
    def allocate_resources(self, node_id: str, workload: Workload):
        """Allocate resources for workload on node"""
        node = self.nodes[node_id]
        
        for resource_type, required in workload.resource_requirements.items():
            current_available = node.available_resources.get(resource_type, 0)
            node.available_resources[resource_type] = current_available - required
        
        node.workloads.append(workload.workload_id)
        self.workloads[workload.workload_id] = workload
    
    def deallocate_resources(self, node_id: str, workload_id: str):
        """Deallocate resources when workload is removed"""
        if workload_id not in self.workloads:
            return
        
        node = self.nodes[node_id]
        workload = self.workloads[workload_id]
        
        for resource_type, required in workload.resource_requirements.items():
            current_available = node.available_resources.get(resource_type, 0)
            node.available_resources[resource_type] = current_available + required
        
        if workload_id in node.workloads:
            node.workloads.remove(workload_id)
        
        del self.workloads[workload_id]
    
    def rebalance_workloads(self) -> List[Dict[str, str]]:
        """Rebalance workloads across nodes for optimal resource utilization"""
        migrations = []
        
        # Find overloaded and underloaded nodes
        overloaded_nodes = []
        underloaded_nodes = []
        
        for node_id, node in self.nodes.items():
            avg_utilization = sum(node.resource_utilization(rt) for rt in ResourceType) / len(ResourceType)
            
            if avg_utilization > 0.8:  # Over 80% utilization
                overloaded_nodes.append((avg_utilization, node_id))
            elif avg_utilization < 0.3:  # Under 30% utilization
                underloaded_nodes.append((avg_utilization, node_id))
        
        # Sort nodes by utilization
        overloaded_nodes.sort(reverse=True)
        underloaded_nodes.sort()
        
        # Migrate workloads from overloaded to underloaded nodes
        for _, overloaded_node_id in overloaded_nodes:
            overloaded_node = self.nodes[overloaded_node_id]
            
            for workload_id in overloaded_node.workloads[:]:  # Copy list to avoid modification during iteration
                workload = self.workloads[workload_id]
                
                # Find suitable underloaded node
                for _, underloaded_node_id in underloaded_nodes:
                    underloaded_node = self.nodes[underloaded_node_id]
                    
                    if self.can_accommodate_workload(underloaded_node, workload):
                        # Perform migration
                        self.deallocate_resources(overloaded_node_id, workload_id)
                        self.allocate_resources(underloaded_node_id, workload)
                        
                        migrations.append({
                            "workload_id": workload_id,
                            "from_node": overloaded_node_id,
                            "to_node": underloaded_node_id
                        })
                        
                        break
        
        return migrations
    
    def get_cluster_metrics(self) -> Dict[str, Any]:
        """Get cluster-wide metrics"""
        total_nodes = len(self.nodes)
        total_workloads = len(self.workloads)
        
        # Calculate average resource utilization
        total_utilization = {rt: 0.0 for rt in ResourceType}
        
        for node in self.nodes.values():
            for resource_type in ResourceType:
                total_utilization[resource_type] += node.resource_utilization(resource_type)
        
        avg_utilization = {
            rt.value: total_utilization[rt] / total_nodes if total_nodes > 0 else 0
            for rt in ResourceType
        }
        
        return {
            "total_nodes": total_nodes,
            "total_workloads": total_workloads,
            "average_resource_utilization": avg_utilization,
            "placement_success_rate": self.calculate_placement_success_rate()
        }
    
    def calculate_placement_success_rate(self) -> float:
        """Calculate placement success rate"""
        if not self.placement_history:
            return 0.0
        
        successful_placements = len(self.placement_history)
        # In a real implementation, you'd track failed placement attempts
        total_attempts = successful_placements  # Simplified
        
        return successful_placements / total_attempts if total_attempts > 0 else 0.0
```

## Best Practices

### Edge Container Orchestration Best Practices

1. **Resource Optimization**
   - Use minimal base images
   - Implement resource limits and requests
   - Optimize container startup time

2. **Offline Capability**
   - Local image caching
   - Autonomous operation modes
   - Local service discovery

3. **Security**
   - Image scanning and verification
   - Network segmentation
   - Secrets management

4. **Monitoring and Observability**
   - Resource usage monitoring
   - Application health checks
   - Distributed logging

5. **Update Strategies**
   - Rolling updates with health checks
   - Rollback capabilities
   - Staged deployments

## Conclusion

Container orchestration at the edge requires specialized approaches that account for resource constraints, connectivity challenges, and autonomous operation requirements. Success depends on choosing the right orchestration platform, implementing edge-specific configurations, and following best practices for resource management, security, and monitoring.