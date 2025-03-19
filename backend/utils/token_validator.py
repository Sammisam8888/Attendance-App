import hashlib
import time
import jwt
from flask import request, jsonify
from functools import wraps

SECRET_KEY = "secure_secret"

def validate_token(token, timestamp=None):
    if timestamp is None:
        timestamp = int(time.time() // 3)  # Match the same interval as token generation
    expected_token = hashlib.sha256(f"{SECRET_KEY}_{timestamp}".encode()).hexdigest()
    return token == expected_token

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({"message": "Token is missing!", "status": "failed"}), 401
        try:
            decoded_data = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
            request.user = decoded_data  # Attach user data to the request object
        except jwt.ExpiredSignatureError:
            return jsonify({"message": "Token has expired!", "status": "failed"}), 401
        except jwt.InvalidTokenError:
            return jsonify({"message": "Invalid token!", "status": "failed"}), 401
        return f(*args, **kwargs)
    return decorated
