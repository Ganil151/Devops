"""
Challenge: API Response Parser
Scenario: You receive a nested JSON response from a cloud provider describing EC2 instances.
Your task is to extract all 'running' instances and their 'Name' tag values.

TODO: Implement the get_running_instances(json_response) function.
"""
import json

# Sample AWS-style response
api_response = '''
{
    "Reservations": [
        {
            "Instances": [
                {
                    "InstanceId": "i-001", 
                    "State": {"Name": "running"}, 
                    "Tags": [{"Key": "Name", "Value": "web-01"}]
                },
                {
                    "InstanceId": "i-002", 
                    "State": {"Name": "stopped"}, 
                    "Tags": [{"Key": "Name", "Value": "db-01"}]
                },
                {
                    "InstanceId": "i-003", 
                    "State": {"Name": "running"}, 
                    "Tags": [{"Key": "Env", "Value": "prod"}]
                }
            ]
        }
    ]
}
'''

def get_running_instances(json_response):
    """
    Parses JSON and returns a list of dicts: [{'id': '...', 'name': '...'}, ...]
    If an instance has no 'Name' tag, use 'unnamed'.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    running_instances = get_running_instances(api_response)
    print("Running Instances:", json.dumps(running_instances, indent=2))
