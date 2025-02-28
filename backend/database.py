from pymongo import MongoClient

# Initialize MongoDB Connection
client = MongoClient("mongodb://localhost:27017/")
db = client["qr_attendance"]

# Get the collections
def get_student_collection():
    return db.students

def get_teacher_collection():
    return db.teachers

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
