from src.firebase_service import db

docs = db.collection("soil_readings").stream()

for doc in docs:
    print(doc.id, doc.to_dict())