import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../booking/presentation/widgets/booking_bottom_sheet.dart';
import '../../../subscription/presentation/widgets/subscription_modal.dart';
import '../../data/models/vehicle_model.dart';
import '../controllers/vehicle_controller.dart';

class VehicleDetailScreen extends ConsumerStatefulWidget {
  final String vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends ConsumerState<VehicleDetailScreen> {
  VehicleModel? _vehicle;
  bool _isLoading = true;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadVehicle();
  }

  Future<void> _loadVehicle() async {
    final repo = ref.read(vehicleRepositoryProvider);
    final response = await repo.getVehicleById(widget.vehicleId);
    if (mounted) {
      setState(() {
        _vehicle = response.data;
        _isLoading = false;
      });
    }
  }

  Future<void> _callOwner(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone, String title) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/91$cleanPhone?text=${Uri.encodeComponent('Hi, I am interested in your vehicle listing: $title on EasyDeal')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _getMaskedPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '+91 98******10';
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length >= 10) {
      return '+91 ${clean.substring(0, 2)}******${clean.substring(clean.length - 2)}';
    }
    return '+91 98******10';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isPremium = authState.isPremium;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_vehicle == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Vehicle listing not found')),
      );
    }

    final v = _vehicle!;
    final images = v.images;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.5),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: 'Check out this vehicle on EasyDeal: ${v.title} - ${CurrencyHelper.format(v.expectedPrice)}'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vehicle link copied to clipboard!')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gallery
            Stack(
              children: [
                SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: images.isNotEmpty
                      ? PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                          itemBuilder: (ctx, i) {
                            return CachedNetworkImage(
                              imageUrl: images[i],
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.directions_car_rounded, size: 60),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.vehicleAccentLight,
                          child: const Icon(Icons.directions_car_rounded, size: 60, color: AppColors.vehicleAccent),
                        ),
                ),

                // Blur gate for free users
                if (!isPremium && images.isNotEmpty)
                  Positioned.fill(
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          color: Colors.black.withOpacity(0.4),
                          padding: const EdgeInsets.all(24),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.lock_rounded, color: AppColors.goldAccent, size: 28),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Full Vehicle Gallery is Locked',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Upgrade to Premium to view all photos',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () => SubscriptionModal.show(context),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.goldAccent,
                                  foregroundColor: const Color(0xFF0F172A),
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                child: const Text('Unlock for ₹299'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                if (images.length > 1)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1} / ${images.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.vehicleAccentLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${v.year} • ${v.brand.toUpperCase()}',
                          style: const TextStyle(
                            color: AppColors.vehicleAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
                            SizedBox(width: 4),
                            Text(
                              'Verified RTO',
                              style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    v.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.vehicleAccent),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          v.location,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        CurrencyHelper.format(v.expectedPrice),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.vehicleAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${CurrencyHelper.formatCompact(v.expectedPrice)})',
                        style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: AppColors.border),

                  const Text(
                    'Vehicle Specifications',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildFeatureTile(Icons.branding_watermark_outlined, 'Brand', v.brand),
                      _buildFeatureTile(Icons.directions_car_filled_outlined, 'Model', v.model),
                      _buildFeatureTile(Icons.calendar_month_outlined, 'Year', v.year),
                      if (v.kmDriven != null)
                        _buildFeatureTile(Icons.speed_rounded, 'KM Driven', '${v.kmDriven} km'),
                      if (v.fuelType != null)
                        _buildFeatureTile(Icons.local_gas_station_outlined, 'Fuel Type', v.fuelType!),
                      if (v.transmission != null)
                        _buildFeatureTile(Icons.tune_rounded, 'Transmission', v.transmission!),
                      if (v.ownerCount != null)
                        _buildFeatureTile(Icons.person_pin_circle_outlined, 'Ownership', v.ownerCount!),
                      if (v.rtoCode != null)
                        _buildFeatureTile(Icons.pin_drop_outlined, 'RTO Code', v.rtoCode!),
                      if (v.vehicleNumber != null)
                        _buildFeatureTile(Icons.confirmation_number_outlined, 'Reg. No.', v.vehicleNumber!),
                    ],
                  ),
                  const Divider(height: 36, color: AppColors.border),

                  const Text(
                    'Owner / Dealer Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),

                  if (isPremium)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.vehicleAccentLight,
                                child: const Icon(Icons.person, color: AppColors.vehicleAccent),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      v.ownerName ?? 'Verified Seller',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                    ),
                                    const Text(
                                      'Direct Vehicle Owner',
                                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.goldLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.star_rounded, size: 14, color: AppColors.goldDark),
                                    SizedBox(width: 2),
                                    Text('Gold Access', style: TextStyle(color: AppColors.goldDark, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _callOwner(v.contactNumber ?? '9876543210'),
                                  icon: const Icon(Icons.phone, size: 16, color: AppColors.vehicleAccent),
                                  label: Text(v.contactNumber ?? '9876543210', style: const TextStyle(color: AppColors.vehicleAccent)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.vehicleAccent),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () => _openWhatsApp(v.contactNumber ?? '9876543210', v.title),
                                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                                  label: const Text('WhatsApp'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    // Masked seller contact card for Free users
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: AppColors.vehicleAccentLight,
                                child: Icon(Icons.person, color: AppColors.vehicleAccent),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      v.ownerName ?? 'Verified Seller',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.goldDark),
                                        const SizedBox(width: 4),
                                        Text(
                                          _getMaskedPhone(v.contactNumber),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.lock_rounded, size: 12, color: AppColors.textSecondary),
                                    SizedBox(width: 3),
                                    Text('Masked', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.goldAccent.withOpacity(0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.workspace_premium_rounded, color: AppColors.goldAccent, size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'Seller Contact Gated for Free Users',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Direct calling, WhatsApp chat, and vehicle RTO documents are unlocked with EasyDeal Gold.',
                                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, height: 1.3),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    onPressed: () => SubscriptionModal.show(context),
                                    icon: const Icon(Icons.star_rounded, size: 16, color: Color(0xFF0F172A)),
                                    label: const Text('Unlock Contacts for ₹299'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.goldAccent,
                                      foregroundColor: const Color(0xFF0F172A),
                                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (isPremium)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callOwner(v.contactNumber ?? '9876543210'),
                    icon: const Icon(Icons.phone_rounded, size: 18),
                    label: const Text('Call Seller'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.vehicleAccent,
                      side: const BorderSide(color: AppColors.vehicleAccent, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                )
              else
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => SubscriptionModal.show(context),
                    icon: const Icon(Icons.lock_open_rounded, size: 18),
                    label: const Text('Unlock Contact'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.goldDark,
                      side: const BorderSide(color: AppColors.goldAccent, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => BookingBottomSheet.show(
                    context,
                    listingId: v.id,
                    listingType: 'vehicle',
                    title: v.title,
                    price: v.expectedPrice,
                    location: v.location,
                    imageUrl: images.isNotEmpty ? images.first : null,
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: const Text('Book Token ₹999'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String value) {
    return Container(
      width: (MediaQuery.of(context).size.width - 52) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.vehicleAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
