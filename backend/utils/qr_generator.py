from flask import Flask, send_file, jsonify
import qrcode
import time
import io
import hashlib
def generate_token():
    timestamp = int(time.time() // 45)  # Change every 45 seconds
    secret_key = "secure_secret"
    unique_token = f"{secret_key}_{timestamp}"
    return hashlib.sha256(unique_token.encode()).hexdigest()

# Generate QR Code
def generate_qr():
    token = generate_token()
    qr = qrcode.make(token)
    img_io = io.BytesIO()
    qr.save(img_io, 'PNG')
    img_io.seek(0)
    return img_io
