# GreenBin — Community Recycling Pickup Scheduler App

An eco-friendly, responsive cross-platform Flutter application designed to empower communities to schedule recyclable waste pickups, educate residents on proper waste segregation, and track collection statuses in real time using Cloud Firestore.

---

## 🌐 Live Web Deployment & Android APK

| Platform | Deployment / Download | Status |
| :--- | :--- | :--- |
| **Web App (Live)** | [https://greenbin-41080.web.app](https://greenbin-41080.web.app) | 🟢 Live (Firebase Hosting) |
| **Alternative Web Link** | [https://greenbin-41080.firebaseapp.com](https://greenbin-41080.firebaseapp.com) | 🟢 Live (CDN Edge) |
| **Android APK** | [`greenbin-release.apk`](greenbin-release.apk) | 🟢 Built (Android 15 / SDK 35 Ready) |
| **Firebase Project** | `greenbin-41080` | 🟢 Auth + Cloud Firestore Active |

---

## 📌 Problem Statement

> **"GreenBin wants an app where a resident schedules a recyclable-waste pickup by selecting waste type and preferred date/time, and the request is stored centrally so the community's collection team can view and manage it."**

### Problem Justification
Urban and suburban communities face significant waste mismanagement challenges due to irregular collection schedules, lack of resident awareness regarding recyclable segregation, and the absence of centralized logistics. Traditional recycling methods rely heavily on roadside dumps or informal collectors, leading to contaminated recyclable batches and low recycling yields. 

**GreenBin bridges this gap by providing:**
1. **Resident Empowerment**: Easy, structured scheduling with category-specific instructions (Paper, Plastic, Glass, Metal, Electronics, Organic) to eliminate contamination at the source.
2. **Transparent Lifecycle Tracking**: Real-time status visibility (`Scheduled` → `Collected`) so residents know exactly when their recyclables are collected.
3. **Centralized Cloud Backend**: Centralized Cloud Firestore storage allowing community collection teams to plan optimal pickup routes, balance daily collection loads, and verify collections with zero paperwork.

---

## 🎯 Objectives

* **UI / Widgets**: Build **Schedule Pickup**, **My Pickups**, and **Waste Category Guide** screens using standard Flutter `Form`, `ListView`, and `Card` widgets.
* **Styling & Theming**: Apply an eco-friendly **Material 3** theme with vibrant recycling-category color coding (Emerald greens, ocean blues, amber, slate, and clean neutrals).
* **Dart Logic**: Implement type-safe **Named Routes with Arguments** to pass the selected waste category from the Category Guide directly into the Schedule form.
* **Figma & UX**: Design a clean, guided flow covering every screen with step indicators, progress cues, and intuitive touch feedback.
* **Pickup Entry Details**: Display waste category badge, scheduled date, time slot, and real-time pickup status (`Scheduled` or `Collected`) on every entry in **My Pickups**.

---

## ✨ Outcomes

* **Form Validation**: The Schedule Pickup form strictly validates waste category selection, pickup address, date selection, and time slot before submission.
* **Centralized Firestore Storage**: Submitted pickup requests are created directly in Cloud Firestore with an initial status of `Scheduled`.
* **Real-Time Status Reflection**: The My Pickups screen reflects live status changes (`Scheduled` / `Collected`) fetched directly from Firestore snapshots.
* **Guided Routing**: The Waste Category Guide screen navigates to a pre-filled Schedule form via route arguments, reducing user data-entry effort.

---

## 📦 Deliverables

| Deliverable | Description & Implementation |
| :--- | :--- |
| **Figma Design** | End-to-end design prototype covering onboarding, waste category education, schedule form with progress steps, and pickup-tracking list. |
| **UI / Widgets** | Modular Flutter widget architecture: `SchedulePickupScreen` (`Form`, validation, date/time pickers), `CategoryGuideScreen` (`Card`, grid layout), and `PickupsListScreen` (`ListView.separated`, status badges). |
| **Styling / Theming** | Eco-friendly Material 3 theme (`AppTheme`) with category color palettes, dark-mode support, dynamic card elevation, and smooth micro-animations. |
| **Dart Logic** | Named routing system (`AppRoutes`) passing `SchedulePickupArguments` across screens with null-safe form validation logic. |
| **Firestore Integration** | Production Cloud Firestore service (`FirestoreService`) managing pickups collection, user profiles, and role-based permissions (`firestore.rules`). |
| **Responsive Prototype** | Fluid responsiveness across Mobile, Tablet, and Desktop/Web breakpoints (`ResponsiveLayout`). |

---

## 🏗️ Architecture & Key Screens

```
lib/
├── main.dart                       # App entry point, Firebase init & multi-provider setup
├── firebase_options.dart           # FlutterFire generated config
├── theme/
│   └── app_theme.dart              # Material 3 eco-friendly color scheme & typography
├── routes/
│   └── app_routes.dart             # Named routes & argument parsing
├── models/
│   ├── pickup_model.dart           # Pickup request data model with JSON/Firestore converters
│   ├── category_model.dart         # Waste categories metadata (Paper, Plastic, Metal, etc.)
│   ├── user_model.dart             # Resident & Collector profile model
│   └── notification_model.dart     # System notification model
├── services/
│   ├── auth_service.dart           # Firebase Authentication (Email/Password, state stream)
│   └── firestore_service.dart      # Cloud Firestore CRUD & real-time snapshot streams
├── screens/
│   ├── auth/                       # Login & Registration screens
│   ├── home/                       # Dashboard with quick actions & recycling stats
│   ├── schedule/                   # Guided pickup scheduling form & confirmation
│   ├── pickups/                    # My Pickups real-time list & pickup detail screen
│   ├── guide/                      # Waste Category Guide with recyclable rules
│   └── profile/                    # User profile, address, and community settings
└── widgets/                        # Reusable UI components (PickupCard, CategoryCard, etc.)
```

---

## 🔒 Cloud Firestore Data Schema

### 1. `pickups/{pickupId}`
```json
{
  "id": "auto_generated_doc_id",
  "userId": "firebase_auth_uid",
  "userName": "Jane Doe",
  "wasteCategory": "Plastic",
  "pickupDate": "Timestamp",
  "timeSlot": "09:00 AM - 11:00 AM",
  "address": "123 Eco Green Way, Apt 4B",
  "notes": "Recyclables placed in marked blue bin outside door",
  "status": "Scheduled",
  "assignedTeam": null,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### 2. `users/{userId}`
```json
{
  "id": "firebase_auth_uid",
  "name": "Jane Doe",
  "email": "jane@greenbin.org",
  "phone": "+1-555-0199",
  "community": "Maple Grove Eco Community",
  "address": "123 Eco Green Way, Apt 4B",
  "role": "resident",
  "createdAt": "Timestamp"
}
```

---

## 🛡️ Security Rules Summary (`firestore.rules`)

* **Resident Self-Service**: Residents can create new `Scheduled` pickup requests and view/cancel their own pickups.
* **Collector Privilege**: Only authenticated users with the `collector` or `admin` role can update a pickup status to `Collected`.
* **Zero Privilege Escalation**: Users cannot modify their own `role` field upon signup.

---

## 🚀 Getting Started Locally

### Prerequisites
* Flutter SDK (`>= 3.13.0`)
* Dart SDK (`>= 3.1.0`)
* Firebase CLI (`firebase-tools`)

### Setup & Run
```bash
# 1. Clone repository
git clone https://github.com/Vrutti88/GreenBin.git
cd GreenBin

# 2. Install dependencies
flutter pub get

# 3. Run analyzer and unit tests
flutter analyze
flutter test

# 4. Run on Web
flutter run -d chrome

# 5. Run on Android
flutter run -d android
```

### Build for Production
```bash
# Build Web release
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting

# Build Android release APK
flutter build apk --release
```

---

## 📄 License
This project is licensed under the MIT License — see the LICENSE file for details.
