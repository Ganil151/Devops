#!/usr/bin/env python3
"""
Topic: Docker and Kubernetes SDKs
Description: Demonstrates simple Kubernetes cluster interaction.
"""

# Note: requires 'kubernetes' package
# pip install kubernetes

try:
    from kubernetes import client, config
    from kubernetes.client.rest import ApiException
except ImportError:
    print("❌ Error: 'kubernetes' SDK not installed. Run 'pip install kubernetes'")
    import sys
    sys.exit(0) # Silent exit for demo

def list_pods(namespace: str = "default"):
    """🚀 Standard: Querying infrastructure state via official SDK."""
    try:
        # Load local ~/.kube/config
        config.load_kube_config()
        
        v1 = client.CoreV1Api()
        print(f"📡 Querying Pods in namespace: {namespace}...")
        
        ret = v1.list_namespaced_pod(namespace)
        
        if not ret.items:
            print(f"✅ No pods found in {namespace}.")
            return

        for i, pod in enumerate(ret.items):
            print(f"  {i+1}. [{pod.status.phase}] {pod.metadata.name} (IP: {pod.status.pod_ip})")

    except ApiException as e:
        print(f"❌ K8s API Error: {e}")
    except Exception as e:
        print(f"💥 Could not connect to cluster: {e}")

if __name__ == "__main__":
    # list_pods()
    print("📋 Sample code initialized. Connection to cluster required.")
