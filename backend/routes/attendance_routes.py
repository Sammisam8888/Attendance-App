from flask import Blueprint, request, jsonify
from pymongo import MongoClient
import time
import os

# Create Blueprint
attendance_routes = Blueprint("attendance_routes", __name__)

# Connect to MongoDB
mongo_uri = os.getenv("MONGO_URI", "mongodb://localhost:27017/")
client = MongoClient(mongo_uri)
db = client["attendance_db"]  # Database name
attendance_collection = db["attendance"]  # Collection to store attendance records

# Allowed delay for valid QR codes (in seconds)
QR_CODE_EXPIRY = 10  

# Store last scanned QR codes to prevent duplicates
recent_qr_scans = set()

@attendance_routes.route("/mark_attendance", methods=["POST"])
def mark_attendance():
    """
    Student scans the QR code and sends:
    {
        "qr_data": "attendance_code_1684367890",
        "student_id": "student123"
    }
    """
    data = request.get_json()
    qr_data = data.get("qr_data")
    student_id = data.get("student_id")

    if not qr_data or not student_id:
        return jsonify({"msg": "Missing required data"}), 400

    try:
        prefix, qr_timestamp = qr_data.split("_code_")
        qr_timestamp = int(qr_timestamp)
    except Exception as e:
        return jsonify({"msg": "Invalid QR data", "error": str(e)}), 400

    current_timestamp = int(time.time())

    # Validate QR Code Expiry
    if abs(current_timestamp - qr_timestamp) > QR_CODE_EXPIRY:
        return jsonify({"msg": "QR code expired"}), 400

    # Prevent Duplicate Scans
    if qr_data in recent_qr_scans:
        return jsonify({"msg": "Duplicate scan detected"}), 400
    recent_qr_scans.add(qr_data)

    # Store Attendance in MongoDB (LIFO Order)
    attendance_collection.insert_one({
        "student_id": student_id,
        "qr_timestamp": qr_timestamp,
        "scanned_timestamp": current_timestamp,
    })

    return jsonify({
        "msg": "Attendance marked successfully",
        "student_id": student_id,
        "scanned_timestamp": current_timestamp
    }), 200


@attendance_routes.route("/get_attendance", methods=["GET"])
def get_attendance():
    """
    Get the real-time attendance list (LIFO - Last In First Out)
    """
    records = attendance_collection.find().sort("scanned_timestamp", -1)  # LIFO Order
    attendance_list = [
        {
            "student_id": record["student_id"],
            "timestamp": record["scanned_timestamp"]
        }
        for record in records
    ]
    return jsonify({"attendance": attendance_list}), 200
