# 🛡️ CyberSafe

### Cyber Crime Complaint & Awareness Management System

CyberSafe is a Flutter-based mobile and web application designed to improve cyber-crime awareness, provide a secure complaint submission system, allow users to track complaint status, and help administrators manage complaints through analytics and dashboards.

---

## 📌 Project Overview

CyberSafe provides a centralized platform where users can:

* Learn about cyber safety and common cyber threats
* Read awareness articles and safety tips
* Take an interactive cyber-safety quiz
* Submit cyber-crime complaints
* Upload complaint evidence
* Track complaint status
* Receive complaint-related notifications
* Get general cyber-safety guidance through an AI assistant

Administrators can:

* Manage user complaints
* Review complaint details and evidence
* Update complaint status
* Monitor complaint activity
* View complaint analytics
* View quiz analytics
* Manage administrative activities

---

## 🎯 Problem Statement

Cyber-crime awareness is still limited among many users, while reporting and tracking cyber-crime complaints can be difficult when information is scattered across different platforms.

CyberSafe addresses this problem by providing a centralized system for:

* Cyber-safety education
* Complaint submission
* Complaint status tracking
* Administrative complaint management
* Cyber-safety assessment
* Analytics and reporting

---

## 🎯 Objectives

The main objectives of CyberSafe are:

1. Increase awareness about cyber-crime.
2. Educate users about safe online practices.
3. Provide an easy complaint submission process.
4. Allow users to track complaint status.
5. Provide an interactive cyber-safety quiz.
6. Help administrators manage complaints efficiently.
7. Provide complaint analytics.
8. Provide quiz performance analytics.
9. Improve the overall cyber-safety learning experience.
10. Provide a structured platform for future integration with official cyber-crime reporting authorities.

---

## ✨ Key Features

### 👤 User Module

* User Registration
* User Login
* Forgot Password
* User Profile
* Cyber Safety Awareness
* Awareness Articles
* Safety Tips
* Cyber Safety Quiz
* Quiz Results
* Complaint Submission
* Complaint Review
* Evidence Management
* Complaint Status Tracking
* My Complaints
* Notifications
* AI Cyber-Safety Assistant
* Multi-language Support
* Application Settings

---

### 📝 Complaint Management

Users can submit complaints by providing information such as:

* Complaint title
* Category
* Incident date
* Platform
* Location
* Suspect information
* Description
* Evidence information

Before submission, the user can review the complaint details.

After submission, the system generates a complaint ID and stores the complaint information in Firebase.

---

### 📊 Complaint Status Tracking

Complaints can move through different stages:

```text
Submitted
     ↓
Under Review
     ↓
In Progress
     ↓
Resolved
     ↓
Closed
```

Users can monitor the current status of their submitted complaints.

---

### 🧠 Cyber Safety Quiz

CyberSafe includes an interactive cyber-safety quiz containing multiple-choice questions.

Features include:

* Multiple-choice questions
* Next/Previous navigation
* Progress indicator
* Quiz submission
* Score calculation
* Correct answers
* Wrong answers
* Try Again option
* Quiz result tracking

---

### 📈 Quiz Analytics

Administrators can view quiz-related statistics including:

* Total Attempts
* Completed Quizzes
* Average Score
* Completion Rate
* Highest Score
* Lowest Score
* Topic-wise performance
* Correct answers
* Wrong answers
* Topic accuracy

---

### 📊 Complaint Analytics

Administrators can analyze complaint activity through:

* Total complaints
* Pending complaints
* Under-review complaints
* In-progress complaints
* Resolved complaints
* Closed complaints
* Weekly complaint trends
* Complaint category analysis
* Complaint status distribution

---

### 👨‍💼 Admin Module

The administrator panel provides:

* Admin Login
* Admin Dashboard
* Complaint Management
* Complaint Details
* Complaint Status Updates
* Complaint Analytics
* Quiz Analytics
* Reports
* Notifications
* Admin Profile
* Admin Settings
* Administrative Activity Monitoring

---

### 🤖 AI Cyber-Safety Assistant

CyberSafe includes an AI assistant designed for cyber-safety education.

It can provide general guidance about:

* Phishing
* Online scams
* Account security
* Privacy
* Fake accounts
* Online fraud
* Cyber harassment
* Safe digital practices
* Cyber-crime reporting

The assistant is designed to avoid providing instructions for unauthorized access, credential theft, malware creation, or bypassing security controls.

---

## 🔥 Firebase Integration

CyberSafe uses Firebase services for backend functionality.

Firebase is used for:

* Authentication
* Cloud Firestore
* Application data storage
* Complaint management
* Quiz result storage
* Notifications
* Web hosting

### Main Data Collections

Examples of application data include:

```text
users
complaints
notifications
quiz_results
```

---

## 🔄 System Workflow

### User Workflow

```text
Open CyberSafe
      ↓
Login / Signup
      ↓
User Dashboard
      ↓
 ┌───────────────┬───────────────┬───────────────┐
 ↓               ↓               ↓
Awareness       Quiz          Complaints
 ↓               ↓               ↓
Articles      Quiz Result    Submit Complaint
                                ↓
                           Complaint Review
                                ↓
                           Submit Complaint
                                ↓
                         Complaint Tracking
```

### Admin Workflow

```text
Admin Login
     ↓
Admin Dashboard
     ↓
Complaint Management
     ↓
Review Complaint
     ↓
Update Status
     ↓
User Notification
     ↓
Analytics & Reports
```

---

## 🏗️ Technology Stack

### Frontend

* Flutter
* Dart
* Material Design
* Material 3
* Responsive UI

### Backend / Cloud

* Firebase Authentication
* Cloud Firestore
* Firebase Hosting

### AI

* OpenRouter API
* AI Cyber-Safety Assistant

### Development Tools

* Android Studio
* Visual Studio Code
* Git
* GitHub
* Firebase CLI

---

## 📁 Project Structure

```text
lib/
│
├── animations/
│
├── core/
│   ├── config/
│   ├── constants/
│   ├── theme/
│   └── utils/
│
├── data/
│
├── localization/
│
├── models/
│
├── routes/
│
├── screens/
│   ├── admin/
│   ├── ai_chat/
│   ├── awareness/
│   ├── home/
│   ├── notification/
│   ├── profile/
│   ├── safety/
│   ├── settings/
│   └── users/
│
├── services/
│
├── widgets/
│
├── app.dart
└── main.dart
```

---

## 🔐 Security & Validation

CyberSafe includes validation and safety mechanisms such as:

* Input validation
* Email validation
* Pakistani phone-number validation
* Required-field validation
* Complaint description validation
* Incident-date validation
* Sensitive-data warnings
* AI safety restrictions
* Firebase authentication
* Restricted administrative functionality

The application is designed to discourage users from sharing:

* Passwords
* OTPs
* Verification codes
* CVV
* Card numbers
* Authentication tokens
* Private keys

---

## 🌐 Web Deployment

The CyberSafe web version is deployed using Firebase Hosting.



---

## 📱 Android Application

The Android application can be built using Flutter.

### Build APK

```bash
flutter build apk --release
```

Generated APK location:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## ⚙️ Installation

### 1. Clone the repository

```bash
git clone https://github.com/AALIYA-stack/CyberSafe.git
```

### 2. Open the project

```bash
cd CyberSafe
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the application

```bash
flutter run
```

### 5. Build Android APK

```bash
flutter build apk --release
```

### 6. Build Web

```bash
flutter build web --release
```

---

## 🖥️ Web Deployment

Firebase Hosting can be deployed using:

```bash
flutter build web --release
firebase deploy --only hosting
```

---

## 📸 Screenshots

Screenshots can be added here to demonstrate:

* Splash Screen
* Login Screen
* User Dashboard
* Awareness Articles
* Cyber Safety Quiz
* Quiz Results
* Complaint Form
* Complaint Status
* Notifications
* Admin Dashboard
* Complaint Analytics
* Quiz Analytics

Example:

```text
screenshots/
├── login.png
├── user-dashboard.png
├── awareness.png
├── quiz.png
├── complaint.png
├── complaint-status.png
├── admin-dashboard.png
├── complaint-analytics.png
└── quiz-analytics.png
```

---

## 🚀 Future Enhancements

Possible future improvements include:

* Integration with official cyber-crime reporting authorities
* Advanced AI-based cyber-threat detection
* Improved multilingual support
* Advanced notification system
* Stronger role-based access control
* More detailed analytics
* Automated complaint classification
* Enhanced evidence management
* Advanced security mechanisms
* Cloud-based administrative reporting

---

## 👩‍💻 Project Purpose

CyberSafe was developed as an academic software project to demonstrate practical implementation of:

* Flutter application development
* Firebase integration
* Authentication
* Cloud database management
* Complaint management
* Analytics
* AI integration
* Cyber-safety awareness
* Responsive application design

---

## 📄 License

This project is developed for educational and academic purposes.
