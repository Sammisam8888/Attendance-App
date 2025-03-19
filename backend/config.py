import os
from dotenv import load_dotenv

load_dotenv()  # Load environment variables from .env file

class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "default_secret_key")
    JWT_ALGORITHM = "HS256"
    MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017/attendance_app")
    UPLOAD_FOLDER = os.getenv("UPLOAD_FOLDER", "./uploads")
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16 MB
