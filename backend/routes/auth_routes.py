from flask import Blueprint, request, jsonify
auth_routes = Blueprint('auth_routes', __name__)
from models.user_model import Student, Teacher
from database import db

def add_sample_data():
    if not Teacher.find_by_email("sam@gmail.com"):
        sample_teacher = Teacher(name="Sam", email="sam@gmail.com", password="sammisam", teacher_id="T1001")
        sample_teacher.save_to_db()
    
    if not Student.find_by_email("sammi@gmail.com"):
        sample_student = Student(name="Sammi", email="sammi@gmail.com", password="player", roll_no="S1001")
        sample_student.save_to_db()

add_sample_data()

@auth_routes.route('/student/signup', methods=['POST'])
def student_signup():
    data = request.json
    student = Student(name=data["name"], email=data["email"], password=data["password"], roll_no=data["roll_no"])
    return jsonify(student.save_to_db())

@auth_routes.route('/student/login', methods=['POST'])
def student_login():
    data = request.json
    student = Student.find_by_email(data["email"])
    
    if student and Student.verify_password(data["password"], student["password"], student["roll_no"]):
        return jsonify({"message": "Login successful"}), 200
    return jsonify({"message": "Invalid credentials"}), 400

@auth_routes.route('/teacher/signup', methods=['POST'])
def teacher_signup():
    data = request.json
    teacher = Teacher(name=data["name"], email=data["email"], password=data["password"], teacher_id=data["teacher_id"])
    return jsonify(teacher.save_to_db())

@auth_routes.route('/teacher/login', methods=['POST'])
def teacher_login():
    data = request.json
    teacher = Teacher.find_by_email(data["email"])
    
    if teacher and Teacher.verify_password(data["password"], teacher["password"], teacher["teacher_id"]):
        return jsonify({"message": "Login successful"}), 200
    return jsonify({"message": "Invalid credentials"}), 400
