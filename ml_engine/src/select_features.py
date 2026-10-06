import pandas as pd

df = pd.read_csv("data/Crop_recommendation_encoded.csv")

features = [
    "N",
    "P",
    "K",
    "temperature",
    "humidity",
    "ph",
    "rainfall"
]

X = df[features]
y = df["label_encoded"]

print("Input features:")
print(X.columns.tolist())

print("\nTarget:")
print(y.name)

print("\nInput shape:", X.shape)
print("Target shape:", y.shape)