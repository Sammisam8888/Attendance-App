from flask import Blueprint, request, jsonify
from models.attendance_model import AttendanceModel

attendance_routes = Blueprint('attendance_routes', __name__)

@attendance_routes.route('/mark_attendance', methods=['POST'])
def mark_attendance():
    data = request.get_json()
    email = data.get('email')
    name = data.get('name')
    reg_no = data.get('reg_no')
    timestamp = data.get('timestamp')
    subject_name = data.get('subject_name')
    classroom_number = data.get('classroom_number')
    
    if not email or not name or not reg_no or not timestamp or not subject_name or not classroom_number:
        return jsonify({"message": "Missing data"}), 400
    
    AttendanceModel.mark_attendance(email, name, reg_no, timestamp, subject_name, classroom_number)
    return jsonify({"message": "Attendance marked successfully"}), 200


@attendance_routes.route('/get_all_attendance', methods=['GET'])
def get_all_attendance():
    attendance_records = AttendanceModel.get_all_attendance()
    return jsonify(attendance_records), 200


@attendance_routes.route('/get_attendance_by_email', methods=['GET'])
def get_attendance_by_email():
    email = request.args.get('email')
    if not email:
        return jsonify({"message": "Email is required"}), 400
    
    attendance_records = AttendanceModel.get_attendance_by_field('email', email)
    return jsonify(attendance_records), 200

@attendance_routes.route('/get_attendance_by_reg_no', methods=['GET'])
def get_attendance_by_reg_no():
    reg_no = request.args.get('reg_no')
    if not reg_no:
        return jsonify({"message": "Roll number is required"}), 400
    
    attendance_records = AttendanceModel.get_attendance_by_field('reg_no', reg_no)
    return jsonify(attendance_records), 200

@attendance_routes.route('/delete_attendance_by_email', methods=['DELETE'])
def delete_attendance_by_email():
    email = request.args.get('email')
    if not email:
        return jsonify({"message": "Email is required"}), 400
    
    AttendanceModel.delete_attendance_by_email(email)
    return jsonify({"message": "Attendance records deleted successfully"}), 200
