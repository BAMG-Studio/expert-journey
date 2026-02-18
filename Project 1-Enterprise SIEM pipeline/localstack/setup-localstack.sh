#!/bin/bash
# =============================================================================
# LOCALSTACK SETUP - Initialize local AWS services
# =============================================================================
set -euo pipefail

ENDPOINT="http://localhost:4566"

echo "=== Setting up LocalStack for SIEM Pipeline ==="

# Wait for LocalStack
echo "Waiting for LocalStack..."
until curl -s $ENDPOINT/_localstack/health | grep -q running; do
    sleep 2
done
echo "LocalStack is ready!"

# Create S3 bucket
echo "Creating S3 log bucket..."
aws --endpoint-url=$ENDPOINT s3 mb s3://siem-local-logs-test 2>/dev/null || true

# Create Kinesis stream
echo "Creating Kinesis stream..."
aws --endpoint-url=$ENDPOINT kinesis create-stream   --stream-name siem-local-stream   --shard-count 1 2>/dev/null || true

# Create KMS key
echo "Creating KMS key..."
aws --endpoint-url=$ENDPOINT kms create-key   --description "SIEM LocalStack Key" 2>/dev/null || true

# Create Lambda execution role
echo "Creating IAM role..."
aws --endpoint-url=$ENDPOINT iam create-role   --role-name siem-lambda-role   --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"lambda.amazonaws.com"},"Action":"sts:AssumeRole"}]}' 2>/dev/null || true

echo "=== LocalStack Setup Complete ==="
