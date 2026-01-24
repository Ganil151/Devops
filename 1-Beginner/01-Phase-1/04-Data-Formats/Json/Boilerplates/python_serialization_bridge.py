"""
🛠️ The Python-to-JSON Serialization Bridge
Focus: Handling complex data types (Datetimes, Decimals, Custom Objects) that the 
standard `json` library cannot handle natively.
"""

import json
from datetime import datetime
from decimal import Decimal
from uuid import UUID, uuid4

class DevOpsResource:
    """A custom class representing a cloud resource."""
    def __init__(self, name, resource_type):
        self.id = uuid4()
        self.name = name
        self.type = resource_type
        self.created_at = datetime.now()
        self.specs = {
            "cost_per_hour": Decimal("0.052"),
            "region": "us-east-1"
        }

class DevOpsEncoder(json.JSONEncoder):
    """
    Fail-Safe Custom Encoder:
    Converts Python objects that are NOT JSON-serializable by default.
    """
    def default(self, obj):
        if isinstance(obj, datetime):
            return obj.isoformat()  # Standard ISO 8601 string
        if isinstance(obj, Decimal):
            return float(obj)       # API expected format
        if isinstance(obj, UUID):
            return str(obj)         # Convert to string
        if isinstance(obj, DevOpsResource):
            # Transform custom object into a dictionary
            return {
                "resource_id": str(obj.id),
                "resource_name": obj.name,
                "created": obj.created_at.isoformat()
            }
        # Fall back to base class (raises TypeError if unhandled)
        return super().default(obj)

# 🚀 Practical Execution
def run_bridge_demo():
    # 1. Create complex data structure
    infrastructure_state = {
        "audit_id": uuid4(),
        "timestamp": datetime.utcnow(),
        "resources": [
            DevOpsResource("web-01", "ec2-instance"),
            DevOpsResource("db-prod", "rds-instance")
        ],
        "total_estimated_cost": Decimal("124.50")
    }

    print("--- 🔬 Python Object (In-Memory) ---")
    print(type(infrastructure_state))

    # 2. Serialize to JSON using the custom encoder
    json_output = json.dumps(
        infrastructure_state, 
        cls=DevOpsEncoder, 
        indent=4
    )

    print("\n--- ⚡ JSON String (Ready for API Transmission) ---")
    print(json_output)

    # 3. Logic Bridge: Ensuring interoperability
    # This JSON can now be sent via POST request or saved to a configuration file.

if __name__ == "__main__":
    run_bridge_demo()
