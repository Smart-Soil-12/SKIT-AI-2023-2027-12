import pytest
from pydantic import ValidationError
from src.api import CropPredictionRequest
from fastapi.testclient import TestClient

from src.api import app

client = TestClient(app)

VALID_INPUT = {
    "N": 90,
    "P": 42,
    "K": 43,
    "temperature": 20.9,
    "humidity": 82.0,
    "ph": 6.5
}


def test_health_endpoint():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_crop_prediction_returns_top_three():
    response = client.post("/api/crops/predict", json=VALID_INPUT)

    assert response.status_code == 200

    data = response.json()
    assert len(data["recommendations"]) == 3


def test_missing_feature_returns_422():
    payload = VALID_INPUT.copy()
    payload.pop("ph")

    response = client.post("/api/crops/predict", json=payload)

    assert response.status_code == 422


def test_extra_feature_returns_422():
    payload = VALID_INPUT.copy()
    payload["rainfall"] = 200

    response = client.post("/api/crops/predict", json=payload)

    assert response.status_code == 422


def test_non_numeric_feature_returns_422():
    payload = VALID_INPUT.copy()
    payload["N"] = "abc"

    response = client.post("/api/crops/predict", json=payload)

    assert response.status_code == 422


def test_out_of_range_feature_returns_422():
    payload = VALID_INPUT.copy()
    payload["N"] = 999

    response = client.post("/api/crops/predict", json=payload)

    assert response.status_code == 422



def test_infinite_feature_returns_422():
    payload = VALID_INPUT.copy()
    payload["N"] = float("inf")

    with pytest.raises(ValidationError):
        CropPredictionRequest(**payload)

