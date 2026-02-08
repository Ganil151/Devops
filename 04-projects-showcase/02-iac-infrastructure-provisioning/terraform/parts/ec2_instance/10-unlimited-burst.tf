# 10. Instance with T3 Unlimited
# Allows the instance to burst CPU indefinitely (for a fee).

resource "aws_instance" "bursty_instance" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "Unlimited-Burst-Instance"
  }
}
