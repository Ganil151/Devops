module "vpc" {
  source       = "../modules/vpc"
  project_name = var.project_name
}

module "key_pair" {
  source   = "../modules/keys"
  key_name = var.key_pair_name
}

module "security_groups" {
  source = "../modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "build_server" {
  source             = "../modules/ec2"
  name               = "build-server"
  instance_type      = "t3.medium"
  key_pair_name      = module.key_pair.key_name
  subnet_id          = module.vpc.public_subnet_id
  volume_size        = 15
  security_group_ids = [module.security_groups.jenkins_sg_id]
  server_type        = "Build-Server"
  user_data          = file("${path.module}/scripts/setup.sh")
}

module "jenkins_master" {
  source             = "../modules/ec2"
  name               = "jenkins-master"
  instance_type      = "t3.medium"
  key_pair_name      = module.key_pair.key_name
  subnet_id          = module.vpc.public_subnet_id
  volume_size        = 20
  security_group_ids = [module.security_groups.jenkins_sg_id]
  server_type        = "Jenkins-Master"
  user_data          = file("${path.module}/scripts/jenkins-master.sh")
}

module "sonarqube_server" {
  source             = "../modules/ec2"
  name               = "sonarqube-server"
  instance_type      = "t3.medium"
  key_pair_name      = module.key_pair.key_name
  subnet_id          = module.vpc.public_subnet_id
  volume_size        = 25
  security_group_ids = [module.security_groups.sonarqube_sg_id]
  server_type        = "SonarQube"
  user_data          = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install -y docker.io
    sudo usermod -a -G docker ubuntu
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
  EOF
}