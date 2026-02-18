#!/usr/bin/env python3
"""Unit tests for Lambda normalizer functions."""
import json
import os
import sys
import unittest

# Add lambda directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'lambda', 'normalizers'))


class TestGuardDutyNormalizer(unittest.TestCase):
    """Test GuardDuty normalizer function."""

    def setUp(self):
        """Load test fixture."""
        fixture_path = os.path.join(
            os.path.dirname(__file__), 'fixtures', 'guardduty-event.json'
        )
        with open(fixture_path) as f:
            self.event = json.load(f)

    def test_event_loads(self):
        """Test that the fixture loads correctly."""
        self.assertIn('detail', self.event)
        self.assertEqual(self.event['source'], 'aws.guardduty')

    def test_event_has_required_fields(self):
        """Test that the event has required fields."""
        detail = self.event['detail']
        self.assertIn('severity', detail)
        self.assertIn('type', detail)
        self.assertIn('accountId', detail)

    def test_severity_is_numeric(self):
        """Test that severity is a number."""
        self.assertIsInstance(self.event['detail']['severity'], (int, float))


class TestCloudTrailNormalizer(unittest.TestCase):
    """Test CloudTrail normalizer function."""

    def setUp(self):
        fixture_path = os.path.join(
            os.path.dirname(__file__), 'fixtures', 'cloudtrail-event.json'
        )
        with open(fixture_path) as f:
            self.event = json.load(f)

    def test_event_loads(self):
        self.assertIn('detail', self.event)

    def test_event_has_user_identity(self):
        self.assertIn('userIdentity', self.event['detail'])

    def test_event_has_source_ip(self):
        self.assertIn('sourceIPAddress', self.event['detail'])


if __name__ == '__main__':
    unittest.main(verbosity=2)
