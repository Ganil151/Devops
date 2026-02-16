"""
Solution: API Response Parser
"""
import json

def get_running_instances(json_response):
    """Parses JSON and returns a list of running instances with their names."""
    try:
        data = json.loads(json_response)
    except json.JSONDecodeError:
        return []

    running = []
    
    for reservation in data.get("Reservations", []):
        for instance in reservation.get("Instances", []):
            if instance.get("State", {}).get("Name") == "running":
                # Extract the Name tag
                name = "unnamed"
                for tag in instance.get("Tags", []):
                    if tag.get("Key") == "Name":
                        name = tag.get("Value")
                        break
                
                running.append({
                    "id": instance["InstanceId"],
                    "name": name
                })
    
    return running

if __name__ == "__main__":
    # Test Data
    api_response = '''
    {
        "Reservations": [
            {
                "Instances": [
                    {"InstanceId": "i-001", "State": {"Name": "running"}, "Tags": [{"Key": "Name", "Value": "web-01"}]},
                    {"InstanceId": "i-002", "State": {"Name": "stopped"}, "Tags": [{"Key": "Name", "Value": "db-01"}]}
                ]
            }
        ]
    }
    '''
    result = get_running_instances(api_response)
    print(result)
