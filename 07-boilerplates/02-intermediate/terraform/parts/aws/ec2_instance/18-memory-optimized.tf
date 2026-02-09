# 18. RAM Intensive Instance (R5 Series)
# Memory-optimized for databases and real-time processing.

resource "aws_instance" "memory_optimized" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "r5.large"

  tags = {
    Name = "In-Memory-DB-Node"
  }
}
