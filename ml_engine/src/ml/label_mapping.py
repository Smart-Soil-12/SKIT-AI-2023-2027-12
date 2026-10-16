"""Crop label mapping for SmartSoil AI."""

from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
DATA_PATH = ROOT / "data" / "Crop_recommendation.csv"
ENCODED_PATH = ROOT / "data" / "Crop_recommendation_encoded.csv"


def get_crop_mapping():
    original = pd.read_csv(DATA_PATH)
    encoded = pd.read_csv(ENCODED_PATH)

    if len(original) != len(encoded):
        raise ValueError("Original and encoded datasets differ in size.")

    if "label" not in original or "label_encoded" not in encoded:
        raise ValueError("Required crop label columns are missing.")

    pairs = pd.DataFrame({
        "crop": original["label"],
        "id": encoded["label_encoded"]
    }).drop_duplicates()

    if pairs["id"].duplicated().any() or pairs["crop"].duplicated().any():
        raise ValueError("Crop label mapping is inconsistent.")

    return dict(zip(pairs["id"].astype(int), pairs["crop"]))


if __name__ == "__main__":
    mapping = get_crop_mapping()
    print(f"Total crops: {len(mapping)}")
    for crop_id, crop_name in sorted(mapping.items()):
        print(f"{crop_id}: {crop_name}")
