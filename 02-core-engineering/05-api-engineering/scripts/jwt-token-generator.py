"""
JWT Token Generator (Dev)
Description: Generates signed JWTs for development testing.
Author: Senior DevOps Engineer
Requirement: PyJWT
"""

import jwt
import datetime
import argparse

SECRET_KEY = "super-secret-dev-key"

def generate_token(user_id, role, expiration_minutes=60):
    payload = {
        "user_id": user_id,
        "role": role,
        "exp": datetime.datetime.utcnow() + datetime.timedelta(minutes=expiration_minutes),
        "iat": datetime.datetime.utcnow()
    }
    
    token = jwt.encode(payload, SECRET_KEY, algorithm="HS256")
    return token

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--user", default="testuser")
    parser.add_argument("--role", default="admin")
    parser.add_argument("--exp", type=int, default=60)
    args = parser.parse_args()
    
    token = generate_token(args.user, args.role, args.exp)
    print("Generated JWT:")
    print(token)
    
    # decode to verify
    try:
        decoded = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        print("\nDecoded Payload:")
        print(decoded)
    except Exception as e:
        print(f"Verification Error: {e}")
