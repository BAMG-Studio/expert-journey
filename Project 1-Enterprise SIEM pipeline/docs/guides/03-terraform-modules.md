# Terraform Modules Explained

## Module Architecture

```
terraform/
├── main.tf              # Root module - orchestrates everything
├── variables.tf         # Input variables with validation
├── providers.tf         # AWS provider configuration
├── outputs.tf           # Exported values
└── modules/
    ├── kms/             # Encryption keys
    ├── s3-log-archive/  # Log storage
    ├── opensearch/      # SIEM engine
    ├── kinesis-firehose/# Data streaming
    ├── cloudtrail/      # API logging
    ├── eventbridge/     # Event routing
    └── lambda-normalizers/ # Event processing
```

## Module: KMS

**Purpose:** Creates customer-managed encryption keys for all SIEM data.

**Key Features:**
- Automatic annual key rotation
- Multi-region support for DR
- Service-level permissions

**Usage:**
```hcl
module "kms" {
  source      = "./modules/kms"
  name_prefix = "enterprise-siem-dev"
  environment = "dev"
}
```

## Module: S3 Log Archive

**Purpose:** Centralized storage for all security logs.

**Key Features:**
- KMS encryption at rest
- Lifecycle policies (Intelligent-Tiering → Glacier)
- Versioning for compliance
- Cross-region replication option

## Module: OpenSearch

**Purpose:** SIEM dashboard and search engine.

**Key Features:**
- Fine-grained access control
- Node-to-node encryption
- Automated snapshots
- Zone awareness for HA

## Module: Kinesis Firehose

**Purpose:** Real-time data delivery to OpenSearch.

**Key Features:**
- Buffering (size/time based)
- Failed record backup to S3
- CloudWatch monitoring

## Module: Lambda Normalizers

**Purpose:** Transform security events to common schema.

**Normalizers:**
- GuardDuty findings
- CloudTrail events
- Security Hub findings
- VPC Flow Logs
