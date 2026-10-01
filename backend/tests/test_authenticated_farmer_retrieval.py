from unittest.mock import patch
from src.firebase_auth import get_authenticated_farmer_readings


def test_authenticated_farmer_retrieval():
    mock_user = {"uid": "test-uid"}
    mock_farmer_doc = {
        "farmer_id": "F001"
    }

    with patch(
        "src.firebase_auth.verify_user_token",
        return_value=mock_user
    ), patch(
        "src.firebase_auth.db.collection"
    ) as mock_collection, patch(
        "src.firebase_auth.get_farmer_soil_readings",
        return_value=[{"farmer_id": "F001", "id": "R001"}]
    ) as mock_readings:

        mock_document = mock_collection.return_value.document
        mock_document.return_value.get.return_value.exists = True
        mock_document.return_value.get.return_value.to_dict.return_value = mock_farmer_doc

        result = get_authenticated_farmer_readings("test-token")

        assert result == [{"farmer_id": "F001", "id": "R001"}]
        mock_readings.assert_called_once_with("F001")