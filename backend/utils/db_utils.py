from database import db

def get_attendance_collection():
    """Returns the attendance collection from the database."""
    return db.attendance
