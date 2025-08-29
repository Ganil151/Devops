terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
  }
}

module "create_files" {
  source = "./file_creator"
  filename_1 = "my_first_file.txt"
  file1_content = "from file1"
  
  filename_2 = "my_second_file.txt"
  file2_content = "from file1"
}

output "file_paths" {
  value = [
    module.create_files.file1_path,
    module.create_files.file2_path
  ]
}

# https://youtu.be/bEXfPzoB4RE?t=15005