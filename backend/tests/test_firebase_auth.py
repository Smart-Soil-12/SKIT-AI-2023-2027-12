from src.firebase_auth import register_user
import uuid


def test_register_user():
    email = f"smartsoil.test.{uuid.uuid4().hex[:8]}@example.com"
    password = "Test@12345"

    user_id = register_user(email, password)

    assert user_id
    print("Registration test passed:", user_id)