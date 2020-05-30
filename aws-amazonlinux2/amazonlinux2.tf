provider "aws" {
  region                  = var.region
  shared_credentials_file = var.credentials_file
  profile                 = var.credentials_profile
}

resource "aws_instance" "amazonlinux2_instance" {
  ami                    = "ami-04a8e0df11e0026d5"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [var.security_groups]
  key_name               = var.key_name
  user_data              = file("install_docker.conf")

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }

  tags = {
    name = "terraform"
  }
}
