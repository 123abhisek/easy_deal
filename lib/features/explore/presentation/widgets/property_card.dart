import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../property/data/models/property_model.dart';

class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final bool isPremiumUser;
  final VoidCallback onUnlockTap;
  final VoidCallback onTap;

  const PropertyCard({
    super.key,
    required this.property,
    required this.isPremiumUser,
    required this.onUnlockTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = property.images.isNotEmpty;
    final imageUrl = hasImage ? property.images.first : null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Blur gate if user is not premium
            Stack(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: hasImage
                      ? CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.apartment_rounded, size: 48, color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: AppColors.primaryLight,
                          child: const Icon(Icons.apartment_rounded, size: 48, color: AppColors.primary),
                        ),
                ),

                // Blur overlay if user is not premium
                if (!isPremiumUser && hasImage)
                  Positioned.fill(
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                        child: Container(
                          color: Colors.black.withOpacity(0.35),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_rounded, size: 14, color: AppColors.goldAccent),
                                SizedBox(width: 6),
                                Text(
                                  'Premium Content',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Property Type Badge (Teal)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.propertyAccent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${property.propertyType} • ${property.rentLease}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Price Compact Tag top right
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      CurrencyHelper.formatCompact(property.price),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.propertyAccent),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Specs Row (Beds, Baths, Area)
                  Row(
                    children: [
                      if (property.bedrooms != null) ...[
                        _buildSpecItem(Icons.bed_outlined, '${property.bedrooms} Beds'),
                        const SizedBox(width: 14),
                      ],
                      if (property.area != null) ...[
                        _buildSpecItem(Icons.square_foot_rounded, '${property.area!.toStringAsFixed(0)} sqft'),
                        const SizedBox(width: 14),
                      ],
                      if (property.landArea != null) ...[
                        _buildSpecItem(Icons.landscape_outlined, '${property.landArea} Acres'),
                        const SizedBox(width: 14),
                      ],
                      if (property.furnishing != null) ...[
                        Expanded(
                          child: _buildSpecItem(Icons.chair_outlined, property.furnishing!),
                        ),
                      ],
                    ],
                  ),

                  const Divider(height: 24, color: AppColors.border),

                  // Bottom Action Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Price',
                            style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                          ),
                          Text(
                            CurrencyHelper.format(property.price),
                            style: const TextStyle(
                              color: AppColors.propertyAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      if (!isPremiumUser)
                        FilledButton.tonalIcon(
                          onPressed: onUnlockTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.goldLight,
                            foregroundColor: AppColors.goldDark,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.lock_open_rounded, size: 15),
                          label: const Text(
                            'Unlock ₹299',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        )
                      else
                        FilledButton(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.propertyAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('View Details', style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
