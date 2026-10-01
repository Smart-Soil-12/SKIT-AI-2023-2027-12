import pandas as pd

df = pd.read_csv("data/Crop_recommendation.csv")

print("Missing values before handling:")
print(df.isnull().sum())

df = df.dropna()

print("\nMissing values after handling:")
print(df.isnull().sum())

print("\nFinal dataset shape:", df.shape)