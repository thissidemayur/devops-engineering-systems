# AWS Configuration – How Terraform Actually Talks to AWS

Before Terraform can create anything on AWS, one question must be answered:

**Who am I, and am I allowed to do this?**

Terraform itself does not answer this question.
AWS does.

- Terraform never logs into AWS.
- Terraform never stores AWS credentials.
- Terraform simply *asks AWS to do things* and AWS decides whether to allow it.

Understanding this separation is critical.

---

## The starting point: configuring AWS access

Before touching Terraform, AWS access must already work.

This is usually verified by running:

```bash
aws configure
```
This command does only one thing:
    - it stores credentials locally so the AWS CLI (and later Terraform) can use them

To confirm that AWS credentials are valid, always run:
```
aws sts get-caller-identity
```
If this command fails:
- Terraform will fail
- not because Terraform is broken
- but because AWS authentication is broken

Terraform depends on AWS access that already exists.

## Multiple AWS accounts and profiles
In real environments, a single AWS account is never enough.
You may have:
- personal account
- company dev account
- staging account
- production account

This is handled using named profile
```
aws configure --profile profileName
```
This creates a separate identity context.

Terraform does not choose accounts.
It simply consumes whatever identity is active.

You can select a profile using environment variables:
```
AWS_PROFILE=profileName
AWS_DEFAULT_REGION=ap-south-1
```
This tells all AWS-aware tools:
- “Use this identity and this region.”

## Terraform is not a statless
Terraform does not store credentials, but it does maintain state about infrastructure.

If Terraform fails during:
- initialization
- planning
- applying

It usually means one of three things:
1. AWS rejected the request (permissions, identity, region)
2. The provider could not authenticate
3. The declared infrastructure conflicts with reality

Terraform itself is rarely the root cause.

### Always-run commands (non-negotiable)
Every terraform workflow starts the same way:
```
terraform init
terraform plan
```
Why?
- `init` prepares providers and backend access
- `plan` shows exactly what Terraform thinks will change

--

## How Terraform actually gets AWS credentials
Terraform uses the AWS SDK credential resolution chain.

It tries credentials in a strict order and stops at the first valid one.

### Credential resolution order
**1. Environment variables (highest priority)**
Terraform checks for:
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN
```
If these exist, Terraform ignores everything else.
This is powerful — and dangerous if misused.


**2. Shared credentials file**
Located at
```
~/.aws/credentials
```
This is where aws configure stores profiles.
example:
```
[dev]
aws_access_key_id=...
aws_secret_access_key=...
```

**3. Shared config file**
Located at:
```
~/.aws/config
```

This usually contains:
- regions
- role assumptions
- profile metadata

**4. IAM Role (cloud-native identity)**
When running on:
- EC2
- ECS
- EKS

Terraform automatically uses the attached IAM Role.
No keys.
No secrets.
No configuration files.

This is safest model

--

## Production reality (non-negotiable rules)

### Local development
Acceptable options:
- `aws configure`
- envionemnt variables
- named profiels

This is fine only for local machines

### CI/CD systems
Static access keys are forbidden.

**Correct approches**
- GitHub Actions → OIDC → IAM Role
- GitLab CI → OIDC → IAM Role
- Jenkins → IAM Role via instance profile

If a CI pipeline uses long-lived access keys:
- it is already a security incident waiting to happen


### Cloud runtime
Always use IAM Roles.

--

## What Terraform actually knows
Terraform does not know:
- access keys
- secret keys
- tokens

Terraform only knows one thing:
` “AWS API calls succeeded or failed.”`

Internally, the flow looks like this:
```

Terraform → AWS Provider → AWS SDK → Credential Chain → AWS API

```
Terraform trusts the AWS SDK completely.

--

## Final rule (easy to forget)
**Environment variables** override everything.
If AWS_ACCESS_KEY_ID exists:
- profiles are ignored
- config files are ignored
- roles are ignored

Many “Terraform bugs” are actually caused by forgotten environment variables.