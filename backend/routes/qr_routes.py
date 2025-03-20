from flask import Flask, send_file, jsonify, Blueprint, request
from utils.qr_generator import generate_qr
from models.user_model import Student
import time
from utils.token_validator import validate_token, token_required

qr_routes = Blueprint('qr_routes', __name__)

# Generate QR Code in teacher interface
@qr_routes.route('/teacher/get_qr', methods=['GET'])
@token_required
def get_qr():
    token = request.headers.get('Authorization')
    if not token:
        return jsonify({"message": "Token is missing!", "status": "failed"}), 401
    timestamp = request.args.get('timestamp', default=int(time.time() // 10), type=int)
    return send_file(generate_qr(timestamp), mimetype='image/png')

@qr_routes.route('/student/verify_qr', methods=['POST'])
@token_required
def verify_qr():
    data = request.json
    scanned_token = data.get('token')
    email = data.get('email')
    
    timestamp = int(time.time() // 3)  # Match the same interval as token generation
    if validate_token(scanned_token, timestamp):
        student = Student.find_by_email(email)
        if student:
            current_timestamp = int(time.time())
            return jsonify({
                "message": "Valid QR Code",
                "status": "success",
                "name": student["name"],
                "roll_no": student["roll_no"],
                "timestamp": current_timestamp
            }), 200
    return jsonify({"message": "Invalid or Expired QR Code", "status": "failed"}), 400

