# 08. VPC Gateway Endpoint Route Table
# Route traffic to S3 or DynamoDB privately through a Gateway Endpoint.

resource "aws_vpc_endpoint_route_table_association" "s3_endpoint" {
  route_table_id  = var.route_table_id
  vpc_endpoint_id = var.s3_endpoint_id
}

# (The association adds a route to the service prefix list)
