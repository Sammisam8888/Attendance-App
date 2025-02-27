import pyqrcode
import time
import io
from flask import Blueprint, send_file, request, jsonify

qr_generator = Blueprint('qr_generator', __name__)

@qr_generator.route('/generate_qr', methods=['GET'])
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
    data = request.get_json()
    qr_code = data.get("qr_code", "")

    # Trish: Verify the scanned QR code with the generated data

    return jsonify({"message": "QR validation pending"}), 200

