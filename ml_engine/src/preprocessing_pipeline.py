import pandas as pd
from sklearn.model_selection import train_test_split

FEATURES = [
    "N", "P", "K",
    "temperature", "humidity", "ph", "rainfall"
]


def prepare_data():
    df = pd.read_csv("data/Crop_recommendation_encoded.csv")

    X = df[FEATURES]
    y = df["label_encoded"]

    if X.isnull().sum().sum() > 0:
        raise ValueError("Missing values found in features")

    if len(X) != len(y):
        raise ValueError("Feature and target sizes do not match")

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.2,
        random_state=42,
        stratify=y
    )

    return X_train, X_test, y_train, y_test


if __name__ == "__main__":
    X_train, X_test, y_train, y_test = prepare_data()

    print("Training features:", X_train.shape)
    print("Testing features:", X_test.shape)
    print("Training target:", y_train.shape)
    print("Testing target:", y_test.shape)
    print("\nPreprocessing pipeline retest successful.")