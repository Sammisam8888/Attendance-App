from pymongo import MongoClient

client = MongoClient("mongodb://localhost:27017/")
db = client["qr_attendance"]

def get_student_collection():
    return db.students
