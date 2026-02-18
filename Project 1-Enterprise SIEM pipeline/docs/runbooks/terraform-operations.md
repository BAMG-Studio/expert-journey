# Terraform Operations Runbook

## Standard Deployment

### Pre-Deployment Checklist
- [ ] AWS credentials configured
- [ ] Terraform version >= 1.5.0
- [ ] Backend state accessible
- [ ] Variables file updated
- [ ] PR approved (for production)

### Deploy Procedure
```bash
cd terraform

# 1. Initialize
terraform init

# 2. Validate
terraform validate
terraform fmt -check

# 3. Plan and review
terraform plan -var-file=environments/dev.tfvars -out=tfplan
terraform show tfplan

# 4. Apply
terraform apply tfplan

# 5. Verify outputs
terraform output
```

## Emergency Rollback

### Option 1: Apply Previous State
```bash
# List state versions (if using S3 backend)
aws s3api list-object-versions --bucket terraform-state-bucket   --prefix siem-pipeline/terraform.tfstate

# Download previous version
aws s3api get-object --bucket terraform-state-bucket   --key siem-pipeline/terraform.tfstate   --version-id "xxx" previous.tfstate

# Restore
terraform state push previous.tfstate
terraform apply -refresh-only
```

### Option 2: Targeted Destroy
```bash
# Destroy only problematic resource
terraform destroy -target=module.opensearch

# Re-apply
terraform apply -var-file=environments/dev.tfvars
```

## State Recovery

### State Lock Stuck
```bash
# Force unlock (use with caution)
terraform force-unlock LOCK_ID
```

### State Corruption
```bash
# Pull remote state
terraform state pull > backup.tfstate

# List resources
terraform state list

# Remove corrupted resource
terraform state rm module.corrupted_resource
```
