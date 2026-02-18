"""Moto Tests for KMS Encryption

WHAT IS KMS?
- KMS = Key Management Service
- It creates and manages encryption keys
- We use it to encrypt all SIEM logs at rest
- Moto lets us test this without real AWS keys
"""
import unittest

try:
    import boto3
    from moto import mock_aws
    MOTO_AVAILABLE = True
except ImportError:
    MOTO_AVAILABLE = False


@unittest.skipUnless(MOTO_AVAILABLE, "moto not installed")
class TestKMSEncryption(unittest.TestCase):

    @mock_aws
    def test_create_kms_key(self):
        kms = boto3.client("kms", region_name="us-east-1")
        key = kms.create_key(Description="SIEM encryption key")
        self.assertIn("KeyMetadata", key)
        self.assertTrue(key["KeyMetadata"]["Enabled"])

    @mock_aws
    def test_encrypt_decrypt_roundtrip(self):
        kms = boto3.client("kms", region_name="us-east-1")
        key = kms.create_key(Description="SIEM test key")
        key_id = key["KeyMetadata"]["KeyId"]
        plaintext = b"secret-log-data-sample"
        encrypted = kms.encrypt(KeyId=key_id, Plaintext=plaintext)
        decrypted = kms.decrypt(
            CiphertextBlob=encrypted["CiphertextBlob"]
        )
        self.assertEqual(decrypted["Plaintext"], plaintext)


if __name__ == "__main__":
    unittest.main()
