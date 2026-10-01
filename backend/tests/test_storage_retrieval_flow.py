from unittest.mock import patch
from src.firebase_service import save_soil_reading
from src.firebase_auth import get_authenticated_farmer_readings


def test_storage_retrieval_flow():
    soil_data = {
        "pH": 6.5,
        "moisture": 45,
        "N": 80,
        "P": 40,
        "K": 50,
        "temperature": 28
    }

    with patch(
        "src.firebase_service.db.collection"
    ) as mock_collection:

        mock_collection.return_value.add.return_value = (
            None,
            type("DocRef", (), {"id": "R001"})()
        )

        reading_id = save_soil_reading(
            "F001",
            "ESP32-001",
            soil_data
        )

        assert reading_id == "R001"

    mock_readings = [
        {
            "id": "R001",
            "farmer_id": "F001",
            "device_id": "ESP32-001",
            **soil_data
        }
    ]

    with patch(
        "src.firebase_auth.verify_user_token",
        return_value={"uid": "test-uid"}
    ), patch(
        "src.firebase_auth.db.collection"
    ) as mock_auth_collection, patch(
        "src.firebase_auth.get_farmer_soil_readings",
        return_value=mock_readings
    ):

        farmer_doc = mock_auth_collection.return_value.document.return_value.get.return_value
        farmer_doc.exists = True
        farmer_doc.to_dict.return_value = {"farmer_id": "F001"}

        readings = get_authenticated_farmer_readings("test-token")

        assert len(readings) == 1
        assert readings[0]["farmer_id"] == "F001"
        assert readings[0]["id"] == "R001"