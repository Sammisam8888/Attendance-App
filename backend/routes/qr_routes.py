import time
from flask import Blueprint, request, jsonify

qr_routes = Blueprint('qr_routes', __name__)

@qr_routes.route('/scan_qr', methods=['POST'])
def scan_qr():
    """
    Expected JSON payload from the student’s app:
    {
        "qr_data": "attendance_code_1684367890",
        "student_id": "student123"
    }
    """
    data = request.get_json()

    # Retrieve QR code data and student information
    qr_data = data.get("qr_data")
    student_id = data.get("student_id")

    if not qr_data or not student_id:
        return jsonify({"msg": "Missing data"}), 400

    # Attempt to extract the timestamp from the QR code data
    try:
        prefix, qr_timestamp = qr_data.split("_code_")
        qr_timestamp = int(qr_timestamp)
    except Exception as e:
        return jsonify({"msg": "Invalid QR code data", "error": str(e)}), 400

    # Capture the time when the QR code was scanned (server-side)
    scanned_timestamp = int(time.time())

    # Optionally, you can compare qr_timestamp and scanned_timestamp to ensure validity
    # For example, reject if the difference is too large (indicating an expired QR code)
    allowed_delay = 10  # seconds
    if abs(scanned_timestamp - qr_timestamp) > allowed_delay:
        return jsonify({"msg": "QR code expired or invalid", 
                        "qr_timestamp": qr_timestamp, 
                        "scanned_timestamp": scanned_timestamp}), 400

    # Here you could mark attendance in the database for the given student

    return jsonify({
        "msg": "QR code scanned successfully",
        "qr_timestamp": qr_timestamp,
        "scanned_timestamp": scanned_timestamp
    }), 200
