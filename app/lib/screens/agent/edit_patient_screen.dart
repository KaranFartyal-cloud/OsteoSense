import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/patient_provider.dart';
import '../../models/patient.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_motion.dart';
import '../../widgets/common/index.dart';

class EditPatientScreen extends StatefulWidget {
  final Patient? patient;
  const EditPatientScreen({super.key, required this.patient});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _contactController;
  late final TextEditingController _villageController;
  late final TextEditingController _addressController;
  late final TextEditingController _occupationController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late String _gender;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    if (p != null) {
      _nameController = TextEditingController(text: p.name);
      _ageController = TextEditingController(text: p.age.toString());
      _contactController = TextEditingController(text: p.contact ?? '');
      _villageController = TextEditingController(text: p.village ?? '');
      _addressController = TextEditingController(text: p.address ?? '');
      _occupationController = TextEditingController(text: p.occupation ?? '');
      _gender = p.gender;
    } else {
      _nameController = TextEditingController();
      _ageController = TextEditingController();
      _contactController = TextEditingController();
      _villageController = TextEditingController();
      _addressController = TextEditingController();
      _occupationController = TextEditingController();
      _gender = 'male';
    }
    _heightController = TextEditingController();
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _villageController.dispose();
    _addressController.dispose();
    _occupationController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final patientProvider = context.read<PatientProvider>();
    if (widget.patient == null) return; // Can't save without a base patient

    final updated = widget.patient!.copyWith(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text),
      gender: _gender,
      contact: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
      village: _villageController.text.trim().isEmpty ? null : _villageController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      occupation: _occupationController.text.trim().isEmpty ? null : _occupationController.text.trim(),
      updatedAt: DateTime.now(),
      synced: false,
    );

    final success = await patientProvider.updatePatient(updated);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Patient updated successfully'),
          ]),
          backgroundColor: AppColors.riskLow,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
        ),
      );
      Navigator.of(context).pop(updated); // Return updated patient
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(patientProvider.errorMessage ?? 'Failed to update patient'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = context.watch<PatientProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Edit Patient',
        centerTitle: false,
        showBackButton: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: TextButton(
              onPressed: patientProvider.isLoading ? null : _saveChanges,
              child: Text(
                'Save',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
          children: [
            // ── Header
            _buildSectionHeader('Personal Information', Icons.person_outline),
            const SizedBox(height: AppSpacing.md),

            CustomTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter patient\'s full name',
              prefixIcon: const Icon(Icons.person_outline),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ).animate().fadeIn(duration: AppMotion.standard, delay: 50.ms).slideY(begin: 0.1, end: 0, duration: AppMotion.standard),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _ageController,
                    label: 'Age',
                    hint: 'Years',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.cake_outlined),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final age = int.tryParse(v);
                      if (age == null || age < 1 || age > 120) return 'Invalid age';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildGenderPicker(),
                ),
              ],
            ).animate().fadeIn(duration: AppMotion.standard, delay: 100.ms).slideY(begin: 0.1, end: 0, duration: AppMotion.standard),
            const SizedBox(height: AppSpacing.md),

            CustomTextField(
              controller: _occupationController,
              label: 'Occupation',
              hint: 'e.g., Farmer, Teacher',
              prefixIcon: const Icon(Icons.work_outline),
            ).animate().fadeIn(duration: AppMotion.standard, delay: 150.ms).slideY(begin: 0.1, end: 0, duration: AppMotion.standard),

            const SizedBox(height: AppSpacing.xl),
            _buildSectionHeader('Contact & Location', Icons.location_on_outlined),
            const SizedBox(height: AppSpacing.md),

            CustomTextField(
              controller: _contactController,
              label: 'Phone Number',
              hint: '10-digit mobile number',
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined),
            ).animate().fadeIn(duration: AppMotion.standard, delay: 200.ms).slideY(begin: 0.1, end: 0, duration: AppMotion.standard),
            const SizedBox(height: AppSpacing.md),

            CustomTextField(
              controller: _villageController,
              label: 'Village',
              hint: 'Village or town name',
              prefixIcon: const Icon(Icons.location_city_outlined),
            ).animate().fadeIn(duration: AppMotion.standard, delay: 250.ms).slideY(begin: 0.1, end: 0, duration: AppMotion.standard),
            const SizedBox(height: AppSpacing.md),

            CustomTextField(
              controller: _addressController,
              label: 'Full Address',
              hint: 'Block, district, state',
              maxLines: 2,
              keyboardType: TextInputType.streetAddress,
              prefixIcon: const Icon(Icons.home_outlined),
            ).animate().fadeIn(duration: AppMotion.standard, delay: 300.ms).slideY(begin: 0.1, end: 0, duration: AppMotion.standard),

            const SizedBox(height: AppSpacing.xl),
            _buildSectionHeader('Physical Measurements', Icons.straighten_outlined),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _heightController,
                    label: 'Height (cm)',
                    hint: 'e.g., 165',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.height),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: CustomTextField(
                    controller: _weightController,
                    label: 'Weight (kg)',
                    hint: 'e.g., 70',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: AppMotion.standard, delay: 350.ms).slideY(begin: 0.1, end: 0, duration: AppMotion.standard),

            const SizedBox(height: AppSpacing.xxl),

            CustomButton(
              text: 'Save Changes',
              onPressed: patientProvider.isLoading ? null : _saveChanges,
              variant: ButtonVariant.primary,
              size: ButtonSize.large,
              fullWidth: true,
              isLoading: patientProvider.isLoading,
              icon: const Icon(Icons.check_rounded),
            ).animate().fadeIn(duration: AppMotion.standard, delay: 400.ms),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: AppTypography.semiBold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Container(height: 1, color: AppColors.border)),
      ],
    );
  }

  Widget _buildGenderPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gender', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          DropdownButton<String>(
            value: _gender,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => _gender = v!),
          ),
        ],
      ),
    );
  }
}
