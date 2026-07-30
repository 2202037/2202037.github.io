# 🏥 Ayur Healthcare Mobile App

> **Enterprise-level, cross-platform healthcare ecosystem** — built with Flutter + PHP REST API + MySQL

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![PHP](https://img.shields.io/badge/PHP-8.1+-777BB4?logo=php)](https://php.net)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1?logo=mysql)](https://mysql.com)

---

## 📋 Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture](#2-architecture)
3. [Features](#3-features)
4. [Project Structure](#4-project-structure)
5. [Prerequisites](#5-prerequisites)
6. [Database Setup](#6-database-setup)
7. [Backend Setup (PHP API)](#7-backend-setup-php-api)
8. [Flutter App Setup](#8-flutter-app-setup)
9. [Running the Project](#9-running-the-project)
10. [API Reference](#10-api-reference)
11. [Environment Variables](#11-environment-variables)
12. [Deployment](#12-deployment)
13. [Testing](#13-testing)
14. [Troubleshooting](#14-troubleshooting)

---

## 1. Project Overview

**Ayur** is a production-ready, multi-role healthcare mobile application that connects patients, doctors, clinics, pharmacies, and administrators.

### Roles
| Role | Capabilities |
|------|-------------|
| **Patient** | Book appointments, buy medicine, request blood, view history |
| **Doctor** | Manage appointments, view patient records |
| **Clinic** | Register clinic, manage availability |
| **Pharmacy** | Manage products, process orders |
| **Admin** | Full system control, analytics |

### Tech Stack
| Layer | Technology |
|-------|-----------|
| **Mobile App** | Flutter 3+ (Android & iOS) |
| **State Management** | Riverpod 2 |
| **Backend API** | PHP 8.1+ (REST) |
| **Database** | MySQL 8.0+ |
| **Authentication** | JWT (HS256) |
| **Maps** | Google Maps + Geolocator |
| **Notifications** | Firebase Cloud Messaging |
| **Local Storage** | Flutter Secure Storage + Hive |

---

## 2. Architecture

```
┌─────────────────────────────────────┐
│         Flutter App (Client)         │
│  Clean Architecture + Riverpod       │
│  Screens → Providers → Services      │
└───────────────┬─────────────────────┘
                │ HTTPS / REST
┌───────────────▼─────────────────────┐
│         PHP REST API (Server)        │
│  JWT Auth → Business Logic → PDO     │
└───────────────┬─────────────────────┘
                │
┌───────────────▼─────────────────────┐
│         MySQL Database               │
│  14 tables, triggers, indexes        │
└─────────────────────────────────────┘
```

---

## 3. Features

- 🔐 **Authentication** — JWT login/register, secure token storage, role-based access
- 🏠 **Dashboard** — Personalized greeting, health tips, quick actions, appointments
- 👨‍⚕️ **Doctor Directory** — Search, specialty filter, ratings, fees, location-based
- 📅 **Appointment Booking** — Calendar picker, time slots, booking management
- 🩸 **Blood Bank** — Real-time inventory, color-coded availability, emergency SOS
- 💊 **Pharmacy** — Product catalog, cart, order management
- 📍 **Location** — Nearby clinics, Google Maps, GPS-based distance
- 🔔 **Push Notifications** — Firebase Cloud Messaging, appointment reminders
- 👤 **Profile** — View/edit profile, history, secure logout

---

## 4. Project Structure

```
2202037.github.io/
├── 📄 README.md
├── 📁 database/
│   └── ayur_db.sql              # Complete MySQL schema + seed data
│
├── �� backend/                  # PHP REST API
│   ├── 📁 config/
│   │   ├── database.php
│   │   ├── cors.php
│   │   └── response.php
│   ├── 📁 helpers/
│   │   ├── jwt.php
│   │   └── validator.php
│   └── 📁 api/v1/
│       ├── auth/       (login, register, profile)
│       ├── directory/  (doctors, clinics)
│       ├── appointments/ (book, my, cancel)
│       ├── blood_bank/ (inventory, request)
│       ├── pharmacy/   (products, cart)
│       └── notifications/ (fcm)
│
└── 📁 ayur_app/                 # Flutter Mobile App
    ├── pubspec.yaml
    └── 📁 lib/
        ├── main.dart
        ├── app.dart
        ├── core/       (constants, theme, router, utils)
        ├── models/     (user, doctor, clinic, appointment, etc.)
        ├── services/   (api, auth, storage, notifications)
        ├── providers/  (Riverpod state providers)
        ├── features/   (splash, auth, home, directory, appointments,
        │               blood_bank, pharmacy, profile)
        └── shared/widgets/ (reusable UI components)
```

---

## 5. Prerequisites

| Software | Version | Download |
|----------|---------|----------|
| **Flutter** | 3.16+ | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| **XAMPP** | 8.1+ | [apachefriends.org](https://www.apachefriends.org) |
| **Android Studio** | Latest | [developer.android.com](https://developer.android.com/studio) |
| **VS Code** | Latest | [code.visualstudio.com](https://code.visualstudio.com) |

---

## 6. Database Setup

### Step 1: Start XAMPP
1. Open **XAMPP Control Panel**
2. Start **Apache** ✅
3. Start **MySQL** ✅

### Step 2: Open phpMyAdmin
Navigate to: **http://localhost/phpmyadmin**

### Step 3: Create Database
Click **SQL** tab and run:
```sql
CREATE DATABASE ayur_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;
```

### Step 4: Import Schema

**Option A — phpMyAdmin GUI:**
1. Click `ayur_db` in the left sidebar
2. Click **Import** tab
3. Click **Choose File** → select `database/ayur_db.sql`
4. Click **Go**

**Option B — Command Line:**
```bash
mysql -u root -p ayur_db < database/ayur_db.sql
```

### Step 5: Verify

You should see **14 tables**: users, doctors, clinics, appointments, blood_inventory, blood_requests, pharmacy_products, cart, orders, order_items, payments, notifications, device_tokens, audit_logs

### Seed Data Included
- 🧑‍⚕️ **3 sample doctors** (Cardiologist, Dermatologist, General Physician)
- 🏥 **2 sample clinics**
- 🩸 **Blood inventory** for all 8 blood groups
- 💊 **5 pharmacy products**
- 👤 **Admin**: `admin@ayur.com` / `Admin@123`

---

## 7. Backend Setup (PHP API)

### Step 1: Copy Backend Files to XAMPP

**Windows:**
```
Copy backend/ folder to: C:\xampp\htdocs\ayur\backend\
```

**Mac/Linux:**
```bash
cp -r backend/ /Applications/XAMPP/htdocs/ayur/backend/
# OR create symlink:
ln -s $(pwd)/backend /Applications/XAMPP/htdocs/ayur/backend
```

### Step 2: Configure JWT Secret

Edit `backend/helpers/jwt.php` and set a strong secret key, OR set environment variable:
```
JWT_SECRET=your-super-secret-key-minimum-32-chars
```

### Step 3: Test the API

Open in browser:
```
http://localhost/ayur/backend/api/v1/blood_bank/inventory.php
```

Expected:
```json
{"status":"success","data":[{"blood_group":"A+","quantity":25,"availability":"Available"},...]}'
```

### Step 4: Test Login
```bash
curl -X POST http://localhost/ayur/backend/api/v1/auth/login.php \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@ayur.com","password":"Admin@123"}'
```

---

## 8. Flutter App Setup

### Step 1: Navigate to App Directory
```bash
cd ayur_app
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Configure API URL

Edit `lib/core/constants/api_constants.dart`:

```dart
// Android Emulator (connects to host machine localhost)
static const String baseUrl = 'http://10.0.2.2/ayur/backend/api/v1';

// Physical Android Device (use your computer's local IP)
// static const String baseUrl = 'http://192.168.1.xxx/ayur/backend/api/v1';

// iOS Simulator
// static const String baseUrl = 'http://localhost/ayur/backend/api/v1';
```

### Step 4: Create Asset Directories
```bash
mkdir -p assets/images assets/animations assets/icons assets/fonts
```

### Step 5: Firebase Setup (Optional — for Push Notifications)
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create project "AyurApp"
3. Add Android app with package: `com.ayur.app`
4. Download `google-services.json` → place in `android/app/`

### Step 6: Google Maps Setup (Optional)
1. Get API key from [Google Cloud Console](https://console.cloud.google.com)
2. Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

---

## 9. Running the Project

### Start Android Emulator
1. Open **Android Studio** → **Device Manager**
2. Click **▶ Play** on your emulator (Pixel 6 API 34 recommended)

### Run Flutter App
```bash
cd ayur_app
flutter run
```

### First Login
- Email: `admin@ayur.com`
- Password: `Admin@123`

---

## 10. API Reference

### Authentication
| Method | Endpoint | Auth |
|--------|----------|------|
| POST | `/auth/login.php` | ❌ |
| POST | `/auth/register.php` | ❌ |
| GET/PUT | `/auth/profile.php` | ✅ JWT |

### Directory
| Method | Endpoint | Query Params |
|--------|----------|-------------|
| GET | `/directory/doctors.php` | specialty, search, page, limit |
| GET | `/directory/clinics.php` | lat, lng, search, page, limit |

### Appointments
| Method | Endpoint | Auth |
|--------|----------|------|
| POST | `/appointments/book.php` | ✅ |
| GET | `/appointments/my.php` | ✅ |
| POST | `/appointments/cancel.php` | ✅ |

### Blood Bank
| Method | Endpoint | Auth |
|--------|----------|------|
| GET | `/blood_bank/inventory.php` | ❌ |
| POST | `/blood_bank/request.php` | ✅ |

### Pharmacy
| Method | Endpoint | Auth |
|--------|----------|------|
| GET | `/pharmacy/products.php` | ❌ |
| GET/POST/DELETE | `/pharmacy/cart.php` | ✅ |

**Standard Response Format:**
```json
{
  "status": "success",
  "message": "...",
  "data": { ... }
}
```

**Request Auth Header:**
```
Authorization: Bearer <JWT_TOKEN>
```

---

## 11. Environment Variables

Create `backend/.env`:
```env
DB_HOST=localhost
DB_NAME=ayur_db
DB_USER=root
DB_PASSWORD=

JWT_SECRET=change-this-to-a-random-64-char-secret-in-production
APP_ENV=development
FCM_SERVER_KEY=your-firebase-server-key
```

---

## 12. Deployment

### Backend to VPS
```bash
# Upload files
scp -r backend/ user@your-server:/var/www/html/ayur/

# Enable HTTPS (Let's Encrypt)
sudo certbot --apache -d api.yourdomain.com

# Set environment variables
export JWT_SECRET="your-production-secret"
export APP_ENV="production"
```

### Build Flutter APK
```bash
cd ayur_app
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# For Play Store (App Bundle)
flutter build appbundle --release
```

### Update Production URL
```dart
// lib/core/constants/api_constants.dart
static const String baseUrl = 'https://api.yourdomain.com/api/v1';
```

---

## 13. Testing

### Backend (curl)
```bash
# Public endpoint
curl http://localhost/ayur/backend/api/v1/blood_bank/inventory.php

# Login
curl -X POST http://localhost/ayur/backend/api/v1/auth/login.php \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@ayur.com","password":"Admin@123"}'
```

### Flutter Tests
```bash
cd ayur_app
flutter test
```

---

## 14. Troubleshooting

| Problem | Solution |
|---------|----------|
| Network Error in app | Use `10.0.2.2` for emulator, local IP for physical device |
| CORS Error | Ensure `cors.php` included in each API endpoint |
| 401 Unauthorized | Token expired — login again; check JWT_SECRET matches |
| Table doesn't exist | Re-import `database/ayur_db.sql` |
| `pub get` fails | Run `flutter pub cache clean && flutter pub get` |
| Google Maps blank | Add valid Maps API key to AndroidManifest.xml |
| Emulator slow | Enable Intel HAXM, use x86_64 image, allocate 4GB+ RAM |

---

## 🔒 Security Notes

- **Never commit** `.env` files or `google-services.json`
- **Change JWT_SECRET** before production
- **Use HTTPS** only in production
- Passwords use **bcrypt** (cost 12)

---

## 🗓️ Development Roadmap

- [x] Phase 1: Database schema + PHP REST API
- [x] Phase 2: Flutter app (Clean Architecture + Riverpod)
- [x] Phase 3: API integration (Dio + interceptors)
- [x] Phase 4: Core features (appointments, blood bank, pharmacy)
- [ ] Phase 5: Payment gateway integration
- [ ] Phase 6: Admin web dashboard
- [ ] Phase 7: CI/CD pipeline
- [ ] Phase 8: Play Store / App Store deployment

---

<div align="center">
  <strong>Built with ❤️ for better healthcare</strong><br>
  <em>Ayur — Connecting patients with the care they need</em><br><br>
  <a href="https://ayurbd.me">ayurbd.me</a>
</div>
