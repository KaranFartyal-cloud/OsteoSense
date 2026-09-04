import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/screening.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/index.dart';
import '../../widgets/common/animated_risk_gauge.dart' show AnimatedRiskGauge;

class RiskResultScreen extends StatelessWidget {
  final Screening screening;

  const RiskResultScreen({super.key, required this.screening});

  @override
  Widget build(BuildContext context) {
    final riskColor = AppColors.getRiskColor(screening.riskLevel ?? 'low');
    final confidence = screening.confidence ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Risk Assessment Result',
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Risk Gauge
            Center(
              child: AnimatedRiskGauge(
                value: (screening.confidence ?? 0.0) * 100,
                riskLevel: _getRiskLevelEnum(screening.riskLevel ?? 'low'),
                confidencePercentage: ((screening.confidence ?? 0.0) * 100).toInt(),
                animate: true,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Risk Description
            CustomCard(
              variant: CardVariant.elevated,
              padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Risk Level: ${(screening.riskLevel ?? 'low').toUpperCase()}',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _getRiskDescription(screening.riskLevel ?? 'low'),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            const SizedBox(height: AppSpacing.xl),

            // Contributing Factors
            Text(
              'Contributing Factors',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFactorsCard(screening).animate().fadeIn(
              duration: 400.ms,
              delay: 200.ms,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Recommendations
            Text(
              'Recommendations',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            CustomCard(
              variant: CardVariant.elevated,
              padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: AppColors.accent,
                        size: AppSpacing.iconMd,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          _getRecommendation(screening.riskLevel ?? 'low'),
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

            const SizedBox(height: AppSpacing.xl),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Back to Home',
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    ),
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.large,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: CustomButton(
                    text: 'Share',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share feature coming soon')),
                    ),
                    variant: ButtonVariant.primary,
                    size: ButtonSize.large,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorsCard(Screening screening) {
    final factors = <String>[
      if ((screening.painLevel ?? 0) >= 5) 'High pain level detected',
      if ((int.tryParse(screening.stiffnessDuration ?? '0') ?? 0) >= 30) 'Prolonged morning stiffness',
      if (screening.swelling == true) 'Joint swelling observed',
      if (screening.pastInjury == true) 'History of joint injury',
      if ((double.tryParse(screening.gaitData ?? '0') ?? 0.0) > 0.5) 'Irregular gait pattern',
    ];

    return CustomCard(
      variant: CardVariant.outlined,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
      child: Column(
        children: factors.isEmpty
            ? [
                Text(
                  'No significant risk factors detected',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ]
            : List.generate(
                factors.length,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index < factors.length - 1 ? AppSpacing.md : 0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.riskHigh,
                        size: AppSpacing.iconSm,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          factors[index],
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  String _getRiskDescription(String riskLevel) {
    switch (riskLevel) {
      case 'high':
        return 'High OA risk detected. Urgent specialist referral recommended for proper diagnosis and intervention.';
      case 'medium':
        return 'Moderate OA risk. Recommend consultation with a specialist for further evaluation.';
      default:
        return 'Low OA risk. Continue routine health check-ups and maintain healthy lifestyle.';
    }
  }

  String _getRecommendation(String riskLevel) {
    switch (riskLevel) {
      case 'high':
        return 'Schedule immediate consultation with an orthopedic specialist. Consider imaging studies (X-ray/MRI).';
      case 'medium':
        return 'Follow up with a healthcare provider. Consider physical therapy and lifestyle modifications.';
      default:
        return 'Maintain regular exercise routine. Focus on joint health and early symptom detection.';
    }
  }

  RiskLevel _getRiskLevelEnum(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return RiskLevel.high;
      case 'medium':
        return RiskLevel.medium;
      case 'low':
      default:
        return RiskLevel.low;
    }
  }
}
