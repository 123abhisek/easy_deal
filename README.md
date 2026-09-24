# 🚀 EasyDeal World — Mobile App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Material 3](https://img.shields.io/badge/Design-Material%203-7C3AED)](https://m3.material.io)
[![State Management](https://img.shields.io/badge/State-Riverpod-00C49F)](https://riverpod.dev)
[![Tests](https://img.shields.io/badge/Unit%20Tests-9%2F9%20Passed-22C55E)]()
[![Analysis](https://img.shields.io/badge/flutter%20analyze-0%20Issues-22C55E)]()

**EasyDeal World** is a modern, high-performance cross-platform mobile marketplace application built with **Flutter & Material 3**. It replicates the production React web application (`marketplace-ui`) while integrating seamlessly with the **existing production FastAPI backend running on the VPS**.

---

## 🌐 Production Architecture & Topology

```
                    EASYDEAL WORLD
                          │
             ┌────────────┴────────────┐
             ▼                         ▼
       React Web App           Flutter Mobile App
       (marketplace-ui)           (easy_deal)
             │                         │
             └────────────┬────────────┘
                          │
                          │ HTTPS :443
                          ▼
              https://easydealworld.com
                          │
                          ▼
                        Nginx
                          │  /v1/api/* (proxy_pass)
                          ▼
                   FastAPI :8000
                          │
                          ▼
                     PostgreSQL
```

- **API Base URL**: `https://easydealworld.com/v1/api`
- **Zero Client Secrets**: No database credentials, SSH keys, or private JWT secrets are included in the mobile client.
- **Secure Token Storage**: Encrypted token persistence via `flutter_secure_storage` with centralized `AuthInterceptor`.

---

## 🌟 Key Features & User Experience

### 1. 🛡️ Role-Based Functionality & Content Gating
- **Free Tier**: Public users can explore the catalog teasers and post listings.
- **EasyDeal Gold (₹299/mo)**: Unlocks full HD photos, verified owner direct phone numbers, and WhatsApp chat.
- **Verified Seller Hub**: Dedicated seller operations center for tracking listings, inquiries, token reserves, and earnings.
- **Admin Moderation Hub**: Listing moderation queue with instant approve/reject actions and platform metrics.

### 2. ⚡ ₹999 Token Bookings & Digital Receipts
- **Holding Deposit Flow**: Instant bottom sheet on detail pages displaying listing breakdown, ₹999 token payment via Razorpay.
- **Digital Receipt (`DigitalReceiptDialog`)**: Interactive modal with copyable `#BK-xxxxx` reference, confirmed status badge, and direct owner call shortcuts.

### 3. ➕ Multi-Step Ad Posting Wizards
- **Properties**: Support for apartments, villas, plots, and agricultural land with custom land units and pricing.
- **Vehicles**: Support for cars, SUVs, bikes, and EVs with RTO codes, km driven, and specs.
- **Live Verbal Rupee Preview**: Converts numeric inputs (e.g. `8500000` $\rightarrow$ `💬 ₹ 85.00 Lakhs`).

### 4. 🧭 4-Tab Persistent Navigation Shell (`StatefulShellRoute`)
- **Explore**: Search, city filters, promo banners, and category chips.
- **Listings**: Unified properties and vehicles catalog.
- **Bookings**: Token reservation tracking and receipts.
- **Account / Profile**: Gold countdown, My Listings, Seller/Admin hub access, and Help Center.

---

## 📂 Project Directory Structure

```text
easy_deal/
├── android/
├── ios/
├── docs/
│   ├── api-mapping.md              # Complete React vs Flutter vs FastAPI mapping
│   ├── feature-mapping.md          # Screen and UI component mapping
│   ├── architecture.md             # System topology and security design
│   └── react-analysis.md           # React codebase audit and feature inventory
├── lib/
│   ├── app.dart                    # Application root with Riverpod & GoRouter
│   ├── main.dart                   # App entry point
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_endpoints.dart  # FastAPI backend endpoints
│   │   │   └── app_colors.dart     # Material 3 color tokens & gold accents
│   │   ├── network/
│   │   │   ├── api_client.dart     # Centralized Dio HTTP client
│   │   │   ├── api_response.dart   # Generic API response wrapper
│   │   │   └── auth_interceptor.dart # Bearer token interceptor
│   │   ├── services/
│   │   │   └── payment_service.dart # Razorpay gateway integration
│   │   ├── storage/
│   │   │   └── secure_storage.dart # Encrypted JWT storage
│   │   ├── theme/
│   │   │   └── app_theme.dart      # Material 3 typography & styling
│   │   ├── utils/
│   │   │   ├── currency_formatter.dart # ₹ Lakhs/Crores & verbal conversion
│   │   │   ├── image_helper.dart   # Image picking & base64 encoding
│   │   │   └── validators.dart     # Form validation utilities
│   │   └── widgets/                # Reusable buttons, inputs, skeletons
│   ├── features/
│   │   ├── admin/                  # Admin moderation hub & controllers
│   │   ├── auth/                   # Login, Register, Forgot Password & AuthController
│   │   ├── booking/                # Bookings repository, bottom sheet & digital receipt
│   │   ├── explore/                # Feed, Category bar, Property & Vehicle cards
│   │   ├── profile/                # Profile screen, Gold countdown, My Listings, Help Center
│   │   ├── property/               # Property models, repository, 3-step wizard, detail screen
│   │   ├── seller/                 # Seller onboarding & seller operations hub
│   │   ├── subscription/           # Gold subscription modal & checkout
│   │   └── vehicle/                # Vehicle models, repository, 3-step wizard, detail screen
│   └── routing/
│       ├── app_router.dart         # GoRouter navigation configuration
│       └── main_shell_screen.dart  # 4-tab bottom navigation shell
├── test/
├── .env.example                    # Environment configuration template
├── pubspec.yaml
└── README.md
```

---

## ⚙️ Setup & Execution

### Prerequisites
- **Flutter SDK**: `>= 3.3.0`
- **Dart SDK**: `>= 3.3.0`

### Installation & Run

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run static analysis
flutter analyze

# 3. Run test suite
flutter test

# 4. Launch application
flutter run
```

---

## 📄 Documentation Reference
- [React Analysis](docs/react-analysis.md)
- [API Mapping](docs/api-mapping.md)
- [Feature Mapping](docs/feature-mapping.md)
- [Architecture Guide](docs/architecture.md)
