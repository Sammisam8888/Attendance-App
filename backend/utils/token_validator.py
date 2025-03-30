import time
import jwt
from database import db  # Import the database connection

qr_collection = db["qr_tokens"]

SECRET_KEY = "your_secret_key"  # Use the same secret key as in qr_generator

def validate_token(scanned_token, tolerance=1):
    """
    Validate the scanned token by decoding it and checking its existence in MongoDB.
    """
    try:
        # Decode the JWT token
        decoded_token = jwt.decode(scanned_token, SECRET_KEY, algorithms=["HS256"])
        token_entry = qr_collection.find_one({"qr_token": scanned_token})
        if token_entry:
            return True
    except jwt.ExpiredSignatureError:
        print("Token has expired.")
    except jwt.InvalidTokenError:
        print("Invalid token.")
    return False
