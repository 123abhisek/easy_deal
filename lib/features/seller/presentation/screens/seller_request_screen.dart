import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../controllers/seller_controller.dart';

class SellerRequestScreen extends ConsumerStatefulWidget {
  const SellerRequestScreen({super.key});

  @override
  ConsumerState<SellerRequestScreen> createState() => _SellerRequestScreenState();
}

class _SellerRequestScreenState extends ConsumerState<SellerRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _idProofController = TextEditingController();
  final _commentsController = TextEditingController();
  String _businessType = 'Agency / Broker';
  bool _isLoading = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    _idProofController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final repo = ref.read(sellerRepositoryProvider);
    final response = await repo.submitSellerRequest(
      businessName: _businessNameController.text.trim(),
      businessType: _businessType,
      location: _addressController.text.trim(),
      description: _commentsController.text.trim().isNotEmpty
          ? _commentsController.text.trim()
          : 'Business ID: ${_idProofController.text.trim()}',
    );
    setState(() => _isLoading = false);

    if (mounted) {
      if (response.isSuccess) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                SizedBox(width: 8),
                Text('Application Sent!'),
              ],
            ),
            content: const Text(
              'Your seller onboarding verification request has been submitted to the admin moderation team. You will be notified once verified.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.pop();
                },
                child: const Text('Back to Profile'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Submission error'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Verified Seller'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.storefront_rounded, color: AppColors.primary, size: 32),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seller Onboarding Hub',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Get a verified seller badge, listing priority, and direct buyer token alerts.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                CustomTextField(
                  controller: _businessNameController,
                  label: 'Business / Agency / Individual Name',
                  hint: 'e.g. Prestige Realty Experts / John Auto Deals',
                  validator: (val) => Validators.requiredField(val, 'Name is required'),
                ),
                const SizedBox(height: 16),

                const Text('Seller Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _businessType,
                  decoration: const InputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'Agency / Broker', child: Text('Real Estate Agency / Broker')),
                    DropdownMenuItem(value: 'Car Dealer', child: Text('Automotive Dealer / Showroom')),
                    DropdownMenuItem(value: 'Individual Seller', child: Text('Individual Property/Car Owner')),
                    DropdownMenuItem(value: 'Builder / Developer', child: Text('Builder / Developer')),
                  ],
                  onChanged: (val) => setState(() => _businessType = val!),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _addressController,
                  label: 'Registered Office / Operating Address',
                  hint: 'Full physical office address',
                  maxLines: 2,
                  validator: (val) => Validators.requiredField(val, 'Address is required'),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _idProofController,
                  label: 'GST Number or Aadhar / PAN',
                  hint: 'e.g. 29ABCDE1234F1Z5 or PAN',
                  validator: (val) => Validators.requiredField(val, 'Identity proof number is required'),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _commentsController,
                  label: 'Portfolio / Experience (Optional)',
                  hint: 'Number of active listings, deals closed per year...',
                  maxLines: 3,
                ),
                const SizedBox(height: 28),

                PrimaryButton(
                  text: 'Submit Application',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
