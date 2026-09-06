import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../providers/screening_provider.dart';
import '../../services/tflite_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_motion.dart';
import '../shared/risk_result_screen.dart';
import '../../models/screening.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  final TFLiteService _tfliteService = TFLiteService();
  final List<ProcessingStep> _steps = [
    ProcessingStep(label: 'Analyzing symptoms', status: StepStatus.inProgress),
    ProcessingStep(label: 'Processing gait data', status: StepStatus.pending),
    ProcessingStep(label: 'Calculating risk factors', status: StepStatus.pending),
    ProcessingStep(label: 'Generating recommendations', status: StepStatus.pending),
  ];
  bool _showSuccess = false;
  late AnimationController _checkmarkController;

  @override
  void initState() {
    super.initState();
    _checkmarkController = AnimationController(
      vsync: this,
      duration: AppMotion.slow,
    );
    _processScreening();
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _tfliteService.dispose();
    super.dispose();
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

    // Ensure we have a patient to run the screening against
    if (screeningProvider.draftPatientId == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    // Load TFLite model
    await _tfliteService.loadModel();

    // Parse gait features if available
    List<double> gaitFeatures = [];
    if (screeningProvider.draftGaitData != null) {
      try {
        final parsed = screeningProvider.draftGaitData!.replaceAll('[', '').replaceAll(']', '').split(',');
        gaitFeatures = parsed.map((e) => double.tryParse(e.trim()) ?? 0.0).toList();
      } catch (e) {
        // Handle parsing error
      }
    }

    // Run AI prediction
    final prediction = await _tfliteService.predictRisk(
      painLevel: screeningProvider.draftPainLevel,
      stiffnessDuration: screeningProvider.draftStiffnessDuration,
      swelling: screeningProvider.draftSwelling,
      pastInjury: screeningProvider.draftPastInjury ? screeningProvider.draftPastInjuryDetail : null,
      gaitFeatures: gaitFeatures,
    );

    if (!mounted) return;
    _updateStep(2, StepStatus.completed);
    _updateStep(3, StepStatus.inProgress);

    await Future.delayed(const Duration(seconds: 1));
    _updateStep(3, StepStatus.completed);

    // Brief checkmark delight moment (400ms) before navigating
    setState(() => _showSuccess = true);
    await _checkmarkController.forward();
    await Future.delayed(const Duration(milliseconds: 600));

    // Construct the final screening object
    final newScreening = Screening(
      patientId: screeningProvider.draftPatientId!,
      userId: 1, // Temporarily hardcoded until auth is integrated
      screeningDate: DateTime.now(),
      painLevel: screeningProvider.draftPainLevel,
      stiffnessDuration: screeningProvider.draftStiffnessDuration,
      swelling: screeningProvider.draftSwelling,
      pastInjury: screeningProvider.draftPastInjury ? screeningProvider.draftPastInjuryDetail : null,
      gaitData: screeningProvider.draftGaitData,
      riskLevel: prediction.riskLevel,
      confidence: prediction.confidence,
      contributingFactors: prediction.contributingFactors.join(','),
      aiReasoning: prediction.reasoning,
      doctorRecommendations: _generateRecommendations(prediction.riskLevel),
      synced: false,
    );

    // Save screening to database
    final success = await screeningProvider.saveScreening(newScreening);
    
    // Clear draft answers after submission
    screeningProvider.clearDraft();

    if (mounted) {
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            // Access the saved screening from provider since it now has an ID
            builder: (_) => RiskResultScreen(screening: screeningProvider.currentScreening ?? newScreening),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save screening: ${screeningProvider.errorMessage}')),
        );
        Navigator.of(context).pop();
      }
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
        child: AnimatedSwitcher(
          duration: AppMotion.moderate,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _showSuccess
              // Delight moment: crisp checkmark before results
              ? _buildSuccessState()
              : _buildProcessingState(),
        ),
      ),
    );
  }

  Widget _buildProcessingState() {
    return Column(
      key: const ValueKey('processing'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Lottie animation — the focal point, clean surroundings
        Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Lottie.asset(
              'assets/animations/scanning.json',
              repeat: true,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),

        // Heading — minimal, clean
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingLg),
          child: Column(
            children: [
              Text(
                'Analyzing Results',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: AppTypography.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: AppMotion.slow),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'AI model is processing your screening data',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: AppMotion.slow, delay: 100.ms),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),

        // Processing steps
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingLg),
          child: Column(
            children: List.generate(
              _steps.length,
              (index) {
                final step = _steps[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: _buildStepRow(step, index)
                      .animate()
                      .fadeIn(
                        duration: AppMotion.slow,
                        delay: Duration(milliseconds: 100 * (index + 1)),
                      ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
          child: Text(
            'This may take a few moments…',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildStepRow(ProcessingStep step, int index) {
    return Row(
      children: [
        // Step indicator — pulse dot for in-progress, not a spinner
        SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: _buildStepIndicator(step),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AnimatedDefaultTextStyle(
            duration: AppMotion.standard,
            curve: AppMotion.curve,
            style: AppTypography.bodySmall.copyWith(
              color: step.status == StepStatus.pending
                  ? AppColors.textTertiary
                  : AppColors.textPrimary,
              fontWeight: step.status == StepStatus.inProgress
                  ? AppTypography.semiBold
                  : AppTypography.regular,
            ),
            child: Text(step.label),
          ),
        ),
        if (step.status == StepStatus.completed)
          const Icon(
            Icons.check,
            color: AppColors.success,
            size: 16,
          ).animate().scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            duration: AppMotion.fast,
            curve: AppMotion.curvePop,
          ),
      ],
    );
  }

  Widget _buildStepIndicator(ProcessingStep step) {
    switch (step.status) {
      case StepStatus.inProgress:
        // Pulsing teal dot — branded, not generic spinner
        return Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ).animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        ).scaleXY(
          begin: 0.7,
          end: 1.3,
          duration: 800.ms,
          curve: Curves.easeInOut,
        ).animate().fadeIn(duration: AppMotion.fast);

      case StepStatus.completed:
        return Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
        );

      case StepStatus.pending:
        return Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.gray300,
            shape: BoxShape.circle,
          ),
        );
    }
  }

  Widget _buildSuccessState() {
    return Column(
      key: const ValueKey('success'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Crisp checkmark animation — draw-on circle + check, 400ms
        _DrawOnCheckmark(controller: _checkmarkController),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Analysis Complete',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: AppTypography.semiBold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(duration: AppMotion.slow, delay: 200.ms),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Preparing your results…',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ).animate().fadeIn(duration: AppMotion.slow, delay: 300.ms),
      ],
    );
  }
}

/// Draw-on checkmark animation — crisp circle outline draws in, then
/// the check appears. 400ms total, purposeful and tasteful (not celebratory).
class _DrawOnCheckmark extends StatelessWidget {
  final AnimationController controller;

  const _DrawOnCheckmark({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final circleProgress = (controller.value * 2).clamp(0.0, 1.0);
        final checkProgress = ((controller.value * 2) - 1).clamp(0.0, 1.0);

        return CustomPaint(
          size: const Size(80, 80),
          painter: _CheckmarkPainter(
            circleProgress: circleProgress,
            checkProgress: checkProgress,
            color: AppColors.success,
          ),
        );
      },
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double circleProgress;
  final double checkProgress;
  final Color color;

  _CheckmarkPainter({
    required this.circleProgress,
    required this.checkProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Draw circle outline (draws in from top)
    if (circleProgress > 0) {
      final circlePaint = Paint()
        ..color = color
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2, // start at top
        2 * 3.14159 * circleProgress,
        false,
        circlePaint,
      );
    }

    // Draw checkmark (appears after circle)
    if (checkProgress > 0) {
      final checkPaint = Paint()
        ..color = color
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final p1 = Offset(size.width * 0.25, size.height * 0.5);
      final p2 = Offset(size.width * 0.45, size.height * 0.68);
      final p3 = Offset(size.width * 0.75, size.height * 0.33);

      final path = Path();
      if (checkProgress < 0.5) {
        // Draw from p1 to p2
        final t = checkProgress * 2;
        path.moveTo(p1.dx, p1.dy);
        path.lineTo(
          p1.dx + (p2.dx - p1.dx) * t,
          p1.dy + (p2.dy - p1.dy) * t,
        );
      } else {
        // Draw full first segment + partial second
        final t = (checkProgress - 0.5) * 2;
        path.moveTo(p1.dx, p1.dy);
        path.lineTo(p2.dx, p2.dy);
        path.lineTo(
          p2.dx + (p3.dx - p2.dx) * t,
          p2.dy + (p3.dy - p2.dy) * t,
        );
      }
      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(_CheckmarkPainter old) =>
      old.circleProgress != circleProgress || old.checkProgress != checkProgress;
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
