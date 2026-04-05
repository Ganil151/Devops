"""
Solution: K8s Manifest Generator
"""
import yaml

def generate_deployment(app_name, image, replicas=1, port=8080):
    """Generate Kubernetes Deployment manifest dictionary and dump to YAML."""
    deployment = {
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "metadata": {
            "name": app_name,
            "labels": {"app": app_name}
        },
        "spec": {
            "replicas": replicas,
            "selector": {
                "matchLabels": {"app": app_name}
            },
            "template": {
                "metadata": {
                    "labels": {"app": app_name}
                },
                "spec": {
                    "containers": [{
                        "name": app_name,
                        "image": image,
                        "ports": [{"containerPort": port}],
                        "resources": {
                            "limits": {"cpu": "500m", "memory": "256Mi"},
                            "requests": {"cpu": "100m", "memory": "128Mi"}
                        }
                    }]
                }
            }
        }
    }
    
    return yaml.dump(deployment, default_flow_style=False, sort_keys=False)

if __name__ == "__main__":
    print(generate_deployment("web-api", "nginx:latest", replicas=3))
