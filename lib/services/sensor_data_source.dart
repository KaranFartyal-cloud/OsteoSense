import 'dart:math';

/// Abstract interface for sensor data across different input sources
/// Allows seamless switching between phone sensors and BLE wearables
abstract class SensorDataSource {
  /// Stream of accelerometer data (x, y, z)
  Stream<SensorData> get accelerometerStream;

  /// Stream of gyroscope data (x, y, z)
  Stream<SensorData> get gyroscopeStream;

  /// Initialize the sensor data source
  Future<void> initialize();

  /// Start recording sensor data
  Future<void> startRecording();

  /// Stop recording sensor data
  Future<void> stopRecording();

  /// Cleanup resources
  Future<void> dispose();

  /// Get device name/identifier
  String get deviceName;

  /// Check if sensor is connected/available
  bool get isConnected;
}

/// Represents raw sensor reading (accelerometer/gyroscope)
class SensorData {
  final double x;
  final double y;
  final double z;
  final DateTime timestamp;

  SensorData({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
  });

  /// Calculate magnitude (useful for gait analysis)
  double get magnitude {
    final sum = (x * x + y * y + z * z).toDouble();
    return sqrt(sum);
  }

  @override
  String toString() => 'SensorData(x:$x, y:$y, z:$z, time:$timestamp)';
}

/// Processed gait metrics from raw sensor data
class GaitMetrics {
  final double cadence; // steps per minute
  final double stride; // average stride length
  final double variance; // gait variability (0-1, lower = more regular)
  final double stability; // postural stability score (0-100)
  final List<double> accelerationPeaks; // peaks detected during walking
  final int stepsDetected;
  final Duration recordingDuration;

  GaitMetrics({
    required this.cadence,
    required this.stride,
    required this.variance,
    required this.stability,
    required this.accelerationPeaks,
    required this.stepsDetected,
    required this.recordingDuration,
  });

  @override
  String toString() =>
      'GaitMetrics(cadence:$cadence, stride:$stride, variance:$variance, stability:$stability, steps:$stepsDetected)';
}
