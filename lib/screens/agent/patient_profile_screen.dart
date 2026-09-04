import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/screening.dart';
import '../../providers/patient_provider.dart';
import '../../providers/screening_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/index.dart';

class PatientProfileScreen extends StatefulWidget {
  final int patientId;

  const PatientProfileScreen({super.key, required this.patientId});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);
    final screeningProvider = Provider.of<ScreeningProvider>(context, listen: false);

    await patientProvider.loadPatientById(widget.patientId);
    await screeningProvider.loadScreeningsByPatient(widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);
    final screeningProvider = Provider.of<ScreeningProvider>(context);
    final patient = patientProvider.selectedPatient;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: patient?.name ?? 'Patient Profile',
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement edit patient
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: patientProvider.isLoading
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
                    'Loading patient profile...',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : patient == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Patient Not Found',
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      CustomButton(
                        text: 'Go Back',
                        onPressed: () => Navigator.pop(context),
                        variant: ButtonVariant.primary,
                        size: ButtonSize.medium,
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header card with patient info
                        _buildPatientHeader(patient).animate().fadeIn(duration: 300.ms),
                        const SizedBox(height: AppSpacing.xl),

                        // Patient details
                        Text(
                          'Patient Information',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                        const SizedBox(height: AppSpacing.md),
                        _buildPatientDetails(patient)
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 150.ms),
                        const SizedBox(height: AppSpacing.xl),

                        // Screening history
                        Text(
                          'Screening History',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                        const SizedBox(height: AppSpacing.md),
                        _buildScreeningHistory(screeningProvider.screenings)
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 250.ms),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildPatientHeader(patient) {
    final riskLevel = patient.lastScreening?.riskLevel ?? 'low';
    final riskColor = AppColors.getRiskColor(riskLevel);

    return CustomCard(
      variant: CardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.getRiskSurfaceColor(riskLevel),
            child: Text(
              patient.name.substring(0, 1).toUpperCase(),
              style: AppTypography.displaySmall.copyWith(
                color: riskColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${patient.age} years • ${patient.gender}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
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
          if (patient.lastScreening != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.getRiskSurfaceColor(riskLevel),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Column(
                children: [
                  Text(
                    riskLevel.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: riskColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${(patient.lastScreening!.confidence ?? 0).toInt()}%',
                    style: AppTypography.labelSmall.copyWith(
                      color: riskColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPatientDetails(patient) {
    return CustomCard(
      variant: CardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
      child: Column(
        children: [
          _buildDetailRow('ID:', patient.id?.toString() ?? 'N/A'),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow('Phone:', patient.phoneNumber ?? 'N/A'),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow('Occupation:', patient.occupation ?? 'N/A'),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow('Height:', patient.height != null ? '${patient.height} cm' : 'N/A'),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow('Weight:', patient.weight != null ? '${patient.weight} kg' : 'N/A'),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow(
            'Added:',
            DateFormat('MMM dd, yyyy').format(patient.createdAt ?? DateTime.now()),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildScreeningHistory(List<Screening> screenings) {
    if (screenings.isEmpty) {
      return CustomCard(
        variant: CardVariant.elevated,
        padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
        child: Column(
          children: [
            Icon(
              Icons.assignment,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Screenings Yet',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(
        screenings.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _buildScreeningTimelineItem(screenings[index], index),
        ),
      ),
    );
  }

  Widget _buildScreeningTimelineItem(Screening screening, int index) {
    final riskColor = AppColors.getRiskColor(screening.riskLevel ?? 'low');
    final isLast = index == 0; // Most recent first

    return CustomCard(
      variant: screening.riskLevel == 'high'
          ? CardVariant.riskHigh
          : screening.riskLevel == 'medium'
              ? CardVariant.riskMedium
              : CardVariant.riskLow,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: riskColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (isLast)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(color: riskColor, width: 2),
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (controller) => controller.repeat()).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.3, 1.3),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeInOut,
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),

          // Screening details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(screening.screeningDate ?? DateTime.now()),
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.getRiskSurfaceColor(screening.riskLevel ?? 'low'),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        '${(screening.confidence ?? 0).toInt()}%',
                        style: AppTypography.labelSmall.copyWith(
                          color: riskColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Risk Level: ${(screening.riskLevel ?? 'low').toUpperCase()}',
                  style: AppTypography.bodySmall.copyWith(
                    color: riskColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (screening.contributingFactors != null &&
                    screening.contributingFactors!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Factors: ${screening.contributingFactors}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // View details arrow
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    ).animate().slideX(
      begin: -0.2,
      end: 0,
      duration: 300.ms,
      delay: Duration(milliseconds: 50 * index),
      curve: Curves.easeOut,
    );
  }
}
