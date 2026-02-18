import unittest
import sys
import os
import json

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'lambda'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'lambda', 'normalizers'))
from common_schema import SIEMLogSchema, severity_to_score


class TestSIEMLogSchema(unittest.TestCase):
    """Tests for the common SIEM log schema class."""

    def test_schema_creates_instance(self):
        schema = SIEMLogSchema()
        self.assertIsNotNone(schema)

    def test_to_dict_returns_dict(self):
        schema = SIEMLogSchema()
        schema.source = "test"
        schema.event_type = "test_event"
        schema.severity = "LOW"
        result = schema.to_dict()
        self.assertIsInstance(result, dict)

    def test_to_json_returns_string(self):
        schema = SIEMLogSchema()
        schema.source = "test"
        result = schema.to_json()
        self.assertIsInstance(result, str)
        parsed = json.loads(result)
        self.assertIsInstance(parsed, dict)

    def test_has_timestamp(self):
        schema = SIEMLogSchema()
        result = schema.to_dict()
        self.assertIn("timestamp", result)


class TestSeverityScore(unittest.TestCase):
    """Tests for the severity scoring function."""

    def test_high_severity_returns_high_score(self):
        score = severity_to_score("HIGH")
        self.assertIsInstance(score, int)
        self.assertGreater(score, 0)

    def test_low_severity_returns_low_score(self):
        score = severity_to_score("LOW")
        self.assertIsInstance(score, int)


if __name__ == "__main__":
    unittest.main()
