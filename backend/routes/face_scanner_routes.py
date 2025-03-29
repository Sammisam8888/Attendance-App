from flask import Blueprint, request, jsonify
from utils.face_scanner import train_user, recognize_user
face_scanner_routes = Blueprint('face_scanner_routes', __name__)

# Train a student face
@face_scanner_routes.route('/student/train', methods=['POST'])
def train():
    data = request.json
    name = data.get("name")
    roll_no = data.get("roll_no")
    subject_code = data.get("subject_code")

    if not name or not roll_no or not subject_code:
        return jsonify({"message": "Name, Roll Number, and Subject Code are required"}), 400

    response, status = train_user(name, roll_no, subject_code)
    return jsonify(response), status

# Recognize a student face
@face_scanner_routes.route('/student/recognize', methods=['GET'])
def recognize():
    subject_code = request.args.get("subject_code")
    if not subject_code:
        return jsonify({"message": "Subject Code is required"}), 400

    response, status = recognize_user(subject_code)
    return jsonify(response), status

