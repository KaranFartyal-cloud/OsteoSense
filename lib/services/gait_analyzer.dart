import 'dart:math';
import 'sensor_data_source.dart';

/// Processes raw sensor data into gait metrics for OA risk assessment
class GaitAnalyzer {
  /// Detect steps from accelerometer data using peak detection
  static int detectSteps(List<SensorData> accelData) {
    if (accelData.isEmpty) return 0;

    // Calculate magnitude of acceleration for each reading
    final magnitudes = accelData.map((d) => d.magnitude).toList();

    // Apply simple peak detection with threshold
    int stepCount = 0;
    const threshold = 1.5; // Adjust based on calibration
    bool inPeak = false;

    for (int i = 1; i < magnitudes.length - 1; i++) {
      if (magnitudes[i] > threshold &&
          magnitudes[i] > magnitudes[i - 1] &&
          magnitudes[i] > magnitudes[i + 1]) {
        if (!inPeak) {
          stepCount++;
          inPeak = true;
        }
      } else if (magnitudes[i] < threshold * 0.7) {
        inPeak = false;
      }
    }

    return stepCount;
  }

  /// Calculate cadence (steps per minute)
  static double calculateCadence(
    int stepCount,
    Duration recordingDuration,
  ) {
    if (recordingDuration.inSeconds == 0) return 0;
    final minutes = recordingDuration.inSeconds / 60.0;
    return stepCount / minutes;
  }

  /// Calculate average stride length (estimated from cadence and acceleration)
  /// Formula: stride ≈ height / (1.43 * cadence)
  /// Simplified: stride ≈ √(avgAccel) / cadence
  static double calculateStride(
    List<SensorData> accelData,
    double cadence,
  ) {
    if (accelData.isEmpty || cadence == 0) return 0;

    final avgMagnitude =
        accelData.map((d) => d.magnitude).reduce((a, b) => a + b) /
            accelData.length;
    return sqrt(avgMagnitude) / (cadence / 100.0); // Normalize for readable units
  }

  /// Calculate gait variability (0-1, lower = more regular/healthy)
  /// Variability from coefficient of variation of stride intervals
  static double calculateVariance(List<SensorData> accelData) {
    if (accelData.length < 4) return 0.5; // Default mid-range if insufficient data

    // Calculate stride intervals (time between peaks)
    final magnitudes = accelData.map((d) => d.magnitude).toList();
    final peakTimes = <Duration>[];

    const threshold = 1.5;
    bool inPeak = false;
    int lastPeakIndex = 0;

    for (int i = 1; i < magnitudes.length - 1; i++) {
      if (magnitudes[i] > threshold &&
          magnitudes[i] > magnitudes[i - 1] &&
          magnitudes[i] > magnitudes[i + 1]) {
        if (!inPeak) {
          if (lastPeakIndex > 0) {
            peakTimes.add(accelData[i].timestamp
                .difference(accelData[lastPeakIndex].timestamp));
          }
          lastPeakIndex = i;
          inPeak = true;
        }
      } else if (magnitudes[i] < threshold * 0.7) {
        inPeak = false;
      }
    }

    if (peakTimes.length < 2) return 0.5;

    // Calculate coefficient of variation
    final meanInterval = peakTimes
            .map((d) => d.inMilliseconds)
            .reduce((a, b) => a + b) /
        peakTimes.length;
    final variance = peakTimes
        .map((d) => pow(d.inMilliseconds - meanInterval, 2))
        .reduce((a, b) => a + b) /
        peakTimes.length;
    final stdDev = sqrt(variance);
    final cv = stdDev / meanInterval; // Coefficient of variation

    // Normalize to 0-1 (typical CV for gait ~0.03-0.15)
    return (cv / 0.15).clamp(0, 1);
  }

  /// Calculate postural stability score (0-100)
  /// Based on angular velocity variance from gyroscope
  static double calculateStability(List<SensorData> gyroData) {
    if (gyroData.isEmpty) return 50; // Default neutral score

    // Calculate variance of angular velocity
    final magnitudes = gyroData.map((d) => d.magnitude).toList();
    final mean =
        magnitudes.reduce((a, b) => a + b) / magnitudes.length;
    final variance = magnitudes
        .map((m) => pow(m - mean, 2))
        .reduce((a, b) => a + b) /
        magnitudes.length;
    final stdDev = sqrt(variance);

    // Lower angular velocity variance = better stability
    // Normalize: typical range 0-2 rad/s
    final stabilityScore = (100 - (stdDev / 2.0 * 100)).clamp(0.0, 100.0);
    return stabilityScore as double;
  }

  /// Detect acceleration peaks (useful for fall risk assessment)
  static List<double> detectAccelerationPeaks(List<SensorData> accelData) {
    if (accelData.isEmpty) return [];

    final magnitudes = accelData.map((d) => d.magnitude).toList();
    final peaks = <double>[];

    const threshold = 2.0;
    for (int i = 1; i < magnitudes.length - 1; i++) {
      if (magnitudes[i] > threshold &&
          magnitudes[i] > magnitudes[i - 1] &&
          magnitudes[i] > magnitudes[i + 1]) {
        peaks.add(magnitudes[i]);
      }
    }

    return peaks;
  }

  /// Generate comprehensive gait metrics from raw sensor data
  static GaitMetrics analyzeGait(
    List<SensorData> accelData,
    List<SensorData> gyroData,
    Duration recordingDuration,
  ) {
    final stepCount = detectSteps(accelData);
    final cadence = calculateCadence(stepCount, recordingDuration);
    final stride = calculateStride(accelData, cadence);
    final variance = calculateVariance(accelData);
    final stability = calculateStability(gyroData);
    final peaks = detectAccelerationPeaks(accelData);

    return GaitMetrics(
      cadence: cadence,
      stride: stride,
      variance: variance,
      stability: stability,
      accelerationPeaks: peaks,
      stepsDetected: stepCount,
      recordingDuration: recordingDuration,
    );
  }
}
