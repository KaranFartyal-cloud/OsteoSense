import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../providers/patient_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_motion.dart';
import '../../widgets/common/index.dart';
import 'add_patient_screen.dart';
import 'patient_profile_screen.dart';
import 'package:animations/animations.dart';
import '../../widgets/common/open_container_card.dart';

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
          ).animate().fadeIn(duration: 400.ms),

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
            ).animate().fadeIn(duration: AppMotion.fast).slideY(
              begin: -0.2,
              end: 0,
              duration: AppMotion.fast,
            ),
          const SizedBox(height: AppSpacing.md),

          // Patient list or empty state
          Expanded(
            child: patientProvider.isLoading
                // Use skeleton loader instead of spinner
                ? const SkeletonPage(listItemCount: 6)
                : patientProvider.patients.isEmpty
                    ? _buildEmptyState()
                    : _buildPatientList(patientProvider),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.05, end: 0, duration: 400.ms, delay: 100.ms),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
      floatingActionButton: OpenContainer<void>(
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: AppMotion.normal,
        closedElevation: 0,
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        closedColor: Colors.transparent,
        openColor: AppColors.background,
        closedBuilder: (context, openContainer) {
          return PulsingFAB(
            onPressed: openContainer,
            icon: Icons.person_add,
            tooltip: 'Add Patient',
          );
        },
        openBuilder: (context, closeContainer) {
          return const AddPatientScreen();
        },
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
      duration: AppMotion.fast,
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
            duration: AppMotion.slow,
            curve: Curves.easeOut,
          ).then() // gentle floating animation - subtle idle
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            )
            .moveY(
              begin: 0,
              end: -4,
              duration: 3000.ms,
              curve: Curves.easeInOut,
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
    ).animate().fadeIn(duration: AppMotion.slow);
  }

  Widget _buildPatientList(PatientProvider patientProvider) {
    return RefreshIndicator(
      color: AppColors.primary,
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
              duration: AppMotion.slow,
              delay: Duration(milliseconds: index * 35), // 35ms stagger
              child: SlideAnimation(
                verticalOffset: AppMotion.listSlideOffset,
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
    String riskLevel = 'low';
    if (patient.lastScreening != null) {
      riskLevel = patient.lastScreening!.riskLevel ?? 'low';
    }
    final cardVariant = riskLevel == 'high'
        ? CardVariant.riskHigh
        : riskLevel == 'medium'
            ? CardVariant.riskMedium
            : CardVariant.riskLow;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: OpenContainerCard(
        openBuilder: (context) => PatientProfileScreen(patientId: patient.id!),
        closedChild: CustomCard(
          variant: cardVariant,
          padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.getRiskSurfaceColor(riskLevel),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.getRiskBorderColor(riskLevel).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    patient.name.substring(0, 1).toUpperCase(),
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.getRiskColor(riskLevel),
                      fontWeight: FontWeight.bold,
                    ),
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
                    Text(
                      '${patient.age} yrs • ${patient.gender}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (patient.village != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: AppSpacing.iconSm,
                              color: AppColors.textSecondary),
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
              const SizedBox(width: AppSpacing.sm),
              // Risk badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.getRiskColor(riskLevel).withValues(alpha: 0.15),
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
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: AppColors.textTertiary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
