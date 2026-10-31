
"""Train and evaluate the six-feature crop classifier for SmartSoil AI."""

from pathlib import Path
import json
import shutil

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

BACKUP_PATH = MODEL_DIR / "crop_recommendation_model_7_features_backup.joblib"
METRICS_BACKUP = MODEL_DIR / "evaluation_metrics_7_features_backup.json"

# Rainfall completely excluded
FEATURES = [
    "N", "P", "K", "temperature", "humidity", "ph"
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

    # Preserve the original seven-feature model and metrics
    if MODEL_PATH.exists() and not BACKUP_PATH.exists():
        shutil.copy2(MODEL_PATH, BACKUP_PATH)
        print(f"Original model backed up: {BACKUP_PATH}")

    if METRICS_PATH.exists() and not METRICS_BACKUP.exists():
        shutil.copy2(METRICS_PATH, METRICS_BACKUP)
        print(f"Original metrics backed up: {METRICS_BACKUP}")

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
        n_jobs=-1,
        class_weight="balanced"
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
            "model_type": "RandomForestClassifier",
            "rainfall_excluded": True
        },
        MODEL_PATH
    )

    metrics = {
        "model_type": "RandomForestClassifier",
        "rows": int(len(df)),
        "features": FEATURES,
        "rainfall_excluded": True,
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

    print("\nSIX-FEATURE MODEL TRAINED SUCCESSFULLY")
    print(f"Dataset rows: {len(df)}")
    print(f"Training shape: {X_train.shape}")
    print(f"Testing shape: {X_test.shape}")
    print(f"Features: {FEATURES}")
    print(f"Crop classes: {len(model.classes_)}")
    print(f"Test accuracy: {accuracy:.4f} ({accuracy * 100:.2f}%)")
    print(f"Saved model: {MODEL_PATH}")
    print(f"Saved metrics: {METRICS_PATH}")

    print("\nClassification report:")
    print(classification_report(
        y_test,
        predictions,
        zero_division=0
    ))

    return model, metrics


if __name__ == "__main__":
    train_and_evaluate()
