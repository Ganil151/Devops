# 16. Instance with IMDSv2 Mandatory
# Enhanced security by requiring session-oriented metadata access.

resource "aws_instance" "secure_metadata" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 only
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  tags = {
    Name = "IMDSv2-Hardened-Host"
  }
}
