import time
from database import db  # Import the database connection

qr_collection = db["qr_tokens"]

def validate_token(scanned_token, tolerance=1):
    """
    Validate the scanned token by checking its existence in MongoDB.
    """
    # Check if the token exists in the MongoDB collection
    token_entry = qr_collection.find_one({"qr_token": scanned_token})
    if token_entry:
        return True
    return False
