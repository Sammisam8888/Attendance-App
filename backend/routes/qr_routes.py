from flask import Flask, send_file, jsonify, Blueprint, request
from backend.utils.qr_codes import generate_qr, validate_token
from models.user_model import Student
import time

qr_routes = Blueprint('qr_routes', __name__)

# Generate QR Code in teacher interface
@qr_routes.route('/teacher/get_qr', methods=['GET'])
def get_qr():
    timestamp = int((time.time() // 10)*10)
    return send_file(generate_qr(timestamp), mimetype='image/png')

@qr_routes.route('/student/verify_qr', methods=['POST'])
def verify_qr():
    data = request.get_json()
    print("Data received:", data)
    return jsonify(validate_token(data))
    

