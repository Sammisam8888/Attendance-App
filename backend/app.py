from flask import Flask, Blueprint, request, jsonify, send_file
from passlib.hash import pbkdf2_sha256 as sha256
import uuid
import numpy as np
import time
import io
import hashlib
import qrcode
import cv2
import dlib
import os
from pymongo import MongoClient
from pymongo.errors import ServerSelectionTimeoutError

# Initialize Flask app
app = Flask(__name__)

# Initialize MongoDB Connection
client = MongoClient("mongodb://localhost:27017/")
db = client["qr_attendance"]

# ------------------------
# Database Helper Functions
# ------------------------

def get_student_collection():
    return db.students

def get_teacher_collection():
    return db.teachers

def get_attendance_collection():
    return db.attendance

def get_class_collection():
    return db.classes

# ------------------------
# User Models
# ------------------------

class User:
    def __init__(self, name, email, password):
        self.id = uuid.uuid4().hex
        self.name = name
        self.email = email
        self.password = sha256.hash(password)

    def save_to_db(self):
        if db.users.find_one({"email": self.email}):
            return {"message": "User already exists"}, 400
        db.users.insert_one(self.__dict__)
        return self.__dict__, 200

    @staticmethod
    def find_by_email(email):
        return db.users.find_one({"email": email})

    @staticmethod
    def verify_password(password, hashed_password):
        return sha256.verify(password, hashed_password)


class Student(User):
    def __init__(self, name, email, password, roll_no):
        super().__init__(name, email, password)
        self.roll_no = roll_no  # Unique Student Identifier
        self.face_encoding = None  # Initialize face data as None

    def save_to_db(self):
        if db.students.find_one({"email": self.email}):
            return {"message": "User already exists"}, 400
        db.students.insert_one(self.__dict__)
        return self.__dict__, 200

    @staticmethod
    def find_by_email(email):
        return db.students.find_one({"email": email})

    @staticmethod
    def verify_password(password, hashed_password):
        return sha256.verify(password, hashed_password)

    def store_face_encoding(self, encoding):
        """Stores the student's face encoding directly in the students table."""
        encoding_list = encoding.tolist()  # Convert NumPy array to list before storing

        db.students.update_one(
            {"roll_no": self.roll_no},
            {"$set": {"face_encoding": encoding_list}}
        )
        return {"message": "Face data saved successfully"}, 200

    @staticmethod
    def get_face_encoding(roll_no):
        """Fetches the stored face encoding for a student by roll number."""
        student = db.students.find_one({"roll_no": roll_no}, {"_id": 0, "face_encoding": 1})
        return np.array(student["face_encoding"]) if student and "face_encoding" in student else None


class Teacher(User):
    def __init__(self, name, email, password, teacher_id):
        super().__init__(name, email, password)
        self.teacher_id = teacher_id

    def save_to_db(self):
        if db.teachers.find_one({"email": self.email}):
            return {"message": "User already exists"}, 400
        db.teachers.insert_one(self.__dict__)
        return self.__dict__, 200

    @staticmethod
    def find_by_email(email):
        return db.teachers.find_one({"email": email})

    @staticmethod
    def verify_password(password, hashed_password):
        return sha256.verify(password, hashed_password)

# ------------------------
# Attendance Model
# ------------------------

class AttendanceModel:
    collection = db.attendance

    @staticmethod
    def mark_attendance(email, name, roll_no, timestamp, subject_name, classroom_number):
        record = {
            "email": email,
            "name": name,
            "roll_no": roll_no,
            "timestamp": timestamp,
            "subject_name": subject_name,
            "classroom_number": classroom_number
        }
        AttendanceModel.collection.insert_one(record)
        return True

    @staticmethod
    def get_all_attendance():
        return list(AttendanceModel.collection.find({}, {"_id": 0}))

    @staticmethod
    def get_attendance_by_field(field, value):
        return list(AttendanceModel.collection.find({field: value}, {"_id": 0, "timestamp": 1}))

    @staticmethod
    def delete_attendance_by_email(email):
        AttendanceModel.collection.delete_many({"email": email})
        return True

# ------------------------
# Face Recognition Utilities
# ------------------------

# Load Dlib's face detector and models
detector = dlib.get_frontal_face_detector()
try:
    model_dir = os.path.join(os.path.dirname(__file__), "models")
    sp = dlib.shape_predictor(os.path.join(model_dir, "shape_predictor_68_face_landmarks.dat"))
    facerec = dlib.face_recognition_model_v1(os.path.join(model_dir, "dlib_face_recognition_resnet_model_v1.dat"))
except RuntimeError:
    print("Error: Could not load face recognition models. Make sure the model files exist.")
    sp = None
    facerec = None

def capture_training_images():
    cap = cv2.VideoCapture(0)
    images = []
    start_time = time.time()

    print("Look into the camera for 20 seconds...")

    while time.time() - start_time < 20:
        ret, frame = cap.read()
        if not ret:
            continue

        cv2.imshow("Face Capture", frame)

        if len(images) < 40 and (len(images) == 0 or time.time() - start_time >= len(images) * 0.5):
            images.append(frame.copy())

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()
    return images

def cosine_similarity(A, B):
    return np.dot(A, B) / (np.linalg.norm(A) * np.linalg.norm(B))

def train_user(name, roll_no, subject_code):
    if sp is None or facerec is None:
        return {"message": "Face recognition models not loaded properly"}, 500
        
    images = capture_training_images()
    encodings = []

    for img in images:
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        faces = detector(gray)

        if faces:
            shape = sp(gray, faces[0])
            encoding = facerec.compute_face_descriptor(gray, shape)
            encodings.append(np.array(encoding))

    if encodings:
        avg_encoding = np.mean(encodings, axis=0).tolist()  

        # Update student record with face encoding
        db.students.update_one(
            {"roll_no": roll_no, "subject_code": subject_code},
            {"$set": {"face_encoding": avg_encoding}},
            upsert=True
        )
        return {"message": f"User {name} trained successfully!"}, 200
    else:
        return {"message": "No face detected. Training failed."}, 400

def recognize_user(subject_code):
    if sp is None or facerec is None:
        return {"message": "Face recognition models not loaded properly"}, 500
        
    cap = cv2.VideoCapture(0)

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        faces = detector(gray)

        for face in faces:
            shape = sp(gray, face)
            test_encoding = np.array(facerec.compute_face_descriptor(gray, shape))

            students = db.students.find({"subject_code": subject_code}, {"name": 1, "roll_no": 1, "face_encoding": 1})

            best_match_name = "Unknown"
            best_match_roll_no = None
            best_match_score = -1  

            for student in students:
                if "face_encoding" in student:
                    db_encoding = np.array(student["face_encoding"])
                    similarity = cosine_similarity(test_encoding, db_encoding)

                    if similarity > best_match_score:
                        best_match_score = similarity
                        best_match_name = student["name"]
                        best_match_roll_no = student["roll_no"]

            recognized_name = best_match_name if best_match_score > 0.75 else "Unknown"

            x, y, w, h = face.left(), face.top(), face.width(), face.height()
            cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)

            cv2.putText(frame, recognized_name, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

        cv2.imshow("Face Recognition", frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()
    return {"message": "Recognition process completed!"}, 200

# ------------------------
# QR Code Utilities
# ------------------------

def generate_token(timestamp=None):
    if timestamp is None:
        timestamp = int(time.time() // 3)  # Change every 3 seconds
    secret_key = "secure_secret"
    unique_token = f"{secret_key}_{timestamp}"
    return hashlib.sha256(unique_token.encode()).hexdigest()

def generate_qr(timestamp):
    token = generate_token(timestamp)
    qr = qrcode.make(token)
    img_io = io.BytesIO()
    qr.save(img_io, 'PNG')
    img_io.seek(0)
    return img_io

# ------------------------
# Attendance Utilities
# ------------------------

def store_attendance(branch, year, subject_code, attendance_details):
    """Stores attendance details for a specific branch, year, and subject code."""
    attendance_collection = get_attendance_collection()
    attendance_collection.update_one(
        {"branch": branch, "year": year, "subject_code": subject_code},
        {"$set": {"attendance_details": attendance_details}},
        upsert=True
    )

def get_attendance(branch, year, subject_code):
    """Fetches attendance details for a specific branch, year, and subject code."""
    attendance_collection = get_attendance_collection()
    return attendance_collection.find_one({"branch": branch, "year": year, "subject_code": subject_code}, {"_id": 0})

def get_attended_classes(student_name):
    """Fetches attended classes for a specific student."""
    attendance_collection = get_attendance_collection()
    attended_classes = attendance_collection.find({"student_name": student_name}, {"_id": 0, "subject_code": 1, "teacher": 1, "time": 1})
    return list(attended_classes)

def store_class_schedule(classroom, branch, semester, subject, subject_code, timing, notes_link):
    """Stores class schedule details."""
    class_collection = get_class_collection()
    class_collection.insert_one({
        "classroom": classroom,
        "branch": branch,
        "semester": semester,
        "subject": subject,
        "subject_code": subject_code,
        "timing": timing,
        "notes_link": notes_link
    })

def get_all_class_schedules():
    """Fetches all class schedules."""
    try:
        class_collection = get_class_collection()
        return list(class_collection.find({}, {"_id": 0}))
    except Exception as e:
        print(f"Error fetching class schedules: {e}")
        return []

def store_face_encoding(roll_no, encoding):
    """Stores a student's face encoding inside the students collection."""
    student_collection = get_student_collection()

    # Convert numpy array to list before storing
    encoding_list = encoding.tolist()

    # Update student's record with face encoding
    student_collection.update_one(
        {"roll_no": roll_no},
        {"$set": {"face_encoding": encoding_list}}
    )

def get_all_face_encodings():
    """Fetches all students who have a face encoding stored."""
    student_collection = get_student_collection()
    return list(student_collection.find({"face_encoding": {"$exists": True}}, {"_id": 0, "roll_no": 1, "face_encoding": 1}))

def generate_sample_attendance():
    # Sample data for attendance
    sample_attendance_data = [
        {
            "email": "student1@example.com",
            "name": "Student One",
            "roll_no": "001",
            "timestamp": "2023-10-01T10:00:00Z",
            "subject_code": "SUB001",
            "classroom_number": "101"
        },
        {
            "email": "student2@example.com",
            "name": "Student Two",
            "roll_no": "002",
            "timestamp": "2023-10-01T10:00:00Z",
            "subject_code": "SUB002",
            "classroom_number": "102"
        }
    ]
    
    for attendance in sample_attendance_data:
        AttendanceModel.mark_attendance(
            attendance["email"],
            attendance["name"],
            attendance["roll_no"],
            attendance["timestamp"],
            attendance["subject_code"],
            attendance["classroom_number"]
        )

# ------------------------
# Sample Data
# ------------------------

def add_sample_data():
    try:
        if not Teacher.find_by_email("s"):
            sample_teacher = Teacher(name="s", email="s", password="s", teacher_id="s")
            sample_teacher.save_to_db()
        
        if not Student.find_by_email("s"):
            sample_student = Student(name="s", email="s", password="s", roll_no="s")
            sample_student.save_to_db()
    except ServerSelectionTimeoutError:
        print("Database connection error. Could not add sample data.")

# Initialize sample data
add_sample_data()

# ------------------------
# Routes - Authentication
# ------------------------

@app.route('/auth/student/signup', methods=['POST'])
def student_signup():
    data = request.json
    student = Student(name=data["name"], email=data["email"], password=data["password"], roll_no=data["roll_number"])
    try:
        return jsonify(student.save_to_db())
    except ServerSelectionTimeoutError:
        return jsonify({"message": "Database connection error"}), 500

@app.route('/auth/student/login', methods=['POST'])
def student_login():
    data = request.json
    try:
        student = Student.find_by_email(data["email"])
        if student and Student.verify_password(data["password"], student["password"]):
            return jsonify({"message": "Login successful"}), 200
        return jsonify({"message": "Invalid credentials"}), 400
    except ServerSelectionTimeoutError:
        return jsonify({"message": "Database connection error"}), 500

@app.route('/auth/teacher/signup', methods=['POST'])
def teacher_signup():
    data = request.json
    teacher = Teacher(name=data["name"], email=data["email"], password=data["password"], teacher_id=data["teacher_id"])
    try:
        return jsonify(teacher.save_to_db())
    except ServerSelectionTimeoutError:
        return jsonify({"message": "Database connection error"}), 500

@app.route('/auth/teacher/login', methods=['POST'])
def teacher_login():
    data = request.json
    try:
        teacher = Teacher.find_by_email(data["email"])
        if teacher and Teacher.verify_password(data["password"], teacher["password"]):
            return jsonify({"message": "Login successful"}), 200
        return jsonify({"message": "Invalid credentials"}), 400
    except ServerSelectionTimeoutError:
        return jsonify({"message": "Database connection error"}), 500

# ------------------------
# Routes - QR Code
# ------------------------

@app.route('/qr/teacher/get_qr', methods=['GET'])
def get_qr():
    timestamp = request.args.get('timestamp', default=int(time.time() // 10), type=int)
    return send_file(generate_qr(timestamp), mimetype='image/png')

@app.route('/qr/student/verify_qr', methods=['POST'])
def verify_qr():
    data = request.json
    scanned_token = data.get('token')
    email = data.get('email')
    
    if scanned_token == generate_token():
        student = Student.find_by_email(email)
        if student:
            timestamp = int(time.time())
            return jsonify({
                "message": "Valid QR Code",
                "status": "success",
                "name": student["name"],
                "roll_no": student["roll_no"],
                "timestamp": timestamp
            }), 200
    return jsonify({"message": "Invalid or Expired QR Code", "status": "failed"}), 400

# ------------------------
# Routes - Face Scanner
# ------------------------

@app.route('/face_scanner/student/train', methods=['POST'])
def train_face():
    data = request.json
    name = data.get("name")
    roll_no = data.get("roll_no")
    subject_code = data.get("subject_code")

    if not name or not roll_no or not subject_code:
        return jsonify({"message": "Name, Roll Number, and Subject Code are required"}), 400

    response, status = train_user(name, roll_no, subject_code)
    return jsonify(response), status

@app.route('/face_scanner/student/recognize', methods=['GET'])
def recognize_face():
    subject_code = request.args.get("subject_code")
    if not subject_code:
        return jsonify({"message": "Subject Code is required"}), 400

    response, status = recognize_user(subject_code)
    return jsonify(response), status

# ------------------------
# Routes - Attendance
# ------------------------

@app.route('/attendance/mark_attendance', methods=['POST'])
def mark_attendance():
    data = request.json
    email = data.get('email')
    name = data.get('name')
    roll_no = data.get('roll_no')
    timestamp = data.get('timestamp')
    subject_name = data.get('subject_name')
    classroom_number = data.get('classroom_number')
    
    if not email or not name or not roll_no or not timestamp or not subject_name or not classroom_number:
        return jsonify({"message": "Missing data"}), 400
    
    AttendanceModel.mark_attendance(email, name, roll_no, timestamp, subject_name, classroom_number)
    return jsonify({"message": "Attendance marked successfully"}), 200

@app.route('/attendance/get_all_attendance', methods=['GET'])
def get_all_attendance():
    attendance_records = AttendanceModel.get_all_attendance()
    return jsonify(attendance_records), 200

@app.route('/attendance/get_attendance_by_email', methods=['GET'])
def get_attendance_by_email():
    email = request.args.get('email')
    if not email:
        return jsonify({"message": "Email is required"}), 400
    
    attendance_records = AttendanceModel.get_attendance_by_field('email', email)
    return jsonify(attendance_records), 200

@app.route('/attendance/get_attendance_by_roll_no', methods=['GET'])
def get_attendance_by_roll_no():
    roll_no = request.args.get('roll_no')
    if not roll_no:
        return jsonify({"message": "Roll number is required"}), 400
    
    attendance_records = AttendanceModel.get_attendance_by_field('roll_no', roll_no)
    return jsonify(attendance_records), 200

@app.route('/attendance/delete_attendance_by_email', methods=['DELETE'])
def delete_attendance_by_email():
    email = request.args.get('email')
    if not email:
        return jsonify({"message": "Email is required"}), 400
    
    AttendanceModel.delete_attendance_by_email(email)
    return jsonify({"message": "Attendance records deleted successfully"}), 200

# ------------------------
# App Entry Point
# ------------------------

if __name__ == '__main__':
    app.run(debug=True)