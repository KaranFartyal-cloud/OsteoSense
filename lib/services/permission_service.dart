import 'package:permission_handler/permission_handler.dart';

/// Centralized permission management for JointSaathi
/// Handles runtime permissions for both iOS and Android
class PermissionService {
  /// Check and request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Check and request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Check and request sensor permissions (accelerometer/gyroscope)
  static Future<bool> requestSensorPermissions() async {
    // On iOS, sensors are typically always available after initial grant
    // On Android, BODY_SENSORS permission is needed
    final status = await Permission.sensors.request();
    return status.isGranted || status.isDenied;
  }

  /// Check and request Bluetooth permissions
  static Future<bool> requestBluetoothPermissions() async {
    // iOS: NSBluetoothPeripheralUsageDescription and NSBluetoothAlwaysUsageDescription
    // Android 12+: BLUETOOTH_SCAN and BLUETOOTH_CONNECT
    final bluetoothStatus = await Permission.bluetooth.request();
    final bluetoothScanStatus = await Permission.bluetoothScan.request();
    final bluetoothConnectStatus = await Permission.bluetoothConnect.request();

    return bluetoothStatus.isGranted &&
        bluetoothScanStatus.isGranted &&
        bluetoothConnectStatus.isGranted;
  }

  /// Check and request location permissions
  static Future<bool> requestLocationPermissions() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Check and request file storage permissions
  static Future<bool> requestStoragePermissions() async {
    final readStatus = await Permission.storage.request();
    final photosStatus = await Permission.photos.request();

    return readStatus.isGranted && photosStatus.isGranted;
  }

  /// Request all required permissions for core functionality
  static Future<Map<String, bool>> requestAllCorePermissions() async {
    return {
      'camera': await requestCameraPermission(),
      'microphone': await requestMicrophonePermission(),
      'sensors': await requestSensorPermissions(),
      'location': await requestLocationPermissions(),
      'storage': await requestStoragePermissions(),
    };
  }

  /// Request all permissions including optional ones
  static Future<Map<String, bool>> requestAllPermissions() async {
    final corePerms = await requestAllCorePermissions();
    final bluetooth = await requestBluetoothPermissions();

    return {
      ...corePerms,
      'bluetooth': bluetooth,
    };
  }

  /// Check if permission is granted
  static Future<bool> isPermissionGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  /// Check if camera permission is granted
  static Future<bool> isCameraGranted() =>
      isPermissionGranted(Permission.camera);

  /// Check if location permission is granted
  static Future<bool> isLocationGranted() =>
      isPermissionGranted(Permission.location);

  /// Check if Bluetooth permission is granted
  static Future<bool> isBluetoothGranted() =>
      isPermissionGranted(Permission.bluetooth);

  /// Check if storage permission is granted
  static Future<bool> isStorageGranted() =>
      isPermissionGranted(Permission.storage);

  /// Check if sensors permission is granted
  static Future<bool> isSensorsGranted() =>
      isPermissionGranted(Permission.sensors);

  /// Open app settings to manually grant permissions
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Get human-readable status message for a permission
  static String getPermissionStatusMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Permission granted';
      case PermissionStatus.denied:
        return 'Permission denied';
      case PermissionStatus.restricted:
        return 'Permission restricted by system';
      case PermissionStatus.limited:
        return 'Permission granted with limited access';
      case PermissionStatus.permanentlyDenied:
        return 'Permission permanently denied. Please enable in Settings.';
      case PermissionStatus.provisional:
        return 'Permission provisionally granted';
    }
  }

  /// Check if permission is permanently denied (can't be requested again)
  static Future<bool> isPermanentlyDenied(Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  /// Request permission with error handling
  static Future<bool> requestPermissionWithFeedback(
    Permission permission,
    String permissionName,
  ) async {
    try {
      final status = await permission.request();

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        // Permission is permanently denied, user must enable in Settings
        print('$permissionName permanently denied. User must enable in Settings.');
        return false;
      } else if (status.isDenied) {
        print('$permissionName was denied by user.');
        return false;
      } else {
        print('$permissionName status: $status');
        return false;
      }
    } catch (e) {
      print('Error requesting $permissionName: $e');
      return false;
    }
  }
}
