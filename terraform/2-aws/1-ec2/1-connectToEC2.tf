terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.31.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
}

resource "aws_instance" "amazonLinux" {
  ami = "ami-0ff5003538b60d5ec"
  instance_type = "t2.micro"
  tags = {
    Name = "amazonLinuxLearning"
  }
 
}

# to delete resource use `terraform destroy`
# `terraform validate`- support terraform file strcutre