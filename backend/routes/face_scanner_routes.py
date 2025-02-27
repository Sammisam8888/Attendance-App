from flask import Blueprint, request, jsonify
from utils.face_scanner import train_user, recognize_user

face_scanner_routes = Blueprint('face_scanner_routes', __name__)

@face_scanner_routes.route('/train', methods=['POST'])
def train():
    data = request.json
    name = data.get("name")
    if not name:
        return jsonify({"message": "Name is required"}), 400
    train_user(name)
    return jsonify({"message": f"User {name} trained successfully"}), 200

@face_scanner_routes.route('/recognize', methods=['GET'])
def recognize():
    recognize_user()
    return jsonify({"message": "Recognition process completed"}), 200
