from flask import Blueprint, request, jsonify
from attendance import store_attendance, get_attendance, store_class_schedule, get_all_class_schedules, get_attended_classes, generate_sample_attendance
from models.attendance_model import AttendanceModel

attendance_routes = Blueprint('attendance_routes', __name__)
attendance_model = AttendanceModel()  # Instantiate the class

@attendance_routes.route('/mark_attendance', methods=['POST'])
def mark_attendance():
    data = request.json
    email = data.get('email')
    name = data.get('name')
    roll_no = data.get('roll_no')
    timestamp = data.get('timestamp')
    subject_code = data.get('subject_code')
    classroom_number = data.get('classroom_number')
    
    if not email or not name or not roll_no or not timestamp or not subject_code or not classroom_number:
        return jsonify({"message": "Missing data"}), 400
    
    attendance_model.mark_attendance(email, name, roll_no, timestamp, subject_code, classroom_number)
    return jsonify({"message": "Attendance marked successfully"}), 200

@attendance_routes.route('/get_all_attendance', methods=['GET'])
def get_all_attendance():
    attendance_records = attendance_model.get_all_attendance()
    return jsonify(attendance_records), 200

@attendance_routes.route('/get_attendance_by_email', methods=['GET'])
def get_attendance_by_email():
    email = request.args.get('email')
    if not email:
        return jsonify({"message": "Email is required"}), 400
    
    attendance_records = attendance_model.get_attendance_by_field('email', email)
    return jsonify(attendance_records), 200

@attendance_routes.route('/get_attendance_by_roll_no', methods=['GET'])
def get_attendance_by_roll_no():
    roll_no = request.args.get('roll_no')
    if not roll_no:
        return jsonify({"message": "Roll number is required"}), 400
    
    attendance_records = attendance_model.get_attendance_by_field('roll_no', roll_no)
    return jsonify(attendance_records), 200

@attendance_routes.route('/delete_attendance_by_email', methods=['DELETE'])
def delete_attendance_by_email():
    email = request.args.get('email')
    if not email:
        return jsonify({"message": "Email is required"}), 400
    
    attendance_model.delete_attendance_by_email(email)
    return jsonify({"message": "Attendance records deleted successfully"}), 200

@attendance_routes.route('/store_attendance', methods=['POST'])
def store_attendance_route():
    data = request.json
    branch = data.get('branch')
    year = data.get('year')
    subject_code = data.get('subject_code')
    attendance_details = data.get('attendance_details')
    
    if not branch or not year or not subject_code or not attendance_details:
        return jsonify({"message": "Missing data"}), 400
    
    store_attendance(branch, year, subject_code, attendance_details)
    return jsonify({"message": "Attendance details stored successfully"}), 200

@attendance_routes.route('/get_attendance', methods=['GET'])
def get_attendance_route():
    branch = request.args.get('branch')
    year = request.args.get('year')
    subject_code = request.args.get('subject_code')
    
    if not branch or not year or not subject_code:
        return jsonify({"message": "Branch, year, and subject code are required"}), 400
    
    attendance_details = get_attendance(branch, year, subject_code)
    return jsonify(attendance_details), 200

@attendance_routes.route('/store_class_schedule', methods=['POST'])
def store_class_schedule_route():
    data = request.json
    classroom = data.get('classroom')
    branch = data.get('branch')
    semester = data.get('semester')
    subject = data.get('subject')
    subject_code = data.get('subject_code')
    timing = data.get('timing')
    notes_link = data.get('notes_link')
    
    if not classroom or not branch or not semester or not subject or not subject_code or not timing or not notes_link:
        return jsonify({"message": "Missing data"}), 400
    
    store_class_schedule(classroom, branch, semester, subject, subject_code, timing, notes_link)
    return jsonify({"message": "Class schedule stored successfully"}), 200

@attendance_routes.route('/get_all_class_schedules', methods=['GET'])
def get_all_class_schedules_route():
    class_schedules = get_all_class_schedules()
    return jsonify(class_schedules), 200

@attendance_routes.route('/get_attended_classes', methods=['GET'])
def get_attended_classes_route():
    student_name = request.args.get('studentName')
    if not student_name:
        return jsonify({"message": "Student name is required"}), 400
    
    attended_classes = get_attended_classes(student_name)
    return jsonify(attended_classes), 200
