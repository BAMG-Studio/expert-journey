# Blueprint 06: The Security Layer
## How Every Component of the AI System is Secured

## Overview
This blueprint describes the comprehensive security architecture protecting
the Interos AI platform. Every layer of the system has defense-in-depth.

## Security Architecture Diagram
```
[External Clients]
        |
   [WAF + DDoS Protection]
        |
   [API Gateway + Auth]
        |
   [VPC - Private Subnets]
    /         [EKS Inference]  [SageMaker]
    |                |
[IRSA Roles]    [VPC Isolation]
    |                |
[ECR - Signed   [S3 Object Lock
 Images Only]    Training Data]
    |                |
    +----[KMS]-------+
         [CloudTrail]
         [Security Hub]
         [GuardDuty]
```

## Layer 1: Perimeter Security
- AWS WAF: Block SQL injection, XSS, common web attacks against AI APIs
- AWS Shield Standard: DDoS protection
- Route 53: DNS-based health checks and failover
- Certificate Manager: Automated TLS certificate rotation

## Layer 2: Network Security
- VPC: Separate VPCs for production, staging, development
- Private subnets: ML training and inference runs with no public internet
- Security Groups: Whitelist-based rules per component
- VPC Flow Logs: All network traffic logged to S3
- PrivateLink: Connect to AWS services without internet (S3, ECR, KMS)

## Layer 3: Compute Security
### EKS (Inference)
- IRSA: Pod-level IAM roles (no shared credentials)
- Pod Security Standards: restricted profile (no root, no privilege escalation)
- OPA Gatekeeper: Only signed ECR images deploy
- Falco: Runtime threat detection
- Network Policies: Default deny, explicit allows

### SageMaker (Training)
- EnableNetworkIsolation: Training jobs cannot reach internet
- VPC Config: Private subnets only
- KMS: All EBS and S3 volumes encrypted
- IAM: Least privilege execution roles

## Layer 4: Data Security
- S3 Object Lock: Training data is immutable (GOVERNANCE mode)
- KMS CMK: Customer-managed keys for all data
- Macie: Continuous PII scanning on training data
- VPC Endpoints: S3 access stays within AWS network

## Layer 5: Identity & Access Management
- AWS SSO: Centralized identity with MFA enforcement
- IAM: Separate roles for: data access, model training, model deployment
- No long-lived credentials: IRSA and instance profiles only
- IAM Access Analyzer: Detect overly permissive policies
- Service Control Policies (SCPs): Organizational guardrails

## Layer 6: Model Security
- cosign: All model artifacts cryptographically signed
- in-toto: Supply chain attestation for ML pipeline
- SageMaker Model Registry: Approval workflow before deployment
- Lambda gates: Verify signature before every deployment

## Layer 7: Monitoring & Detection
- CloudTrail: All API calls logged and searchable
- Security Hub: Centralized findings (Config + Inspector + GuardDuty + Macie)
- GuardDuty: ML-based threat detection (including SageMaker anomalies)
- SageMaker Model Monitor: Data drift and prediction distribution monitoring
- EventBridge: Real-time alerts on critical security events
- CloudWatch: Custom dashboards for ML security metrics

## Incident Response Triggers
| Event | Trigger | Automated Response |
|-------|---------|--------------------|
| Unsigned model deployment | Lambda rejects | Block + SNS alert |
| Object Lock override attempt | CloudTrail event | Alert CISO |
| Training data access anomaly | Macie finding | Suspend access, alert |
| Model drift > 10% | Model Monitor | Rollback to last good |
| Container escape detected | Falco rule | Kill pod, alert |
| Unusual inference API pattern | GuardDuty ML | Rate limit, investigate |

## Pidgin Summary
Security layer be like castle wey get many walls:
- First wall: WAF stop hackers from outside
- Second wall: Network isolation stop people from moving inside
- Third wall: IRSA give each pod only its own key
- Fourth wall: Object Lock protect training data from change
- Fifth wall: cosign verify every model before deploy
- Guards (CloudTrail, GuardDuty): watch everything 24/7
