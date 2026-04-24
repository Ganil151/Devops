"""
Challenge: K8s Replica Scaler
Scenario: You need to double the replicas for a specific microservice 
during a high-traffic event.

TODO: Implement `scale_replicas(yaml_path, scale_factor=2)`.
1. Load the Kubernetes YAML file.
2. Locate the `replicas` field. (Standard path: spec -> replicas).
3. Update the value by multiplying by `scale_factor`.
4. Save the modified YAML to a new file 'scaled_deploy.yaml'.
"""
import yaml
from pathlib import Path

def scale_replicas(yaml_path, scale_factor=2):
    """
    Scales the replica count in a K8s deployment YAML.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test Setup
    k8s_file = "deployment.yaml"
    k8s_content = {
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "metadata": {"name": "web-app"},
        "spec": {
            "replicas": 3,
            "template": {"spec": {"containers": [{"name": "nginx"}]}}
        }
    }
    with open(k8s_file, "w") as f:
        yaml.safe_dump(k8s_content, f)
        
    scale_replicas(k8s_file, scale_factor=3)
    
    # Verify
    if Path("scaled_deploy.yaml").exists():
        with open("scaled_deploy.yaml") as f:
            scaled = yaml.safe_load(f)
            print(f"Old Replicas: 3, New Replicas: {scaled['spec']['replicas']}")
