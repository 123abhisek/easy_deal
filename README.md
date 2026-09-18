# 🚀 EasyDeal World — Mobile App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Material 3](https://img.shields.io/badge/Design-Material%203-7C3AED)](https://m3.material.io)
[![State Management](https://img.shields.io/badge/State-Riverpod-00C49F)](https://riverpod.dev)
[![Tests](https://img.shields.io/badge/Unit%20Tests-9%2F9%20Passed-22C55E)]()
[![Analysis](https://img.shields.io/badge/flutter%20analyze-0%20Issues-22C55E)]()

**EasyDeal World** is a modern, high-performance cross-platform mobile marketplace application built with **Flutter & Material 3**. It connects verified buyers, sellers, and renters for high-value **Real Estate Properties** and **Automotive Vehicles** across India.

The application integrates seamlessly with the **EasyDeal FastAPI backend**, featuring **tiered content gating (Free vs. Gold)**, **₹999 token bookings**, **interactive digital receipts**, and **Razorpay checkout**.

---

## 🌟 Key Features & User Experience

### 1. 🛡️ Gated Content & Premium Experience
- **100% Transparent Specs & Prices**: All vehicle specs (transmission, RTO code, year, fuel type, km driven) and property details (BHK, super built-up sq.ft, floor, furnishing, facing) remain visible to everyone.
- **Photo Blur Overlay**: Full-screen frosted glass blur across photo galleries for Free users with prompt: *"Upgrade to Premium to view all photos"* and a gold unlock CTA.
- **Masked Owner Contacts**: Real estate and vehicle owner details show masked phone numbers (e.g. `+91 98******10`) with lock indicators for Free users.
- **EasyDeal Gold (₹299/mo)**:
  - Instant unblur of all high-definition photo galleries.
  - Direct 1-tap phone dialer (`tel:+91...`).
  - Direct WhatsApp chat integration with pre-filled enquiry messages (`wa.me/91...`).

---

### 2. ⚡ Direct ₹999 Token Booking & Digital Receipts
- **Holding Deposit Flow**: Instant bottom sheet on detail pages displaying listing summary, token breakdown (₹999 Holding Fee + ₹0 convenience fee), and Razorpay checkout.
- **Interactive Digital Receipt (`DigitalReceiptDialog`)**:
  - Automatically triggered upon payment confirmation.
  - Unique booking reference: `#BK-xxxxx` with 1-tap copy.
  - Receipt details: Listing name, token amount paid, date-time stamp, and `CONFIRMED ✅` badge.
  - Direct *"Call Owner Now"* action button and shortcut to *"View in My Bookings"*.

---

### 3. ➕ Multi-Step Ad Posting Wizards
- **Step 1: Category & Location**: Property/Vehicle type, listing title, locality, city, state.
- **Step 2: Specifications & Live Price Converter**:
  - Interactive stepper counters (`[-] 3 [+]`) for Bedrooms (BHK) and Bathrooms/Rooms.
  - **Live Verbal Rupee Preview**: Converts numeric inputs into spoken Indian currency (e.g. `8500000` $\rightarrow$ `💬 ₹ 85.00 Lakhs`, `12500000` $\rightarrow$ `💬 ₹ 1.25 Crores`), eliminating zero-counting mistakes.
- **Step 3: Media Upload & Contact**: Camera & Gallery photo picker with base64 conversion and contact verification.

---

### 4. 🧭 5-Tab Persistent Navigation Shell (`StatefulShellRoute`)
```text
┌───────────────────────────────────────────────────────────────┐
│ [ 🏠 Explore ] [ 📑 Listings ] [ ➕ Post Ad ] [ 📅 Bookings ] [ 👤 Profile ] │
└───────────────────────────────────────────────────────────────┘
```
1. **🏠 Explore**: Location selector (`📍 Bangalore, KA ▾`), category chip filters, Gold promo banner, featured listings carousel, and mixed feed.
2. **📑 Listings**: Unified tabbed catalog toggling between **Properties** (Flat, House, Plot, Commercial, Agricultural) and **Vehicles** (Hyundai, Tata, Mahindra, BMW, etc.) with search and skeleton shimmer loading states.
3. **➕ Post Ad**: Central prominent action that launches a bottom sheet selector for Property or Vehicle listing wizards.
4. **📅 Bookings**: History of token reservations, active holding statuses, payment IDs, and booking receipts.
5. **👤 Profile**: Gold member countdown card (*"24 Days remaining in your plan"* with `[ Manage / Renew Plan ➔ ]`), saved favorites, and customer support Help Center & FAQs.

---

## 🏗️ Architecture & Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | **Flutter 3.x** (Dart 3.x) with **Material 3** theme tokens |
| **Typography** | Google Fonts (**Plus Jakarta Sans**) |
| **State Management** | **Flutter Riverpod** (`StateNotifierProvider` architecture) |
| **Navigation** | **GoRouter** with `StatefulShellRoute` (persistent navigation) |
| **Networking** | **Dio** with `AuthInterceptor` (JWT Bearer token injection & refresh) |
| **Local Storage** | `FlutterSecureStorage` (JWT Tokens) & `SharedPreferences` (Cache) |
| **Payments** | **Razorpay Flutter SDK** (Subscriptions ₹299 + Booking Tokens ₹999) |
| **Media Handling** | `image_picker` with Base64 encoding for backend sync |
| **Currency** | `intl` with custom Indian Currency formatting engine |

---

## 📂 Project Directory Structure

```text
lib/
├── app.dart                                # Application root with Riverpod & GoRouter
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart              # FastAPI backend endpoints
│   │   └── app_colors.dart                 # Material 3 color tokens & gold accents
│   ├── network/
│   │   ├── api_client.dart                 # Dio client with error handler
│   │   ├── api_response.dart               # Generic API response wrapper
│   │   └── auth_interceptor.dart           # Bearer token interceptor
│   ├── services/
│   │   └── payment_service.dart            # Razorpay gateway integration
│   ├── storage/
│   │   └── secure_storage.dart             # JWT token storage
│   ├── theme/
│   │   └── app_theme.dart                  # Light & Dark M3 theme definitions
│   ├── utils/
│   │   ├── currency_formatter.dart         # ₹ Lakhs/Crores & verbal conversion
│   │   ├── image_helper.dart               # Image picking & base64 encoding
│   │   └── validators.dart                 # Form validation utilities
│   └── widgets/                            # Reusable buttons, inputs, skeletons
├── features/
│   ├── auth/                               # Login, Register, Forgot Password, JWT
│   ├── booking/                            # Bookings repository, bottom sheet & digital receipt
│   ├── explore/                            # Feed, Category bar, Property & Vehicle cards
│   ├── profile/                            # Profile screen, Gold countdown, My Listings, Help Center
│   ├── property/                           # Property models, repository, 3-step wizard, detail screen
│   ├── seller/                             # Seller onboarding & seller verification
│   ├── subscription/                       # Gold subscription modal & checkout
│   └── vehicle/                            # Vehicle models, repository, 3-step wizard, detail screen
└── main.dart                               # App entry point
```

---

## ⚙️ Getting Started

### Prerequisites
- **Flutter SDK**: `>= 3.3.0`
- **Dart SDK**: `>= 3.3.0`
- **Android Studio** / **VS Code** with Flutter extensions
- Android device or emulator (API 24+) / iOS device or simulator (iOS 13+)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-repo/easy_deal.git
   cd easy_deal
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure API Endpoints** (if running a custom backend):
   Check or update the base URL in `lib/core/constants/api_endpoints.dart`:
   ```dart
   static const String baseUrl = 'https://www.easydealworld.com/v1/api';
   ```

4. **Run the application**:
   ```bash
   flutter run
   ```

---

## 🧪 Testing & Verification

### Run Code Analyzer
Ensures zero lint errors, clean null safety, and clean import paths:
```bash
flutter analyze
```
*Output: `No issues found!`*

### Run Unit Tests
Executes unit tests for Currency Helpers, Validators, and Data Models:
```bash
flutter test
```
*Output: `All tests passed! (9/9)`*

### Compile Flutter Bundle
Verifies AOT compilation, kernel snapshotting, and asset bundling:
```bash
flutter build bundle
```
*Output: `Task finished with exit code 0.`*

---

## 💳 Payment Gateway Configuration

The app integrates with **Razorpay**:
- **Subscription Plan**: ₹299 / month (EasyDeal Gold)
- **Token Reservation Fee**: ₹999 (Refundable holding deposit)

To set your live or test Razorpay Key ID, configure it in `lib/core/services/payment_service.dart` or supply it dynamically via the backend `/payment/create-order` endpoint.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.
