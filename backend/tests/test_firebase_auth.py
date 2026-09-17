from src.firebase_auth import register_user


def test_register_user():
    email = "smartsoil.test2@example.com"
    password = "Test@12345"

    user_id = register_user(email, password)

    assert user_id
    print("Registration test passed:", user_id)


if __name__ == "__main__":
    test_register_user()