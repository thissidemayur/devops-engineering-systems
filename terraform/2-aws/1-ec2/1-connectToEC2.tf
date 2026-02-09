############################################
# Terraform Block
############################################
# This block tells Terraform:
# - which providers are required
# - where to download them from
# - which versions are allowed
#
# Terraform will read this BEFORE anything else.
############################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"   # Official AWS provider
      version = "~> 6.31.0"       # Allow compatible 6.x versions
    }
  }
}

############################################
# AWS Provider Configuration
############################################
# The provider defines:
# - HOW Terraform talks to AWS
# - WHICH region it should operate in
#
# Credentials are NOT defined here.
# Terraform uses AWS credentials from:
# - environment variables OR
# - ~/.aws/credentials (aws configure)
############################################
provider "aws" {
  region = var.region
}

############################################
# EC2 Instance Resource
############################################
# This resource tells Terraform:
# - an EC2 instance should exist
# - what AMI to use
# - what instance type to use
#
# Terraform will:
# - create this instance if it does not exist
# - update it if configuration changes
# - destroy it only if explicitly told to
############################################
resource "aws_instance" "amazon_linux" {
  ami           = "ami-0ff5003538b60d5ec"  # Amazon Linux AMI (region-specific)
  instance_type = "t2.micro"

  tags = {
    Name = "amazonLinuxLearning"
  }
}
