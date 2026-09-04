import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../providers/screening_provider.dart';
import '../../services/tflite_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../shared/risk_result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  final TFLiteService _tfliteService = TFLiteService();
  final List<ProcessingStep> _steps = [
    ProcessingStep(label: 'Analyzing symptoms', status: StepStatus.inProgress),
    ProcessingStep(label: 'Processing gait data', status: StepStatus.pending),
    ProcessingStep(label: 'Calculating risk factors', status: StepStatus.pending),
    ProcessingStep(label: 'Generating recommendations', status: StepStatus.pending),
  ];

  @override
  void initState() {
    super.initState();
    _processScreening();
  }

  Future<void> _processScreening() async {
    await Future.delayed(const Duration(seconds: 2));
    _updateStep(0, StepStatus.completed);

    await Future.delayed(const Duration(seconds: 2));
    _updateStep(1, StepStatus.inProgress);

    await Future.delayed(const Duration(seconds: 2));
    _updateStep(1, StepStatus.completed);
    _updateStep(2, StepStatus.inProgress);

    final screeningProvider = Provider.of<ScreeningProvider>(context, listen: false);
    final screening = screeningProvider.currentScreening;

    if (screening == null) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    // Load TFLite model
    await _tfliteService.loadModel();

    // Get gait features if available
    List<double> gaitFeatures = [];
    if (screening.gaitData != null) {
      try {
        // Parse gait data string back to list
        gaitFeatures = [];
      } catch (e) {
        // Handle parsing error
      }
    }

    // Run AI prediction
    final prediction = await _tfliteService.predictRisk(
      painLevel: screening.painLevel ?? 0,
      stiffnessDuration: screening.stiffnessDuration ?? '0 minutes',
      swelling: screening.swelling ?? false,
      pastInjury: screening.pastInjury,
      gaitFeatures: gaitFeatures,
    );

    if (!mounted) return;
    _updateStep(2, StepStatus.completed);
    _updateStep(3, StepStatus.inProgress);

    await Future.delayed(const Duration(seconds: 1));
    _updateStep(3, StepStatus.completed);

    // Update screening with results
    final updatedScreening = screening.copyWith(
      riskLevel: prediction.riskLevel,
      confidence: prediction.confidence,
      contributingFactors: prediction.contributingFactors.join(','),
      aiReasoning: prediction.reasoning,
      doctorRecommendations: _generateRecommendations(prediction.riskLevel),
    );

    // Save screening to database
    await screeningProvider.saveScreening(updatedScreening);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => RiskResultScreen(screening: updatedScreening)),
      );
    }
  }

  void _updateStep(int index, StepStatus status) {
    if (mounted) {
      setState(() {
        _steps[index].status = status;
      });
    }
  }

  String _generateRecommendations(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return 'Immediate medical consultation recommended. Consider referral to orthopedic specialist. Avoid high-impact activities. Begin joint-friendly exercises under supervision.';
      case 'medium':
        return 'Regular monitoring advised. Start low-impact exercises like swimming or walking. Maintain healthy weight. Consider physiotherapy consultation. Use joint protection techniques.';
      case 'low':
      default:
        return 'Continue regular health monitoring. Maintain healthy lifestyle with balanced diet and regular exercise. Practice good posture. Stay hydrated and maintain joint flexibility.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Animated Lottie analysis visual or pulsing rings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingLg),
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Lottie.asset(
                    'assets/animations/scanning.json',
                    repeat: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Main heading
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingLg),
              child: Column(
                children: [
                  Text(
                    'Analyzing Results',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'AI model is processing your screening data...',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Processing steps with animation
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingLg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _steps.length,
                    (index) {
                      final step = _steps[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        child: _buildProcessingStepItem(
                          step,
                          index,
                        ).animate().fadeIn(
                          duration: 300.ms,
                          delay: Duration(milliseconds: 100 * (index + 1)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Footer text
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
              child: Text(
                'This may take a few moments...',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingStepItem(ProcessingStep step, int index) {
    return Row(
      children: [
        // Status icon with animation
        SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: step.status == StepStatus.inProgress
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms)
                : Icon(
                    step.status == StepStatus.completed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: step.status == StepStatus.completed
                        ? AppColors.success
                        : AppColors.textTertiary,
                    size: 24,
                  ).animate(onPlay: (controller) {
                    if (step.status == StepStatus.completed) {
                      controller.forward();
                    }
                  }).scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 300.ms,
                    curve: Curves.elasticOut,
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // Step label
        Expanded(
          child: Text(
            step.label,
            style: AppTypography.bodyMedium.copyWith(
              color: step.status == StepStatus.pending
                  ? AppColors.textTertiary
                  : AppColors.textPrimary,
              fontWeight: step.status == StepStatus.inProgress
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tfliteService.dispose();
    super.dispose();
  }
}

enum StepStatus {
  pending,
  inProgress,
  completed,
}

class ProcessingStep {
  final String label;
  StepStatus status;

  ProcessingStep({
    required this.label,
    required this.status,
  });
}
