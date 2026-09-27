from src.firebase_service import get_farmer_soil_readings


def test_retrieval_final():
    readings = get_farmer_soil_readings("F001")

    assert isinstance(readings, list)

    for reading in readings:
        assert reading["farmer_id"] == "F001"
        assert "id" in reading
        assert "timestamp" in reading
        assert "pH" in reading
        assert "moisture" in reading
        assert "N" in reading
        assert "P" in reading
        assert "K" in reading
        assert "temperature" in reading

    # Verify newest-to-oldest ordering
    timestamps = [reading["timestamp"] for reading in readings]

    assert timestamps == sorted(timestamps, reverse=True)

    print(f"Final retrieval verified: {len(readings)} readings")