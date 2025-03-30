from flask import Flask, send_file, jsonify
import qrcode
import time
import io
import hashlib
import jwt
import secrets
from database import db  # Import the database connection

SECRET_KEY = "your_secret_key"  # Use a secure secret key for JWT

qr_collection = db["qr_tokens"]

# Ensure the TTL index exists
qr_collection.create_index("timestamp", expireAfterSeconds=3)

def generate_token(timestamp=None):
    if timestamp is None:
        timestamp = int(time.time() // 3)  # Change every 3 seconds
    payload = {
        "timestamp": timestamp,
        "nonce": secrets.token_hex(8)
    }
    token = jwt.encode(payload, SECRET_KEY, algorithm="HS256")  # Generate JWT token
    print(f"Generated Token: {token}")  # Debugging: Print the generated token

    # Store the token in MongoDB with a timestamp
    qr_collection.insert_one({"qr_token": token, "timestamp": int(time.time())})
    return token

# Generate QR Code
def generate_qr(timestamp):
    timestamp = int(time.time() // 3)  # Match the 3-second interval
    token = generate_token(timestamp)  # Use the generated token
    qr = qrcode.make(token)  # Create a QR code with the token
    img_io = io.BytesIO()
    qr.save(img_io, 'PNG')
    img_io.seek(0)
    return img_io
