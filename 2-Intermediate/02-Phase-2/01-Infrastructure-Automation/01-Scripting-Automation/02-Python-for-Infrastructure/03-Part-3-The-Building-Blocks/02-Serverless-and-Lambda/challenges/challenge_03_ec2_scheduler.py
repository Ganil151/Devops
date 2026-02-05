"""
Challenge: Instance Auto-Stop Scheduler
Scenario: Your 'Dev' instances should only run during office hours 
(9 AM - 6 PM UTC) to save costs.

TODO: Implement the logic inside `lambda_handler`.
1. Initialize the EC2 Resource.
2. Get the current hour in UTC using `datetime.utcnow().hour`.
3. If the hour is outside the range 9-18:
   a. Filter for instances with tags `{'Key': 'Env', 'Value': 'Dev'}`.
   b. Filter for instances that are currently `running`.
   c. Stop the identified instances.
4. return the list of IDs stopped.
"""
import boto3
from datetime import datetime

ec2 = boto3.resource('ec2')

def lambda_handler(event, context):
    """
    Schedules instance stops based on office hours.
    """
    # --- START YOUR CODE HERE ---
    pass
