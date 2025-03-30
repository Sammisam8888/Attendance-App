from pymongo import MongoClient
from models.user_model import Student
from utils.db_utils import get_attendance_collection  # Updated import

# Initialize MongoDB Connection
client = MongoClient("mongodb://localhost:27017/")
db = client["qr_attendance"]

# Get the collections
def get_student_collection():
    return db.students

def get_teacher_collection():
    return db.teachers

def get_class_collection():
    return db.classes

# Store face encoding inside the students collection
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

# Retrieve all students with face encodings
def get_all_face_encodings():
    """Fetches all students who have a face encoding stored."""
    student_collection = get_student_collection()
    return list(student_collection.find({"face_encoding": {"$exists": True}}, {"_id": 0, "roll_no": 1, "face_encoding": 1}))  # Exclude `_id`

def create_sample_students():
    sample_students = [
        {
            'name': 'John Doe',
            'email': 'john.doe@example.com',
            'password': 'password123',
            'roll_no': 'CSE123',
            'branch': 'CSE',
            'semester': '6'
        },
        {
            'name': 'Jane Smith',
            'email': 'jane.smith@example.com',
            'password': 'password123',
            'roll_no': 'ECE456',
            'branch': 'ECE',
            'semester': '4'
        },
    ]
    for student_info in sample_students:
        student = Student(
            student_info['name'],
            student_info['email'],
            student_info['password'],
            student_info['roll_no'],
            student_info['branch'],
            student_info['semester']
        )
        student.save_to_db()

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
    
    attendance_model = AttendanceModel()  # Instantiate the class
    for attendance in sample_attendance_data:
        attendance_model.mark_attendance(
            attendance["email"],
            attendance["name"],
            attendance["roll_no"],
            attendance["timestamp"],
            attendance["subject_code"],
            attendance["classroom_number"]
        )
