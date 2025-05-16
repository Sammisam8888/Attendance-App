import os, secrets
secrect_key = os.environ.get("SECRET_KEY") or secrets.token_hex(32)
