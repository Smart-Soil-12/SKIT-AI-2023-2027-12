
"""Train and evaluate a baseline crop classifier for SmartSoil AI.

Run from the backend directory:
    python -m src.ml.train_model
"""

from pathlib import Path
import json

import joblib
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report
from sklearn.model_selection import train_test_split

ROOT = Path(__file__).resolve().parents[2]
DATA_PATH = ROOT / "data" / "Crop_recommendation_encoded.csv"
MODEL_DIR = ROOT / "models"
MODEL_PATH = MODEL_DIR / "crop_recommendation_model.joblib"
METRICS_PATH = MODEL_DIR / "evaluation_metrics.json"

FEATURES = [
    "N", "P", "K", "temperature",
    "humidity", "ph", "rainfall"
]
TARGET = "label_encoded"


def train_and_evaluate():
    if not DATA_PATH.exists():
        raise FileNotFoundError(f"Dataset not found: {DATA_PATH}")

    df = pd.read_csv(DATA_PATH)

    missing = [
        col for col in FEATURES + [TARGET]
        if col not in df.columns
    ]
    if missing:
        raise ValueError(f"Missing columns: {missing}")

    if df[FEATURES + [TARGET]].isnull().any().any():
        raise ValueError("Dataset contains missing values.")

    X = df[FEATURES]
    y = df[TARGET].astype(int)

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.2,
        random_state=42,
        stratify=y
    )

    model = RandomForestClassifier(
        n_estimators=200,
        random_state=42,
        n_jobs=-1
    )
    model.fit(X_train, y_train)

    predictions = model.predict(X_test)
    accuracy = accuracy_score(y_test, predictions)

    MODEL_DIR.mkdir(parents=True, exist_ok=True)

    joblib.dump(
        {
            "model": model,
            "feature_names": FEATURES,
            "target_name": TARGET,
            "model_type": "RandomForestClassifier"
        },
        MODEL_PATH
    )

    metrics = {
        "model_type": "RandomForestClassifier",
        "rows": int(len(df)),
        "features": FEATURES,
        "target": TARGET,
        "train_rows": int(len(X_train)),
        "test_rows": int(len(X_test)),
        "accuracy": float(accuracy),
        "classification_report": classification_report(
            y_test,
            predictions,
            output_dict=True,
            zero_division=0
        )
    }

    METRICS_PATH.write_text(
        json.dumps(metrics, indent=2),
        encoding="utf-8"
    )

    print(f"Dataset rows: {len(df)}")
    print(f"Training features: {X_train.shape}")
    print(f"Testing features: {X_test.shape}")
    print("Model: RandomForestClassifier (200 trees)")
    print(f"Test accuracy: {accuracy:.4f} ({accuracy * 100:.2f}%)")
    print(f"Saved model: {MODEL_PATH}")
    print(f"Saved metrics: {METRICS_PATH}")
    print("\nClassification report:")
    print(classification_report(
        y_test, predictions, zero_division=0
    ))

    return model, metrics


if __name__ == "__main__":
    train_and_evaluate()
