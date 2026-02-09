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
.
├── main.tf        # Providers, S3 bucket, and S3 object resources
├── README.md      # Documentation
├── file.txt       # Local file uploaded to S3
└── terraform.tfstate (local, generated after apply)

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

Run this whenever:
    - a new provider is added
    - provider versions change

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

## Important Concepts Explained
### S3 Bucket Naming
- S3 bucket names must be:
    - DNS-compatible
    - lowercase
    - globally unique across all AWS accounts
- Bucket names become part of AWS service URLs

The random_id resource ensures uniqueness.


## Random Provider Behavior

- random_id generates a value once
- The value is stored in Terraform state
- It changes only if:
    - state is deleted
    - resource is tainted
    - resource definition changes

Deleting state = new random value = new bucket name.


## State and Safety
- Terraform state is stored locally in this setup
- Losing the state file breaks Terraform’s ability to manage resources
- In real teams, remote state (S3 + DynamoDB) is mandatory

The S3 bucket uses:
```
lifecycle {
  prevent_destroy = true
}
```