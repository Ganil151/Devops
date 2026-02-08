# 20. Minimalist/Baseline Instance
# The absolute minimum code required to launch an instance.

resource "aws_instance" "minimal" {
  ami           = "ami-0c55b159cbfafe1f0" # Manual AMI ID for PoC
  instance_type = "t2.micro"
}
