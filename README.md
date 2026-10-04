# GreenBin — Community Recycling Pickup Scheduler App

An eco-friendly, responsive cross-platform Flutter application designed to empower communities to schedule recyclable waste pickups, educate residents on proper waste segregation, and track collection statuses in real time using Cloud Firestore.

---

## 🌐 Live Web Deployment & Android APK

| Target | Distribution Channel | Link / Path | Status |
| :--- | :--- | :--- | :--- |
| **Web App (Live)** | Firebase Hosting (Global CDN) | [**https://greenbin-41080.web.app**](https://greenbin-41080.web.app) | 🟢 Live & Active |
| **Alternative Web Link** | Firebase App Edge | [**https://greenbin-41080.firebaseapp.com**](https://greenbin-41080.firebaseapp.com) | 🟢 Live |
| **Android Release APK** | Standalone Release Package | [`greenbin-release.apk`](greenbin-release.apk) | 🟢 Built (Android 15 / SDK 35) |
| **Firebase Project** | Google Cloud / Firebase | `greenbin-41080` | 🟢 Auth + Cloud Firestore Active |

---

## 📌 Problem Statement

> **"GreenBin wants an app where a resident schedules a recyclable-waste pickup by selecting waste type and preferred date/time, and the request is stored centrally so the community's collection team can view and manage it."**

### Proper Justification
Urban and suburban communities face mounting environmental and logistical challenges in handling municipal solid waste. In traditional municipal setups:
1. **Inefficient Segregation at Source**: Residents lack clear, localized guidelines on what materials are recyclable, resulting in contaminated batches ending up in landfills.
2. **Unpredictable Collection Logistics**: Without a centralized scheduling mechanism, municipal collection trucks drive arbitrary routes, wasting fuel, time, and human resources.
3. **Lack of Resident Feedback**: Once waste is disposed of, residents receive no confirmation or visibility regarding whether it was recycled or discarded, discouraging long-term civic participation.

**How GreenBin Solves This:**
* **Educational Waste Guide**: Categorizes recyclables (Paper, Plastic, Glass, Metal, Electronics, Organic) with explicit *Allowed* vs. *Not Allowed* guidelines, directly launching pre-filled pickup requests.
* **Centralized Cloud Scheduling**: Consolidates community pickup requests in Cloud Firestore with deterministic state lifecycles (`Scheduled` → `Collected`).
* **Real-Time Accountability**: Real-time snapshot streams update residents instantly when their waste has been collected by the authorized community collection team.

---

## 🎯 Objectives

* **UI / Widgets**: Build **Schedule Pickup**, **My Pickups**, and **Waste Category Guide** screens using standard Flutter `Form`, `ListView`, and `Card` widgets.
* **Styling & Theming**: Apply an eco-friendly **Material 3** theme with vibrant recycling-category color coding (Emerald greens, ocean blues, warm ambers, slates, and clean neutrals).
* **Dart Logic**: Implement type-safe **Named Routes with Arguments** (`AppRoutes`) to pass the selected waste category from the Guide directly into the Schedule form.
* **Figma & UX**: Design a clean, guided flow covering every screen listed above with step progress cues, intuitive touch targets, and responsive adaptations.
* **Pickup Entry Details**: Show waste category, scheduled date/time, pickup address, and real-time pickup status (`Scheduled` or `Collected`) on every **My Pickups** card.

---

## ✨ Outcomes

* **Strict Form Validation**: The Schedule Pickup form strictly validates waste category selection, address fields, date pickers (preventing past dates), and time slots before submission.
* **Deterministic Firestore Storage**: Submitted pickup requests are created directly in Cloud Firestore with an initial status of `Scheduled`.
* **Live Status Synchronization**: The My Pickups screen reflects live status changes (`Scheduled` / `Collected` / `Cancelled`) streamed directly from Firestore document snapshots without artificial client-side auto-advancements.
* **Seamless Guided Routing**: The Waste Category Guide navigates to a pre-filled Schedule form via route arguments, eliminating duplicate user input.

---

## 📦 Deliverables

| Deliverable | Requirement | Implementation in GreenBin |
| :--- | :--- | :--- |
| **Figma Design** | Category guide through pickup-tracking flow | Complete design system with atomic components, multi-step scheduling forms, and tracking feeds. |
| **UI / Widgets** | Schedule form, category guide, and pickup list | `SchedulePickupScreen` (`Form`), `WasteGuideScreen` (`Card` grid), and `MyPickupsScreen` (`ListView.separated`). |
| **Styling / Theming** | Eco-friendly Material 3 theme | `AppTheme` with custom color palette (`AppColors`), typography (`AppTextStyles`), dark mode, and category tags. |
| **Dart Logic** | Named routes with arguments & validation | `AppRoutes.onGenerateRoute` handling `SchedulePickupArguments`, `PickupModel`, and custom `Validators`. |
| **Firestore Integration**| Storing & tracking pickup request status | `FirestoreService` managing real-time collections, user profiles, and role-based security rules. |
| **Responsive Prototype** | Working schedule-to-track recycling journey | Fully responsive across Mobile (Bottom Nav), Tablet (Nav Rail), and Desktop/Web (Nav Drawer). |

---

## 📱 Complete Screen Catalog (21 Screens)

| Screen | Route | Description |
| :--- | :--- | :--- |
| **Splash Screen** | `/` | Initializing app environment, verifying Firebase Auth session. |
| **Onboarding Screen** | `/onboarding` | 3-step carousel introducing recycling goals and app features. |
| **Login Screen** | `/login` | Email/password authentication with validation and error feedback. |
| **Register Screen** | `/register` | New resident registration with community selection. |
| **Forgot Password** | `/forgot-password` | Firebase password reset email dispatch. |
| **Profile Setup** | `/profile-setup` | Initial address and default contact details configuration. |
| **Home Dashboard** | `/home` | Dynamic waste metrics, upcoming pickup banner, quick action tiles. |
| **Waste Category Guide** | `/guide` | Interactive grid of all 6 recyclable waste streams. |
| **Category Details** | `/category-details` | Detailed prep instructions, allowed/unallowed items, "Schedule Pickup" CTA. |
| **Schedule Pickup** | `/schedule` | 4-step form: Category selection, Date picker, Time slot, Address & Notes. |
| **Review Pickup** | `/review-pickup` | Final summary review before Firestore commit. |
| **Pickup Confirmation** | `/pickup-confirmation`| Success animation, generated tracking ID (`GB-XXXXX`), status badge. |
| **My Pickups** | `/pickups` | Filterable tabs (`All`, `Scheduled`, `Collected`, `Cancelled`) with live stream. |
| **Pickup Details** | `/pickup-details` | Real-time tracking screen, collection notes, cancellation trigger. |
| **Notifications Screen** | `/notifications` | Activity log, unread alerts, pickup reminders. |
| **Profile Screen** | `/profile` | Resident statistics, eco-impact points, community badge. |
| **Edit Profile** | `/edit-profile` | Live user profile updates synced to Firestore `users/{uid}`. |
| **Settings Screen** | `/settings` | Reminder preferences, notification toggles, theme switcher. |
| **Change Password** | `/change-password` | Secure credential re-authentication and password change. |
| **Help & FAQ** | `/help-faq` | Categorized questions, waste guidelines, support contact. |
| **Design System** | `/design-system` | Visual component gallery for buttons, inputs, chips, and cards. |

---

## 🧭 Named Routes & Argument Architecture

GreenBin uses centralized named routing in [`lib/routes/app_routes.dart`](lib/routes/app_routes.dart):

```dart
// Navigating from Category Guide to Schedule with Pre-Filled Category:
Navigator.pushNamed(
  context,
  AppRoutes.schedule,
  arguments: category.name, // e.g., 'Plastic'
);

// Navigating to Review Pickup with Validated PickupModel:
Navigator.pushNamed(
  context,
  AppRoutes.reviewPickup,
  arguments: pickupModel,
);

// Navigating to Pickup Details by ID:
Navigator.pushNamed(
  context,
  AppRoutes.pickupDetails,
  arguments: pickupId,
);
```

---

## 🎨 Design System & Recycling Category Colors

| Category | Primary Color | Hex Code | Items Covered |
| :--- | :--- | :--- | :--- |
| **Plastic** | Vibrant Teal | `#00897B` | Bottles, containers, hard plastics |
| **Paper & Cardboard**| Warm Amber | `#F57C00` | Cardboard boxes, newspapers, magazines |
| **Glass** | Ocean Blue | `#0288D1` | Bottles, glass jars, cullet |
| **Metal** | Cool Slate | `#546E7A` | Aluminum cans, tin, copper scrap |
| **Electronics** | Deep Violet | `#7E57C2` | Batteries, old cables, small appliances |
| **Organic** | Emerald Green | `#2E7D32` | Food scraps, compost, garden clippings |

---

## 🗄️ Cloud Firestore Data Models

### 1. `pickups/{pickupId}`
```json
{
  "id": "doc_id_auto_generated",
  "userId": "firebase_auth_uid",
  "userName": "Jane Doe",
  "wasteCategory": "Plastic",
  "pickupDate": "Timestamp",
  "timeSlot": "09:00 AM - 11:00 AM",
  "address": "123 Green St, Apt 4B",
  "notes": "Left near the blue recycling bin",
  "status": "Scheduled", // "Scheduled" | "Collected" | "Cancelled"
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
  "email": "resident@greenbin.org",
  "phone": "+1-555-0199",
  "community": "Oakridge Green Society",
  "address": "123 Green St, Apt 4B",
  "role": "resident", // "resident" | "collector" | "admin"
  "totalPickups": 12,
  "points": 360,
  "createdAt": "Timestamp"
}
```

---

## 🛡️ Security Rules (`firestore.rules`)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Pickups Collection
    match /pickups/{pickupId} {
      // Residents can create Scheduled requests
      allow create: if request.auth != null 
        && request.resource.data.userId == request.auth.uid
        && request.resource.data.status == 'Scheduled';

      // Owners, collectors, and admins can view requests
      allow read: if request.auth != null && (
        resource.data.userId == request.auth.uid ||
        request.auth.token.role in ['collector', 'admin']
      );

      // Only collectors or admins can mark status as Collected
      allow update: if request.auth != null && (
        (request.auth.token.role in ['collector', 'admin']) ||
        (resource.data.userId == request.auth.uid && request.resource.data.status == 'Cancelled')
      );
    }
  }
}
```

---

## 🧪 Testing Suite & Quality Assurance

GreenBin includes **21 comprehensive automated test suites** spanning unit logic, widget rendering, responsiveness, and Firestore security:

```bash
# Run all tests
flutter test

# Run code analyzer (0 warnings, 0 errors)
flutter analyze
```

### Key Test Suites:
* [`test/pickup_status_logic_test.dart`](test/pickup_status_logic_test.dart): Verifies status integrity (`Scheduled` → `Collected` via collector only).
* [`test/schedule_pickup_test.dart`](test/schedule_pickup_test.dart): Validates form inputs, date picker, slot selection, and route argument pre-population.
* [`test/my_pickups_test.dart`](test/my_pickups_test.dart): Tests real-time pickup cards, status chips, and tab filtering.
* [`test/complete_responsive_audit_test.dart`](test/complete_responsive_audit_test.dart): Ensures layout stability across mobile (390px), tablet (768px), and desktop (1200px+).
* [`test/validators_test.dart`](test/validators_test.dart): Tests input validation rules.

---

## 🚀 Local Development & Deployment

### 1. Run Locally
```bash
# Clone the repository
git clone https://github.com/Vrutti88/GreenBin.git
cd GreenBin

# Get packages
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run on Android Device / Emulator
flutter run -d android
```

### 2. Build for Production
```bash
# Web Production Build
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting

# Android Release APK Build
flutter build apk --release
```

---

## 📄 License
This project is licensed under the MIT License — see the LICENSE file for details.
