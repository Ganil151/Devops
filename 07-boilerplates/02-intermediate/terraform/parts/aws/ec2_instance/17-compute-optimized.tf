# 17. High CPU Instance (C5 Series)
# Compute-optimized for batch processing and high-performance apps.

resource "aws_instance" "compute_optimized" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "c5.large"

  # C5 instances are EBS optimized by default
  
  tags = {
    Name = "Batch-Processor-Node"
  }
}
