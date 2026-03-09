# 13. Import Existing Key
# Import pre-existing key pair into Terraform state.

resource "aws_key_pair" "imported" {
  key_name   = "existing-imported-key"
  public_key = file("~/.ssh/existing_key.pub")

  tags = {
    Name     = "Imported-Key"
    Imported = "true"
  }
}

# Import command:
# terraform import aws_key_pair.imported existing-imported-key
