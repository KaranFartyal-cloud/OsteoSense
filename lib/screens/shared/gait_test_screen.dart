import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../providers/patient_provider.dart';
import '../../services/sensor_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/index.dart';
import 'processing_screen.dart';

class GaitTestScreen extends StatefulWidget {
  const GaitTestScreen({super.key});

  @override
  State<GaitTestScreen> createState() => _GaitTestScreenState();
}

class _GaitTestScreenState extends State<GaitTestScreen> {
  final SensorService _sensorService = SensorService();
  bool _isRecording = false;
  Timer? _timer;
  int _remainingSeconds = 30;
  int _totalSeconds = 30;

  @override
  void dispose() {
    _timer?.cancel();
    _sensorService.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _remainingSeconds = _totalSeconds;
    });

    _sensorService.startRecording(
      duration: const Duration(seconds: 30),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _stopRecording();
        }
      });
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    _sensorService.stopRecording();

    final patientProvider = Provider.of<PatientProvider>(context, listen: false);

    // Get gait features and store them
    final gaitFeatures = _sensorService.getFeatureVector();
    patientProvider.screeningData['gait_features'] = gaitFeatures;

    setState(() {
      _isRecording = false;
    });

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProcessingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);
    final patient = patientProvider.selectedPatient;
    final progress = (_totalSeconds - _remainingSeconds) / _totalSeconds;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Gait Assessment Test',
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient info card
              if (patient != null)
                CustomCard(
                  variant: CardVariant.elevated,
                  padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primarySurface,
                        child: Text(
                          patient.name.substring(0, 1).toUpperCase(),
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
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
                            Text(
                              '${patient.age} years',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: AppSpacing.xl),

              // Instructions card
              CustomCard(
                variant: CardVariant.elevated,
                padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: const Icon(
                            Icons.info,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'How to Perform',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildInstructionItem(
                      '1. Stand naturally with your device in your pocket',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildInstructionItem(
                      '2. Walk at a normal, comfortable pace',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildInstructionItem(
                      '3. Test duration: 30 seconds',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildInstructionItem(
                      '4. Walk in a straight line if possible',
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
              const SizedBox(height: AppSpacing.xxxl),

              // Animated Lottie walking figure
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: _isRecording
                      ? Lottie.asset(
                          'assets/animations/walking.json',
                          repeat: true,
                          reverse: false,
                        )
                      : Icon(
                          Icons.directions_walk,
                          size: 100,
                          color: AppColors.primary,
                        ).animate().fadeIn(duration: 400.ms),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Progress and timer
              if (_isRecording)
                Column(
                  children: [
                    // Circular progress ring with countdown
                    Center(
                      child: CircularProgressRing(
                        value: progress,
                        size: 140,
                        strokeWidth: 8,
                        color: AppColors.primary,
                        label: '$_remainingSeconds"',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Linear progress bar
                    LinearProgressBar(
                      value: progress,
                      height: 6,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Recording in progress...',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms)
              else
                CustomButton(
                  text: 'Start Gait Test',
                  onPressed: _startRecording,
                  variant: ButtonVariant.primary,
                  size: ButtonSize.large,
                  fullWidth: true,
                  icon: const Icon(Icons.play_arrow),
                ).animate().fadeIn(duration: 400.ms).scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                ),
              const SizedBox(height: AppSpacing.md),
              CustomButton(
                text: 'Skip Test',
                onPressed: () => Navigator.pop(context),
                variant: ButtonVariant.outline,
                size: ButtonSize.large,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline,
          color: AppColors.primary,
          size: AppSpacing.iconMd,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
