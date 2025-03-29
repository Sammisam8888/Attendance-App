from flask import Flask, send_file, jsonify, Blueprint, request
from utils.qr_generator import generate_qr
from models.user_model import Student
import time
from utils.token_validator import validate_token

qr_routes = Blueprint('qr_routes', __name__)

# Generate QR Code in teacher interface
@qr_routes.route('/teacher/get_qr', methods=['GET'])
def get_qr():
    timestamp = request.args.get('timestamp', default=int(time.time() // 3), type=int)  # Match 3-second interval
    return send_file(generate_qr(timestamp), mimetype='image/png')

@qr_routes.route('/student/verify_qr', methods=['POST'])
def verify_qr():
    data = request.json
    scanned_token = data.get('token')
    email = data.get('email')

    if validate_token(scanned_token):  # Use MongoDB-backed token validation
        student = Student.find_by_email(email)
        if student:
            return jsonify({
                "message": "Valid QR Code",
                "status": "success",
                "name": student["name"],
                "roll_no": student["roll_no"],
                "timestamp": int(time.time())
            }), 200
    return jsonify({"message": "Invalid or Expired QR Code", "status": "failed"}), 400

