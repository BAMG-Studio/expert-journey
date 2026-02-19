
# SageMaker Security Hardening

## Architecture Overview
SageMaker has multiple components - each needs separate security controls:
- **Notebooks**: Where data scientists write code (must restrict data exfil)
- **Training Jobs**: Where models learn from data (must isolate from internet)
- **Model Registry**: Where trained models are stored (must sign and version)
- **Endpoints**: Where models serve predictions (must authenticate callers)

## Network Isolation

### VPC Configuration for SageMaker
```python
import boto3

sagemaker = boto3.client('sagemaker')

# Create training job in isolated VPC
response = sagemaker.create_training_job(
    TrainingJobName='interos-supply-chain-risk-model-v2',
    AlgorithmSpecification={
        'TrainingImage': '763104351884.dkr.ecr.us-east-1.amazonaws.com/pytorch-training:1.12.0-gpu-py38',
        'TrainingInputMode': 'File'
    },
    RoleArn='arn:aws:iam::123456789:role/SageMakerTrainingRole',
    InputDataConfig=[{
        'ChannelName': 'training',
        'DataSource': {
            'S3DataSource': {
                'S3DataType': 'S3Prefix',
                'S3Uri': 's3://interos-ml-training-data/supply-chain-v2/',
                'S3DataDistributionType': 'FullyReplicated'
            }
        },
        'ContentType': 'application/x-parquet'
    }],
    OutputDataConfig={
        'S3OutputPath': 's3://interos-ml-models/training-output/',
        'KmsKeyId': 'arn:aws:kms:us-east-1:123456789:key/model-key'
    },
    ResourceConfig={
        'InstanceType': 'ml.p3.2xlarge',
        'InstanceCount': 1,
        'VolumeSizeInGB': 100,
        'VolumeKmsKeyId': 'arn:aws:kms:us-east-1:123456789:key/volume-key'
    },
    # CRITICAL: Disable internet access for training jobs
    EnableNetworkIsolation=True,
    EnableInterContainerTrafficEncryption=True,
    VpcConfig={
        'SecurityGroupIds': ['sg-0abc123def456789'],
        'Subnets': ['subnet-private-1a', 'subnet-private-1b']
    },
    StoppingCondition={'MaxRuntimeInSeconds': 86400}
)
```

## SageMaker IAM Role - Least Privilege
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadTrainingData",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": "arn:aws:s3:::interos-ml-training-data/*"
    },
    {
      "Sid": "WriteModelOutput",
      "Effect": "Allow",
      "Action": ["s3:PutObject"],
      "Resource": "arn:aws:s3:::interos-ml-models/training-output/*"
    },
    {
      "Sid": "UseKMSKey",
      "Effect": "Allow",
      "Action": ["kms:Decrypt", "kms:GenerateDataKey"],
      "Resource": "arn:aws:kms:us-east-1:123456789:key/*"
    },
    {
      "Sid": "DenyAllElse",
      "Effect": "Deny",
      "NotAction": [
        "s3:GetObject", "s3:ListBucket", "s3:PutObject",
        "kms:Decrypt", "kms:GenerateDataKey",
        "logs:CreateLogGroup", "logs:PutLogEvents",
        "ecr:GetAuthorizationToken", "ecr:BatchGetImage"
      ],
      "Resource": "*"
    }
  ]
}
```

## SageMaker Endpoint Security
```python
# Secure inference endpoint with authentication
endpoint_config = sagemaker.create_endpoint_config(
    EndpointConfigName='interos-risk-model-config',
    ProductionVariants=[{
        'VariantName': 'primary',
        'ModelName': 'interos-supply-chain-risk-v2',
        'InstanceType': 'ml.m5.xlarge',
        'InitialInstanceCount': 2
    }],
    KmsKeyId='arn:aws:kms:us-east-1:123456789:key/endpoint-key',
    DataCaptureConfig={
        'EnableCapture': True,
        'InitialSamplingPercentage': 100,
        'DestinationS3Uri': 's3://interos-model-monitor/capture/',
        'CaptureOptions': [
            {'CaptureMode': 'Input'},
            {'CaptureMode': 'Output'}
        ]
    }
)

# Invoke endpoint with SigV4 auth (required by AWS SDK)
runtime = boto3.client('sagemaker-runtime')
response = runtime.invoke_endpoint(
    EndpointName='interos-risk-model-endpoint',
    ContentType='application/json',
    Body=json.dumps({'supplier_id': 'SUP-001', 'features': [...]})
)
```

## Model Monitor - Detect Data Drift
```python
from sagemaker.model_monitor import DefaultModelMonitor
from sagemaker.model_monitor.dataset_format import DatasetFormat

monitor = DefaultModelMonitor(
    role='arn:aws:iam::123456789:role/SageMakerMonitorRole',
    instance_count=1,
    instance_type='ml.m5.xlarge',
    volume_size_in_gb=20,
    max_runtime_in_seconds=1800
)

# Create baseline from training data distribution
monitor.suggest_baseline(
    baseline_dataset='s3://interos-ml-training-data/baseline/training.csv',
    dataset_format=DatasetFormat.csv(header=True)
)

# Schedule continuous monitoring
monitor.create_monitoring_schedule(
    monitor_schedule_name='interos-model-drift-monitor',
    endpoint_input='interos-risk-model-endpoint',
    output_s3_uri='s3://interos-model-monitor/reports/',
    statistics='s3://interos-model-monitor/baseline/statistics.json',
    constraints='s3://interos-model-monitor/baseline/constraints.json',
    schedule_cron_expression='cron(0 * ? * * *)'
)
```

## Security Checklist
- [ ] Network isolation enabled for all training jobs
- [ ] VPC with no internet gateway for training subnets
- [ ] KMS encryption on all S3 buckets and EBS volumes
- [ ] Data capture enabled on endpoints
- [ ] Model monitor scheduled for drift detection
- [ ] CloudTrail logging for all SageMaker API calls
- [ ] IAM roles follow least privilege
- [ ] Container images scanned with ECR Enhanced Scanning

## Interview Story
"At my previous role, we caught a supply chain attack on our ML training pipeline.
An attacker had compromised a data preprocessing Lambda and was injecting
subtle label flips into our training data. We detected it because:
1. S3 Object Lock prevented modification of original data
2. We had data lineage tracking with checksums
3. Model Monitor flagged statistical drift in training metrics
The attack would have caused our risk model to underestimate certain supplier risks."
