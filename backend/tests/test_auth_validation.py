import unittest
from src.firebase_auth import verify_user_token

class TestAuthValidation(unittest.TestCase):
    def test_invalid_token_rejected(self):
        with self.assertRaises(Exception):
            verify_user_token("invalid-token")

if __name__ == "__main__":
    unittest.main()