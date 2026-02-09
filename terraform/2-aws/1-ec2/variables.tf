############################################
# Input Variables
############################################
# Variables allow you to:
# - avoid hardcoding values
# - reuse the same Terraform code
# - change behavior per environment
############################################

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}
