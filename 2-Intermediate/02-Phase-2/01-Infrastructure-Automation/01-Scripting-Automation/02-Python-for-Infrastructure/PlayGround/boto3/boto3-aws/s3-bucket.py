import boto3
import json 

client = boto3.client('s3')

# Create a new S3 bucket
# response = client.create_bucket(
#     Bucket='ganil-demo-boto3-yt-12345',
# )

# Remove S3 bucket
response = client.delete_bucket(
    Bucket='ganil-demo-boto3-yt-12345'
)
print(response)


# Print the response in a formatted way
# for line in json.dumps(response, indent=2).splitlines():
#   print(line)

# Print only the grants
# for grant in response['Grants']:
#     print(grant['Permission'], grant['Grantee'].get('URI') or grant['Grantee'].get('ID')) 

# Print the entire response in a formatted way   
# for line in json.dumps(response, indent=2).splitlines():
#   print(line)




