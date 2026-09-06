import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/screening.dart';
import '../../models/patient.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_motion.dart';
import '../../widgets/common/index.dart';
import 'pdf_preview_screen.dart';

class DetailedReportScreen extends StatelessWidget {
  final Screening screening;
  final Patient patient;

  const DetailedReportScreen({
    super.key,
    required this.screening,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final riskColor = AppColors.getRiskColor(screening.riskLevel ?? 'low');
    final dateStr = DateFormat('d MMM yyyy, h:mm a').format(screening.screeningDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Full Report',
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'PDF Preview',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PdfPreviewScreen(screening: screening, patient: patient),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Patient header card
            _buildPatientHeaderCard(context, riskColor)
                .animate().fadeIn(duration: AppMotion.standard).slideY(begin: -0.1, end: 0, duration: AppMotion.standard, curve: AppMotion.curve),

            const SizedBox(height: AppSpacing.xl),

            // ── Risk result banner
            _buildRiskBanner(riskColor, dateStr)
                .animate().fadeIn(duration: AppMotion.standard, delay: 80.ms).slideY(begin: 0.08, end: 0, duration: AppMotion.standard, curve: AppMotion.curve),

            const SizedBox(height: AppSpacing.xl),

            // ── Symptom answers
            _buildSectionTitle('Symptom Questionnaire', Icons.assignment_outlined),
            const SizedBox(height: AppSpacing.md),
            _buildSymptomsCard()
                .animate().fadeIn(duration: AppMotion.standard, delay: 160.ms),

            const SizedBox(height: AppSpacing.xl),

            // ── Gait data
            if (screening.gaitData != null) ...[
              _buildSectionTitle('Gait Analysis', Icons.directions_walk_rounded),
              const SizedBox(height: AppSpacing.md),
              _buildGaitCard()
                  .animate().fadeIn(duration: AppMotion.standard, delay: 240.ms),
              const SizedBox(height: AppSpacing.xl),
            ],

            // ── Contributing factors
            _buildSectionTitle('Contributing Factors', Icons.analytics_outlined),
            const SizedBox(height: AppSpacing.md),
            _buildFactorsCard(riskColor)
                .animate().fadeIn(duration: AppMotion.standard, delay: 320.ms),

            const SizedBox(height: AppSpacing.xl),

            // ── AI Reasoning
            if (screening.aiReasoning != null) ...[
              _buildSectionTitle('AI Clinical Reasoning', Icons.psychology_outlined),
              const SizedBox(height: AppSpacing.md),
              _buildReasoningCard()
                  .animate().fadeIn(duration: AppMotion.standard, delay: 400.ms),
              const SizedBox(height: AppSpacing.xl),
            ],

            // ── Recommendations
            _buildSectionTitle('Recommendations', Icons.lightbulb_outline),
            const SizedBox(height: AppSpacing.md),
            _buildRecommendationsCard(riskColor)
                .animate().fadeIn(duration: AppMotion.standard, delay: 480.ms),

            const SizedBox(height: AppSpacing.xxl),

            // ── Action buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Share PDF',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PdfPreviewScreen(screening: screening, patient: patient),
                      ),
                    ),
                    variant: ButtonVariant.primary,
                    size: ButtonSize.large,
                    icon: const Icon(Icons.share_outlined),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: AppMotion.standard, delay: 540.ms),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeaderCard(BuildContext context, Color riskColor) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: AppTypography.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.name, style: AppTypography.titleMedium.copyWith(fontWeight: AppTypography.semiBold)),
                const SizedBox(height: 2),
                Text(
                  '${patient.age} yrs • ${patient.gender.capitalize()} • ${patient.village ?? 'Location not set'}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                if (patient.occupation != null) ...[
                  const SizedBox(height: 2),
                  Text(patient.occupation!, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              border: Border.all(color: riskColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              (screening.riskLevel ?? 'low').toUpperCase(),
              style: AppTypography.labelSmall.copyWith(
                color: riskColor,
                fontWeight: AppTypography.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskBanner(Color riskColor, String dateStr) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [riskColor.withValues(alpha: 0.15), riskColor.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: riskColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OA Risk Assessment', style: AppTypography.labelSmall.copyWith(color: riskColor.withValues(alpha: 0.8))),
                const SizedBox(height: 4),
                Text(
                  '${(screening.riskLevel ?? 'low').toUpperCase()} RISK',
                  style: AppTypography.headlineSmall.copyWith(color: riskColor, fontWeight: AppTypography.bold),
                ),
                const SizedBox(height: 4),
                Text(dateStr, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${((screening.confidence ?? 0) * 100).round()}%',
                style: AppTypography.headlineLarge.copyWith(color: riskColor, fontWeight: AppTypography.bold),
              ),
              Text('confidence', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsCard() {
    return CustomCard(
      variant: CardVariant.outlined,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
      child: Column(
        children: [
          _answerRow('Pain Level', '${screening.painLevel ?? 0} / 10', Icons.healing_outlined),
          _divider(),
          _answerRow('Morning Stiffness', _stiffnessLabel(screening.stiffnessDuration), Icons.schedule_outlined),
          _divider(),
          _answerRow('Joint Swelling', screening.swelling == true ? 'Yes — swelling present' : 'No swelling', Icons.water_drop_outlined),
          _divider(),
          _answerRow(
            'Past Injury',
            screening.pastInjury != null && screening.pastInjury!.isNotEmpty
                ? 'Yes — ${screening.pastInjury}'
                : 'No prior injury',
            Icons.personal_injury_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildGaitCard() {
    return CustomCard(
      variant: CardVariant.outlined,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(Icons.directions_walk_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gait Data Recorded', style: AppTypography.bodyMedium.copyWith(fontWeight: AppTypography.semiBold)),
                Text('Accelerometer + gyroscope data captured during walk test', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
        ],
      ),
    );
  }

  Widget _buildFactorsCard(Color riskColor) {
    final factors = (screening.contributingFactors ?? '').split('|').where((f) => f.trim().isNotEmpty).toList();

    return CustomCard(
      variant: CardVariant.outlined,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
      child: factors.isEmpty
          ? Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                const SizedBox(width: AppSpacing.md),
                Text('No significant risk factors detected', style: AppTypography.bodySmall.copyWith(color: AppColors.success)),
              ],
            )
          : Column(
              children: factors.asMap().entries.map((e) {
                return Padding(
                  padding: EdgeInsets.only(bottom: e.key < factors.length - 1 ? AppSpacing.md : 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: riskColor, shape: BoxShape.circle),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: Text(e.value.trim(), style: AppTypography.bodySmall.copyWith(height: 1.5))),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildReasoningCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text('AI Reasoning', style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontWeight: AppTypography.semiBold)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            screening.aiReasoning ?? '',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(Color riskColor) {
    final recs = _getRecommendations(screening.riskLevel ?? 'low');
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
      decoration: BoxDecoration(
        color: riskColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: riskColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: recs.asMap().entries.map((e) {
          return Padding(
            padding: EdgeInsets.only(bottom: e.key < recs.length - 1 ? AppSpacing.md : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${e.key + 1}',
                      style: AppTypography.labelSmall.copyWith(color: riskColor, fontWeight: AppTypography.bold),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(e.value, style: AppTypography.bodySmall.copyWith(height: 1.5))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Text(title, style: AppTypography.titleSmall.copyWith(fontWeight: AppTypography.semiBold)),
      ],
    );
  }

  Widget _answerRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary))),
        Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: AppTypography.semiBold)),
      ],
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Divider(color: AppColors.border, height: 1),
      );

  String _stiffnessLabel(String? val) {
    switch (val) {
      case '<30': return 'Less than 30 minutes';
      case '30-60': return '30–60 minutes';
      case '>60': return 'More than 60 minutes';
      default: return 'No stiffness';
    }
  }

  List<String> _getRecommendations(String riskLevel) {
    switch (riskLevel) {
      case 'high':
        return [
          'Refer urgently to an orthopedic specialist',
          'Consider X-ray or MRI imaging',
          'Prescribe analgesics per clinical guidelines',
          'Educate on joint protection techniques',
          'Schedule follow-up within 2 weeks',
        ];
      case 'medium':
        return [
          'Consult physician within 1 month',
          'Physiotherapy assessment recommended',
          'Encourage weight management if BMI > 25',
          'Prescribe low-impact exercise program',
          'Follow-up screening in 3 months',
        ];
      default:
        return [
          'Maintain healthy lifestyle and regular exercise',
          'Ensure adequate calcium and vitamin D intake',
          'Schedule routine screening in 6–12 months',
          'Educate on early OA symptoms to watch for',
        ];
    }
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}