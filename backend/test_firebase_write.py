
from datetime import datetime, timezone
from src.firebase_service import db

data = {
    "N": 80,
    "P": 40,
    "K": 60,
    "pH": 6.5,
    "moisture": 45,
    "temperature": 28,
    "device_id": "TEST_DEVICE",
    "timestamp": datetime.now(timezone.utc),
}

doc = db.collection("soil_readings").add(data)
print("Saved document ID:", doc[1].id)

saved = db.collection("soil_readings").document(doc[1].id).get()
print("Retrieved data:", saved.to_dict())
