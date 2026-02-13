# Deployment Runbook: [Project Name]

## Prerequisites

- [ ] AWS CLI configured with appropriate credentials
- [ ] Terraform >= 1.5.0 installed
- [ ] Python >= 3.11 installed
- [ ] Required environment variables set (see below)

### Environment Variables

```bash
export AWS_REGION=us-east-1
export AWS_PROFILE=security-admin
export TF_VAR_environment=production
export TF_VAR_project_name=[project-name]
```

---

## Step 1: Initialize Infrastructure

```bash
cd infra/
terraform init -backend-config=backend.hcl
terraform workspace select production || terraform workspace new production
```

**Verification**: `terraform workspace show` returns `production`

## Step 2: Plan and Review

```bash
terraform plan -out=tfplan
# Review the plan output carefully
# Verify no unexpected resource deletions or modifications
```

**Verification**: Plan output shows only expected changes

## Step 3: Security Scan

```bash
checkov -d . --framework terraform
tfsec .
```

**Verification**: Zero high or critical findings

## Step 4: Apply Infrastructure

```bash
terraform apply tfplan
```

**Verification**: All resources created successfully (check outputs)

## Step 5: Deploy Application Code

```bash
cd ../automation/
# Package and deploy Lambda functions
python deploy.py --env production
```

**Verification**: Lambda functions deployed and aliases updated

## Step 6: Validate Deployment

```bash
python tests/integration/test_deployment.py
```

**Verification**: All integration tests pass

---

## Rollback Procedure

If any step fails:

1. **Infrastructure rollback**: `terraform apply -target=<resource> -var="previous_version"`
2. **Application rollback**: `python deploy.py --env production --rollback`
3. **Notify team**: Post in #security-ops Slack channel

---

## Post-Deployment Verification

- [ ] CloudWatch dashboard shows healthy metrics
- [ ] Security Hub compliance score unchanged or improved
- [ ] GuardDuty shows no new findings related to deployment
- [ ] Config rules show all resources compliant
- [ ] Application logs show no errors

---

## Emergency Contacts

| Role | Contact | Escalation |
|---|---|---|
| Security Engineer | [Name] | Primary |
| Platform Lead | [Name] | Secondary |
| Incident Commander | [Name] | Escalation |
