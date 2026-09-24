import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/booking_model.dart';

class BookingRepository {
  final ApiClient client;

  BookingRepository({required this.client});

  Future<ApiResponse<Map<String, dynamic>>> initiateBooking({
    required String listingId,
    required String listingType,
    double amount = 999.0,
    String? payerUpiId,
  }) async {
    final Map<String, dynamic> payload = {
      'amount': amount.toInt(),
      'currency': 'INR',
      if (listingType.toLowerCase() == 'property') 'property_id': listingId,
      if (listingType.toLowerCase() == 'vehicle') 'vehicle_id': listingId,
    };

    final response = await client.post(
      ApiEndpoints.initiateBooking,
      data: payload,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(Map<String, dynamic>.from(response.data!));
    }

    return ApiResponse.error(response.message ?? 'Failed to initiate booking');
  }

  Future<ApiResponse<BookingModel>> verifyBooking({
    required String bookingId,
    required String paymentId,
    required String orderId,
    String? signature,
  }) async {
    final response = await client.post(
      ApiEndpoints.verifyBooking,
      data: {
        'booking_id': bookingId,
        'razorpay_payment_id': paymentId,
        'razorpay_order_id': orderId,
        if (signature != null) 'razorpay_signature': signature,
      },
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data is Map && response.data['booking'] != null
          ? response.data['booking']
          : response.data;
      return ApiResponse.success(BookingModel.fromJson(Map<String, dynamic>.from(data)));
    }

    return ApiResponse.error(response.message ?? 'Payment verification failed');
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
    return ApiResponse.error(response.message ?? 'Failed to load bookings');
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
    return ApiResponse.error(response.message ?? 'Failed to load received bookings');
  }
}
