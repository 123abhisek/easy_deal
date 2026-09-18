import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../subscription/presentation/widgets/subscription_modal.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: user == null
                  ? Column(
                      children: [
                        const CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(Icons.person_outline_rounded, size: 40, color: AppColors.primary),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Guest Explorer',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sign in to post listings, book tokens, and unlock verified owner contacts.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context.push('/login'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: const Text('Sign In / Register'),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.primaryLight,
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                  if (user.phone != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      user.phone!,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Badges Row
                        Row(
                          children: [
                            if (user.isPremium)
                              _buildBadge('⭐ Gold Member', AppColors.goldDark, AppColors.goldLight)
                            else
                              _buildBadge('Free Tier', AppColors.textSecondary, AppColors.surfaceVariant),
                            const SizedBox(width: 8),
                            if (user.isSeller)
                              _buildBadge('✓ Verified Seller', AppColors.propertyAccent, AppColors.propertyAccentLight),
                          ],
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),

            // Gold Status Card for Premium Members
            if (user != null && user.isPremium)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.goldAccent, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldAccent.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.goldAccent.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.workspace_premium_rounded, color: AppColors.goldAccent, size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EasyDeal Gold Active',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '24 Days remaining in your plan',
                                style: TextStyle(
                                  color: AppColors.goldAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Includes unlimited HD photos, verified owner phone numbers, and direct WhatsApp contact.',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, height: 1.3),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => SubscriptionModal.show(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.goldAccent,
                          side: const BorderSide(color: AppColors.goldAccent),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Manage / Renew Plan ➔', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),

            // Upgrade Banner if not premium
            if (user != null && !user.isPremium)
              GestureDetector(
                onTap: () => SubscriptionModal.show(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.goldAccent.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: AppColors.goldAccent, size: 28),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upgrade to EasyDeal Gold',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '₹299/mo • Direct phone numbers, HD photos & WhatsApp',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.goldAccent, size: 14),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Options List
            if (user != null) ...[
              _buildOptionTile(
                icon: Icons.inventory_2_outlined,
                title: 'My Listings',
                subtitle: 'Manage posted properties and vehicles',
                color: AppColors.primary,
                onTap: () => context.push('/my-listings'),
              ),
              _buildOptionTile(
                icon: Icons.receipt_long_rounded,
                title: 'My Bookings & Tokens',
                subtitle: 'View your token reservations and receipts',
                color: AppColors.propertyAccent,
                onTap: () => context.push('/my-bookings'),
              ),
              _buildOptionTile(
                icon: user.isSeller ? Icons.storefront_rounded : Icons.handshake_outlined,
                title: user.isSeller ? 'Seller Dashboard' : 'Become a Verified Seller',
                subtitle: user.isSeller
                    ? 'View leads, listings, and customer bookings'
                    : 'Apply for seller verification and listing privileges',
                color: AppColors.vehicleAccent,
                onTap: () {
                  if (user.isSeller) {
                    context.push('/seller-dashboard');
                  } else {
                    context.push('/seller-request');
                  }
                },
              ),
              _buildOptionTile(
                icon: Icons.favorite_rounded,
                title: 'Saved Favorites',
                subtitle: 'View saved properties and vehicles',
                color: Colors.redAccent,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Favorites synced with your EasyDeal account')),
                  );
                },
              ),
              _buildOptionTile(
                icon: Icons.help_outline_rounded,
                title: 'Help Center & FAQs',
                subtitle: 'Customer support, tokens & subscription guide',
                color: AppColors.propertyAccent,
                onTap: () => _showHelpCenterModal(context),
              ),
              _buildOptionTile(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profile Information',
                subtitle: 'Update location, phone number, and occupation',
                color: AppColors.textSecondary,
                onTap: () => context.push('/edit-profile'),
              ),
              _buildOptionTile(
                icon: Icons.lock_reset_rounded,
                title: 'Change Password',
                subtitle: 'Update your account security password',
                color: AppColors.textSecondary,
                onTap: () => _showChangePasswordDialog(context, ref),
              ),
              const SizedBox(height: 12),
              _buildOptionTile(
                icon: Icons.logout_rounded,
                title: 'Log Out',
                subtitle: 'Sign out of your session',
                color: AppColors.error,
                onTap: () => _confirmLogout(context, ref),
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out?'),
        content: const Text('Are you sure you want to sign out from EasyDeal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authControllerProvider.notifier).logout();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final oldPass = TextEditingController();
    final newPass = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldPass,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current Password'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newPass,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password (min 6 chars)'),
                validator: (val) => val == null || val.length < 6 ? 'Min 6 characters' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final repo = ref.read(authRepositoryProvider);
                final res = await repo.changePassword(
                  oldPassword: oldPass.text,
                  newPassword: newPass.text,
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res.isSuccess ? 'Password changed successfully' : (res.message ?? 'Error changing password')),
                      backgroundColor: res.isSuccess ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.help_center_rounded, color: AppColors.primary, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Help Center & Support',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFaqItem(
                'How does ₹999 Token Booking work?',
                'A token booking reserves the vehicle or property exclusively while you inspect it in person. The seller is instantly notified and provides direct inspection access.',
              ),
              _buildFaqItem(
                'What benefits does EasyDeal Gold include?',
                'Gold members get instant access to verified owner phone numbers, direct WhatsApp chat, unblurred full HD galleries, and priority notifications for ₹299/mo.',
              ),
              _buildFaqItem(
                'How do I post a listing?',
                'Tap the "+" Post Ad button in the bottom navigation bar to list your property or vehicle in three simple steps.',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.headset_mic_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Need immediate assistance?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('Email: support@easydealworld.com\nWhatsApp: +91 98765 43210', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          Text(answer, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35)),
        ],
      ),
    );
  }
}
