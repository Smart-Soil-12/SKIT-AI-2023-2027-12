import unittest

from src.soil_processor import (
    convert_values,
    validate_soil_data,
    structure_soil_data,
    calculate_averages,
    process_soil_data
)


class TestSoilProcessor(unittest.TestCase):

    def setUp(self):
        self.valid_data = [
            {
                "pH": "6.8",
                "moisture": "42",
                "N": "40",
                "P": "20",
                "K": "30",
                "temperature": "27"
            }
        ]

    def test_convert_values(self):
        result = convert_values(self.valid_data)

        self.assertEqual(result[0]["pH"], 6.8)
        self.assertEqual(result[0]["N"], 40.0)

    def test_valid_soil_data(self):
        data = convert_values(self.valid_data)
        result = validate_soil_data(data)

        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]["pH"], 6.8)

    def test_invalid_pH(self):
        data = self.valid_data.copy()
        data[0] = data[0].copy()
        data[0]["pH"] = "20"

        converted = convert_values(data)
        result = validate_soil_data(converted)

        self.assertEqual(result, [])

    def test_invalid_moisture(self):
        data = self.valid_data.copy()
        data[0] = data[0].copy()
        data[0]["moisture"] = "120"

        converted = convert_values(data)
        result = validate_soil_data(converted)

        self.assertEqual(result, [])

    def test_invalid_nitrogen(self):
        data = self.valid_data.copy()
        data[0] = data[0].copy()
        data[0]["N"] = "-10"

        converted = convert_values(data)
        result = validate_soil_data(converted)

        self.assertEqual(result, [])

    def test_invalid_temperature(self):
        data = self.valid_data.copy()
        data[0] = data[0].copy()
        data[0]["temperature"] = "100"

        converted = convert_values(data)
        result = validate_soil_data(converted)

        self.assertEqual(result, [])

    def test_missing_value(self):
        data = self.valid_data.copy()
        data[0] = data[0].copy()
        data[0]["N"] = ""

        result = convert_values(data)

        self.assertEqual(result, [])

    def test_non_numeric_value(self):
        data = self.valid_data.copy()
        data[0] = data[0].copy()
        data[0]["N"] = "abc"

        result = convert_values(data)

        self.assertEqual(result, [])

    def test_multiple_invalid_fields(self):
        data = self.valid_data.copy()
        data[0] = data[0].copy()
        data[0]["pH"] = "20"
        data[0]["moisture"] = "120"

        converted = convert_values(data)
        result = validate_soil_data(converted)

        self.assertEqual(result, [])

    def test_structure_data(self):
        data = convert_values(self.valid_data)
        result = structure_soil_data(data)

        self.assertEqual(result[0]["pH"], 6.8)
        self.assertEqual(result[0]["moisture"], 42.0)

    def test_average(self):
        data = convert_values(self.valid_data)
        result = calculate_averages(data)

        self.assertEqual(result["pH"], 6.8)
        self.assertEqual(result["N"], 40.0)

    def test_multiple_valid_readings(self):
        data = [
            {
                "pH": "6.8",
                "moisture": "42",
                "N": "40",
                "P": "20",
                "K": "30",
                "temperature": "27"
            },
            {
                "pH": "6.5",
                "moisture": "55",
                "N": "45",
                "P": "25",
                "K": "35",
                "temperature": "26"
            }
        ]

        converted = convert_values(data)
        validated = validate_soil_data(converted)
        structured = structure_soil_data(validated)

        self.assertEqual(len(structured), 2)
        self.assertEqual(structured[1]["pH"], 6.5)

    def test_process_soil_data(self):
        result = process_soil_data("data/soil_data.csv")

        self.assertEqual(len(result), 5)
        self.assertEqual(result[0]["pH"], 6.8)
        self.assertEqual(result[0]["moisture"], 42.0)
        self.assertEqual(result[0]["N"], 40.0)


if __name__ == "__main__":
    unittest.main()