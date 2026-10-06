import pandas as pd

df = pd.read_csv("data/Crop_recommendation.csv")

print("Data types:")
print(df.dtypes)

numeric_cols = [
    "N", "P", "K",
    "temperature", "humidity",
    "ph", "rainfall"
]

print("\nNumeric column validation:")

for col in numeric_cols:
    converted = pd.to_numeric(df[col], errors="coerce")
    invalid = converted.isna().sum()

    print(f"{col}: invalid values = {invalid}")

print("\nLabel column type:")
print(f"label: {df['label'].dtype}")