from flask import Flask, jsonify, request
from passlib.hash import pbkdf2_sha256 as sha256
from database import db
import uuid


class Student:
    def signup(self):
        student = {
            "_id": uuid.uuid4().hex,
            "name": request.json['name'],
            "email": request.json['email'],
            "password": request.json['password'],
        }
        # Hash the password
        student['password'] = sha256.hash(student['password'])
        if db.users.find_one({"email": student['email']}):
            return jsonify({"message": "User already exists"}), 400
        db.users.insert_one(student)
        return jsonify(student), 200

    def login(self):
        email = request.json['email']
        password = request.json['password']
        student = db.users.find_one({"email": email})
        if student and sha256.verify(password, student['password']):
            return jsonify({"message": "Login successful"}), 200
        return jsonify({"message": "Invalid email or password"}), 400