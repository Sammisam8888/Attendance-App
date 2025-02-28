from flask import Flask, send_file, jsonify
import qrcode
import time
import io
from flask import Blueprint, send_file, request, jsonify
import hashlib
def generate_token():
    timestamp = int(time.time() // 45)  # Change every 45 seconds
    secret_key = "secure_secret"
    unique_token = f"{secret_key}_{timestamp}"
    return hashlib.sha256(unique_token.encode()).hexdigest()

# Generate QR Code
def generate_qr():
    current_time = int(time.time())  # current timestamp in seconds
    # Create a token that contains the current timestamp
    qr_data = f"attendance_code_{current_time}"
    
    qr = pyqrcode.create(qr_data)  # Generate the QR code
    buffer = io.BytesIO()
    qr.png(buffer, scale=8)  # Write QR code to buffer as PNG
    buffer.seek(0)

    return send_file(buffer, mimetype='image/png')

@qr_generator.route('/validate_qr', methods=['POST'])
def validate_qr():

#     data = request.get_json()
#     qr_code = data.get("qr_code", "")
#     token = generate_token()
#     qr = qrcode.make(token)
#     img_io = io.BytesIO()
#     qr.save(img_io, 'PNG')
#     img_io.seek(0)
#     return img_io
  
  # Trish: Verify the scanned QR code with the generated data

    return jsonify({"message": "QR validation pending"}), 200
