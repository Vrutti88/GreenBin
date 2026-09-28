# GreenBin — Smart Community Waste & Recycling Management

GreenBin is a responsive Flutter application designed to streamline community waste segregation, pickup scheduling, and recycling tracking across Mobile, Tablet, and Desktop platforms.

---

## 🚀 Firebase Setup Guide

Follow these steps to connect your Firebase project to GreenBin.

### Prerequisites

1. **Flutter SDK** (v3.13.0 or higher) installed and configured:
   ```bash
   flutter doctor
   ```
2. **Firebase CLI** installed:
   ```bash
   npm install -g firebase-tools
   ```
3. **FlutterFire CLI** installed:
   ```bash
   dart pub global activate flutterfire_cli
   ```

---

### Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** (or **Create a project**).
3. Name your project (e.g., `greenbin-app`).
4. (Optional) Enable or disable Google Analytics as desired.
5. Click **Create Project** and wait for provisioning to finish.

---

### Step 2: Enable Firebase Authentication

1. In your Firebase Console, navigate to **Build > Authentication** in the left sidebar.
2. Click **Get Started**.
3. Under the **Sign-in method** tab:
   - Select **Email/Password**.
   - Toggle **Enable** to ON (leave "Email link / passwordless" disabled).
   - Click **Save**.

---

### Step 3: Enable Cloud Firestore Database

1. In the Firebase Console, navigate to **Build > Firestore Database**.
2. Click **Create database**.
3. Choose your database location (select a multi-region or region closest to your users, e.g., `us-central1` or `asia-south1`).
4. Select **Start in production mode** (our security rules will manage access).
5. Click **Enable**.

---

### Step 4: Configure Platforms with FlutterFire CLI

From the root of the GreenBin repository, log in to Firebase and generate your project-specific configurations:

```bash
# 1. Log in to your Firebase account
firebase login

# 2. Configure FlutterFire (select Android, iOS, Web, macOS, Windows)
flutterfire configure
```

- When prompted, select your newly created Firebase project from the list.
- Select the platforms you want to support (Android, iOS, Web, macOS, Windows).
- FlutterFire will automatically generate/update [`lib/firebase_options.dart`](lib/firebase_options.dart) and register the native configuration files.

---

### Step 5: Deploy Firestore Security Rules & Indexes

GreenBin comes pre-configured with security rules in [`firestore.rules`](firestore.rules) and query indexes in [`firestore.indexes.json`](firestore.indexes.json).

Deploy them directly using the Firebase CLI:

```bash
# Ensure you are linked to your project
firebase use --add

# Deploy security rules and indexes
firebase deploy --only firestore:rules,firestore:indexes
```

---

### Step 6: Firestore Schema Reference

#### 1. `users/{userId}`
Stores user profiles and role permissions:
```json
{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "phone": "+1234567890",
  "community": "Maple Grove",
  "address": "123 Green St, Apt 4B",
  "role": "resident", // "resident" | "collector" | "admin"
  "createdAt": "Timestamp"
}
```

#### 2. `pickups/{pickupId}`
Stores pickup scheduling requests:
```json
{
  "userId": "firebase_auth_uid",
  "wasteCategory": "Plastic",
  "pickupDate": "Timestamp",
  "timeSlot": "09:00 AM - 11:00 AM",
  "address": "123 Green St, Apt 4B",
  "notes": "Recyclables placed in blue bin",
  "status": "Scheduled", // "Scheduled" | "Collected" | "Cancelled"
  "assignedTeam": null,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

#### 3. `notifications/{notificationId}`
Stores user-specific status updates and reminders:
```json
{
  "userId": "firebase_auth_uid",
  "title": "Pickup Scheduled",
  "message": "Your Plastic waste pickup is confirmed for tomorrow.",
  "timestamp": "Timestamp",
  "isRead": false,
  "type": "scheduled" // "scheduled" | "reminder" | "status"
}
```

---

### Step 7: Run the Application

Once your Firebase project is configured:

```bash
# Get dependencies
flutter pub get

# Run analyzer & test suite
flutter analyze
flutter test

# Run app on your target device / browser
flutter run -d chrome      # Web
flutter run -d macos       # macOS
flutter run                # Connected Android / iOS device
```

---

## 🛡️ Security Rules Summary

- **Self-Service Restriction:** Residents can only read and modify their own user document and pickup requests.
- **Collector Role Integrity:** Users cannot assign themselves `collector` or `admin` roles upon signup.
- **Status Validation:** Only collectors or admins can mark a pickup as `"Collected"`. Residents may only cancel a `"Scheduled"` pickup.
- **Safe Fallback:** The codebase includes graceful fallbacks so unit and widget tests run offline without requiring live Firebase credentials.
