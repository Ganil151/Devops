"""
Solution: K8s Replica Scaler
"""
import yaml

def scale_replicas(yaml_path, scale_factor=2):
    # Load
    with open(yaml_path, 'r') as f:
        config = yaml.safe_load(f)
        
    # Modify (safely handle missing keys)
    if "spec" in config and "replicas" in config["spec"]:
        current = config["spec"]["replicas"]
        config["spec"]["replicas"] = current * scale_factor
        
    # Save
    with open("scaled_deploy.yaml", "w") as f:
        yaml.safe_dump(config, f)

if __name__ == "__main__":
    # Test logic
    pass
