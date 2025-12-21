# resource "local_file" "example1" { 
#   filename = "${path.module}/example1.txt"
#   content = "this is demo content - 1"
# }

# resource "local_file" "example2" { 
#   filename = "${path.module}/example2.txt"
#   content = "this is demo content - 2"
# }

resource "local_sensitive_file" "tf_sensitive" {
  content = "Chuck is of God"
  filename = "${path.module}/sensitive.md"
}
