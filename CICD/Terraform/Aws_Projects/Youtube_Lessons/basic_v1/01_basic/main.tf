
# Normal
resource "local_file" "tf_example1" {
  #filename = "01_basic/example.txt"  
  filename = "${path.module}/example1.txt"
  content = "Ganil is of many"
}

# Sensitive 
# resource "local_sensitive_file" "tf_example2" {
#   content = "the is sensitive info"
#   filename = "${path.module}/sensitive.txt"
# } 

# Count
# resource "local_file" "tf_example1" {
#   filename = "${path.module}/example1-${count.index}.txt"
#   content = "Ganil is of many"
#   count = 3
# }

# Terraform State