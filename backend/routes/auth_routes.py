from flask import Blueprint, request, jsonify
from pymongo.errors import ServerSelectionTimeoutError
auth_routes = Blueprint('auth_routes', __name__)
from models.user_model import Student, Teacher
from database import db

def add_sample_data():
    try:
        if not Teacher.find_by_email("t"):
            sample_teacher = Teacher(name="Teacher", email="t", password="t", teacher_id="T1001", subject_specialisation="Math", assigned_classes=["Class1"])
            sample_teacher.save_to_db()
        
        if not Student.find_by_email("s"):
            sample_student = Student(name="Sammi", email="s", password="s", roll_no="s", branch="CS", semester="5", subject_code="CS101")
            sample_student.save_to_db()
    except ServerSelectionTimeoutError:
        print("Database connection error. Could not add sample data.")

add_sample_data()

@auth_routes.route('/student/signup', methods=['POST'])
def student_signup():
    data = request.json
    student = Student(name=data["name"], email=data["email"], password=data["password"], roll_no=data["roll_number"])
    try:
        return jsonify(student.save_to_db())
    except ServerSelectionTimeoutError:
        return jsonify({"message": "Database connection error"}), 500

@auth_routes.route('/student/login', methods=['POST'])
def student_login():
    data = request.json
    try:
        student = Student.find_by_email(data["email"])
        if student and Student.verify_password(data["password"], student["password"]):
            return jsonify({"message": "Login successful"}), 200
        return jsonify({"message": "Invalid credentials"}), 400
    except ServerSelectionTimeoutError:
        return jsonify({"message": "Database connection error"}), 500

@auth_routes.route('/teacher/signup', methods=['POST'])
def teacher_signup():
    data = request.json
    teacher = Teacher(name=data["name"], email=data["email"], password=data["password"], teacher_id=data["teacher_id"])
    try:
        return jsonify(teacher.save_to_db())
    except ServerSelectionTimeoutError:
        return jsonify({"message": "Database connection error"}), 500

@auth_routes.route('/teacher/login', methods=['POST'])
def teacher_login():
    data = request.json
    try:
        teacher = Teacher.find_by_email(data["email"])
        if teacher and Teacher.verify_password(data["password"], teacher["password"]):
            return jsonify({"message": "Login successful"}), 200
        return jsonify({"message": "Invalid credentials"}), 400
    except ServerSelectionTimeoutError:
        return jsonify({"message": "Database connection error"}), 500
