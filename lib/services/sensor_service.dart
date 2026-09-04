import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  static SensorService? _instance;
  bool _isRecording = false;
  final List<double> _accelerometerData = [];
  final List<double> _gyroscopeData = [];
  final List<double> _userAccelerometerData = [];
  Timer? _recordingTimer;
  StreamSubscription? _accelerometerSubscription;
  StreamSubscription? _gyroscopeSubscription;
  StreamSubscription? _userAccelerometerSubscription;

  factory SensorService() {
    _instance ??= SensorService._internal();
    return _instance!;
  }

  SensorService._internal();

  bool get isRecording => _isRecording;
  List<double> get accelerometerData => List.from(_accelerometerData);
  List<double> get gyroscopeData => List.from(_gyroscopeData);
  List<double> get userAccelerometerData => List.from(_userAccelerometerData);

  void startRecording({Duration duration = const Duration(seconds: 30)}) {
    if (_isRecording) return;

    _isRecording = true;
    _accelerometerData.clear();
    _gyroscopeData.clear();
    _userAccelerometerData.clear();

    // Subscribe to accelerometer events
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      if (_isRecording) {
        _accelerometerData.addAll([event.x, event.y, event.z]);
      }
    });

    // Subscribe to gyroscope events
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      if (_isRecording) {
        _gyroscopeData.addAll([event.x, event.y, event.z]);
      }
    });

    // Subscribe to user accelerometer events (gravity removed)
    _userAccelerometerSubscription = userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      if (_isRecording) {
        _userAccelerometerData.addAll([event.x, event.y, event.z]);
      }
    });

    // Set timer to stop recording after duration
    _recordingTimer = Timer(duration, stopRecording);

    debugPrint('Sensor recording started for ${duration.inSeconds} seconds');
  }

  void stopRecording() {
    if (!_isRecording) return;

    _isRecording = false;
    
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _userAccelerometerSubscription?.cancel();
    _recordingTimer?.cancel();

    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;
    _userAccelerometerSubscription = null;
    _recordingTimer = null;

    debugPrint('Sensor recording stopped');
    debugPrint('Accelerometer samples: ${(_accelerometerData.length / 3).toInt()}');
    debugPrint('Gyroscope samples: ${(_gyroscopeData.length / 3).toInt()}');
    debugPrint('User accelerometer samples: ${(_userAccelerometerData.length / 3).toInt()}');
  }

  Map<String, dynamic> getGaitFeatures() {
    if (_accelerometerData.isEmpty && _gyroscopeData.isEmpty) {
      return {};
    }

    final features = <String, dynamic>{};

    // Calculate statistical features from accelerometer data
    if (_accelerometerData.isNotEmpty) {
      final accelX = _extractAxis(_accelerometerData, 0);
      final accelY = _extractAxis(_accelerometerData, 1);
      final accelZ = _extractAxis(_accelerometerData, 2);

      features['accel_mean_x'] = _mean(accelX);
      features['accel_mean_y'] = _mean(accelY);
      features['accel_mean_z'] = _mean(accelZ);
      features['accel_std_x'] = _stdDev(accelX);
      features['accel_std_y'] = _stdDev(accelY);
      features['accel_std_z'] = _stdDev(accelZ);
      features['accel_rms'] = _rms(_accelerometerData);
    }

    // Calculate statistical features from gyroscope data
    if (_gyroscopeData.isNotEmpty) {
      final gyroX = _extractAxis(_gyroscopeData, 0);
      final gyroY = _extractAxis(_gyroscopeData, 1);
      final gyroZ = _extractAxis(_gyroscopeData, 2);

      features['gyro_mean_x'] = _mean(gyroX);
      features['gyro_mean_y'] = _mean(gyroY);
      features['gyro_mean_z'] = _mean(gyroZ);
      features['gyro_std_x'] = _stdDev(gyroX);
      features['gyro_std_y'] = _stdDev(gyroY);
      features['gyro_std_z'] = _stdDev(gyroZ);
      features['gyro_rms'] = _rms(_gyroscopeData);
    }

    // Calculate features from user accelerometer (gravity removed)
    if (_userAccelerometerData.isNotEmpty) {
      final userAccelX = _extractAxis(_userAccelerometerData, 0);
      final userAccelY = _extractAxis(_userAccelerometerData, 1);
      final userAccelZ = _extractAxis(_userAccelerometerData, 2);

      features['user_accel_mean_x'] = _mean(userAccelX);
      features['user_accel_mean_y'] = _mean(userAccelY);
      features['user_accel_mean_z'] = _mean(userAccelZ);
      features['user_accel_std_x'] = _stdDev(userAccelX);
      features['user_accel_std_y'] = _stdDev(userAccelY);
      features['user_accel_std_z'] = _stdDev(userAccelZ);
    }

    // Calculate step count estimation
    features['estimated_steps'] = _estimateSteps(_userAccelerometerData);

    // Calculate regularity score
    features['regularity_score'] = _calculateRegularity(_userAccelerometerData);

    return features;
  }

  List<double> _extractAxis(List<double> data, int axisIndex) {
    final result = <double>[];
    for (int i = axisIndex; i < data.length; i += 3) {
      result.add(data[i]);
    }
    return result;
  }

  double _mean(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _stdDev(List<double> values) {
    if (values.isEmpty) return 0.0;
    final mean = _mean(values);
    final variance = values.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / values.length;
    return variance > 0 ? variance.sqrt() : 0.0;
  }

  double _rms(List<double> values) {
    if (values.isEmpty) return 0.0;
    final sumSquares = values.map((x) => x * x).reduce((a, b) => a + b);
    return (sumSquares / values.length).sqrt();
  }

  int _estimateSteps(List<double> userAccelData) {
    if (userAccelData.isEmpty) return 0;

    // Extract vertical acceleration (assuming z-axis is vertical)
    final verticalAccel = _extractAxis(userAccelData, 2);
    
    // Simple peak detection algorithm
    int stepCount = 0;
    const threshold = 0.5; // Acceleration threshold for step detection
    const minPeakDistance = 10; // Minimum samples between peaks
    
    int lastPeakIndex = -minPeakDistance;
    
    for (int i = 1; i < verticalAccel.length - 1; i++) {
      final current = verticalAccel[i];
      final prev = verticalAccel[i - 1];
      final next = verticalAccel[i + 1];
      
      // Check for local peak above threshold
      if (current > threshold && current > prev && current > next) {
        if (i - lastPeakIndex >= minPeakDistance) {
          stepCount++;
          lastPeakIndex = i;
        }
      }
    }
    
    return stepCount;
  }

  double _calculateRegularity(List<double> userAccelData) {
    if (userAccelData.isEmpty) return 0.0;

    final verticalAccel = _extractAxis(userAccelData, 2);
    
    // Calculate autocorrelation to assess periodicity
    final n = verticalAccel.length;
    final mean = _mean(verticalAccel);
    
    double maxCorrelation = 0.0;
    
    // Check correlations at different lags (typical walking cadence)
    for (int lag = 20; lag < 60 && lag < n ~/ 2; lag++) {
      double correlation = 0.0;
      for (int i = 0; i < n - lag; i++) {
        correlation += (verticalAccel[i] - mean) * (verticalAccel[i + lag] - mean);
      }
      correlation /= (n - lag);
      
      if (correlation > maxCorrelation) {
        maxCorrelation = correlation;
      }
    }
    
    // Normalize to 0-1 range
    final variance = _stdDev(verticalAccel) * _stdDev(verticalAccel);
    return variance > 0 ? (maxCorrelation / variance).clamp(0.0, 1.0) : 0.0;
  }

  List<double> getFeatureVector() {
    final features = getGaitFeatures();
    final featureVector = <double>[];

    // Convert features to a flat list for ML model input
    // Order should match the model's expected input
    featureVector.addAll([
      features['accel_mean_x'] ?? 0.0,
      features['accel_mean_y'] ?? 0.0,
      features['accel_mean_z'] ?? 0.0,
      features['accel_std_x'] ?? 0.0,
      features['accel_std_y'] ?? 0.0,
      features['accel_std_z'] ?? 0.0,
      features['accel_rms'] ?? 0.0,
      features['gyro_mean_x'] ?? 0.0,
      features['gyro_mean_y'] ?? 0.0,
      features['gyro_mean_z'] ?? 0.0,
      features['gyro_std_x'] ?? 0.0,
      features['gyro_std_y'] ?? 0.0,
      features['gyro_std_z'] ?? 0.0,
      features['gyro_rms'] ?? 0.0,
      features['user_accel_mean_x'] ?? 0.0,
      features['user_accel_mean_y'] ?? 0.0,
      features['user_accel_mean_z'] ?? 0.0,
      features['user_accel_std_x'] ?? 0.0,
      features['user_accel_std_y'] ?? 0.0,
      features['user_accel_std_z'] ?? 0.0,
      (features['estimated_steps'] ?? 0).toDouble(),
      features['regularity_score'] ?? 0.0,
    ]);

    return featureVector;
  }

  void clearData() {
    _accelerometerData.clear();
    _gyroscopeData.clear();
    _userAccelerometerData.clear();
  }

  void dispose() {
    stopRecording();
    clearData();
  }
}

extension on double {
  double sqrt() => math.sqrt(this);
}
