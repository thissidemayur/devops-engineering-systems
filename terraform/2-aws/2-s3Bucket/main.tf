############################################
# Terraform Block
############################################
# This block defines:
# - which providers Terraform must use
# - where those providers come from
# - which versions are allowed
#
# Terraform reads this FIRST, before anything else.
# Changing provider versions requires re-running:
#   terraform init -upgrade
############################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"     # Official AWS provider
      version = "6.31.0"            # Exact version for reproducibility
    }

    random = {
      source  = "hashicorp/random"  # Used to generate unique values
      version = "3.8.1"
    }
  }
}

############################################
# Random Provider Resource
############################################
# This resource generates a random value ONCE
# and stores it in Terraform state.
#
# Important:
# - The value is NOT regenerated on every apply
# - It only changes if:
#   - the resource is tainted
#   - the state is deleted
#   - the resource definition changes
#
# This is commonly used to:
# - ensure global uniqueness (e.g., S3 bucket names)
############################################
resource "random_id" "rand_id" {
  byte_length = 8
}

############################################
# AWS Provider Configuration
############################################
# Defines HOW Terraform connects to AWS.
#
# Credentials are NOT defined here.
# Terraform automatically uses credentials from:
# - environment variables OR
# - ~/.aws/credentials (aws configure)
#
# Region determines WHERE resources are created.
############################################
provider "aws" {
  region = "ap-south-1"
}

############################################
# S3 Bucket Resource
############################################
# Creates an S3 bucket with a globally unique name.
#
# S3 bucket names must:
# - be DNS-compatible
# - be globally unique across ALL AWS accounts
#
# The random suffix prevents name collisions.
############################################
resource "aws_s3_bucket" "bucket_demo" {
  bucket = "demo-bucket-${random_id.rand_id.hex}"

  # Safety guard:
  # Prevents accidental deletion of the bucket.
  # Terraform will FAIL loudly instead of deleting data.
  lifecycle {
    prevent_destroy = true
  }
}

############################################
# S3 Object Resource
############################################
# Uploads a file into the S3 bucket.
#
# This resource is fully managed by Terraform:
# - file changes trigger updates
# - deletion removes the object from S3
############################################
resource "aws_s3_object" "bucket_object" {
  bucket = aws_s3_bucket.bucket_demo.bucket

  # Local file path (must exist)
  source = "./file.txt"

  # Object key (path inside the bucket)
  key = "file.txt"

  # Ensures Terraform detects file content changes
  # If file content changes → object is updated
  etag = filemd5("./file.txt")
}
