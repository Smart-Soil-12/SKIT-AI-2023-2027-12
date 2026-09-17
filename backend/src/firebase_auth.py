from firebase_admin import auth
from src.firebase_service import db


def verify_user_token(id_token):
    return auth.verify_id_token(id_token)


def register_user(email, password):
    user = auth.create_user(
        email=email,
        password=password
    )
    return user.uid
