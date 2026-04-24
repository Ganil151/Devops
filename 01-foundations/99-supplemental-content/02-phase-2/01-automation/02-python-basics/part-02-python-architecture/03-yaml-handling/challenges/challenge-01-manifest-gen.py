"""
Challenge: K8s Manifest Generator
Scenario: You need to automate the creation of Kubernetes deployment manifests.
Instead of manually editing YAML files, you will create a Python function that generates them.

TODO: Implement `generate_deployment(app_name, image, replicas=1, port=8080)` function.
1. Create a Python dictionary representing a K8s Deployment.
2. The deployment must include labels, selector, and resource limits/requests.
3. Use 'yaml.dump' to return a string of valid YAML.
"""
import yaml

def generate_deployment(app_name, image, replicas=1, port=8080):
    """
    Generates a Kubernetes Deployment manifest as a YAML string.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test your function
    manifest = generate_deployment(
        app_name="web-api", 
        image="nginx:1.21", 
        replicas=3, 
        port=80
    )
    print("Generated Kubernetes Manifest:")
    print(manifest)
