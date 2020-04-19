provider "aws" {
  region                  = "us-east-2"
  shared_credentials_file = "var.credentials_dir"
  profile                 = "var.credentials_profile"
}

resource "aws_instance" "swarm-master" {
  ami                    = "ami-07c1207a9d40bc3bd"
  instance_type          = "t3a.small"
  vpc_security_group_ids = ["sg-2e311957"]
  key_name               = "hacks-mbp-aws"
  user_data              = file("install_docker.sh")

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }

  tags = {
    name = "sefazpb"
  }
}

resource "aws_instance" "swarm-node" {
  count                  = 3
  ami                    = "ami-07c1207a9d40bc3bd"
  instance_type          = "t3a.micro"
  vpc_security_group_ids = ["sg-2e311957"]
  key_name               = "hacks-mbp-aws"
  user_data              = file("install_docker.sh")

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }

  tags = {
    name = "sefazpb"
  }
}

variable "credentials_dir" {
  type=string
}

variable "credentials_profile" {
  type=string
}
