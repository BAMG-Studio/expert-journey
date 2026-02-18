"""Moto Tests for S3 Log Archive

WHAT IS MOTO?
- Moto is a Python library that MOCKS (fakes) AWS services
- Instead of creating REAL S3 buckets that cost money,
  Moto creates fake ones in memory for testing
- This means you can test your AWS code for FREE!

HOW TO RUN:
  pip install moto boto3
  python -m pytest tests/moto-tests/ -v
"""
import unittest

try:
    import boto3
    from moto import mock_aws
    MOTO_AVAILABLE = True
except ImportError:
    MOTO_AVAILABLE = False


@unittest.skipUnless(MOTO_AVAILABLE, "moto not installed")
class TestS3LogArchive(unittest.TestCase):
    """Test S3 bucket operations for SIEM log storage."""

    @mock_aws
    def test_create_log_bucket(self):
        """Test creating the S3 bucket where all SIEM logs are stored."""
        s3 = boto3.client("s3", region_name="us-east-1")
        s3.create_bucket(Bucket="siem-log-archive-test")
        buckets = s3.list_buckets()["Buckets"]
        names = [b["Name"] for b in buckets]
        self.assertIn("siem-log-archive-test", names)

    @mock_aws
    def test_put_and_get_log(self):
        """Test storing and retrieving a log file."""
        s3 = boto3.client("s3", region_name="us-east-1")
        s3.create_bucket(Bucket="siem-logs-test")
        log_data = b'{"event": "test", "source": "cloudtrail"}'
        s3.put_object(
            Bucket="siem-logs-test",
            Key="cloudtrail/2024/01/test.json",
            Body=log_data
        )
        obj = s3.get_object(
            Bucket="siem-logs-test",
            Key="cloudtrail/2024/01/test.json"
        )
        self.assertEqual(obj["Body"].read(), log_data)

    @mock_aws
    def test_bucket_versioning(self):
        """Test enabling versioning on the log bucket.

        WHY VERSIONING?
        - Versioning keeps old copies of files when they are overwritten
        - Critical for audit trails - you can never lose log data
        """
        s3 = boto3.client("s3", region_name="us-east-1")
        s3.create_bucket(Bucket="siem-versioned-test")
        s3.put_bucket_versioning(
            Bucket="siem-versioned-test",
            VersioningConfiguration={"Status": "Enabled"}
        )
        resp = s3.get_bucket_versioning(Bucket="siem-versioned-test")
        self.assertEqual(resp["Status"], "Enabled")


if __name__ == "__main__":
    unittest.main()
