from mcp.server.fastmcp import FastMCP
from kubernetes import client, config
import json
import logging
import os

# Initialize FastMCP
mcp = FastMCP("K8s-SRE-Assistant")

# Setup Kubernetes client
try:
    # This will load from ~/.kube/config or service account if in cluster
    config.load_kube_config()
    v1 = client.CoreV1Api()
    apps_v1 = client.AppsV1Api()
except Exception as e:
    logging.error(f"Failed to load Kubeconfig: {e}")

@mcp.tool()
def list_pods(namespace: str = "default") -> str:
    """
    Lists all pods in a given namespace with their status and restart counts.
    Use this to identify crashing pods.
    """
    try:
        pods = v1.list_namespaced_pod(namespace)
        pod_list = []
        for p in pods.items:
            pod_list.append({
                "name": p.metadata.name,
                "status": p.status.phase,
                "restarts": p.status.container_statuses[0].restart_count if p.status.container_statuses else 0,
                "ip": p.status.pod_ip
            })
        return json.dumps(pod_list, indent=2)
    except Exception as e:
        return f"Error listing pods: {str(e)}"

@mcp.tool()
def get_pod_logs(pod_name: str, namespace: str = "default", tail_lines: int = 50) -> str:
    """
    Fetches the last N lines of logs from a specific pod.
    """
    try:
        logs = v1.read_namespaced_pod_log(name=pod_name, namespace=namespace, tail_lines=tail_lines)
        return logs
    except Exception as e:
        return f"Error fetching logs for {pod_name}: {str(e)}"

@mcp.tool()
def describe_deployment(name: str, namespace: str = "default") -> str:
    """
    Returns the current scale and image information for a deployment.
    """
    try:
        dep = apps_v1.read_namespaced_deployment(name=name, namespace=namespace)
        info = {
            "name": dep.metadata.name,
            "replicas": dep.spec.replicas,
            "ready_replicas": dep.status.ready_replicas,
            "image": dep.spec.template.spec.containers[0].image
        }
        return json.dumps(info, indent=2)
    except Exception as e:
        return f"Error describing deployment {name}: {str(e)}"

@mcp.resource("k8s://cluster-info")
def get_cluster_context() -> str:
    """
    Returns basic information about the current Kubernetes context being used.
    """
    try:
        contexts, active_context = config.list_kube_config_contexts()
        return f"Active Context: {active_context['name']}\nCluster: {active_context['context']['cluster']}"
    except Exception as e:
        return f"Error retrieving cluster info: {str(e)}"

if __name__ == "__main__":
    mcp.run()
