from soil_processor import process_soil_data


data = process_soil_data("data/soil_data.csv")

print("Data received by another module:")

for reading in data:
    print(reading)