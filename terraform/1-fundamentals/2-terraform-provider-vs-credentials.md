

# Terraform Provider vs Credentials – Who Does What

A common beginner mistake is assuming Terraform manages authentication.

It does not.

---

## The real separation of responsibilities

### Terraform Core
- Reads `.tf` files
- Builds a dependency graph
- Computes desired vs current state

Terraform core never talks to AWS directly.

---

### Terraform AWS Provider
- Translates Terraform resources into AWS API calls
- Uses the AWS SDK
- Handles retries and request formatting

The provider does not store credentials.

---

### AWS SDK
- Resolves credentials
- Signs requests
- Sends API calls

If authentication fails, Terraform cannot fix it.

---

## Why this separation exists

Terraform supports many providers:
- AWS
- Azure
- GCP
- Kubernetes
- GitHub

If Terraform handled authentication itself:
- every cloud auth model would be reimplemented
- security would be impossible to maintain

Providers delegate auth to native SDKs by design.

---

## Practical debugging rule

If Terraform fails with:
- `AccessDenied`
- `InvalidClientTokenId`
- `NoCredentialProviders`

Do NOT debug Terraform first.

Debug:
1. AWS identity
2. IAM permissions
3. Credential source
