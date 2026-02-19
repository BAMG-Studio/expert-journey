# THE BRAIN (The "How") - Application Logic / Backend / Middleware
## "Omo, Na Here the Real Magic Happen!"

---

## What Is The Brain?
The brain na the backend - the part users no dey see but na em dey do all the
work. Think am like engine inside car. You press accelerator (send request),
engine (backend) dey process, and car move (response come back).

## Core Components

### 1. AWS Lambda (Serverless Functions)
**What it is**: Small code functions wey run ONLY when called. No server to manage.
**Pidgin**: Like okada rider wey dey wait for call. When customer call, dem ride,
deliver, and go back wait. You only pay for the ride - not the waiting time!

**Our Use Cases in This Project**:
```
GuardDuty Alert  -->  Lambda: Disable compromised IAM credentials
S3 Upload        -->  Lambda: Generate SBOM for new model artifact  
Scheduled Timer  -->  Lambda: Daily compliance check (Config rules)
API Gateway      -->  Lambda: Query ML model, return risk score
EventBridge      -->  Lambda: Orchestrate full incident response
```

**Real Code - Incident Response Lambda**:
```python
import boto3, json, logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # LINE 1: Get the GuardDuty finding details from event payload
    finding = event['detail']

    # LINE 2: Extract WHO did the bad thing (the compromised user)
    user_name = finding['resource']['accessKeyDetails']['userName']
    access_key = finding['resource']['accessKeyDetails']['accessKeyId']

    logger.info(f'THREAT: Compromised user detected: {user_name}')

    # LINE 3: Connect to AWS IAM (Identity and Access Management) service
    iam = boto3.client('iam')

    # LINE 4: Immediately deactivate the stolen access key - STOP the attacker!
    iam.update_access_key(
        UserName=user_name,
        AccessKeyId=access_key,
        Status='Inactive'  # Key don block - attacker can't use am again
    )

    # LINE 5: Attach DENY ALL policy - even if attacker has other keys
    iam.put_user_policy(
        UserName=user_name,
        PolicyName='EMERGENCY-DENY-ALL',
        PolicyDocument=json.dumps({
            'Version': '2012-10-17',
            'Statement': [{'Effect': 'Deny', 'Action': '*', 'Resource': '*'}]
        })
    )

    # LINE 6: Alert the security team immediately via SNS
    boto3.client('sns').publish(
        TopicArn='arn:aws:sns:us-east-1:ACCT:security-critical',
        Subject=f'CRITICAL BREACH: User {user_name} BLOCKED',
        Message=f'Auto-response complete. Key {access_key} disabled. Investigate NOW.'
    )

    return {'blocked': user_name, 'status': 'CONTAINED'}
```

### 2. AWS SageMaker - The AI Factory
**What it is**: Fully managed service for building, training, and deploying ML models.
**Pidgin**: SageMaker na the factory where we manufacture AI brains.
You bring raw materials (training data), factory processes am (training job),
out comes finished product (trained model), then you put am for shop shelf
(inference endpoint) where customers buy (query am for predictions).

**Security Controls Applied**:
| Control | What It Does | Why It Matters |
|---------|-------------|----------------|
| VPC Isolation | Training environment has NO internet access | Bad guy can't call home |
| KMS Encryption | All data encrypted at rest AND in transit | Even if stolen, data useless |
| IAM Roles | Only approved roles can deploy/access models | No unauthorized access |
| Container Signing | Only cosign-verified images deploy | No tampered containers |
| S3 Object Lock | Training data immutable (cannot be modified) | Prevents data poisoning |

### 3. Amazon EKS - The Container Army
**What it is**: Elastic Kubernetes Service - managed Kubernetes cluster on AWS.
**Pidgin**: If Lambda na one soldier, EKS na the whole battalion!
E dey manage hundreds of containers (small apps) simultaneously,
restart dem if dem fall sick, scale up when traffic plenty.

**Security Controls**:
- Pod Security Standards (Restricted profile) - no root containers allowed
- Network Policies - containers can only talk to who dem supposed to talk to
- Kyverno policies - enforce security rules automatically
- Falco runtime security - detect suspicious container behavior in real-time

### 4. EventBridge - The Traffic Warden
**What it is**: Central event bus that connects all AWS services.
**Pidgin**: Na like traffic warden for Oshodi junction!
GuardDuty raise alarm --> EventBridge decide which Lambda should handle am
Config violation --> EventBridge route am to remediation Lambda
Scheduled job --> EventBridge trigger compliance checker
Everything organized. Nothing get lost.

---

## Complete Data Flow: AI Security Pipeline

```
Developer pushes ML model code
           |
    GitHub Actions CI/CD
           |
    +------v--------+
    | Security Scan |  <-- Checkov, tfsec (IaC security)
    | SBOM Generate |  <-- Syft (list all dependencies)
    | Vuln Scan     |  <-- Grype, Snyk (find CVEs)
    | Model Sign    |  <-- cosign (cryptographic stamp)
    +------+--------+
           | (ALL PASSED)
    +------v--------+
    | SageMaker     |  <-- Train/Deploy the model
    | Endpoint      |  <-- KMS encrypted, VPC isolated
    +------+--------+
           |
    +------v--------+
    | API Gateway   |  <-- WAF, rate limiting, auth
    | Lambda        |  <-- Input validation, output filter
    +------+--------+
           |
    Client receives risk score
           |
    GuardDuty monitors everything
    CloudTrail logs every API call
    OpenSearch SIEM analyzes patterns
```

> **Sisi Lola Voice**: "Omo! See the beauty of this architecture!
From code push to inference - everything get security check.
E no possible for bad thing to pass through without alarm!
Na this one dem call DEFENSE IN DEPTH - layer upon layer!"
