# 🛠️ Serverless Challenges

## Challenge 1: The S3 Thumbnail Trigger
**Objective**: Write a handler that reacts to S3 uploads.
1.  Event Source: S3 PUT.
2.  Parse `event['Records'][0]['s3']['bucket']['name']` and `['object']['key']`.
3.  Check if extension is `.jpg`.
4.  Print "Generating thumbnail for {key}..." (Simulation).
5.  If not jpg, print "Skipping non-image".

## Challenge 2: CloudWatch Auto-Remediation
**Objective**: Restart an EC2 instance if CPU > 90%.
1.  Event Source: CloudWatch Alarm (SNs or EventBridge).
2.  Parse the Instance ID from the alarm data.
3.  Use Boto3 to `reboot_instances(InstanceIds=[id])`.
4.  Log the action.
