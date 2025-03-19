from flask import Flask
from routes.auth_routes import auth_routes
from routes.qr_routes import qr_routes
from routes.face_scanner_routes import face_scanner_routes
from routes.attendance_routes import attendance_routes
from config import Config

app = Flask(__name__)
app.config.from_object(Config)
    app = Flask(__name__)
    app.config.from_object(config[env_name])
    # Register blueprints with updated URL prefixes
    app.register_blueprint(auth_routes, url_prefix='/auth')
    app.register_blueprint(qr_routes, url_prefix='/qr')
    app.register_blueprint(face_scanner_routes, url_prefix='/face_scanner')
    app.register_blueprint(attendance_routes, url_prefix='/attendance')
    return app

if __name__ == "__main__":
    env_name = os.getenv("FLASK_ENV", "development")
    app = create_app(env_name)
    app.run()