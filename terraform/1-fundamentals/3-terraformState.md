# Terraform State – The Memory of Infrastructure

Terraform can only do one thing reliably:
**remember what it created last time.**

That memory is called **state**.

Without state:
- Terraform does not know what exists
- Terraform cannot know what to change
- Terraform cannot know what to destroy

Terraform without state is blind.

---

## What Terraform state actually contains

Terraform state is not just a file.
It is a **mapping table between Terraform and reality**.

At minimum, it stores:

- Terraform resource address  
  `aws_instance.web`

- Provider + region  
  `aws / ap-south-1`

- Real cloud resource ID  
  `i-0f123abc`

- Last-known attributes  
  instance type, tags, AMI, subnets, etc.

State answers one question:

> “This Terraform resource corresponds to *this exact AWS object*.”

AWS APIs are **stateless**.  
Terraform is **stateful by design**.

That is why Terraform can calculate changes.

---

## Why Terraform needs state (critical insight)

Cloud providers do NOT say:
> “Here is what Terraform created last time.”

They only say:
> “Here is what currently exists.”

Terraform must:
1. Remember what it created
2. Compare it with what exists
3. Compare both with what you *want*

State is the memory that enables this comparison.

---

## What happens during `terraform plan`

Internally, Terraform does this:

1. Load the current state
2. Query AWS for real resource data
3. Compare:
   - **State** (what Terraform remembers)
   - **Config** (what you want)
   - **Reality** (what AWS reports)
4. Generate actions:
   - create
   - update
   - destroy
   - or do nothing

Terraform does **not** “understand intent”.
It only understands **differences**.

---

## Production reality: state is dangerous

### 1. State is a single-writer system

Only **one writer** is allowed at a time.

If two people run `apply` simultaneously:
- one will overwrite the other
- changes may be silently lost
- infrastructure may diverge

Terraform does NOT merge changes.
Last write wins.

---

### 2. State is sensitive data

State files often contain:
- resource IDs
- IAM ARNs
- internal architecture details
- sometimes secrets (bad, but real)

If state leaks:
- attackers get a map of your infrastructure
- blast radius becomes massive

State must be treated like credentials.

---

### 3. State loss is catastrophic

If state is deleted:
- Terraform thinks nothing exists
- next `apply` tries to recreate everything
- AWS may block due to conflicts
- partial recreation can break production

State loss ≠ clean slate  
State loss = chaos.

---

## Local state vs Remote state

### Local state (only for learning)

Local state works only when:
- one human
- one laptop
- no CI
- no teammates

Failure modes:
- laptop dies → infra orphaned
- git branches → conflicting realities
- no locking
- no audit trail

Local state collapses the moment teamwork starts.

---

### Remote state (production standard)

Remote state gives you:
- centralized truth
- locking
- durability
- versioning
- access control

On AWS, this means:
- **S3** for storage
- **DynamoDB** for locking

Remote state exists because:
> Infrastructure is a **multi-writer distributed system**.

---

## Why remote state exists (systems thinking)

Local state assumes:
- one writer
- one timeline
- no failures

Real infrastructure has:
- teammates
- CI pipelines
- retries
- partial failures
- human mistakes

Distributed systems require:
- coordination
- mutual exclusion
- durability
- auditability

Remote state provides exactly that.

---

## How Terraform remote state works (S3 backend)

High-level flow:

1. Terraform downloads state from S3
2. Terraform acquires lock in DynamoDB
3. Terraform builds the plan
4. Terraform applies changes
5. Terraform uploads the new state to S3
6. Terraform releases the lock

Terraform does NOT stream updates.
State is replaced as a whole.

If apply fails:
- state may or may not update
- manual inspection is required

This is why small states matter.

---

## Why S3 + DynamoDB (AWS standard)

### S3 – state storage
S3 is used because:
- durable
- cheap
- versioned
- IAM-controlled
- simple object semantics

Terraform needs:
- full state snapshot
- historical recovery
- atomic object replacement

S3 fits perfectly.

---

### DynamoDB – locking (this part matters)

DynamoDB is NOT used to store state.
It is used for **coordination**.

Terraform uses DynamoDB as a **distributed mutex**.

This works because DynamoDB supports:
- strongly consistent reads (everyone sees the same lock state)
- atomic conditional writes (only one writer can acquire lock)
- low latency
- high availability

In simple terms:
> DynamoDB guarantees that only one Terraform process can hold the lock at a time.

That is mutual exclusion.

---

## Minimal remote state setup (AWS)

### S3 bucket
Rules:
- globally unique name
- versioning ON
- encryption ON
- public access blocked

Example: terraform-state-devops-systems

---

### DynamoDB table
- Name: `terraform-locks`
- Partition key: `LockId` (string)
- On-demand capacity

---

### Backend configuration

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-devops-systems"
    key            = "network/prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```
The key defines state identity.

Change the key → new state → new isolation boundary.

-- 

## State isolation and blast radius (read carefully)
**Blast radius** = how much damage a bad Terraform action can cause.

Terraform is NOT transactional.
Partial applies happen.
Rollbacks are manual and imperfect.

State isolation is the ONLY safety mechanism.

### Correct mental model
`❌ Wrong model: `**One AWS account = one Terraform state**
This causes:
- massive blast radius
- slow plans
- blocked teams
- risky deploys

`✅ Correct model: ` **One Terraform state** = one independently deployable system

State should map to:
- ownership
- lifecycle
- failure boundaries


-- 


### Isolation strategy #1: By environment (mandatory)
```
dev/
staging/
prod/
```
Each envionemnts:
- seperate state
- seprate IAM permissions
- sepreate blast radius


### Isolation strategy #2: By system / domain
This is NOT about environments.
This is about what changes together.

Think in terms of failure domains.

Example systems:
- network (VPC, subnets, routing)
- compute (EC2, ASG, ECS)
- data (RDS, DynamoDB)
- security (IAM, KMS)

why?
Beacuse:
- Network changes are rare but extremely dangerous
- App changes are frequent and should be fast
- You do NOT want app deploys blocked by VPC edits

So we split states like this:
```
terraform/
  network/
    dev/
    prod/
  compute/
    dev/
    prod/
  data/
    dev/
    prod/
```

Each folder:
- one backend
- one state
- one blast radius

If compute breaks:
- network is untouched
- data is untouched

That is domain isolation.

### Isolation strategy #3: By service (advanced)
Only for large orgs:
```
payments/
auth/
orders/
```

use only when:
- teams are independent
- ownership is clear
- APIs are stable

Beginners should NOT start here.

--

## Key defines isolation (important)
```
key = "network/prod/terraform.tfstate"
```
That string defines:
- who shares the state
- what collide
-  what fails together

Changing the key = new reality.


--


## Final production rules (memorize these)
- Smaller states = safer applies
- Too many states = coordination pain
- Beginners usually choose extremes
- Balance comes from experience

Terraform state is not a file problem.
It is a distributed systems problem.