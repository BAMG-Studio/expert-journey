"""Moto Tests for Kinesis Firehose

WHAT IS KINESIS FIREHOSE?
- A fully managed service that delivers streaming data
- In our SIEM, it receives logs and delivers them to S3/OpenSearch
- Think of it as a conveyor belt for log data
"""
import unittest

try:
    import boto3
    from moto import mock_aws
    MOTO_AVAILABLE = True
except ImportError:
    MOTO_AVAILABLE = False


@unittest.skipUnless(MOTO_AVAILABLE, "moto not installed")
class TestKinesisFirehose(unittest.TestCase):

    @mock_aws
    def test_create_delivery_stream(self):
        s3 = boto3.client("s3", region_name="us-east-1")
        s3.create_bucket(Bucket="siem-firehose-dest")
        firehose = boto3.client("firehose", region_name="us-east-1")
        firehose.create_delivery_stream(
            DeliveryStreamName="siem-log-stream",
            S3DestinationConfiguration={
                "RoleARN": "arn:aws:iam::123456789012:role/firehose",
                "BucketARN": "arn:aws:s3:::siem-firehose-dest"
            }
        )
        streams = firehose.list_delivery_streams()
        self.assertIn("siem-log-stream", streams["DeliveryStreamNames"])


if __name__ == "__main__":
    unittest.main()
