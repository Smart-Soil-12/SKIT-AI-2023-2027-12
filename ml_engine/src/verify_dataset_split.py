import pandas as pd
from sklearn.model_selection import train_test_split

df = pd.read_csv("data/Crop_recommendation_encoded.csv")

features = [
    "N", "P", "K",
    "temperature", "humidity", "ph", "rainfall"
]

X = df[features]
y = df["label_encoded"]

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42,
    stratify=y
)

print("Training features:", X_train.shape)
print("Testing features:", X_test.shape)

print("\nTraining class distribution:")
print(y_train.value_counts().sort_index())

print("\nTesting class distribution:")
print(y_test.value_counts().sort_index())