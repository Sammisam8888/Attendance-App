import qrcode
import hashlib
import time
from io import BytesIO

def generate_qr(timestamp):
    # Generate a QR code image for the given timestamp
    qr_data = generate_token(timestamp)
    qr = qrcode.QRCode(version=1, error_correction=qrcode.constants.ERROR_CORRECT_L, box_size=10, border=4)
    qr.add_data(qr_data)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    buffer = BytesIO()
    img.save(buffer, format="PNG")
    buffer.seek(0)
    return buffer

def generate_token(timestamp=None):
    # Generate a unique token based on the timestamp
    if timestamp is None:
        timestamp = int(time.time() // 10)
    secret_key = "your_secret_key"  # Replace with a secure key
    token = hashlib.sha256(f"{timestamp}{secret_key}".encode()).hexdigest()
    return token

