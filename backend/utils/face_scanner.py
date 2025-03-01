import cv2
import dlib
import numpy as np
from pymongo import MongoClient
import time

# Initialize MongoDB Connection
client = MongoClient("mongodb://localhost:27017/")
db = client["qr_attendance"]
students_collection = db["students"]

# Load Dlib's face detector and models
detector = dlib.get_frontal_face_detector()
sp = dlib.shape_predictor("./models/shape_predictor_68_face_landmarks.dat")
facerec = dlib.face_recognition_model_v1("./models/dlib_face_recognition_resnet_model_v1.dat")

# Function to capture training images
def capture_training_images():
    cap = cv2.VideoCapture(0)
    images = []
    start_time = time.time()

    print("Look into the camera for 20 seconds...")

    while time.time() - start_time < 20:
        ret, frame = cap.read()
        if not ret:
            continue

        cv2.imshow("Face Capture", frame)

        if len(images) < 40 and (len(images) == 0 or time.time() - start_time >= len(images) * 0.5):
            images.append(frame.copy())

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()
    return images

# Train User (Store Face Encoding in Student Collection)
def train_user(name, roll_no):
    images = capture_training_images()
    encodings = []

    for img in images:
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        faces = detector(gray)

        if faces:
            shape = sp(gray, faces[0])
            encoding = facerec.compute_face_descriptor(gray, shape)
            encodings.append(np.array(encoding))

    if encodings:
        avg_encoding = np.mean(encodings, axis=0).tolist()  

        # Update student record with face encoding
        students_collection.update_one(
            {"roll_no": roll_no},
            {"$set": {"face_encoding": avg_encoding}},
            upsert=True
        )
        return {"message": f"User {name} trained successfully!"}, 200
    else:
        return {"message": "No face detected. Training failed."}, 400

# Cosine Similarity for Face Matching
def cosine_similarity(A, B):
    return np.dot(A, B) / (np.linalg.norm(A) * np.linalg.norm(B))

# Recognize User
def recognize_user():
    cap = cv2.VideoCapture(0)

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        faces = detector(gray)

        for face in faces:
            shape = sp(gray, face)
            test_encoding = np.array(facerec.compute_face_descriptor(gray, shape))

            students = students_collection.find({}, {"name": 1, "roll_no": 1, "face_encoding": 1})

            best_match_name = "Unknown"
            best_match_roll_no = None
            best_match_score = -1  

            for student in students:
                if "face_encoding" in student:
                    db_encoding = np.array(student["face_encoding"])
                    similarity = cosine_similarity(test_encoding, db_encoding)

                    if similarity > best_match_score:
                        best_match_score = similarity
                        best_match_name = student["name"]
                        best_match_roll_no = student["roll_no"]

            recognized_name = best_match_name if best_match_score > 0.75 else "Unknown"

            x, y, w, h = face.left(), face.top(), face.width(), face.height()
            cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)

            cv2.putText(frame, recognized_name, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

        cv2.imshow("Face Recognition", frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()
    return {"message": "Recognition process completed!"}, 200
