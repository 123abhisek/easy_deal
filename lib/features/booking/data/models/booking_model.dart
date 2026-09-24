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
    // Check if nested in 'listing', 'buyer', 'payment' (FastAPI BookingOut)
    final listing = json['listing'] is Map ? Map<String, dynamic>.from(json['listing']) : null;
    final buyer = json['buyer'] is Map ? Map<String, dynamic>.from(json['buyer']) : null;
    final payment = json['payment'] is Map ? Map<String, dynamic>.from(json['payment']) : null;

    final String listingId = json['listing_id']?.toString() ??
        listing?['id']?.toString() ??
        listing?['property_id']?.toString() ??
        listing?['vehicle_id']?.toString() ??
        json['property_id']?.toString() ??
        json['vehicle_id']?.toString() ??
        '';

    final String listingType = json['listing_type']?.toString() ??
        listing?['type']?.toString() ??
        (json['property_id'] != null ? 'property' : (json['vehicle_id'] != null ? 'vehicle' : 'property'));

    final String listingTitle = json['listing_title']?.toString() ??
        listing?['title']?.toString() ??
        json['title']?.toString() ??
        'Listing Reservation';

    final rawAmount = json['amount'] ?? payment?['amount'];
    final double amount = rawAmount is num
        ? rawAmount.toDouble()
        : (double.tryParse(rawAmount?.toString() ?? '999') ?? 999.0);

    final String? paymentId = json['razorpay_payment_id']?.toString() ??
        json['payment_id']?.toString() ??
        payment?['razorpay_payment_id']?.toString() ??
        payment?['payment_id']?.toString();

    final String? orderId = json['razorpay_order_id']?.toString() ??
        json['order_id']?.toString() ??
        payment?['razorpay_order_id']?.toString();

    final String? payerName = json['payer_name']?.toString() ??
        json['buyer_name']?.toString() ??
        buyer?['name']?.toString();

    final String? payerEmail = json['payer_email']?.toString() ??
        json['buyer_email']?.toString() ??
        buyer?['email']?.toString();

    final String? payerPhone = json['payer_phone']?.toString() ??
        json['buyer_phone']?.toString() ??
        buyer?['phone']?.toString();

    final String? imageUrl = json['listing_image_url']?.toString() ??
        json['image_url']?.toString() ??
        listing?['thumbnail']?.toString();

    final String? location = json['listing_location']?.toString() ??
        json['location']?.toString() ??
        listing?['location']?.toString();

    return BookingModel(
      id: json['id']?.toString() ?? json['booking_id']?.toString() ?? '',
      listingId: listingId,
      listingType: listingType,
      listingTitle: listingTitle,
      amount: amount,
      status: json['status']?.toString() ?? 'confirmed',
      razorpayPaymentId: paymentId,
      razorpayOrderId: orderId,
      payerName: payerName,
      payerEmail: payerEmail,
      payerPhone: payerPhone,
      createdAt: json['created_at']?.toString(),
      listingImageUrl: imageUrl,
      listingLocation: location,
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
