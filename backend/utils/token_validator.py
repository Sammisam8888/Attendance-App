import time
from utils.qr_generator import generate_token

def validate_token(scanned_token, tolerance=1):
    """
    Validate the scanned token by checking it against tokens generated
    for the current and nearby timestamps (within the tolerance range).
    """
    current_timestamp = int(time.time() // 3)  # Match the 3-second interval
    for offset in range(-tolerance, tolerance + 1):
        generated_token = generate_token(current_timestamp + offset)
        print(f"Scanned Token: {scanned_token}, Generated Token: {generated_token}")
        if scanned_token == generated_token:
            return True
    return False
