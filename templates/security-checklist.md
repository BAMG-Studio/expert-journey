# Security Checklist

Pre-deployment security verification checklist based on OWASP, CIS Benchmarks, and AWS Well-Architected Security Pillar.

---

## Identity and Access Management

- [ ] IAM policies follow least-privilege principle
- [ ] No wildcard (*) permissions in IAM policies unless justified and documented
- [ ] MFA enabled for all human IAM users
- [ ] Service accounts use IAM roles (not access keys)
- [ ] Permission boundaries applied for delegated admin roles
- [ ] Root account has MFA and no access keys
- [ ] Cross-account access uses external ID condition

## Network Security

- [ ] Resources deployed in private subnets (no direct internet exposure)
- [ ] Security groups restrict inbound to minimum required ports and sources
- [ ] NACLs provide additional network-level filtering
- [ ] VPC Flow Logs enabled
- [ ] VPC endpoints used for AWS service access (no internet traversal)
- [ ] WAF rules configured for public-facing endpoints

## Data Protection

- [ ] Encryption at rest enabled (KMS CMK preferred over AWS-managed keys)
- [ ] Encryption in transit enforced (TLS 1.2+)
- [ ] S3 buckets block public access (account-level and bucket-level)
- [ ] S3 bucket policies deny unencrypted uploads (aws:SecureTransport)
- [ ] Sensitive data classified and monitored (Macie)
- [ ] KMS key rotation enabled
- [ ] Backup and recovery procedures documented and tested

## Logging and Monitoring

- [ ] CloudTrail enabled (organization trail preferred)
- [ ] CloudTrail log file validation enabled
- [ ] GuardDuty enabled in all regions
- [ ] Security Hub enabled with standards (CIS, NIST)
- [ ] CloudWatch alarms for security-critical metrics
- [ ] Log retention policies comply with compliance requirements (min 1 year)

## Infrastructure as Code

- [ ] Terraform plans pass Checkov scan (zero high/critical findings)
- [ ] Terraform plans pass tfsec scan (zero high/critical findings)
- [ ] No secrets or credentials in code or Terraform state
- [ ] Terraform state stored in encrypted S3 with DynamoDB locking
- [ ] Provider versions pinned
- [ ] Module versions pinned

## CI/CD Pipeline Security

- [ ] Branch protection enabled (require PR reviews)
- [ ] Secret scanning enabled in repository
- [ ] Dependency scanning enabled (Dependabot or equivalent)
- [ ] SAST scanning in pipeline
- [ ] Container image scanning before push to registry
- [ ] Deployment requires passing all security gates

## Container and Kubernetes (if applicable)

- [ ] Container images built from minimal base images
- [ ] Container images scanned for vulnerabilities (Trivy)
- [ ] Images signed with cosign
- [ ] Pod security standards enforced (restricted profile)
- [ ] Network policies restrict pod-to-pod communication
- [ ] RBAC configured with least-privilege
- [ ] Secrets managed via external secrets operator (not Kubernetes secrets)

## OWASP Top 10 (for APIs and Web Applications)

- [ ] Input validation on all user-supplied data
- [ ] Authentication and session management follow best practices
- [ ] Access control enforced server-side
- [ ] Sensitive data exposure mitigated (encryption, masking)
- [ ] Security headers configured (HSTS, CSP, X-Frame-Options)
- [ ] Dependency vulnerabilities tracked and remediated
- [ ] Logging sufficient for security event investigation
