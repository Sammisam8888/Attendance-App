from flask import Flask
from routes.auth_routes import auth_routes
from routes.qr_routes import qr_routes
from routes.face_scanner_routes import face_scanner_routes
from routes.attendance_routes import attendance_routes
from utils.qr_generator import qr_generator

app = Flask(__name__)

# Register blueprints
app.register_blueprint(auth_routes, url_prefix='/auth')
app.register_blueprint(qr_routes, url_prefix='/qr')
app.register_blueprint(qr_generator, url_prefix='/qr')
app.register_blueprint(face_scanner_routes, url_prefix='/face_scanner')
app.register_blueprint(attendance_routes, url_prefix='/attendance')

if __name__ == '__main__':
    app.run(debug=True)