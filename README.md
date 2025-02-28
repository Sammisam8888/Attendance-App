## Installation

1. Clone the repository.
    ```sh
    git clone https://github.com/Trishna2005Das/Attendance-App.git
    cd Attendance-App
    ```
2. Navigate to the `backend` directory and install the required Python packages:
    ```sh
    cd backend
    python3 -m venv env
    source ./env/bin/activate
    pip install -r requirements.txt
    ```
3. Navigate to the `frontend/attendance_app` directory and install the required Dart packages:
    ```sh
    cd ../frontend/attendance_app
    flutter pub get
    ```

## Running the Application

1. Start the backend server:
    ```sh
    cd backend
    source ./env/bin/activate
    python app.py
    ```
2. Start the frontend application:
    ```sh
    cd frontend/attendance_app
    flutter run
    ```

## Project Structure

```
Attendance-app/
│── backend/                     # Flask backend
│   ├── app.py                   # Main Flask app
│   ├── config.py                # Configuration settings (MongoDB, Heroku settings)
│   ├── requirements.txt         # Python dependencies
│   ├── routes/                  # API endpoints
│   │   ├── auth_routes.py       # Login/signup, face verification
│   │   ├── qr_routes.py         # QR generation & validation
│   │   ├── attendance_routes.py # Attendance marking logic
│   ├── models/                  # Database models
│   │   ├── user_model.py        # User (Teacher/Student) model
│   │   ├── attendance_model.py  # Attendance model
│   ├── utils/                   # Helper functions
│   │   ├── qr_generator.py      # QR code generation logic
│   │   ├── face_match.py        # Face matching logic
│   │   ├── token_validator.py   # Token/session validation
│   ├── templates/               # HTML files for testing API (optional)
│   ├── static/                  # Static files (if needed)
│   ├── tests/                   # Unit tests for backend
│   ├── .env                     # Environment variables (MongoDB URI, secret keys)
│   ├── Procfile                 # Heroku deployment config
│
│── frontend/                     # Flutter frontend
│   ├── lib/
│   │   ├── main.dart             # Entry point of the app
│   │   ├── screens/              # UI Screens
│   │   │   ├── login_screen.dart         # Login with face auth
│   │   │   ├── face_scan.dart            # Face scanning
│   │   │   ├── teacher_dashboard.dart    # Teacher dashboard
│   │   │   ├── student_scanner.dart      # QR scanner for students
│   │   │   ├── attendance_list.dart      # Attendance records
│   │   ├── widgets/              # Reusable UI components
│   │   │   ├── qr_scanner.dart    # QR scanning logic
│   │   │   ├── attendance_card.dart # Attendance display
│   │   │   ├── face_widget.dart    # Face UI component
│   │   ├── services/             # API Calls
│   │   │   ├── auth_service.dart  # Handles login & face auth
│   │   │   ├── qr_service.dart    # Handles QR generation & scanning
│   │   │   ├── attendance_service.dart # Attendance submission
│   │   ├── utils/                # Helper functions
│   │   │   ├── constants.dart     # App-wide constants
│   │   │   ├── themes.dart        # Styling and themes
│   │   ├── plugins/               # Third-party packages (like biometric auth)
│   │   │   ├── local_auth.dart     # Flutter's biometric authentication
│   ├── pubspec.yaml              # Flutter dependencies
│   ├── android/                  # Android-specific files
│   ├── ios/                      # iOS-specific files
│   ├── web/                      # Web-specific files
│   ├── build/                    # Build outputs
│   ├── test/                     # Unit tests for frontend
│
│── .gitignore                    # Ignore unnecessary files
│── README.md                      # Project documentation
│── LICENSE                        # Open-source license (optional)
│── docs/                          # Documentation files
│── devops/                        # CI/CD scripts, Dockerfile
│   ├── Dockerfile                 # Containerization
│   ├── heroku.yml                 # Heroku config (if needed)
│   ├── github-actions.yml         # GitHub Actions for CI/CD
```

## Face Scanner Integration

We plan to integrate a face scanner to verify students' identities. The raw face data will be stored and matched using the [face_match.py](https://github.com/Sammisam8888/face-scanner.git) utility. The process involves:

1. Capturing the face data from the scanner.
2. Storing the face data securely in the database.
3. Using the [face_match.py](https://github.com/Sammisam8888/face-scanner.git) utility to match the scanned face with the stored data during attendance verification.

## Real-Time QR Code Generator

We will implement a real-time QR code generator to conduct attendance. The QR code will be updated in real-time and displayed to students. The process involves:

1. Generating a unique QR code for each attendance session using the [qr_generator.py](http://_vscodecontentref_/4) utility.
2. Displaying the QR code on the frontend.
3. Students will scan the QR code using their devices.
4. The backend will verify the scanned QR code and update the attendance record.
5. The QR code will be refreshed periodically to ensure security.

## Biometric Verification

In addition to QR code scanning, we will use biometric verification to ensure the authenticity of the students. The process involves:

1. Capturing the student's face during the QR code scan.
2. Matching the face with the stored data using the https://github.com/Sammisam8888/face-scanner.git utility.
3. Verifying the student's identity and updating the attendance record.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License.