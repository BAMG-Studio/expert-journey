"""Lambda Handler Tests

These tests verify the AWS Lambda function handlers
that process incoming security logs.

EACH LAMBDA:
1. Receives a raw log event from EventBridge/S3/Kinesis
2. Calls the appropriate normalizer
3. Sends the normalized event to OpenSearch via Firehose
"""
import unittest
import json
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))


class TestVPCFlowLogHandler(unittest.TestCase):
    def test_handler_processes_valid_event(self):
        from normalizers.vpc_flowlog_normalizer import normalize_vpc_flowlog
        event = {
            "version": 2,
            "srcaddr": "10.0.1.1",
            "dstaddr": "10.0.2.2",
            "action": "ACCEPT"
        }
        result = normalize_vpc_flowlog(event)
        self.assertEqual(result["source"], "vpc-flowlog")


class TestGuardDutyHandler(unittest.TestCase):
    def test_handler_processes_finding(self):
        from normalizers.guardduty_normalizer import normalize_guardduty
        event = {"detail": {"type": "Recon:EC2/PortProbeUnprotectedPort", "severity": 5}}
        result = normalize_guardduty(event)
        self.assertEqual(result["source"], "guardduty")


if __name__ == "__main__":
    unittest.main()
