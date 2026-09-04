import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SettingsProvider with ChangeNotifier {
  String _language = 'en';
  bool _notificationsEnabled = true;
  bool _autoSyncEnabled = true;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  int _pendingSyncCount = 0;

  String get language => _language;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoSyncEnabled => _autoSyncEnabled;
  ConnectivityResult get connectionStatus => _connectionStatus;
  bool get isConnected => _connectionStatus != ConnectivityResult.none;
  int get pendingSyncCount => _pendingSyncCount;

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _language = prefs.getString('language') ?? 'en';
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _autoSyncEnabled = prefs.getBool('auto_sync_enabled') ?? true;
      
      await checkConnectivity();
      await updatePendingSyncCount();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', language);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', enabled);
    } catch (e) {
      debugPrint('Error saving notification preference: $e');
    }
  }

  Future<void> setAutoSyncEnabled(bool enabled) async {
    _autoSyncEnabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_sync_enabled', enabled);
    } catch (e) {
      debugPrint('Error saving auto sync preference: $e');
    }
  }

  Future<void> checkConnectivity() async {
    try {
      final connectivity = Connectivity();
      final results = await connectivity.checkConnectivity();

      // Handle both single ConnectivityResult and List<ConnectivityResult>
      if (results is List<ConnectivityResult>) {
        final List<ConnectivityResult> resultList = results as List<ConnectivityResult>;
        if (resultList.isNotEmpty) {
          _connectionStatus = resultList.first;
        } else {
          _connectionStatus = ConnectivityResult.none;
        }
      } else {
        _connectionStatus = results as ConnectivityResult;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      _connectionStatus = ConnectivityResult.none;
      notifyListeners();
    }
  }

  Future<void> updatePendingSyncCount() async {
    try {
      // This would typically query the database for unsynced records
      // For now, we'll use a placeholder
      _pendingSyncCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating pending sync count: $e');
    }
  }

  void incrementPendingSync() {
    _pendingSyncCount++;
    notifyListeners();
  }

  void decrementPendingSync() {
    if (_pendingSyncCount > 0) {
      _pendingSyncCount--;
      notifyListeners();
    }
  }

  Future<void> clearOfflineData() async {
    try {
      // This would clear all offline data from the database
      // For now, it's a placeholder
      _pendingSyncCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing offline data: $e');
    }
  }

  void startConnectivityListener() {
    final connectivity = Connectivity();
    connectivity.onConnectivityChanged.listen((results) {
      // Handle both single ConnectivityResult and List<ConnectivityResult>
      ConnectivityResult result;
      if (results is List<ConnectivityResult>) {
        final List<ConnectivityResult> resultList = results as List<ConnectivityResult>;
        if (resultList.isNotEmpty) {
          result = resultList.first;
        } else {
          result = ConnectivityResult.none;
        }
      } else {
        result = results as ConnectivityResult;
      }
      
      _connectionStatus = result;
      notifyListeners();
      
      // Auto-sync if enabled and connected
      if (_autoSyncEnabled && _connectionStatus != ConnectivityResult.none) {
        // Trigger sync
      }
    });
  }
}
