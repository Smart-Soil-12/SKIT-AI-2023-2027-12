from src.firebase_service import get_farmer_soil_readings


def test_farmer_specific_retrieval():
    readings = get_farmer_soil_readings("F001")

    assert isinstance(readings, list)

    for reading in readings:
        assert reading["farmer_id"] == "F001"

    print(f"Retrieved {len(readings)} readings for farmer F001")