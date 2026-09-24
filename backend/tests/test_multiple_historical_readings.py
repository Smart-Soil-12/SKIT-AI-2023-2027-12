import unittest
from src.firebase_service import (
    save_soil_reading,
    get_farmer_soil_readings
)


class TestMultipleReadings(unittest.TestCase):

    def test_store_multiple_readings(self):
        data = {
            "pH": 6.5, "moisture": 45,
            "N": 80, "P": 40, "K": 60,
            "temperature": 28
        }

        id1 = save_soil_reading("F001", "TEST_DEVICE", data)
        id2 = save_soil_reading("F001", "TEST_DEVICE", data)

        self.assertNotEqual(id1, id2)

        readings = get_farmer_soil_readings("F001")
        ids = [r["id"] for r in readings]

        self.assertIn(id1, ids)
        self.assertIn(id2, ids)


if __name__ == "__main__":
    unittest.main()