from flask import Blueprint, render_template, request
auth_routes = Blueprint('auth_routes', __name__)
from models.user_model import Student
from database import db

@auth_routes.route('/student/signup', methods=['POST'])
def signup():
    student = Student()
    response = student.signup()
    return response

@auth_routes.route('/student/login', methods=['POST'])
def login():
    student = Student()
    response = student.login()
    return response

@auth_routes.route('/teacher/signup', methods=['POST'])
def teacher_signup():
    return 


@auth_routes.route('/teacher/login', methods=['POST'])
def teacher_login():
    return