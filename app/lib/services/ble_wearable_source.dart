import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'sensor_data_source.dart';

/// BLE wearable device sensor data source
/// Template for integrating external Bluetooth wearables (e.g., smartwatch, accelerometer bracelet)
class BLEWearableSensorSource implements SensorDataSource {
  final BluetoothDevice device;
  BluetoothCharacteristic? _accelCharacteristic;
  BluetoothCharacteristic? _gyroCharacteristic;

  StreamSubscription<List<int>>? _accelSubscription;
  StreamSubscription<List<int>>? _gyroSubscription;

  final StreamController<SensorData> _accelerometerController =
      StreamController<SensorData>.broadcast();
  final StreamController<SensorData> _gyroscopeController =
      StreamController<SensorData>.broadcast();

  bool _isConnected = false;
  bool _isRecording = false;

  BLEWearableSensorSource({required this.device});

  @override
  Stream<SensorData> get accelerometerStream =>
      _accelerometerController.stream;

  @override
  Stream<SensorData> get gyroscopeStream => _gyroscopeController.stream;

  @override
  String get deviceName => device.name;

  @override
  bool get isConnected => _isConnected;

  /// Initialize BLE connection and discover sensor services
  @override
  Future<void> initialize() async {
    try {
      // Connect to BLE device
      await device.connect();
      _isConnected = true;

      // Discover services and characteristics
      final services = await device.discoverServices();

      for (final service in services) {
        // Look for standard IMU service UUIDs
        // Common UUIDs:
        // - Accelerometer: 180D (Health Thermometer) or custom
        // - Gyroscope: 180F (Battery Service) or custom
        for (final characteristic in service.characteristics) {
          if (characteristic.uuid.toString().contains('accel') ||
              characteristic.uuid.toString().contains('180D')) {
            _accelCharacteristic = characteristic;
          }
          if (characteristic.uuid.toString().contains('gyro') ||
              characteristic.uuid.toString().contains('180F')) {
            _gyroCharacteristic = characteristic;
          }
        }
      }

      if (_accelCharacteristic == null || _gyroCharacteristic == null) {
        throw Exception('Required sensor characteristics not found on device');
      }
    } catch (e) {
      print('BLE initialization error: $e');
      _isConnected = false;
      rethrow;
    }
  }

  /// Start receiving sensor data from wearable
  @override
  Future<void> startRecording() async {
    if (!_isConnected) {
      throw Exception('Device not connected');
    }

    _isRecording = true;

    // Enable notifications on accelerometer characteristic
    if (_accelCharacteristic != null) {
      await _accelCharacteristic!.setNotifyValue(true);
      _accelSubscription = _accelCharacteristic!.onValueReceived.listen(
        (value) {
          if (_isRecording) {
            _parseAccelerometerData(value);
          }
        },
        onError: (error) => print('Accelerometer stream error: $error'),
      );
    }

    // Enable notifications on gyroscope characteristic
    if (_gyroCharacteristic != null) {
      await _gyroCharacteristic!.setNotifyValue(true);
      _gyroSubscription = _gyroCharacteristic!.onValueReceived.listen(
        (value) {
          if (_isRecording) {
            _parseGyroscopeData(value);
          }
        },
        onError: (error) => print('Gyroscope stream error: $error'),
      );
    }
  }

  /// Stop receiving sensor data
  @override
  Future<void> stopRecording() async {
    _isRecording = false;

    if (_accelCharacteristic != null) {
      await _accelCharacteristic!.setNotifyValue(false);
    }
    if (_gyroCharacteristic != null) {
      await _gyroCharacteristic!.setNotifyValue(false);
    }

    await _accelSubscription?.cancel();
    await _gyroSubscription?.cancel();
  }

  /// Cleanup and disconnect from wearable
  @override
  Future<void> dispose() async {
    await stopRecording();
    await device.disconnect();
    await _accelerometerController.close();
    await _gyroscopeController.close();
    _isConnected = false;
  }

  /// Parse accelerometer data from BLE packet
  /// Implementation depends on wearable's data format
  void _parseAccelerometerData(List<int> data) {
    try {
      // Example: 6-byte format (2 bytes per axis, little-endian)
      // Adjust parsing based on actual wearable protocol
      if (data.length < 6) return;

      final x = _bytesToInt16(data, 0) / 1000.0;
      final y = _bytesToInt16(data, 2) / 1000.0;
      final z = _bytesToInt16(data, 4) / 1000.0;

      _accelerometerController.add(
        SensorData(
          x: x,
          y: y,
          z: z,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      print('Error parsing accelerometer data: $e');
    }
  }

  /// Parse gyroscope data from BLE packet
  void _parseGyroscopeData(List<int> data) {
    try {
      if (data.length < 6) return;

      final x = _bytesToInt16(data, 0) / 1000.0;
      final y = _bytesToInt16(data, 2) / 1000.0;
      final z = _bytesToInt16(data, 4) / 1000.0;

      _gyroscopeController.add(
        SensorData(
          x: x,
          y: y,
          z: z,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      print('Error parsing gyroscope data: $e');
    }
  }

  /// Helper: Convert 2 bytes to signed 16-bit integer (little-endian)
  int _bytesToInt16(List<int> data, int offset) {
    int value = data[offset] | (data[offset + 1] << 8);
    if (value & 0x8000 != 0) {
      value -= 0x10000;
    }
    return value;
  }
}
