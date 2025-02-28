from flask import Flask, jsonify, request
from passlib.hash import pbkdf2_sha256 as sha256
from database import db
import uuid
import numpy as np


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
