import csv

FIELDS = ["pH", "moisture", "N", "P", "K", "temperature"]

RANGES = {
    "pH": (0, 14),
    "moisture": (0, 100),
    "N": (0, 1000),
    "P": (0, 1000),
    "K": (0, 1000),
    "temperature": (-40, 80)
}


def read_soil_data(file_path):
    with open(file_path, newline="") as file:
        return list(csv.DictReader(file))


def convert_values(rows):
    valid_rows = []

    for row_number, row in enumerate(rows, start=2):
        valid = True

        for field in FIELDS:
            try:
                if row[field].strip() == "":
                    raise ValueError("missing value")

                row[field] = float(row[field])

            except (ValueError, TypeError):
                print(f"Row {row_number}: invalid {field} value '{row[field]}'")
                valid = False

        if valid:
            valid_rows.append(row)

    return valid_rows


def validate_soil_data(rows):
    valid_rows = []

    for row_number, row in enumerate(rows, start=2):
        valid = True

        for field in FIELDS:
            value = row[field]
            minimum, maximum = RANGES[field]

            if not minimum <= value <= maximum:
                print(
                    f"Row {row_number}: {field} value {value} "
                    f"is outside range {minimum}-{maximum}"
                )
                valid = False

        if valid:
            valid_rows.append(row)

    return valid_rows


def structure_soil_data(rows):
    return [
        {
            "pH": row["pH"],
            "moisture": row["moisture"],
            "N": row["N"],
            "P": row["P"],
            "K": row["K"],
            "temperature": row["temperature"]
        }
        for row in rows
    ]


def calculate_averages(rows):
    averages = {}

    for field in FIELDS:
        total = sum(row[field] for row in rows)
        averages[field] = round(total / len(rows), 2)

    return averages

def process_soil_data(file_path):
    data = read_soil_data(file_path)
    data = convert_values(data)
    data = validate_soil_data(data)
    data = structure_soil_data(data)
    return data


def main():
    data = process_soil_data("data/soil_data.csv")

    print("\nStructured Soil Data:")
    for row in data:
        print(row)

    averages = calculate_averages(data)

    print("\nAverage Soil Values:")
    for field, value in averages.items():
        print(f"{field}: {value}")


if __name__ == "__main__":
    main()