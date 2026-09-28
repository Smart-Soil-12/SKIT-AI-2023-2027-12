import pandas as pd

df = pd.read_csv("data/Crop_recommendation.csv")

label_counts = df["label"].value_counts()

print("Number of crop classes:", df["label"].nunique())
print("\nCrop class distribution:")
print(label_counts)

print("\nMinimum records in a class:", label_counts.min())
print("Maximum records in a class:", label_counts.max())