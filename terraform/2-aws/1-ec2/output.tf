############################################
# Output Values
############################################
# Outputs allow Terraform to:
# - expose useful information after apply
# - pass values to other Terraform states
# - make infra details visible to users or CI
############################################

output "aws_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.amazon_linux.public_ip
}
