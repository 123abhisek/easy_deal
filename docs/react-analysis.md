# React Application Audit & Feature Analysis

**Reference Application**: `C:\Users\hp\Documents\GitHub\marketplace-ui`  
**Target Mobile App**: `easy_deal` (Flutter)  
**Backend**: FastAPI (`https://easydealworld.com/v1/api`)

---

## 1. Application Overview & Architecture
The React application (`marketplace-ui`) is a modern Vite/React marketplace platform for real estate properties and vehicles with:
- **Authentication**: JWT token storage in `localStorage` (`access_token`) with bearer header injection.
- **User Roles**:
  - `free`: Public user who can browse teasers (images & contacts locked) and post listings.
  - `premium`: Gold subscriber who unlocked owner contacts, unblurred HD galleries, and priority notifications.
  - `seller`: Verified partner seller with dedicated operations panel, analytics, listings, and customer inquiry tracking.
  - `admin`: Platform moderator with approval queue, user suspension/activation, GST reports, and revenue metrics.
- **Payments & Bookings**:
  - Razorpay checkout integration for ₹999 token bookings and ₹299/mo subscription upgrades.
  - Verification on FastAPI backend with signature validation.

---

## 2. React Routes Inventory

| Route | Element / Component | Access Role | Description & Primary APIs |
| :--- | :--- | :--- | :--- |
| `/` | `LandingPage.jsx` | Public | Home landing page with hero banner and highlights |
| `/explore` | `ExplorePage.jsx` | Public / All | Combined catalog feed with category filters (`/property/all`, `/vehicle/all`) |
| `/properties/:id` | `PropertyDetailPage.jsx` | Public / Premium | Property details with teaser/full contact lock (`/property/{id}`) |
| `/vehicles/:id` | `VehicleDetailPage.jsx` | Public / Premium | Vehicle details with teaser/full contact lock (`/vehicle/{id}`) |
| `/login` | `LoginPage.jsx` | Guest | User login via email/password (`POST /auth/login`) |
| `/register` | `RegisterPage.jsx` | Guest | User registration with personal details (`POST /auth/register`) |
| `/forgot-password` | `ForgotPasswordPage.jsx` | Guest | Password reset request and confirmation (`POST /auth/forgot-password`, `/auth/reset-password`) |
| `/subscription` | `SubscriptionPage.jsx` | Auth | Subscription plans & Razorpay payment order initiation |
| `/dashboard/home` | `DashboardHome.jsx` | Auth | User dashboard home overview |
| `/dashboard/profile` | `ProfilePage.jsx` | Auth | User profile details and account management (`GET/PUT /auth/me`) |
| `/dashboard/change-password` | `ChangePasswordPage.jsx` | Auth | Password change (`POST /auth/change-password`) |
| `/dashboard/my-listings` | `MyListingsPage.jsx` | Auth | User's posted properties and vehicles (`GET /property/my/listings`, `/vehicle/my/listings`) |
| `/dashboard/my-bookings` | `MyBookingsPage.jsx` | Auth | User's token reservations and receipts (`GET /booking/my`) |
| `/dashboard/add-property` | `AddPropertyPage.jsx` | Auth | Property creation form (`POST /property/add`) |
| `/dashboard/add-vehicle` | `AddVehiclePage.jsx` | Auth | Vehicle creation form (`POST /vehicle/add`) |
| `/dashboard/become-seller` | `SellerRequest.jsx` | Auth | Seller application form (`POST /seller-request/request`) |
| `/seller/overview` | `SellerOverviewPage.jsx` | Seller | Seller metrics, inquiries & earnings (`GET /seller/dashboard-stats`) |
| `/seller/listings` | `SellerListingsPage.jsx` | Seller | Seller property & vehicle listings (`GET /seller/properties`, `/seller/vehicles`) |
| `/seller/orders` | `SellerOrdersPage.jsx` | Seller | Received customer bookings (`GET /seller/bookings`) |
| `/admin/overview` | `AdminOverviewPage.jsx` | Admin | Admin analytics & KPIs (`GET /admin/dashboard-stats`, `/admin/analytics-summary`) |
| `/admin/approvals` | `AdminApprovalsPage.jsx` | Admin | Moderation queue for pending listings (`GET /admin/pending-listings`, `PATCH /property/{id}/status`, `PATCH /vehicle/{id}/status`) |
| `/admin/users` | `AdminUsersPage.jsx` | Admin | Customer and seller management (`GET /admin/customers`, `/admin/sellers`) |
| `/admin/seller-requests` | `AdminSellerRequests.jsx` | Admin | Review seller requests (`GET /seller-request/admin/all`, approve/reject) |

---

## 3. UI/UX Paradigm Translation (Web → Mobile)
- **Navigation**: Web topbar + sidebar navigation is translated into an ergonomic 4-branch mobile `StatefulShellRoute` with Bottom Navigation Bar (Explore, Listings, Bookings, Account).
- **Listing Cards**: Touch-optimized responsive cards with badges (Verified, For Sale, For Rent), price formatting in Indian numbering format (Lakhs/Crores), and instant bookmarking.
- **Teaser Lock Banner**: Locked contact and photo teaser banners adapted to bottom-sheet prompts prompting Gold membership upgrades seamlessly.
- **Booking Flow**: Responsive modal bottom sheet for instant ₹999 token bookings with integrated receipt dialog.
