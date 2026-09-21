import unittest
from src.firebase_service import get_farmer_soil_readings


class TestFarmerSoilReadings(unittest.TestCase):
    def test_retrieve_farmer_readings(self):
        readings = get_farmer_soil_readings("F001")

        self.assertTrue(readings)
        self.assertTrue(
            all(r["farmer_id"] == "F001" for r in readings)
        )

        timestamps = [r["timestamp"] for r in readings]
        self.assertEqual(timestamps, sorted(timestamps, reverse=True))


if __name__ == "__main__":
    unittest.main()