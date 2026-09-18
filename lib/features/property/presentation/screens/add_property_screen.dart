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
import '../controllers/property_controller.dart';

class AddPropertyScreen extends ConsumerStatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  ConsumerState<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddPropertyScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  // Step 1: Basic Info & Location
  String _propertyType = 'Flat';
  String _rentLease = 'Sale';
  final _titleController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _cityController = TextEditingController(text: 'Bangalore');
  final _stateController = TextEditingController(text: 'Karnataka');
  final _locationController = TextEditingController();

  // Step 2: Specs & Price
  final _priceController = TextEditingController();
  final _bedroomsController = TextEditingController(text: '3');
  final _roomsController = TextEditingController(text: '4');
  final _areaController = TextEditingController(text: '1500');
  final _floorController = TextEditingController(text: '3rd Floor');
  String _furnishing = 'Semi-Furnished';
  String _facing = 'East';
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
    _apartmentController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _bedroomsController.dispose();
    _roomsController.dispose();
    _areaController.dispose();
    _floorController.dispose();
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
        const SnackBar(content: Text('Please upload at least 1 photo for your listing'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    final repo = ref.read(propertyRepositoryProvider);
    final data = {
      'title': _titleController.text.trim(),
      'property_type': _propertyType,
      'rent_lease': _rentLease,
      'location': '${_locationController.text.trim()}, ${_cityController.text.trim()}, ${_stateController.text.trim()}',
      'apartment_name': _apartmentController.text.trim(),
      'floor': _floorController.text.trim(),
      'bedrooms': int.tryParse(_bedroomsController.text) ?? 2,
      'rooms': int.tryParse(_roomsController.text) ?? 3,
      'area': double.tryParse(_areaController.text) ?? 1000.0,
      'price': double.tryParse(_priceController.text.replaceAll(',', '')) ?? 5000000.0,
      'contact': _contactController.text.trim(),
      'facing': _facing,
      'furnishing': _furnishing,
      'images': _images,
    };

    final response = await repo.addProperty(data);
    setState(() => _isLoading = false);

    if (mounted) {
      if (response.isSuccess) {
        ref.read(propertyListControllerProvider.notifier).fetchProperties();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                SizedBox(width: 8),
                Text('Listing Submitted!'),
              ],
            ),
            content: const Text(
              'Your property listing has been successfully submitted and is live on the marketplace.',
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
        title: const Text('Add Property Listing'),
      ),
      body: Column(
        children: [
          // Step Progress Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                _buildStepPill(0, 'Basic Info'),
                _buildStepConnector(0),
                _buildStepPill(1, 'Specs & Price'),
                _buildStepConnector(1),
                _buildStepPill(2, 'Photos & Contact'),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Scrollable Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildCurrentStepContent(),
            ),
          ),

          // Navigation buttons
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
                      backgroundColor: AppColors.propertyAccent,
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
          backgroundColor: isActive ? AppColors.propertyAccent : AppColors.surfaceVariant,
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
        color: isActive ? AppColors.propertyAccent : AppColors.border,
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
                'Step 1: Property Basics & Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),

              // Property Type Dropdown
              const Text('Property Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _propertyType,
                decoration: const InputDecoration(),
                items: const [
                  DropdownMenuItem(value: 'Flat', child: Text('Apartment / Flat')),
                  DropdownMenuItem(value: 'House', child: Text('Independent House / Villa')),
                  DropdownMenuItem(value: 'Plot', child: Text('Residential Plot / Land')),
                  DropdownMenuItem(value: 'Commercial', child: Text('Commercial Space / Office')),
                  DropdownMenuItem(value: 'Agricultural Land', child: Text('Agricultural Land / Farm')),
                ],
                onChanged: (val) => setState(() => _propertyType = val!),
              ),
              const SizedBox(height: 16),

              // Purpose (Sale / Rent)
              const Text('Listing Purpose', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Sale', label: Text('For Sale')),
                  ButtonSegment(value: 'Rent', label: Text('For Rent')),
                  ButtonSegment(value: 'Lease', label: Text('For Lease')),
                ],
                selected: {_rentLease},
                onSelectionChanged: (set) => setState(() => _rentLease = set.first),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _titleController,
                label: 'Listing Title',
                hint: 'e.g. Spacious 3BHK Apartment with Balcony',
                validator: (val) => Validators.requiredField(val, 'Listing title is required'),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _apartmentController,
                label: 'Society / Project Name (Optional)',
                hint: 'e.g. Prestige Ozone, Sobha Dream',
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
                hint: 'e.g. Whitefield, Indiranagar',
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
                    child: _buildStepperField(
                      label: 'Bedrooms',
                      controller: _bedroomsController,
                      unit: 'BHK',
                      min: 1,
                      max: 10,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStepperField(
                      label: 'Bathrooms',
                      controller: _roomsController,
                      unit: 'Baths',
                      min: 1,
                      max: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _areaController,
                      label: 'Area (sq.ft)',
                      hint: '1850',
                      keyboardType: TextInputType.number,
                      validator: (val) => Validators.positiveNumber(val, 'Area'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _floorController,
                      label: 'Floor Details',
                      hint: '4th Floor of 12',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Furnishing', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _furnishing,
                    decoration: const InputDecoration(),
                    items: const [
                      DropdownMenuItem(value: 'Unfurnished', child: Text('Unfurnished')),
                      DropdownMenuItem(value: 'Semi-Furnished', child: Text('Semi-Furnished')),
                      DropdownMenuItem(value: 'Fully Furnished', child: Text('Fully Furnished')),
                    ],
                    onChanged: (val) => setState(() => _furnishing = val!),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Price with live verbal Indian Rupee preview
              CustomTextField(
                controller: _priceController,
                label: 'Expected Price (₹)',
                hint: 'e.g. 8500000',
                keyboardType: TextInputType.number,
                validator: (val) => Validators.positiveNumber(val, 'Price'),
              ),
              if (_priceInWords.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.propertyAccentLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.propertyAccent.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💬  ', style: TextStyle(fontSize: 14)),
                      Text(
                        _priceInWords,
                        style: const TextStyle(
                          color: AppColors.propertyAccent,
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
                'Add high-quality photos. Verified gold users will be able to see them in full HD.',
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
                  // Add Photo Button
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
                          Icon(Icons.add_a_photo_outlined, color: AppColors.propertyAccent, size: 28),
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
              const SizedBox(height: 12),
              const Text(
                'Note: Your phone number is masked for free visitors and only visible to verified Gold members.',
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary, height: 1.3),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepperField({
    required String label,
    required TextEditingController controller,
    required String unit,
    int min = 1,
    int max = 15,
  }) {
    final currentVal = int.tryParse(controller.text) ?? min;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                color: currentVal > min ? AppColors.propertyAccent : AppColors.textTertiary,
                onPressed: currentVal > min
                    ? () {
                        setState(() {
                          controller.text = (currentVal - 1).toString();
                        });
                      }
                    : null,
              ),
              Text(
                '$currentVal $unit',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                color: currentVal < max ? AppColors.propertyAccent : AppColors.textTertiary,
                onPressed: currentVal < max
                    ? () {
                        setState(() {
                          controller.text = (currentVal + 1).toString();
                        });
                      }
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
