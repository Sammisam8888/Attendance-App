from flask import Flask, jsonify, request
from passlib.hash import pbkdf2_sha256 as sha256
from ..database import db
import uuid


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
        self.roll_no = roll_no

    def save_to_db(self):
        if db.students.find_one({"email": self.email}):
            return {"message": "User already exists"}, 400
        db.students.insert_one(self.__dict__)
        return self.__dict__, 200

    @staticmethod
    def find_by_email(email):
        return db.students.find_one({"email": email})   

    @staticmethod
    def verify_password(password, hashed_password, roll_no):
        return sha256.verify(password, hashed_password)

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
    def verify_password(password, hashed_password, teacher_id):
        return sha256.verify(password, hashed_password)
