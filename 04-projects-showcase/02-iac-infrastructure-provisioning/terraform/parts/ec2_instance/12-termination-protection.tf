# 12. Instance with Termination Protection
# Prevents accidental deletion of critical instances.

resource "aws_instance" "critical_db_node" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "m5.large"

  disable_api_termination = true # Prevents termination via API/Console

  tags = {
    Name = "Protected-Database-Host"
  }
}
