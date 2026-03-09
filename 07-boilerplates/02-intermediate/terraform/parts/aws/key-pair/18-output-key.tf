# 18. Key with Comprehensive Outputs
# Export key details for use in other modules.

resource "tls_private_key" "output_example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "output_example" {
  key_name   = "output-key"
  public_key = tls_private_key.output_example.public_key_openssh

  tags = {
    Name = "Output-Example-Key"
  }
}

output "key_name" {
  value = aws_key_pair.output_example.key_name
}

output "key_pair_id" {
  value = aws_key_pair.output_example.id
}

output "key_fingerprint" {
  value = aws_key_pair.output_example.fingerprint
}

output "public_key" {
  value = aws_key_pair.output_example.public_key
}

output "private_key_pem" {
  value     = tls_private_key.output_example.private_key_pem
  sensitive = true
}
