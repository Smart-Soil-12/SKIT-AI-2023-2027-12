import pandas as pd

df = pd.read_csv("data/Crop_recommendation.csv")

numeric_cols = [
    "N", "P", "K",
    "temperature", "humidity",
    "ph", "rainfall"
]

print("Outlier analysis using IQR:\n")

for col in numeric_cols:
    q1 = df[col].quantile(0.25)
    q3 = df[col].quantile(0.75)
    iqr = q3 - q1

    lower = q1 - 1.5 * iqr
    upper = q3 + 1.5 * iqr

    outliers = ((df[col] < lower) | (df[col] > upper)).sum()

    print(f"{col}: {outliers} outliers")

print("\nNo values will be removed during this analysis.")