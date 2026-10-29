
from src.firebase_service import get_soil_readings

readings = get_soil_readings()

print("Total readings:", len(readings))

for reading in readings[:5]:
    print({
        key: value
        for key, value in reading.items()
        if key not in ("id", "farmer_id")
    })
