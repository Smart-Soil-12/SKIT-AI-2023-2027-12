import pandas as pd

df = pd.read_csv("data/Crop_recommendation.csv")

print("Rows before cleaning:", len(df))

before = len(df)

df = df.drop_duplicates()

numeric_cols = ["N", "P", "K", "temperature", "humidity", "ph", "rainfall"]

for col in numeric_cols:
    df = df[df[col] >= 0]

print("Rows after cleaning:", len(df))
print("Duplicate rows removed:", before - len(df))
print("\nInvalid numeric values:")
print((df[numeric_cols] < 0).sum().sum())