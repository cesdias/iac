provider "aws" {
  region                  = "us-east-2"
  shared_credentials_file = var.credentials_file
  profile                 = var.credentials_profile
}

resource "aws_instance" "swarm-master" {
  ami                    = "ami-07c1207a9d40bc3bd"
  instance_type          = "t3a.micro"
  vpc_security_group_ids = ["sg-2e311957","sg-0948b071add88d464"]
  key_name               = var.key_name
  user_data              = file("install_docker.conf")

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }

  tags = {
    name = "swarm-master"
  }
}

resource "aws_instance" "swarm-node" {
  count                  = 3
  ami                    = "ami-07c1207a9d40bc3bd"
  instance_type          = "t3a.micro"
  vpc_security_group_ids = ["sg-2e311957","sg-0948b071add88d464"]
  key_name               = var.key_name
  user_data              = file("install_docker.conf")

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }

  tags = {
    name = "swarm-nodes"
  }
}
