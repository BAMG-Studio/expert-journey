import unittest
import sys
import os
import json

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'lambda'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'lambda', 'normalizers'))
from normalizers.guardduty_normalizer import normalize_guardduty


class TestGuardDutyNormalizer(unittest.TestCase):
    def setUp(self):
        self.event = {
            "detail": {
                "type": "Recon:EC2/PortProbeUnprotectedPort",
                "severity": 5,
                "accountId": "123456789012",
                "region": "us-east-1"
            }
        }

    def _normalize(self, event):
        result = normalize_guardduty(event)
        if isinstance(result, str):
            return json.loads(result)
        return result

    def test_returns_valid_output(self):
        result = self._normalize(self.event)
        self.assertIsInstance(result, dict)

    def test_has_required_fields(self):
        result = self._normalize(self.event)
        for field in ["timestamp", "event_source", "event_type", "severity", "raw_event"]:
            self.assertIn(field, result)

    def test_event_type_is_guardduty(self):
        result = self._normalize(self.event)
        self.assertEqual(result["event_type"], "guardduty")

    def test_empty_event(self):
        result = self._normalize({})
        self.assertIsInstance(result, dict)


if __name__ == "__main__":
    unittest.main()
