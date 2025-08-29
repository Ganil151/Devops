variable "ami" {
  description = "Aws ami"
  type        = string
  default = "ami-020cba7c55df1f615"
}

variable "associate_public_ip_address" {
  description = "Public Ip Address"
  type = bool
  default = true
}

variable "instance_type" {
  description = "Instance Type"
  type = string
  default = "t3.micro"
}

variable "vpc_security_group_ids" {
  description = "Vpc Security Group Id's "
  type = list(string) 
  default = [aws_security_group.ec2_youtube_sg.id]
  
}

variable "key_name" {
  description = "Key Name"
  type = string
  default = "tf_youtube"
}

variable "depends_on" {
  description = "Depends On"
  type = string
  default = [aws_s3_object.tf_s3_object]
}

variable "user_data" {
  description = "Script"
  type = string
  default = file("script.sh")
}

variable "user_data_replace_on_change" {
  description = "Replace instance"
  type = bool
  default = true
}

variable "tags" {
  description = "Tags"
  type = map(string)
  default = {
    "Name" = "NodeJs-Server"
  }
}