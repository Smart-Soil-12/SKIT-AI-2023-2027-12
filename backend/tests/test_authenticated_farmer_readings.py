
import unittest
from unittest.mock import patch
from src.firebase_auth import get_authenticated_farmer_readings


class TestAuthenticatedFarmerReadings(unittest.TestCase):

    @patch("src.firebase_auth.verify_user_token")
    def test_retrieve_authenticated_farmer_readings(self, mock_verify):
        mock_verify.return_value = {
            "uid": "7AuaXcfcKZYDxlXMRTEayDhA5g72"
        }

        readings = get_authenticated_farmer_readings("mock-token")

        self.assertTrue(readings)
        self.assertTrue(all(r["farmer_id"] == "F001" for r in readings))


if __name__ == "__main__":
    unittest.main()