from flask import Blueprint, request, jsonify
from utils.face_scanner import train_user, recognize_user

face_scanner_routes = Blueprint('face_scanner_routes', __name__)

# Train a student face
@face_scanner_routes.route('/student/train', methods=['POST'])
def train():
    data = request.json
    name = data.get("name")
    roll_no = data.get("roll_no")

    if not name or not roll_no:
        return jsonify({"message": "Name and Roll Number are required"}), 400

    response, status = train_user(name, roll_no)
    return jsonify(response), status

# Recognize a student face
@face_scanner_routes.route('/student/recognize', methods=['GET'])
def recognize():
    
    response, status = recognize_user()
    return jsonify(response), status

