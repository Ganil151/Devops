"""
Challenge: EC2 Auto-Tagger
Scenario: Your finance department needs to know who created which instance. 
Implement a script that tags all instances missing the 'Owner' tag.

TODO: Implement `tag_untagged_instances(owner_name)`.
1. Use `boto3.resource('ec2')`.
2. Filter for all instances.
3. For each instance, check its `.tags` attribute.
4. If 'Owner' key is missing, add a tag: `{'Key': 'Owner', 'Value': owner_name}`.
5. Return the count of instances that were tagged.
"""
import boto3

def tag_untagged_instances(owner_name):
    """
    Applies an Owner tag to EC2 instances missing it.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test would run here
    pass
