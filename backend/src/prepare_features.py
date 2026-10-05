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

print("Feature data types:")
print(X.dtypes)

print("\nFeature shape:", X.shape)

print("\nMissing values:")
print(X.isnull().sum())

print("\nFeature preview:")
print(X.head())

X.to_csv("data/model_features.csv", index=False)

print("\nModel feature dataset saved successfully.")