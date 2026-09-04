import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../providers/patient_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/index.dart';
import 'add_patient_screen.dart';
import 'patient_profile_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterRisk = 'all';
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Patients',
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar with animation
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
            child: CustomTextField(
              controller: _searchController,
              hint: 'Search patients by name or village',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        patientProvider.loadPatients();
                        setState(() {});
                      },
                    )
                  : null,
              onChanged: (value) {
                setState(() {});
                if (value.isEmpty) {
                  patientProvider.loadPatients();
                } else {
                  patientProvider.searchPatients(value);
                }
              },
            ),
          ).animate().fadeIn(duration: 300.ms),

          // Animated filter chips
          if (_showFilters)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingLg),
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', _filterRisk == 'all'),
                  const SizedBox(width: AppSpacing.md),
                  _buildFilterChip('Low Risk', 'low', _filterRisk == 'low'),
                  const SizedBox(width: AppSpacing.md),
                  _buildFilterChip('Medium Risk', 'medium', _filterRisk == 'medium'),
                  const SizedBox(width: AppSpacing.md),
                  _buildFilterChip('High Risk', 'high', _filterRisk == 'high'),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(
              begin: -0.2,
              end: 0,
              duration: 300.ms,
            ),
          const SizedBox(height: AppSpacing.md),

          // Patient list or empty state
          Expanded(
            child: patientProvider.isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Loading patients...',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : patientProvider.patients.isEmpty
                    ? _buildEmptyState()
                    : _buildPatientList(patientProvider),
          ),
        ],
      ),
      floatingActionButton: PulsingFAB(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddPatientScreen()),
          );
        },
        icon: Icons.person_add,
        tooltip: 'Add Patient',
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool selected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (isSelected) {
        setState(() {
          _filterRisk = value;
          final patientProvider = Provider.of<PatientProvider>(context, listen: false);
          if (value == 'all') {
            patientProvider.loadPatients();
          } else {
            patientProvider.filterByRiskLevel(value);
          }
        });
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
        width: selected ? 2 : 1,
      ),
      labelStyle: AppTypography.labelMedium.copyWith(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    ).animate().scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1, 1),
      duration: 300.ms,
      curve: Curves.easeOut,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: const Icon(
              Icons.person_add_alt,
              size: 40,
              color: AppColors.primary,
            ),
          ).animate().scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1, 1),
            duration: 400.ms,
            curve: Curves.elasticOut,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No Patients Yet',
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tap the + button to add your first patient',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          CustomButton(
            text: 'Add Patient',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddPatientScreen()),
              );
            },
            variant: ButtonVariant.primary,
            size: ButtonSize.medium,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildPatientList(PatientProvider patientProvider) {
    return RefreshIndicator(
      onRefresh: () async {
        await patientProvider.loadPatients();
      },
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPaddingLg,
            vertical: AppSpacing.md,
          ),
          itemCount: patientProvider.patients.length,
          itemBuilder: (context, index) {
            final patient = patientProvider.patients[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildPatientCard(patient),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPatientCard(patient) {
    // Determine risk level from last screening
    String riskLevel = 'low';
    if (patient.lastScreening != null) {
      riskLevel = patient.lastScreening!.riskLevel ?? 'low';
    }

    final cardVariant = riskLevel == 'high'
        ? CardVariant.riskHigh
        : riskLevel == 'medium'
            ? CardVariant.riskMedium
            : CardVariant.riskLow;

    return CustomCard(
      variant: cardVariant,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PatientProfileScreen(patientId: patient.id!),
          ),
        );
      },
      isClickable: true,
      child: Row(
        children: [
          // Avatar with risk color
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.getRiskSurfaceColor(riskLevel),
            child: Text(
              patient.name.substring(0, 1).toUpperCase(),
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.getRiskColor(riskLevel),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Patient info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: AppSpacing.iconSm,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${patient.age} yrs • ${patient.gender}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (patient.village != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: AppSpacing.iconSm,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          patient.village!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Risk badge and arrow
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.getRiskColor(riskLevel).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  riskLevel.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.getRiskColor(riskLevel),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
