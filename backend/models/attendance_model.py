from database import db

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

