import pandas as pd

df = pd.read_csv("data/Crop_recommendation.csv")

numeric_cols = [
    "N", "P", "K",
    "temperature", "humidity",
    "ph", "rainfall"
]

print("Dataset shape:", df.shape)

print("\nMissing values:")
print(df.isnull().sum())

print("\nDuplicate rows:", df.duplicated().sum())

print("\nNegative numeric values:")
print((df[numeric_cols] < 0).sum())

print("\nData types:")
print(df.dtypes)

print("\nNumber of crop classes:", df["label"].nunique())
print("Total crop labels:", df["label"].notna().sum())