import pandas as pd
from sklearn.preprocessing import LabelEncoder

df = pd.read_csv("data/Crop_recommendation.csv")

encoder = LabelEncoder()
df["label_encoded"] = encoder.fit_transform(df["label"])

print("Number of crop classes:", len(encoder.classes_))

print("\nCrop label mapping:")
for crop, code in zip(encoder.classes_, encoder.transform(encoder.classes_)):
    print(f"{crop}: {code}")

print("\nEncoded dataset preview:")
print(df[["label", "label_encoded"]].head())