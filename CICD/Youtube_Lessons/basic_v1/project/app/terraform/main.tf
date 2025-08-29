resource "aws_instance" "tf_ec2_instance" {
  ami                         = "ami-020cba7c55df1f615"
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.ec2_youtube_sg.id]
  key_name                    = "tf_youtube"
  depends_on                  = [aws_s3_object.tf_s3_object]
  # user_data                   = file("script.sh")
  user_data                   = <<-EOF
  #!/bin/bash

    # Update and install Node.js & npm
    sudo apt update -y
    sudo apt install -y nodejs npm git

    # Clone the repository
    cd /home/ubuntu
    git clone https://github.com/verma-kunal/nodejs-mysql.git
    cd nodejs-mysql

    # Install project dependencies
    npm install

    # Create .env file with example DB config
    cat <<EOT > .env
      DB_HOST=${local.rds_endpoint} 
      DB_USER=${aws_db_instance.tf_rds_instance.username}
      DB_PASSWORD=${aws_db_instance.tf_rds_instance.password}
      DB_NAME=${aws_db_instance.tf_rds_instance.db_name}
      DB_PORT=${aws_db_instance.tf_rds_instance.port}
      TABEL_NAME=${aws_db_instance.tf_rds_instance.db_name}      
    EOT

    # Start the Node.js server (in background)
    nohup npm start &
  EOF

  user_data_replace_on_change = true

  tags = {
    Name = "NodeJs-Server"
  }
}
