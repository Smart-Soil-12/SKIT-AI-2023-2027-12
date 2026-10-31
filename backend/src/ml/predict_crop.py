
"""Crop prediction utilities for SmartSoil AI."""

from pathlib import Path

import joblib
import pandas as pd

from src.ml.label_mapping import get_crop_mapping

ROOT = Path(__file__).resolve().parents[2]
MODEL_PATH = ROOT / "models" / "crop_recommendation_model.joblib"

FEATURES = [
    "N", "P", "K", "temperature", "humidity", "ph"
]

FEATURE_RANGES = {
    "N": (0, 140),
    "P": (5, 145),
    "K": (5, 205),
    "temperature": (8.825675, 43.675493),
    "humidity": (14.258040, 99.981876),
    "ph": (3.504752, 9.935091),
}


def predict_crop(soil_data):
    if not MODEL_PATH.exists():
        raise FileNotFoundError(f"Model not found: {MODEL_PATH}")

    if not isinstance(soil_data, dict) or set(soil_data) != set(FEATURES):
        raise ValueError(f"Required inputs: {FEATURES}")

    values = pd.DataFrame([soil_data], columns=FEATURES)

    for feature in FEATURES:
        try:
            values[feature] = pd.to_numeric(
                values[feature], errors="raise"
            )
        except (ValueError, TypeError):
            raise ValueError(
                f"{feature} must be a valid number."
            ) from None

    if values.isnull().any().any():
        raise ValueError("Input values cannot be missing.")

    for feature in FEATURES:
        value = values.at[0, feature]
        if not float("-inf") < value < float("inf"):
            raise ValueError("Input values must be finite numbers.")

    for feature, (minimum, maximum) in FEATURE_RANGES.items():
        value = values.at[0, feature]
        if not minimum <= value <= maximum:
            raise ValueError(
                f"{feature} must be between {minimum} and {maximum}."
            )

    model_data = joblib.load(MODEL_PATH)
    model = model_data["model"]

    if list(model_data["feature_names"]) != FEATURES:
        raise ValueError(
            "Model feature configuration does not match prediction inputs."
        )

    mapping = get_crop_mapping()
    probabilities = model.predict_proba(values)[0]

    ranked = sorted(
        zip(model.classes_, probabilities),
        key=lambda item: item[1],
        reverse=True
    )

    results = []

    for crop_id, score in ranked:
        crop_id = int(crop_id)

        if crop_id not in mapping:
            raise ValueError(f"Unknown crop class ID: {crop_id}")

        results.append({
            "crop": mapping[crop_id],
            "confidence": round(float(score) * 100, 2)
        })

        if len(results) == 3:
            break

    return results


if __name__ == "__main__":
    sample = {
        "N": 90,
        "P": 42,
        "K": 43,
        "temperature": 20.9,
        "humidity": 82.0,
        "ph": 6.5
    }

    for result in predict_crop(sample):
        print(result)
