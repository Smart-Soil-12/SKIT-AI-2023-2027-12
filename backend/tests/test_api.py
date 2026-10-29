
"""API contract and validation tests for crop recommendations."""

from fastapi.testclient import TestClient
from src.api import app

client = TestClient(app)

VALID_INPUT = {
    "N": 90,
    "P": 42,
    "K": 43,
    "temperature": 20.9,
    "humidity": 82.0,
    "ph": 6.5,
    "rainfall": 202.9,
}


def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_crop_prediction_returns_top_three():
    response = client.post("/api/crops/predict", json=VALID_INPUT)
    assert response.status_code == 200
    results = response.json()["recommendations"]
    assert len(results) == 3
    assert all(set(item) == {"crop", "confidence"} for item in results)
    assert all(isinstance(item["crop"], str) for item in results)
    scores = [item["confidence"] for item in results]
    assert all(0 <= score <= 100 for score in scores)
    assert scores == sorted(scores, reverse=True)


def test_missing_feature_returns_422():
    payload = VALID_INPUT.copy()
    payload.pop("rainfall")
    assert client.post("/api/crops/predict", json=payload).status_code == 422


def test_extra_feature_returns_422():
    payload = {**VALID_INPUT, "moisture": 50}
    assert client.post("/api/crops/predict", json=payload).status_code == 422


def test_non_numeric_feature_returns_422():
    payload = {**VALID_INPUT, "N": "not-a-number"}
    assert client.post("/api/crops/predict", json=payload).status_code == 422


def test_out_of_range_feature_returns_422():
    payload = {**VALID_INPUT, "ph": 99}
    assert client.post("/api/crops/predict", json=payload).status_code == 422


def test_infinite_feature_returns_422():
    payload = {**VALID_INPUT, "N": "Infinity"}
    assert client.post("/api/crops/predict", json=payload).status_code == 422
