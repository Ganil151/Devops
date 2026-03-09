# 2. File-Based Key Pair
# Load public key from local file.

resource "aws_key_pair" "from_file" {
  key_name   = "file-based-key"
  public_key = file("~/.ssh/id_rsa.pub")

  tags = {
    Name = "File-Based-Key"
  }
}
