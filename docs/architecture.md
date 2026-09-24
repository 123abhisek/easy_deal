# EasyDeal Architecture Documentation

## 1. System Topology

```
┌───────────────────────────────────────────────────────────────┐
│                    PRODUCTION CLIENTS                         │
├───────────────────────────────┬───────────────────────────────┤
│    React Web Application      │     Flutter Mobile App        │
│   (marketplace-ui / Vite)     │        (easy_deal)            │
└───────────────┬───────────────┴───────────────┬───────────────┘
                │                               │
                │ HTTPS: 443                    │ HTTPS: 443
                ▼                               ▼
┌───────────────────────────────────────────────────────────────┐
│              VPS Nginx Reverse Proxy (46.250.239.148)         │
│               Domain: https://easydealworld.com               │
│                                                               │
│   location /v1/api/ ───► proxy_pass http://127.0.0.1:8000     │
└───────────────────────────────┬───────────────────────────────┘
                                │
                                ▼
┌───────────────────────────────────────────────────────────────┐
│             FastAPI Production Backend (port 8000)            │
│                 /home/marketplace_backend                     │
│               - JWT Authentication & Roles                    │
│               - Property & Vehicle Catalog APIs               │
│               - Razorpay Payment Verification                 │
│               - Moderation & Seller Workflows                 │
└───────────────────────────────┬───────────────────────────────┘
                                │
                                ▼
┌───────────────────────────────────────────────────────────────┐
│                 PostgreSQL Database Engine                    │
│                 Localhost (Port 5432 Internal)                │
└───────────────────────────────────────────────────────────────┘
```

---

## 2. Flutter Clean Architecture Pattern

The Flutter project is structured into feature modules with separation of concerns:

```
lib/
├── app.dart                   # Root MaterialApp with theme & router
├── main.dart                  # App initialization with Riverpod scope
│
├── core/
│   ├── constants/             # ApiEndpoints, AppColors
│   ├── network/               # ApiClient (Dio), ApiResponse, AuthInterceptor
│   ├── storage/               # SecureStorage (JWT) & SharedPreferences
│   ├── theme/                 # Clean, modern Material 3 typography & styling
│   ├── utils/                 # Indian currency formatter, validators, image helpers
│   └── widgets/               # Reusable custom inputs, buttons, skeletons, error states
│
├── features/
│   ├── admin/                 # AdminModerationHub & approval controllers
│   ├── auth/                  # Login, Register, Forgot Password & AuthController
│   ├── booking/               # Token reservation bottom sheet, receipts & controller
│   ├── explore/               # Home feed, banners, unified cards & category filters
│   ├── profile/               # Profile management, listings & password update
│   ├── property/              # Real estate catalog, details & posting form
│   ├── seller/                # Seller verification request & seller operations hub
│   ├── subscription/          # Gold subscription upgrade modal & Razorpay checkout
│   └── vehicle/               # Automobile catalog, details & posting form
│
└── routing/
    ├── app_router.dart        # GoRouter navigation config
    └── main_shell_screen.dart # 4-tab bottom navigation shell
```

---

## 3. Security Design
1. **Zero Client Secrets**: No database passwords, SSH keys, private JWT secrets, or payment secrets exist in the mobile code.
2. **Encrypted Token Storage**: Tokens are kept inside hardware-backed storage via `flutter_secure_storage` (iOS Keychain / Android EncryptedSharedPreferences).
3. **No Direct Database Access**: Mobile client communicates solely via public HTTPS endpoints.
