# NIST SP 800-53 Control Mapping

## Audit and Accountability (AU)

| Control | Description | SIEM Implementation |
|---------|-------------|--------------------|
| AU-2 | Audit Events | CloudTrail captures all API calls |
| AU-3 | Content of Audit Records | Common schema includes who, what, when, where |
| AU-4 | Audit Storage Capacity | S3 with auto-scaling, lifecycle policies |
| AU-5 | Response to Audit Failures | CloudWatch alarms on pipeline failures |
| AU-6 | Audit Review | OpenSearch dashboards for review |
| AU-7 | Audit Reduction | Lambda normalizers filter noise |
| AU-9 | Protection of Audit Info | KMS encryption, S3 versioning |
| AU-11 | Audit Record Retention | Configurable retention (90-2190 days) |
| AU-12 | Audit Generation | EventBridge rules capture security events |

## Security Assessment (CA)

| Control | Description | SIEM Implementation |
|---------|-------------|--------------------|
| CA-7 | Continuous Monitoring | Real-time event processing |
| CA-8 | Penetration Testing | GuardDuty findings analysis |

## Incident Response (IR)

| Control | Description | SIEM Implementation |
|---------|-------------|--------------------|
| IR-4 | Incident Handling | OpenSearch correlation |
| IR-5 | Incident Monitoring | Real-time dashboards |
| IR-6 | Incident Reporting | Automated alerts via SNS |
