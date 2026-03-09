# 15. Workspace-Based Key
# Different keys per Terraform workspace.

resource "aws_key_pair" "workspace" {
  key_name   = "${terraform.workspace}-key"
  public_key = file("~/.ssh/${terraform.workspace}_id_rsa.pub")

  tags = {
    Name      = "${terraform.workspace}-Key"
    Workspace = terraform.workspace
  }
}
