# 13. Instance with Detailed Monitoring
# High-frequency (1-minute) CloudWatch metrics.

resource "aws_instance" "monitored_node" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  monitoring = true # Detailed monitoring

  tags = {
    Name = "High-Res-Monitored-Host"
  }
}
