import pandas as pd

df = pd.read_csv("data/Crop_recommendation.csv")

features = ["N", "P", "K", "temperature", "humidity", "ph", "rainfall"]

print("Duplicate rows:", df.duplicated().sum())
print("\nNegative values:\n", (df[features] < 0).sum())
print("\nFeature ranges:\n", df[features].describe())