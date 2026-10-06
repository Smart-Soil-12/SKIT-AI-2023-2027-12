import pandas as pd

df = pd.read_csv("data/model_features.csv")

print("Feature ranges:\n")
for col in df.columns:
    print(f"{col}: min={df[col].min()}, max={df[col].max()}")

print("\nMissing values:")
print(df.isnull().sum())

print("\nData types:")
print(df.dtypes)

print("\nDataset shape:", df.shape)