"""Integration Tests for SIEM Pipeline

WHAT ARE INTEGRATION TESTS?
- Unlike unit tests that test ONE piece, integration tests
  verify that MULTIPLE components work TOGETHER
- These tests simulate the full log ingestion pipeline

PREREQUISITES:
- LocalStack or moto must be running
- Docker must be available

HOW TO RUN:
  docker-compose up -d  # Start LocalStack
  python -m pytest tests/integration/ -v
"""
import unittest
import json
import os


class TestPipelineEndToEnd(unittest.TestCase):
    """Test the full SIEM pipeline from log ingestion to storage."""

    @classmethod
    def setUpClass(cls):
        """Check if LocalStack is available before running tests."""
        cls.localstack_url = os.environ.get(
            "LOCALSTACK_URL", "http://localhost:4566"
        )
        cls.skip_reason = None
        try:
            import boto3
            client = boto3.client(
                "s3",
                endpoint_url=cls.localstack_url,
                aws_access_key_id="test",
                aws_secret_access_key="test",
                region_name="us-east-1"
            )
            client.list_buckets()
        except Exception as e:
            cls.skip_reason = f"LocalStack not available: {e}"

    def setUp(self):
        if self.skip_reason:
            self.skipTest(self.skip_reason)

    def test_s3_bucket_creation(self):
        """Verify we can create the SIEM log archive bucket."""
        import boto3
        s3 = boto3.client(
            "s3",
            endpoint_url=self.localstack_url,
            aws_access_key_id="test",
            aws_secret_access_key="test",
            region_name="us-east-1"
        )
        bucket_name = "siem-integration-test"
        try:
            s3.create_bucket(Bucket=bucket_name)
            buckets = [b["Name"] for b in s3.list_buckets()["Buckets"]]
            self.assertIn(bucket_name, buckets)
        finally:
            try:
                s3.delete_bucket(Bucket=bucket_name)
            except Exception:
                pass

    def test_log_normalization_pipeline(self):
        """Test that raw logs can be normalized and stored."""
        import sys
        sys.path.insert(0, os.path.join(
            os.path.dirname(__file__), '..', '..', 'lambda'
        ))
        from normalizers.vpc_flowlog_normalizer import normalize_vpc_flowlog

        raw_log = {
            "version": 2,
            "srcaddr": "10.0.1.1",
            "dstaddr": "10.0.2.2",
            "action": "ACCEPT"
        }
        normalized = normalize_vpc_flowlog(raw_log)
        self.assertIn("timestamp", normalized)
        self.assertEqual(normalized["source"], "vpc-flowlog")


if __name__ == "__main__":
    unittest.main()
