import pandas as pd

df = pd.read_csv("data/Crop_recommendation.csv")

columns = ["N", "P", "K", "temperature", "humidity", "ph", "rainfall"]

print("Column validation:")

for col in columns:
    print(
        f"{col}: "
        f"min={df[col].min()}, "
        f"max={df[col].max()}, "
        f"missing={df[col].isnull().sum()}"
    )

print("\nInvalid negative values:")

for col in columns:
    print(f"{col}: {(df[col] < 0).sum()}")