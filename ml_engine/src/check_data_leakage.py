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

print("Training rows:", len(X_train))
print("Testing rows:", len(X_test))

print("\nTraining and testing indices overlap:",
      bool(set(X_train.index) & set(X_test.index)))

print("\nTraining target size:", len(y_train))
print("Testing target size:", len(y_test))

if not (set(X_train.index) & set(X_test.index)):
    print("\nNo data leakage detected.")