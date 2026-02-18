import unittest
import sys
import os
import json

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'lambda'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'lambda', 'normalizers'))
from normalizers.cloudtrail_normalizer import normalize_cloudtrail


class TestCloudTrailNormalizer(unittest.TestCase):
    def setUp(self):
        self.event = {
            "eventSource": "s3.amazonaws.com",
            "eventName": "GetObject",
            "userIdentity": {"arn": "arn:aws:iam::123456789012:user/test"},
            "sourceIPAddress": "1.2.3.4",
            "eventTime": "2024-01-15T10:30:00Z"
        }

    def _normalize(self, event):
        result = normalize_cloudtrail(event)
        if isinstance(result, str):
            return json.loads(result)
        return result

    def test_returns_valid_output(self):
        result = self._normalize(self.event)
        self.assertIsInstance(result, dict)

    def test_event_type_is_cloudtrail(self):
        result = self._normalize(self.event)
        self.assertEqual(result["event_type"], "cloudtrail")

    def test_has_required_fields(self):
        result = self._normalize(self.event)
        for field in ["timestamp", "event_source", "event_type", "severity", "raw_event"]:
            self.assertIn(field, result)

    def test_empty_event(self):
        result = self._normalize({})
        self.assertIsInstance(result, dict)


if __name__ == "__main__":
    unittest.main()
