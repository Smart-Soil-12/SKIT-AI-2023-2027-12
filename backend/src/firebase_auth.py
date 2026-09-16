from firebase_admin import auth
from src.firebase_service import db


def verify_user_token(id_token):
    return auth.verify_id_token(id_token)