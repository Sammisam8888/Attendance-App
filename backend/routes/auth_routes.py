from flask import Blueprint, render_template
auth_routes = Blueprint('auth_routes', __name__)

@auth_routes.route('/login')
def login():
    return render_template('login.html')
