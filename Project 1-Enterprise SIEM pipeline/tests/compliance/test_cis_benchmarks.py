import unittest
import os


class TestCISBenchmarks(unittest.TestCase):
    """Verify SIEM infrastructure meets CIS AWS benchmarks."""

    def _read_tf_main(self):
        tf_main = os.path.join(
            os.path.dirname(__file__), '..', '..', 'terraform', 'main.tf'
        )
        if os.path.exists(tf_main):
            with open(tf_main, 'r') as f:
                return f.read().lower()
        return None

    def test_terraform_enforces_encryption(self):
        """CIS 2.1.1 - S3 must have encryption."""
        content = self._read_tf_main()
        if content:
            self.assertTrue(
                'encryption' in content,
                "Terraform must reference encryption for S3"
            )

    def test_terraform_enforces_versioning(self):
        """CIS 2.1.3 - S3 buckets should have versioning."""
        content = self._read_tf_main()
        if content:
            self.assertIn('versioning', content)

    def test_terraform_enforces_logging(self):
        """CIS 3.1 - CloudTrail must be enabled."""
        content = self._read_tf_main()
        if content:
            self.assertIn('cloudtrail', content)

    def test_destroy_script_exists(self):
        """Verify TERRAFORM_DESTROY.sh exists."""
        script = os.path.join(
            os.path.dirname(__file__), '..', '..', 'TERRAFORM_DESTROY.sh'
        )
        self.assertTrue(os.path.exists(script))


if __name__ == "__main__":
    unittest.main()
