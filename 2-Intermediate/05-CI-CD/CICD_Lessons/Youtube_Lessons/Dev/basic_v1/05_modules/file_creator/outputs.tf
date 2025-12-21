output "file1_path" {
  description = "this is the path of file"
  value = local_file.file1.filename
}

output "file2_path" {
  description = "this is the path of file"
  value = local_file.file2.filename
}