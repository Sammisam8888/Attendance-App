from flask import Flask, jsonify
from routes.auth_routes import auth_routes
from routes.qr_routes import qr_routes
from routes.face_scanner_routes import face_scanner_routes
from routes.attendance_routes import attendance_routes

app = Flask(__name__)

# Register blueprints with updated URL prefixes
app.register_blueprint(auth_routes, url_prefix='/auth')
app.register_blueprint(qr_routes, url_prefix='/qr')
app.register_blueprint(face_scanner_routes, url_prefix='/face_scanner')
app.register_blueprint(attendance_routes, url_prefix='/attendance')

# Add a basic landing page
@app.route('/')
def landing_page():
    return jsonify({"message": "Welcome to the Attendance App Backend!"})

if __name__ == '__main__':
    app.run(debug=True, port=5000)  # Explicitly set the port to 5000