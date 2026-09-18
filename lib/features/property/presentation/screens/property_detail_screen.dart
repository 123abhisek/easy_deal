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
import '../../data/models/property_model.dart';
import '../controllers/property_controller.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  ConsumerState<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  PropertyModel? _property;
  bool _isLoading = true;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProperty();
  }

  Future<void> _loadProperty() async {
    final repo = ref.read(propertyRepositoryProvider);
    final response = await repo.getPropertyById(widget.propertyId);
    if (mounted) {
      setState(() {
        _property = response.data;
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
    final uri = Uri.parse('https://wa.me/91$cleanPhone?text=${Uri.encodeComponent('Hi, I am interested in your property listing: $title on EasyDeal')}');
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

    if (_property == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Property listing not found')),
      );
    }

    final p = _property!;
    final images = p.images;

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
                  Clipboard.setData(ClipboardData(text: 'Check out this property on EasyDeal: ${p.title} - ${CurrencyHelper.format(p.price)}'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Listing link copied to clipboard!')),
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
            // Image Gallery Carousel
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
                                child: const Icon(Icons.apartment_rounded, size: 60),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.propertyAccentLight,
                          child: const Icon(Icons.apartment_rounded, size: 60, color: AppColors.propertyAccent),
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
                                'Full Photo Gallery is Locked',
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

                // Page Indicator
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

            // Main Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type & Sale Chip
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.propertyAccentLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${p.propertyType.toUpperCase()} • ${p.rentLease.toUpperCase()}',
                          style: const TextStyle(
                            color: AppColors.propertyAccent,
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
                              'Verified',
                              style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    p.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.propertyAccent),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          p.location,
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

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        CurrencyHelper.format(p.price),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.propertyAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${CurrencyHelper.formatCompact(p.price)})',
                        style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: AppColors.border),

                  // Overview Grid
                  const Text(
                    'Property Specifications',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (p.bedrooms != null)
                        _buildFeatureTile(Icons.king_bed_outlined, 'Bedrooms', '${p.bedrooms} BHK'),
                      if (p.area != null)
                        _buildFeatureTile(Icons.square_foot_rounded, 'Super Built-up', '${p.area!.toStringAsFixed(0)} sqft'),
                      if (p.landArea != null)
                        _buildFeatureTile(Icons.landscape_outlined, 'Land Area', '${p.landArea} Acres'),
                      if (p.floor != null)
                        _buildFeatureTile(Icons.apartment_outlined, 'Floor', p.floor!),
                      if (p.facing != null)
                        _buildFeatureTile(Icons.explore_outlined, 'Facing', p.facing!),
                      if (p.furnishing != null)
                        _buildFeatureTile(Icons.chair_outlined, 'Furnishing', p.furnishing!),
                      if (p.parking != null)
                        _buildFeatureTile(Icons.local_parking_rounded, 'Parking', p.parking!),
                      if (p.cropsGrown != null && p.cropsGrown!.isNotEmpty)
                        _buildFeatureTile(Icons.eco_outlined, 'Crops Grown', p.cropsGrown!),
                    ],
                  ),
                  const Divider(height: 36, color: AppColors.border),

                  // Owner / Seller Details Card
                  const Text(
                    'Owner & Seller Information',
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
                                backgroundColor: AppColors.propertyAccentLight,
                                child: const Icon(Icons.person, color: AppColors.propertyAccent),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.ownerName ?? 'Verified Owner',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                    ),
                                    const Text(
                                      'Direct Property Lister',
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
                                  onPressed: () => _callOwner(p.contact ?? '9876543210'),
                                  icon: const Icon(Icons.phone, size: 16, color: AppColors.propertyAccent),
                                  label: Text(p.contact ?? '9876543210', style: const TextStyle(color: AppColors.propertyAccent)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.propertyAccent),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () => _openWhatsApp(p.contact ?? '9876543210', p.title),
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
                    // Masked owner contact card for Free users
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
                                backgroundColor: AppColors.propertyAccentLight,
                                child: Icon(Icons.person, color: AppColors.propertyAccent),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.ownerName ?? 'Verified Owner',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.goldDark),
                                        const SizedBox(width: 4),
                                        Text(
                                          _getMaskedPhone(p.contact),
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
                                      'Owner Contact Gated for Free Users',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Direct calling, WhatsApp chat, and verified identity records are unlocked with EasyDeal Gold.',
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
                    onPressed: () => _callOwner(p.contact ?? '9876543210'),
                    icon: const Icon(Icons.phone_rounded, size: 18),
                    label: const Text('Call Owner'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.propertyAccent,
                      side: const BorderSide(color: AppColors.propertyAccent, width: 1.5),
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
                    listingId: p.id,
                    listingType: 'property',
                    title: p.title,
                    price: p.price,
                    location: p.location,
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
          Icon(icon, size: 20, color: AppColors.propertyAccent),
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
