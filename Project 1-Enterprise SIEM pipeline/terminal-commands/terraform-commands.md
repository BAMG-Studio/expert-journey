# Terraform CLI Commands

## Init & Plan
```bash
terraform init
terraform plan -var-file=environments/dev.tfvars
terraform plan -var-file=environments/localstack.tfvars
```

## Apply & Destroy
```bash
terraform apply -var-file=environments/dev.tfvars
terraform apply -auto-approve -var-file=environments/dev.tfvars
terraform destroy -var-file=environments/dev.tfvars
./TERRAFORM_DESTROY.sh  # Recommended safe destroy
```

## State Management
```bash
terraform state list
terraform state show module.opensearch
terraform state mv module.old module.new
terraform import module.s3.aws_s3_bucket.log my-bucket
```

## Formatting & Validation
```bash
terraform fmt -recursive
terraform validate
terraform output
terraform output -json
```

## Workspace
```bash
terraform workspace list
terraform workspace new staging
terraform workspace select dev
```

## Debug
```bash
export TF_LOG=DEBUG
terraform apply
unset TF_LOG
```
