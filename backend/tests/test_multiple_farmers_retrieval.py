from src.firebase_service import get_farmer_soil_readings


def test_multiple_farmers_retrieval():
    farmer_1 = get_farmer_soil_readings("F001")
    farmer_2 = get_farmer_soil_readings("F002")

    assert isinstance(farmer_1, list)
    assert isinstance(farmer_2, list)

    for reading in farmer_1:
        assert reading["farmer_id"] == "F001"

    for reading in farmer_2:
        assert reading["farmer_id"] == "F002"

    print(f"F001 readings: {len(farmer_1)}")
    print(f"F002 readings: {len(farmer_2)}")