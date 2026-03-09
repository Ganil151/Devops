# 20. Minimalist Key Pair
# Bare minimum configuration.

resource "aws_key_pair" "minimal" {
  key_name   = "minimal-key"
  public_key = file("~/.ssh/id_rsa.pub")
}
