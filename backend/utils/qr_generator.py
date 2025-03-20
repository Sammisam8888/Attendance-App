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
    return hashlib.sha256(unique_token.encode()).hexdigest()

# Generate QR Code
def generate_qr(timestamp=None):
    token = generate_token(timestamp)
    qr = qrcode.make(token)
    img_io = io.BytesIO()
    qr.save(img_io, 'PNG')
    img_io.seek(0)
    return img_io
