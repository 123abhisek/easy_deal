import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/vehicle_controller.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  // Step 1: Identity & Location
  final _titleController = TextEditingController();
  final _brandController = TextEditingController(text: 'Hyundai');
  final _modelController = TextEditingController();
  final _yearController = TextEditingController(text: '2022');
  final _cityController = TextEditingController(text: 'Bangalore');
  final _stateController = TextEditingController(text: 'Karnataka');
  final _locationController = TextEditingController();

  // Step 2: Specs & Price
  final _vehicleNumberController = TextEditingController();
  final _rtoCodeController = TextEditingController(text: 'KA01');
  final _kmDrivenController = TextEditingController();
  final _priceController = TextEditingController();
  String _fuelType = 'Petrol';
  String _transmission = 'Automatic';
  String _ownerCount = '1st Owner';
  String _priceInWords = '';

  // Step 3: Photos & Contact
  final _contactController = TextEditingController();
  final List<String> _images = [];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    if (user != null && user.phone != null) {
      _contactController.text = user.phone!;
    }
    _priceController.addListener(() {
      final val = num.tryParse(_priceController.text.replaceAll(',', '').trim());
      setState(() {
        _priceInWords = CurrencyHelper.toWords(val);
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _locationController.dispose();
    _vehicleNumberController.dispose();
    _rtoCodeController.dispose();
    _kmDrivenController.dispose();
    _priceController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final b64 = await ImageHelper.pickImageAsBase64();
    if (b64 != null) {
      setState(() {
        _images.add(b64);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submitListing() async {
    if (!_step3Key.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least 1 photo for your vehicle'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    final repo = ref.read(vehicleRepositoryProvider);
    final data = {
      'title': _titleController.text.trim(),
      'brand': _brandController.text.trim(),
      'model': _modelController.text.trim(),
      'year': _yearController.text.trim(),
      'vehicleNumber': _vehicleNumberController.text.trim(),
      'rtoCode': _rtoCodeController.text.trim(),
      'kmDriven': _kmDrivenController.text.trim(),
      'fuelType': _fuelType,
      'transmission': _transmission,
      'ownerCount': _ownerCount,
      'location': '${_locationController.text.trim()}, ${_cityController.text.trim()}',
      'state': _stateController.text.trim(),
      'expectedPrice': double.tryParse(_priceController.text.replaceAll(',', '')) ?? 1000000.0,
      'contactNumber': _contactController.text.trim(),
      'images': _images,
    };

    final response = await repo.addVehicle(data);
    setState(() => _isLoading = false);

    if (mounted) {
      if (response.isSuccess) {
        ref.read(vehicleListControllerProvider.notifier).fetchVehicles();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                SizedBox(width: 8),
                Text('Vehicle Listed!'),
              ],
            ),
            content: const Text(
              'Your vehicle listing has been published to the marketplace.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.pop();
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Submission failed'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_step1Key.currentState!.validate()) return;
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (!_step2Key.currentState!.validate()) return;
      setState(() => _currentStep = 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle Listing'),
      ),
      body: Column(
        children: [
          // Step Progress Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                _buildStepPill(0, 'Identity'),
                _buildStepConnector(0),
                _buildStepPill(1, 'Specs & Price'),
                _buildStepConnector(1),
                _buildStepPill(2, 'Photos & Contact'),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildCurrentStepContent(),
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep -= 1),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      text: _currentStep == 2 ? 'Submit Listing' : 'Continue',
                      isLoading: _isLoading,
                      backgroundColor: AppColors.vehicleAccent,
                      onPressed: _currentStep == 2 ? _submitListing : _nextStep,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepPill(int step, String label) {
    final isActive = _currentStep >= step;
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isActive ? AppColors.vehicleAccent : AppColors.surfaceVariant,
          child: Text(
            '${step + 1}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int step) {
    final isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? AppColors.vehicleAccent : AppColors.border,
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return Form(
          key: _step1Key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Step 1: Vehicle Identity & Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: _titleController,
                label: 'Listing Title',
                hint: 'e.g. 2022 Hyundai Creta SX (O) Turbo Petrol',
                validator: (val) => Validators.requiredField(val, 'Listing title is required'),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _brandController,
                      label: 'Brand / Make',
                      hint: 'e.g. Hyundai, Toyota',
                      validator: (val) => Validators.requiredField(val, 'Brand is required'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _modelController,
                      label: 'Model / Variant',
                      hint: 'e.g. Creta SX (O)',
                      validator: (val) => Validators.requiredField(val, 'Model is required'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _yearController,
                label: 'Manufacture Year',
                hint: '2022',
                keyboardType: TextInputType.number,
                validator: (val) => Validators.requiredField(val, 'Year is required'),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'Bangalore',
                      validator: (val) => Validators.requiredField(val, 'City is required'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _stateController,
                      label: 'State',
                      hint: 'Karnataka',
                      validator: (val) => Validators.requiredField(val, 'State is required'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _locationController,
                label: 'Locality / Area',
                hint: 'e.g. Koramangala, Indiranagar',
                validator: (val) => Validators.requiredField(val, 'Locality is required'),
              ),
            ],
          ),
        );

      case 1:
        return Form(
          key: _step2Key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Step 2: Specifications & Price',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _kmDrivenController,
                      label: 'KM Driven',
                      hint: 'e.g. 28500',
                      keyboardType: TextInputType.number,
                      validator: (val) => Validators.positiveNumber(val, 'KM Driven'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _rtoCodeController,
                      label: 'RTO Code',
                      hint: 'e.g. KA01',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _vehicleNumberController,
                label: 'Vehicle Number (Optional / Partial)',
                hint: 'e.g. KA-01-MJ-1234',
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fuel Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _fuelType,
                          decoration: const InputDecoration(),
                          items: const [
                            DropdownMenuItem(value: 'Petrol', child: Text('Petrol')),
                            DropdownMenuItem(value: 'Diesel', child: Text('Diesel')),
                            DropdownMenuItem(value: 'Electric', child: Text('Electric (EV)')),
                            DropdownMenuItem(value: 'CNG', child: Text('CNG')),
                            DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                          ],
                          onChanged: (val) => setState(() => _fuelType = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Transmission', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _transmission,
                          decoration: const InputDecoration(),
                          items: const [
                            DropdownMenuItem(value: 'Automatic', child: Text('Automatic')),
                            DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                          ],
                          onChanged: (val) => setState(() => _transmission = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text('Ownership', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: '1st Owner', label: Text('1st Owner')),
                  ButtonSegment(value: '2nd Owner', label: Text('2nd Owner')),
                  ButtonSegment(value: '3rd+ Owner', label: Text('3rd+')),
                ],
                selected: {_ownerCount},
                onSelectionChanged: (set) => setState(() => _ownerCount = set.first),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _priceController,
                label: 'Expected Price (₹)',
                hint: 'e.g. 1450000',
                keyboardType: TextInputType.number,
                validator: (val) => Validators.positiveNumber(val, 'Expected Price'),
              ),
              if (_priceInWords.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.vehicleAccentLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.vehicleAccent.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💬  ', style: TextStyle(fontSize: 14)),
                      Text(
                        _priceInWords,
                        style: const TextStyle(
                          color: AppColors.vehicleAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );

      case 2:
        return Form(
          key: _step3Key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Step 3: Photos & Seller Contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Add clear exterior & interior photos. Verified gold users will be able to see them in full HD.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Photos Grid
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ...List.generate(_images.length, (index) {
                    final imgStr = _images[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: imgStr.startsWith('data:')
                                ? Image.memory(
                                    base64Decode(imgStr.split(',').last),
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(imgStr, fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black87,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, color: AppColors.vehicleAccent, size: 28),
                          SizedBox(height: 4),
                          Text('Add Photo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              CustomTextField(
                controller: _contactController,
                label: 'Direct Contact Phone',
                hint: '9876543210',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                validator: Validators.phone,
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
