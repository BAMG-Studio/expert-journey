# Getting Started with Enterprise SIEM Pipeline

## Prerequisites

1. **Tools Required:**
   - Terraform >= 1.5.0
   - AWS CLI v2
   - Docker & Docker Compose
   - Python 3.11+
   - Git

2. **AWS Account Setup:**
   - AWS account with admin access
   - IAM user with programmatic access
   - AWS CLI configured (`aws configure`)

## Quick Start (LocalStack - Zero Cost)

### Step 1: Clone and Navigate
```bash
git clone https://github.com/BAMG-Studio/expert-journey.git
cd "expert-journey/Project 1-Enterprise SIEM pipeline"
```

### Step 2: Start LocalStack
```bash
docker-compose up -d
# Wait for services to be ready
sleep 30
curl http://localhost:4566/_localstack/health
```

### Step 3: Deploy with Terraform
```bash
cd terraform
terraform init
terraform plan -var-file=environments/localstack.tfvars
terraform apply -var-file=environments/localstack.tfvars -auto-approve
```

### Step 4: Access SIEM Dashboard
```bash
open http://localhost:5601
```

## AWS Deployment

### Step 1: Configure Credentials
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
export TF_VAR_opensearch_master_password="YourSecure@Pass123"
```

### Step 2: Deploy
```bash
cd terraform
terraform init
terraform plan -var-file=environments/dev.tfvars
terraform apply -var-file=environments/dev.tfvars
```

### Step 3: Get Dashboard URL
```bash
terraform output siem_dashboard_url
```

## Next Steps

- Read [Architecture Overview](../architecture/overview.md)
- Review [Security Best Practices](../compliance/security-best-practices.md)
- Configure [Alert Rules](./05-configuring-alerts.md)
