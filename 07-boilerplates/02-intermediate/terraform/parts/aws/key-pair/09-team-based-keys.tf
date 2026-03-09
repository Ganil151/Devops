# 9. Team-Based Key Pairs
# Multiple keys for different teams.

resource "aws_key_pair" "devops_team" {
  key_name   = "devops-team-key"
  public_key = file("~/.ssh/devops_team.pub")

  tags = {
    Name = "DevOps-Team-Key"
    Team = "DevOps"
  }
}

resource "aws_key_pair" "dev_team" {
  key_name   = "dev-team-key"
  public_key = file("~/.ssh/dev_team.pub")

  tags = {
    Name = "Dev-Team-Key"
    Team = "Development"
  }
}

resource "aws_key_pair" "ops_team" {
  key_name   = "ops-team-key"
  public_key = file("~/.ssh/ops_team.pub")

  tags = {
    Name = "Ops-Team-Key"
    Team = "Operations"
  }
}
