import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'sensor_data_source.dart';

/// Phone-based sensor data source using device accelerometer/gyroscope
class PhoneSensorDataSource implements SensorDataSource {
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;

  final StreamController<SensorData> _accelerometerController =
      StreamController<SensorData>.broadcast();
  final StreamController<SensorData> _gyroscopeController =
      StreamController<SensorData>.broadcast();

  bool _isRecording = false;

  @override
  Stream<SensorData> get accelerometerStream =>
      _accelerometerController.stream;

  @override
  Stream<SensorData> get gyroscopeStream => _gyroscopeController.stream;

  @override
  String get deviceName => 'Phone Sensors';

  @override
  bool get isConnected => true;

  @override
  Future<void> initialize() async {
    // Phone sensors are always available
    // Set sampling interval to 50ms (20Hz) for gait analysis
    await accelerometerEvents.listen(null).cancel();
  }

  @override
  Future<void> startRecording() async {
    _isRecording = true;

    // Listen to accelerometer events
    _accelSubscription = accelerometerEvents.listen(
      (AccelerometerEvent event) {
        if (_isRecording) {
          _accelerometerController.add(
            SensorData(
              x: event.x,
              y: event.y,
              z: event.z,
              timestamp: DateTime.now(),
            ),
          );
        }
      },
      onError: (dynamic error) {
        print('Accelerometer error: $error');
      },
    );

    // Listen to gyroscope events
    _gyroSubscription = gyroscopeEvents.listen(
      (GyroscopeEvent event) {
        if (_isRecording) {
          _gyroscopeController.add(
            SensorData(
              x: event.x,
              y: event.y,
              z: event.z,
              timestamp: DateTime.now(),
            ),
          );
        }
      },
      onError: (dynamic error) {
        print('Gyroscope error: $error');
      },
    );
  }

  @override
  Future<void> stopRecording() async {
    _isRecording = false;
    await _accelSubscription?.cancel();
    await _gyroSubscription?.cancel();
  }

  @override
  Future<void> dispose() async {
    await stopRecording();
    await _accelerometerController.close();
    await _gyroscopeController.close();
  }
}
