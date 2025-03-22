from database import get_attendance_collection

class AttendanceModel:
    def mark_attendance(self, email, name, roll_no, timestamp, subject_code, classroom_number):
        attendance_collection = get_attendance_collection()
        attendance_collection.insert_one({
            "email": email,
            "name": name,
            "roll_no": roll_no,
            "timestamp": timestamp,
            "subject_code": subject_code,
            "classroom_number": classroom_number
        })

    def get_all_attendance(self):
        attendance_collection = get_attendance_collection()
        return list(attendance_collection.find({}, {"_id": 0}))

    def get_attendance_by_field(self, field, value):
        attendance_collection = get_attendance_collection()
        return list(attendance_collection.find({field: value}, {"_id": 0}))

    def delete_attendance_by_email(self, email):
        attendance_collection = get_attendance_collection()
        attendance_collection.delete_many({"email": email})

