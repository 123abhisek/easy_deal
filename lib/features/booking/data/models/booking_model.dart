class BookingModel {
  final String id;
  final String listingId;
  final String listingType; // property or vehicle
  final String listingTitle;
  final double amount; // e.g. 999
  final String status; // pending, confirmed, cancelled
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? payerName;
  final String? payerEmail;
  final String? payerPhone;
  final String? createdAt;
  final String? listingImageUrl;
  final String? listingLocation;

  const BookingModel({
    required this.id,
    required this.listingId,
    required this.listingType,
    required this.listingTitle,
    required this.amount,
    this.status = 'confirmed',
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.payerName,
    this.payerEmail,
    this.payerPhone,
    this.createdAt,
    this.listingImageUrl,
    this.listingLocation,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? json['booking_id']?.toString() ?? '',
      listingId: json['listing_id']?.toString() ?? '',
      listingType: json['listing_type']?.toString() ?? 'property',
      listingTitle: json['listing_title']?.toString() ?? json['title']?.toString() ?? 'Listing Reservation',
      amount: json['amount'] is num ? (json['amount'] as num).toDouble() : double.tryParse(json['amount']?.toString() ?? '999') ?? 999.0,
      status: json['status']?.toString() ?? 'confirmed',
      razorpayPaymentId: json['razorpay_payment_id']?.toString() ?? json['payment_id']?.toString(),
      razorpayOrderId: json['razorpay_order_id']?.toString() ?? json['order_id']?.toString(),
      payerName: json['payer_name']?.toString() ?? json['buyer_name']?.toString(),
      payerEmail: json['payer_email']?.toString() ?? json['buyer_email']?.toString(),
      payerPhone: json['payer_phone']?.toString() ?? json['buyer_phone']?.toString(),
      createdAt: json['created_at']?.toString(),
      listingImageUrl: json['listing_image_url']?.toString() ?? json['image_url']?.toString(),
      listingLocation: json['listing_location']?.toString() ?? json['location']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listing_id': listingId,
      'listing_type': listingType,
      'listing_title': listingTitle,
      'amount': amount,
      'status': status,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_order_id': razorpayOrderId,
      'payer_name': payerName,
      'payer_email': payerEmail,
      'payer_phone': payerPhone,
      'created_at': createdAt,
      'listing_image_url': listingImageUrl,
      'listing_location': listingLocation,
    };
  }
}
