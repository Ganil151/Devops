# -----------------------------------------------------------------------------
# Name: __main__.py
# Description: Pulumi Infrastructure as Code using Python.
# -----------------------------------------------------------------------------

import pulumi
import pulumi_aws as aws

# 1. Create a variable (Stack Configuration)
config = pulumi.Config()
bucket_name = config.get("bucket_name") or "my-pulumi-bucket"

# 2. Provision Resource
bucket = aws.s3.BucketV2("my-bucket",
    bucket=bucket_name,
    tags={
        "Environment": pulumi.get_stack(), # dev, staging, prod
        "ManagedBy": "Pulumi"
    }
)

# 3. Export Output (Equivalent to Terraform Output)
pulumi.export('bucket_id', bucket.id)
pulumi.export('bucket_arn', bucket.arn)
