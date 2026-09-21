import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timezone

cred = credentials.Certificate("firebase-service-account.json")
firebase_admin.initialize_app(cred)

db = firestore.client()


def save_soil_reading(farmer_id, device_id, soil_data):
    reading = {
        "farmer_id": farmer_id,
        "device_id": device_id,
        "timestamp": datetime.now(timezone.utc),
        "pH": soil_data["pH"],
        "moisture": soil_data["moisture"],
        "N": soil_data["N"],
        "P": soil_data["P"],
        "K": soil_data["K"],
        "temperature": soil_data["temperature"]
    }

    doc_ref = db.collection("soil_readings").add(reading)
    return doc_ref[1].id

def get_soil_readings():
    docs = db.collection("soil_readings").stream()

    readings = []

    for doc in docs:
        reading = doc.to_dict()
        reading["id"] = doc.id
        readings.append(reading)

    return readings

def get_latest_soil_reading():
    docs = (
        db.collection("soil_readings")
        .order_by("timestamp", direction=firestore.Query.DESCENDING)
        .limit(1)
        .stream()
    )

    for doc in docs:
        reading = doc.to_dict()
        reading["id"] = doc.id
        return reading

    return None

def get_farmer_soil_readings(farmer_id):
    docs = (
        db.collection("soil_readings")
        .where("farmer_id", "==", farmer_id)
        .order_by("timestamp", direction=firestore.Query.DESCENDING)
        .stream()
    )

    readings = []

    for doc in docs:
        reading = doc.to_dict()
        reading["id"] = doc.id
        readings.append(reading)

    return readings