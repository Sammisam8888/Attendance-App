from flask import Flask, send_file, jsonify
import qrcode
import time
import io
from flask import Blueprint, send_file, request, jsonify
import hashlib

def generate_token(timestamp=None):
    if timestamp is None:
        timestamp = int(time.time() // 3)  # Change every 3 seconds
    secret_key = "secure_secret"
    unique_token = f"{secret_key}_{timestamp}"
    token = hashlib.sha256(unique_token.encode()).hexdigest()
    print(f"Generated Token: {token}")  # Debugging: Print the generated token
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
