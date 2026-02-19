# THE FRONT DOOR (The "Where" & "What") - Presentation Layer
## "How People Dey Enter This System?"

---

## System Entry Points

### 1. AWS Console (Web Interface)
**What**: Browser-based dashboard for managing AWS services
**Who Uses It**: Security Engineers, DevOps, Compliance Officers
**Pidgin**: "Na the website wey you dey use control everything.
You fit see your S3 buckets, check GuardDuty alerts, review
Config compliance - all from one place."

### 2. AWS CLI (Command Line Interface)
**What**: Terminal-based tool for interacting with AWS
**Who Uses It**: Engineers who prefer speed over clicking
**Example Commands**:
```bash
# List S3 buckets wey get Object Lock
aws s3api list-buckets --query "Buckets[].Name"

# Check GuardDuty findings (see who dey try enter)
aws guardduty list-findings --detector-id <id>

# Get SageMaker endpoint status
aws sagemaker describe-endpoint --endpoint-name i-score-v2
```
**Pidgin**: "Instead of say you dey click click for website,
you fit type commands for terminal. E dey faster and you fit
automate am with scripts."

### 3. Terraform CLI (Infrastructure as Code)
**What**: Tool for defining and deploying cloud infrastructure
**Who Uses It**: DevOps and Security Engineers
**Example**:
```bash
# See wetin go change before you apply
terraform plan

# Deploy the infrastructure
terraform apply

# Destroy everything (CAREFUL!)
terraform destroy
```
**Pidgin**: "Instead of say you dey click click to create S3
bucket, VPC, Lambda - you write code wey describe everything,
then Terraform go create am for you. If you wan delete am,
one command and everything go comot. Na power!"

### 4. GitHub Actions (CI/CD Pipeline)
**What**: Automated workflows triggered by code changes
**Who Uses It**: The system itself (automated)
**Flow**:
```
Developer pushes code --> GitHub Actions triggers -->
Security scan (Checkov, tfsec) --> SBOM generation (Syft) -->
Vulnerability check (Snyk, Grype) --> Deploy (if all pass)
```
**Pidgin**: "Anytime person push code, robot go automatically
check say the code no get security problems. If e clean, e go
deploy. If e dirty, e go block am and shout for you."

### 5. API Gateway (For External Clients)
**What**: REST API endpoint for querying AI models
**Who Uses It**: Government agencies, partner applications
**Pidgin**: "Na the door wey outside people dey use enter.
Dem send request, our AI process am, send back answer.
But we put bouncer for door (authentication, rate limiting)
so only people wey get permission fit enter."

---

## Architecture Diagram (High Level)

```
                    +------------------+
                    |  AWS Console /   |
                    |  CLI / Terraform |
                    +--------+---------+
                             |
                    +--------v---------+
                    |   API Gateway    |
                    |  (WAF + Auth)    |
                    +--------+---------+
                             |
              +--------------+--------------+
              |              |              |
     +--------v---+  +-------v----+  +------v-------+
     |  Lambda    |  | SageMaker  |  |    EKS       |
     | (Serverless)|  | (ML Train/ |  | (Kubernetes) |
     |            |  |  Inference) |  |              |
     +--------+---+  +-------+----+  +------+-------+
              |              |              |
              +--------------+--------------+
                             |
                    +--------v---------+
                    |    S3 / DynamoDB |
                    |  (Data Storage)  |
                    +--------+---------+
                             |
                    +--------v---------+
                    |  GuardDuty /     |
                    |  Security Hub /  |
                    |  CloudTrail      |
                    +------------------+
```

> **Sisi Lola Voice**: "See as everything connect! From the top
> where people dey enter, to the middle where the AI brain dey
> work, to the bottom where we dey store data and monitor
> everything. Na beautiful architecture!"
