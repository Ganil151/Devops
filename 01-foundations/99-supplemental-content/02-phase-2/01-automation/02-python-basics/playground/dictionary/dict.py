# Example of a dictionary representing a student's information
# student_info = {
#   "name": "Alice",
#   "age": 22,
#   "courses": ["Math", "Science", "Art"],
#   "is_enrolled": True
# }

# Example of a list of dictionaries representing multiple EC2 instances
ec2_instances_info = [
    {
      "id": "instance-001",
      "type": "t2.micro",
      "region": "us-west-1",
      "status": "running"
    },
    {
      "id": "instance-002",
      "type": "t2.large",
      "region": "us-east-1",
      "status": "stopped"
    },
    {
      "id": "instance-003",
      "type": "m5.xlarge",
      "region": "eu-central-1",
      "status": "running"
    }
]

print(ec2_instances_info[1]["type"])  # Output: t2.large  

