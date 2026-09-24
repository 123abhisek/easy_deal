# EasyDeal API Mapping Documentation

**Production Base URL**: `https://easydealworld.com/v1/api`  
**Authentication Header**: `Authorization: Bearer <JWT_ACCESS_TOKEN>`

---

## 1. Authentication APIs

| Feature | React Source | Flutter Method | FastAPI Endpoint | HTTP Method | Auth Required |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Login | `authService.login` | `AuthRepository.login` | `/auth/login` | `POST` | No |
| Register | `authService.register` | `AuthRepository.register` | `/auth/register` | `POST` | No |
| Current Profile | `authService.me` | `AuthRepository.getMe` | `/auth/me` | `GET` | Yes |
| Update Profile | `authService.updateProfile` | `AuthRepository.updateProfile` | `/auth/me` | `PATCH` / `PUT` | Yes |
| Change Password | `authService.changePassword` | `AuthRepository.changePassword` | `/auth/change-password` | `POST` | Yes |
| Forgot Password | `authService.forgotPassword` | `AuthRepository.forgotPassword` | `/auth/forgot-password` | `POST` | No |
| Reset Password | `authService.resetPassword` | `AuthRepository.resetPassword` | `/auth/reset-password` | `POST` | No |
| Logout | `authService.logout` | `AuthRepository.logout` | `/auth/logout` | `POST` | Yes |

---

## 2. Property APIs

| Feature | React Source | Flutter Method | FastAPI Endpoint | HTTP Method | Auth Required |
| :--- | :--- | :--- | :--- | :--- | :--- |
| List Properties | `propertyService.getAll` | `PropertyRepository.getProperties` | `/property/all` | `GET` | Optional (Free=Teaser, Prem=Full) |
| Get Property Details | `propertyService.getOne` | `PropertyRepository.getPropertyById` | `/property/{id}` | `GET` | Optional (Free=Teaser, Prem=Full) |
| Add Property | `propertyService.add` | `PropertyRepository.addProperty` | `/property/add` | `POST` | Yes |
| Update Property | `propertyService.update` | `PropertyRepository.updateProperty` | `/property/{id}` | `PUT` | Yes (Owner/Admin) |
| Delete Property | `propertyService.deleteOne` | `PropertyRepository.deleteProperty` | `/property/{id}` | `DELETE` | Yes (Owner/Admin) |
| My Property Listings | `propertyService.myListings` | `PropertyRepository.getMyListings` | `/property/my/listings` | `GET` | Yes |
| Moderate Status | `api.put(/property/{id}/status)` | `PropertyRepository.updateListingStatus` | `/property/{id}/status` | `PATCH` | Yes (Admin) |

---

## 3. Vehicle APIs

| Feature | React Source | Flutter Method | FastAPI Endpoint | HTTP Method | Auth Required |
| :--- | :--- | :--- | :--- | :--- | :--- |
| List Vehicles | `vehicleService.getAll` | `VehicleRepository.getVehicles` | `/vehicle/all` | `GET` | Optional (Free=Teaser, Prem=Full) |
| Get Vehicle Details | `vehicleService.getOne` | `VehicleRepository.getVehicleById` | `/vehicle/{id}` | `GET` | Optional (Free=Teaser, Prem=Full) |
| Add Vehicle | `vehicleService.add` | `VehicleRepository.addVehicle` | `/vehicle/add` | `POST` | Yes |
| Update Vehicle | `vehicleService.update` | `VehicleRepository.updateVehicle` | `/vehicle/{id}` | `PUT` | Yes (Owner/Admin) |
| Delete Vehicle | `vehicleService.deleteOne` | `VehicleRepository.deleteVehicle` | `/vehicle/{id}` | `DELETE` | Yes (Owner/Admin) |
| My Vehicle Listings | `vehicleService.myListings` | `VehicleRepository.getMyListings` | `/vehicle/my/listings` | `GET` | Yes |
| Moderate Status | `api.put(/vehicle/{id}/status)` | `VehicleRepository.updateListingStatus` | `/vehicle/{id}/status` | `PATCH` | Yes (Admin) |

---

## 4. Booking & Token Reservation APIs

| Feature | React Source | Flutter Method | FastAPI Endpoint | HTTP Method | Auth Required |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Initiate Token Booking | `bookingService.initiateBooking` | `BookingRepository.initiateBooking` | `/booking/initiate` | `POST` | Yes |
| Verify Token Payment | `bookingService.verifyBooking` | `BookingRepository.verifyBooking` | `/booking/verify` | `POST` | Yes |
| My Bookings (Buyer) | `bookingService.getMyBookings` | `BookingRepository.getMyBookings` | `/booking/my` | `GET` | Yes |
| Received Bookings (Owner) | `bookingService.getReceivedBookings` | `BookingRepository.getReceivedBookings` | `/booking/received` | `GET` | Yes |
| Single Booking Details | `bookingService.getBooking` | `BookingRepository.getBookingById` | `/booking/{id}` | `GET` | Yes |
| Cancel Booking | `bookingService.cancelBooking` | `BookingRepository.cancelBooking` | `/booking/{id}` | `DELETE` | Yes (Buyer) |

---

## 5. Subscription & Payment APIs

| Feature | React Source | Flutter Method | FastAPI Endpoint | HTTP Method | Auth Required |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Create Standalone Order | `paymentService.initiatePayment` | `PaymentService.createOrder` | `/payment/create-order` | `POST` | Yes |
| Verify Standalone Payment | `paymentService.initiatePayment` | `PaymentService.verifyPayment` | `/payment/verify-payment` | `POST` | Yes |
| Upgrade Plan | `SubscriptionPage.jsx` | `SubscriptionRepository.upgrade` | `/subscription/upgrade` | `POST` | Yes |
| Subscription Status | `SubscriptionStatusPage.jsx` | `SubscriptionRepository.getStatus` | `/subscription/status` | `GET` | Yes |

---

## 6. Seller & Seller Requests APIs

| Feature | React Source | Flutter Method | FastAPI Endpoint | HTTP Method | Auth Required |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Apply to Become Seller | `SellerRequest.jsx` | `SellerRepository.submitSellerRequest` | `/seller-request/request` | `POST` | Yes |
| Check My Application | `SellerRequest.jsx` | `SellerRepository.getMyLatestRequest` | `/seller-request/my-request` | `GET` | Yes |
| Seller Dashboard Stats | `SellerOrdersApi.getSellersDashboard` | `SellerRepository.getDashboardStats` | `/seller/dashboard-stats` | `GET` | Yes (Seller) |
| Seller Properties | `SellerOrdersApi.getProperties` | `SellerRepository.getSellerProperties` | `/seller/properties` | `GET` | Yes (Seller) |
| Seller Vehicles | `SellerOrdersApi.getVehicles` | `SellerRepository.getSellerVehicles` | `/seller/vehicles` | `GET` | Yes (Seller) |
| Seller Customer Bookings | `SellerOrdersApi.getSellerBookings` | `SellerRepository.getSellerBookings` | `/seller/bookings` | `GET` | Yes (Seller) |

---

## 7. Admin Moderation & Management APIs

| Feature | React Source | Flutter Method | FastAPI Endpoint | HTTP Method | Auth Required |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Admin Dashboard Stats | `adminOrdersService.getDashboardStats` | `AdminRepository.getDashboardStats` | `/admin/dashboard-stats` | `GET` | Yes (Admin) |
| Pending Moderation Queue | `adminOrdersService.getPendingListings`| `AdminRepository.getPendingListings` | `/admin/pending-listings` | `GET` | Yes (Admin) |
| All Seller Applications | `AdminSellerRequests.jsx` | `AdminRepository.getSellerRequests` | `/seller-request/admin/all` | `GET` | Yes (Admin) |
| Approve Seller Request | `AdminSellerRequests.jsx` | `AdminRepository.approveSeller` | `/seller-request/admin/{id}/approve` | `POST` | Yes (Admin) |
| Reject Seller Request | `AdminSellerRequests.jsx` | `AdminRepository.rejectSeller` | `/seller-request/admin/{id}/reject` | `POST` | Yes (Admin) |
| Customers List | `adminOrdersService.getCustomers` | `AdminRepository.getCustomers` | `/admin/customers` | `GET` | Yes (Admin) |
| Sellers List | `adminOrdersService.getSellers` | `AdminRepository.getSellers` | `/admin/sellers` | `GET` | Yes (Admin) |
| Suspend / Activate User | `AdminUsersPage.jsx` | `AdminRepository.updateUserStatus` | `/admin/users/{id}/suspend` | `PATCH` | Yes (Admin) |
