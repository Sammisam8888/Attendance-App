from database import get_attendance_collection, get_class_collection
from models.attendance_model import AttendanceModel  # Ensure this import is correct

# Store attendance details for a specific subject
def store_attendance(branch, year, subject_code, attendance_details):
    """Stores attendance details for a specific branch, year, and subject code."""
    attendance_collection = get_attendance_collection()
    attendance_collection.update_one(
        {"branch": branch, "year": year, "subject_code": subject_code},
        {"$set": {"attendance_details": attendance_details}},
        upsert=True
    )

# Retrieve attendance details for a specific subject
def get_attendance(branch, year, subject_code):
    """Fetches attendance details for a specific branch, year, and subject code."""
    attendance_collection = get_attendance_collection()
    return attendance_collection.find_one({"branch": branch, "year": year, "subject_code": subject_code}, {"_id": 0})

# Fetch attended classes for a specific student
def get_attended_classes(student_name):
    """Fetches attended classes for a specific student."""
    attendance_collection = get_attendance_collection()
    attended_classes = attendance_collection.find({"student_name": student_name}, {"_id": 0, "subject_code": 1, "teacher": 1, "time": 1})
    return list(attended_classes)

# Store class schedule details
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

# Retrieve all class schedules
def get_all_class_schedules():
    """Fetches all class schedules."""
    try:
        class_collection = get_class_collection()
        return list(class_collection.find({}, {"_id": 0}))
    except Exception as e:
        print(f"Error fetching class schedules: {e}")
        return []

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
