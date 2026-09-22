
from firebase_admin import auth
from src.firebase_service import db, get_farmer_soil_readings


def verify_user_token(id_token):
    return auth.verify_id_token(id_token, check_revoked=True)


def register_user(email, password):
    user = auth.create_user(email=email, password=password)
    return user.uid


def get_authenticated_farmer_readings(id_token):
    user = verify_user_token(id_token)

    farmer_doc = db.collection("farmers").document(user["uid"]).get()

    if not farmer_doc.exists:
        raise ValueError("No farmer profile found for this user")

    farmer_id = (farmer_doc.to_dict() or {}).get("farmer_id")

    if not farmer_id:
        raise ValueError("Farmer ID is missing from profile")

    return get_farmer_soil_readings(farmer_id)