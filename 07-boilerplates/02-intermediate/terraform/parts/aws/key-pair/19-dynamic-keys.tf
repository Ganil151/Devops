# 19. Dynamic Multiple Keys
# Create multiple keys dynamically from a map.

variable "key_pairs" {
  type = map(string)
  default = {
    "web-server"  = "~/.ssh/web_server.pub"
    "app-server"  = "~/.ssh/app_server.pub"
    "db-server"   = "~/.ssh/db_server.pub"
  }
}

resource "aws_key_pair" "dynamic" {
  for_each = var.key_pairs

  key_name   = each.key
  public_key = file(each.value)

  tags = {
    Name = "${each.key}-Key"
    Type = each.key
  }
}

output "dynamic_key_names" {
  value = { for k, v in aws_key_pair.dynamic : k => v.key_name }
}
