"""
Cloud Dispatcher Demo: Multi-Cloud Provisioning using First-Class Functions
-------------------------------------------------------------------------
This script demonstrates how to build a dynamic automation pipeline by 
treating functions as data (First-Class Functions).

Architecture:
1. Provider Functions: Individual functions for specific cloud logic.
2. Dispatcher: A dictionary mapping cloud names to functions.
3. Orchestrator: A single entry point that manages the flow.
"""

from typing import Callable, Any, Dict

# --- 1. First-Class Functions (The "Workers") ---

def provision_aws(resource_name: str, **metadata: Any) -> None:
    """Mock AWS Provisioning logic."""
    region = metadata.get("region", "us-east-1")
    instance_type = metadata.get("instance_type", "t3.micro")
    print(f"[AWS] Provisioning {resource_name} in {region} (Type: {instance_type})")

def provision_azure(resource_name: str, **metadata: Any) -> None:
    """Mock Azure Provisioning logic."""
    location = metadata.get("location", "eastus")
    vm_size = metadata.get("vm_size", "Standard_B1s")
    print(f"[Azure] Provisioning {resource_name} in {location} (Size: {vm_size})")

def provision_gcp(resource_name: str, **metadata: Any) -> None:
    """Mock GCP Provisioning logic."""
    zone = metadata.get("zone", "us-central1-a")
    machine_type = metadata.get("machine_type", "n1-standard-1")
    print(f"[GCP] Provisioning {resource_name} in {zone} (Machine: {machine_type})")


# --- 2. The Dispatcher (Functions as Data) ---

# We store the function objects themselves in a dictionary.
# This eliminates long if-elif-else chains.
CLOUD_HANDLERS: Dict[str, Callable] = {
    "aws": provision_aws,
    "azure": provision_azure,
    "gcp": provision_gcp
}


# --- 3. The Orchestrator (Modular Interface) ---

def deploy_infrastructure(provider: str, name: str, **config: Any) -> None:
    """
    Orchestrates deployment across different cloud providers.
    
    Args:
        provider: The cloud name ('aws', 'azure', 'gcp').
        name: Name for the resource being created.
        **config: Cloud-specific parameters (region, zone, etc.).
    """
    provider = provider.lower()
    
    # Validation step
    if provider not in CLOUD_HANDLERS:
        print(f"Error: Infrastructure provider '{provider}' is not supported.")
        return

    print(f"--Starting Deployment for {name}--")
    
    # Dynamically select and call the function
    # Note: We are calling the function retrieved from the dictionary!
    handler = CLOUD_HANDLERS[provider]
    handler(name, **config)
    
    print(f"--Deployment of {name} Complete--\n")


# --- 4. Execution (Dynamic usage) ---

if __name__ == "__main__":
    # Example 1: Standard AWS Deployment
    deploy_infrastructure("aws", "web-server-01", region="eu-west-1", instance_type="m5.large")
    
    # Example 2: Standard GCP Deployment
    deploy_infrastructure("gcp", "data-bucket", zone="europe-west3-c")
    
    # Example 3: Handling an unsupported provider gracefully
    deploy_infrastructure("digitalocean", "droplet-01")
    
    # PRO TIP: You can even expand this at runtime!
    def provision_on_prem(name, **kwargs):
        print(f"[On-Prem] Deploying {name} to local hypervisor.")
        
    CLOUD_HANDLERS["local"] = provision_on_prem
    deploy_infrastructure("local", "dev-db")
