# Terraform CLI Commands Reference

## Initialize (First Time Setup)
```bash
# Download provider plugins and set up backend
cd terraform/
terraform init

# With LocalStack backend
terraform init -backend-config=environments/localstack.tfvars
```

## Plan (Preview Changes)
```bash
# See what Terraform WILL do before doing it
terraform plan -var-file=environments/dev.tfvars

# Save plan to file for review
terraform plan -var-file=environments/dev.tfvars -out=plan.tfplan
```

## Apply (Create Resources)
```bash
# Apply the saved plan
terraform apply plan.tfplan

# Apply directly (will prompt for confirmation)
terraform apply -var-file=environments/dev.tfvars
```

## Destroy (Remove Everything)
```bash
# USE THE DESTROY SCRIPT INSTEAD:
bash TERRAFORM_DESTROY.sh

# Manual destroy (not recommended):
terraform destroy -var-file=environments/dev.tfvars
```

## State Management
```bash
# List all managed resources
terraform state list

# Show details of one resource
terraform state show aws_s3_bucket.log_archive

# Remove resource from state (without destroying)
terraform state rm aws_s3_bucket.log_archive
```

## Formatting and Validation
```bash
# Auto-format all .tf files
terraform fmt -recursive

# Validate configuration syntax
terraform validate
```
