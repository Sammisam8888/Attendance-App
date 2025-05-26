from flask import Blueprint, request, jsonify
from pymongo.errors import ServerSelectionTimeoutError
from models.user_model import Student, Teacher
from database import db
auth_routes = Blueprint('auth_routes', __name__)
# def add_sample_data():
#     try:
#         if not Teacher.find_by_email("sam@gmail.com"):
#             sample_teacher = Teacher(name="Sam", email="sam@gmail.com", password="sammisam", teacher_id="T1001")
#             sample_teacher.save_to_db()
        
#         if not Student.find_by_email("sammi@gmail.com"):
#             sample_student = Student(name="Sammi", email="sammi@gmail.com", password="player", roll_no="S1001")
#             sample_student.save_to_db()
#     except ServerSelectionTimeoutError:
#         print("Database connection error. Could not add sample data.")

# add_sample_data()

@auth_routes.route('/student/signup', methods=['POST'])
def student_signup():
    data = request.get_json()
    student = Student(name=data["name"], email=data["email"], password=data["password"],reg_no=data["reg_no"])
    try:
        return jsonify(student.save_to_db())
    except ServerSelectionTimeoutError:
        return jsonify({"message": "Database connection error"}), 500
    
    
# | ---- | -------------------------------------------------------------------------- |
# | 1    | User sends a POST request to `/student/signup` with JSON data              |
# | 2    | Flask route receives data and creates a `Student` object                   |
# | 3    | Calls `student.save_to_db()`                                               |
# | 4    | Inside `Student`, `super().save_to_db("students", "reg_no")` is called     |
# | 5    | Parent `User` class defines `save_to_db(self, collection_name, unique_id)` |
# | 6    | User is inserted into MongoDB (if not already present)                     |
# | 7    | The result is returned, wrapped in `jsonify()`                             |
# | 8    | Response is sent back to the client                                        |


@auth_routes.route('/student/login', methods=['POST'])
def student_login():
    data = request.get_json()
    try:
        student = Student.find_by_id(data["reg_no"])
        if student and Student.verify_password(data["password"], student["password"]):
            return jsonify({"message": "Login successful"}), 200
        return jsonify({"message": "Invalid credentials"}), 400
    except ServerSelectionTimeoutError:
        return jsonify({"message": "Database connection error"}), 500

@auth_routes.route('/teacher/signup', methods=['POST'])
def teacher_signup():
    data = request.get_json()
    teacher = Teacher(name=data["name"], email=data["email"], password=data["password"], teacher_id=data["teacher_id"])
    try:
        return jsonify(teacher.save_to_db())
    except ServerSelectionTimeoutError:
        return jsonify({"message": "Database connection error"}), 500

@auth_routes.route('/teacher/login', methods=['POST'])
def teacher_login():
    data = request.json
    try:
        teacher = Teacher.find_by_id(data["teacher_id"])
        if teacher and Teacher.verify_password(data["password"], teacher["password"]):
            return jsonify({"message": "Login successful"}), 200
        return jsonify({"message": "Invalid credentials"}), 400
    except ServerSelectionTimeoutError:
        return jsonify({"message": "Database connection error"}), 500
