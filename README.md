# DET Application Frontend

## Requirements
- Flutter SDK
- Dart SDK
- Android Studio หรือ VS Code
- Emulator หรือโทรศัพท์ Android/iOS

## Installation
1. ติดตั้ง Flutter และ Dart SDK จาก [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)
2. รันคำสั่ง:
   ```bash
   flutter pub get
   ```

## Running the Application
1. ใช้คำสั่งนี้เพื่อรันแอปพลิเคชัน:
   ```bash
   flutter run
   ```

## Build Application
- สร้างไฟล์ APK (Android):
  ```bash
  flutter build apk
  ```
- สร้างไฟล์ IPA (iOS):
  ```bash
  flutter build ios
  ```

## Project Structure
```
lib/
├── common_widgets/               # วิดเจ็ตที่ใช้ซ้ำได้
├── features/
│   ├── auth/                     # การจัดการ Authentication
│   │   ├── models/               # โมเดลสำหรับ auth
│   │   ├── providers/            # State management ของ auth
│   │   │   └── auth_provider.dart
│   │   ├── screens/              # หน้าจอที่เกี่ยวข้องกับ auth
│   │   │   ├── forgot_password_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── root_screen.dart
│   │   └── widgets/              # วิดเจ็ตย่อยของ auth
│   ├── home/                     # ส่วน Home ของแอป
│       ├── screens/              # หน้าจอของ Home
│       │   ├── add_post_screen.dart
│       │   ├── home_content_screen.dart
│       │   ├── home_screen.dart
│       │   ├── notifications_screen.dart
│       │   ├── profile_screen.dart
│       │   └── search_screen.dart
│       └── widgets/              # วิดเจ็ตย่อยของ Home
│           └── user_profile_screen.dart
├── routes/                       # การจัดการเส้นทางของแอป
├── services/                     # การเชื่อมต่อ API
│   ├── auth_service.dart         # จัดการ API สำหรับ Auth
│   ├── post_service.dart         # จัดการ API สำหรับโพสต์
│   ├── test.dart                 # สำหรับการทดสอบ
│   └── user.dart                 # จัดการ API สำหรับผู้ใช้
└── main.dart                     # Entry point ของแอป
```

## Features
- **Authentication**
    - Login, Register, และ Forgot Password
- **Home**
    - เพิ่มโพสต์, ดูโพสต์, การแจ้งเตือน และค้นหา
- **User Profile**
    - ดูโปรไฟล์และแก้ไขข้อมูลผู้ใช้

## API Services
- **AuthService**
    - การจัดการ Authentication API
- **PostService**
    - การสร้างและดึงโพสต์
- **User**
    - การดึงข้อมูลผู้ใช้

## Contributing
1. Fork โครงการนี้
2. สร้าง Branch ใหม่ (`git checkout -b feature/your-feature`)
3. Commit การเปลี่ยนแปลง (`git commit -m "เพิ่มฟีเจอร์ใหม่"`)
4. Push Branch (`git push origin feature/your-feature`)
5. สร้าง Pull Request

---
