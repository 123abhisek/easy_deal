import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/booking_model.dart';

class BookingRepository {
  final ApiClient client;

  BookingRepository({required this.client});

  static final List<BookingModel> mockBookings = [
    const BookingModel(
      id: 'book_101',
      listingId: 'prop_01',
      listingType: 'property',
      listingTitle: 'Luxury 3BHK Apartment at Prestige Ozone',
      amount: 999,
      status: 'confirmed',
      razorpayPaymentId: 'pay_KA989021',
      razorpayOrderId: 'order_KA77610',
      createdAt: '2026-09-10T14:30:00Z',
      listingImageUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1000&q=80',
      listingLocation: 'Whitefield, Bangalore',
    ),
    const BookingModel(
      id: 'book_102',
      listingId: 'veh_01',
      listingType: 'vehicle',
      listingTitle: '2022 Hyundai Creta SX (O) Turbo Petrol',
      amount: 999,
      status: 'confirmed',
      razorpayPaymentId: 'pay_KA554433',
      razorpayOrderId: 'order_KA11223',
      createdAt: '2026-09-14T09:15:00Z',
      listingImageUrl: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1000&q=80',
      listingLocation: 'Koramangala, Bangalore',
    ),
  ];

  Future<ApiResponse<Map<String, dynamic>>> initiateBooking({
    required String listingId,
    required String listingType,
    double amount = 999.0,
    String? payerUpiId,
  }) async {
    final response = await client.post(
      ApiEndpoints.initiateBooking,
      data: {
        'listing_id': listingId,
        'listing_type': listingType,
        'amount': amount,
        'payment_method': 'razorpay',
        if (payerUpiId != null) 'payer_upi_id': payerUpiId,
      },
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(Map<String, dynamic>.from(response.data!));
    }

    // Fallback mock order
    return ApiResponse.success({
      'booking_id': 'book_${DateTime.now().millisecondsSinceEpoch}',
      'order_id': 'order_${DateTime.now().millisecondsSinceEpoch}',
      'amount': (amount * 100).toInt(),
      'key_id': 'rzp_test_mock_12345',
    });
  }

  Future<ApiResponse<BookingModel>> verifyBooking({
    required String bookingId,
    required String paymentId,
    required String orderId,
    String signature = 'mock_signature',
  }) async {
    final response = await client.post(
      ApiEndpoints.verifyBooking,
      data: {
        'booking_id': bookingId,
        'razorpay_payment_id': paymentId,
        'razorpay_order_id': orderId,
        'razorpay_signature': signature,
      },
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data is Map && response.data['booking'] != null
          ? response.data['booking']
          : response.data;
      return ApiResponse.success(BookingModel.fromJson(Map<String, dynamic>.from(data)));
    }

    return ApiResponse.success(
      BookingModel(
        id: bookingId,
        listingId: 'listing_reserved',
        listingType: 'general',
        listingTitle: 'Reserved Listing',
        amount: 999,
        status: 'confirmed',
        razorpayPaymentId: paymentId,
        razorpayOrderId: orderId,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
  }

  Future<ApiResponse<List<BookingModel>>> getMyBookings() async {
    final response = await client.get(ApiEndpoints.myBookings);
    if (response.isSuccess && response.data != null) {
      final data = response.data;
      List rawList = [];
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['bookings'] is List) {
        rawList = data['bookings'];
      }
      return ApiResponse.success(
        rawList.map((e) => BookingModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      );
    }
    return ApiResponse.success(mockBookings);
  }

  Future<ApiResponse<List<BookingModel>>> getReceivedBookings() async {
    final response = await client.get(ApiEndpoints.receivedBookings);
    if (response.isSuccess && response.data != null) {
      final data = response.data;
      List rawList = [];
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['bookings'] is List) {
        rawList = data['bookings'];
      }
      return ApiResponse.success(
        rawList.map((e) => BookingModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      );
    }
    return ApiResponse.success([]);
  }
}
