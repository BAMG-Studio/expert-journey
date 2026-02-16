# Deployment Runbook

## Pre-Deployment

- [ ] Prerequisites verified
- [ ] Credentials configured
- [ ] Terraform initialized

## Deployment Steps

1. Plan: `terraform plan`
2. Apply: `terraform apply`
3. Verify: Check outputs and test

## Post-Deployment

- Verify all resources created
- Run smoke tests
- Update documentation

## Rollback

```bash
terraform destroy -target=<resource>
```
