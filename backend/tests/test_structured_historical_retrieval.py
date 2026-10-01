from src.firebase_service import get_farmer_soil_readings


def test_structured_historical_retrieval():
    readings = get_farmer_soil_readings("F001")

    assert isinstance(readings, list)

    required_fields = [
        "id",
        "farmer_id",
        "device_id",
        "timestamp",
        "pH",
        "moisture",
        "N",
        "P",
        "K",
        "temperature"
    ]

    for reading in readings:
        for field in required_fields:
            assert field in reading

    print(f"Verified {len(readings)} structured historical readings")