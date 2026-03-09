# 5. Environment-Specific Key
# Key pair with environment-based naming.

variable "environment" {
  default = "dev"
}

resource "aws_key_pair" "env_key" {
  key_name   = "${var.environment}-deployer-key"
  public_key = file("~/.ssh/${var.environment}_id_rsa.pub")

  tags = {
    Name        = "${var.environment}-Key"
    Environment = var.environment
  }
}
