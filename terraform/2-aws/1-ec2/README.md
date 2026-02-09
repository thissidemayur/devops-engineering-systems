# Terraform EC2 – Learning Project

This directory contains a **minimal, safe Terraform configuration** for launching
an **EC2 instance** on AWS.

The goal of this project is **not** to learn EC2 features,
but to learn **how Terraform works in practice**:
state, plan/apply flow, variables, outputs, and basic safety habits.

---

## What This Project Does

- Uses Terraform to manage **one EC2 instance**
- Uses the **AWS provider**
- Demonstrates:
  - Provider configuration
  - Variables
  - Outputs
  - Terraform workflow commands

This setup uses **local Terraform state**, which is acceptable **only for learning**.

---

## Prerequisites

Before running Terraform, make sure:

- AWS CLI is installed
- AWS credentials are configured using:
  ```bash
  aws configure
  ```


- or environment variables

```

aws sts get-caller-identity

```
Terraform does not manage AWS credentials.

## File Structure

```
.
├── main.tf # Provider and EC2 resource definition
├── variables.tf # Input variables
├── outputs.tf # Values exposed after apply
├── README.md # Project documentation

```
Terraform automatically loads all .tf files in the directory.
File names are for humans, not Terraform.


---

## Terraform Workflow (Very Important)
Terraform always follows this flow:
###  1. Initialize
```
terraform init
```
- Downloads provider plugins
- Prepares Terraform to run
- Must be run once per directory

### 2. Validate
```
terraform validate
```
- Checks Terraform syntax and structure
- Does NOT talk to AWS
- Does NOT verify resources

This is a static check only.

### 3. Plan
```
terraform plan
```
- Compares:
    - Desired configuration (.tf files)
    - Terraform state (last known reality)
    - Actual AWS resources (refresh)
- Shows what Terraform intends to do
- Does NOT change AWS resources

Always read the plan carefully.

### 4. Apply
```
terraform apply
```
- Executes the plan
- Creates or updates AWS resources
- Updates Terraform state

Terraform is not transactional:
partial failures can leave infrastructure partially changed.

### 5. Destroy (Use With Extreme Caution)
```
terraform destroy
```
- Deletes ALL resources tracked in the current state
- Extremely dangerous in real environments
- Acceptable only for learning or disposable infra

---

## Variables
Variables allow:
- Reusability
- Environment flexibility
- Avoiding hardcoded values
Example
```
variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}
```
Variables define inputs.
They do not fetch values from AWS automatically.

---

## Outputs
Outputs expose useful data after apply.
Examples
```
output "aws_instance_public_ip" {
  value = aws_instance.amazon_linux.public_ip
}
```
- Are read from Terraform state
- Represent Terraform’s last known view of reality
- Are commonly used by:
    - Humans
    - CI/CD pipelines
    - Other Terraform states


---
## Key Mental Models
- Terraform manages state, not AWS accounts
- Terraform does not know intent — only differences
- Plan is a proposal, not a guarantee
- Directory = one Terraform state = one blast radius
- Terraform does exactly what you allow it to do

