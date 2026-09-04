import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/database_helper.dart';
import '../utils/constants.dart';

class SyncService {
  static SyncService? _instance;
  final Dio _dio = Dio();
  final DatabaseHelper _db = DatabaseHelper();
  bool _isSyncing = false;
  StreamSubscription? _connectivitySubscription;

  factory SyncService() {
    _instance ??= SyncService._internal();
    return _instance!;
  }

  SyncService._internal() {
    _configureDio();
  }

  bool get isSyncing => _isSyncing;

  void _configureDio() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void startAutoSync() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
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
      
      if (result != ConnectivityResult.none) {
        syncPendingData();
      }
    });
  }

  void stopAutoSync() {
    _connectivitySubscription?.cancel();
  }

  Future<bool> syncPendingData() async {
    if (_isSyncing) return false;

    _isSyncing = true;
    debugPrint('Starting sync...');

    try {
      // Check connectivity
      final connectivity = await Connectivity().checkConnectivity();
      ConnectivityResult result;
      
      // Handle both single ConnectivityResult and List<ConnectivityResult>
      if (connectivity is List<ConnectivityResult>) {
        final List<ConnectivityResult> resultList = connectivity as List<ConnectivityResult>;
        if (resultList.isEmpty || resultList.first == ConnectivityResult.none) {
          debugPrint('No internet connection available');
          _isSyncing = false;
          return false;
        }
        result = resultList.first;
      } else {
        result = connectivity as ConnectivityResult;
        if (result == ConnectivityResult.none) {
          debugPrint('No internet connection available');
          _isSyncing = false;
          return false;
        }
      }

      // Get all pending sync items
      final syncQueue = await _db.getSyncQueue();
      
      if (syncQueue.isEmpty) {
        debugPrint('No pending data to sync');
        _isSyncing = false;
        return true;
      }

      debugPrint('Found ${syncQueue.length} items to sync');

      // Process each sync item
      int successCount = 0;
      int failureCount = 0;

      for (var item in syncQueue) {
        try {
          final tableName = item['table_name'] as String;
          final recordId = item['record_id'] as int;
          final action = item['action'] as String;
          final data = item['data'] as String;

          final success = await _syncItem(tableName, recordId, action, data);
          
          if (success) {
            await _db.removeFromSyncQueue(item['id'] as int);
            await _db.markAsSynced(tableName, recordId);
            successCount++;
          } else {
            failureCount++;
            // Increment retry count
            final retryCount = (item['retry_count'] as int) + 1;
            if (retryCount >= AppConstants.maxRetryCount) {
              await _db.removeFromSyncQueue(item['id'] as int);
              debugPrint('Max retries reached for item ${item['id']}, removing from queue');
            } else {
              await _db.update(
                'sync_queue',
                {'retry_count': retryCount},
                where: 'id = ?',
                whereArgs: [item['id']],
              );
            }
          }
        } catch (e) {
          debugPrint('Error syncing item ${item['id']}: $e');
          failureCount++;
        }
      }

      debugPrint('Sync completed: $successCount succeeded, $failureCount failed');
      _isSyncing = false;
      return failureCount == 0;
    } catch (e) {
      debugPrint('Sync error: $e');
      _isSyncing = false;
      return false;
    }
  }

  Future<bool> _syncItem(String tableName, int recordId, String action, String data) async {
    try {
      final endpoint = _getEndpointForTable(tableName);
      
      switch (action.toLowerCase()) {
        case 'insert':
          return await _postData(endpoint, data);
        case 'update':
          return await _putData('$endpoint/$recordId', data);
        case 'delete':
          return await _deleteData('$endpoint/$recordId');
        default:
          debugPrint('Unknown action: $action');
          return false;
      }
    } catch (e) {
      debugPrint('Error syncing item: $e');
      return false;
    }
  }

  String _getEndpointForTable(String tableName) {
    switch (tableName) {
      case 'patients':
        return '/patients';
      case 'screenings':
        return '/screenings';
      case 'users':
        return '/users';
      default:
        return '/$tableName';
    }
  }

  Future<bool> _postData(String endpoint, String data) async {
    try {
      final response = await _dio.post(
        AppConstants.apiVersion + endpoint,
        data: data,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('POST error for $endpoint: $e');
      return false;
    }
  }

  Future<bool> _putData(String endpoint, String data) async {
    try {
      final response = await _dio.put(
        AppConstants.apiVersion + endpoint,
        data: data,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('PUT error for $endpoint: $e');
      return false;
    }
  }

  Future<bool> _deleteData(String endpoint) async {
    try {
      final response = await _dio.delete(AppConstants.apiVersion + endpoint);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('DELETE error for $endpoint: $e');
      return false;
    }
  }

  Future<bool> syncPatient(int patientId) async {
    try {
      final patients = await _db.query(
        'patients',
        where: 'id = ?',
        whereArgs: [patientId],
      );

      if (patients.isEmpty) return false;

      final patientData = patients.first;
      final endpoint = '${AppConstants.apiVersion}/patients';

      if (patientData['synced'] == 0) {
        // New patient - POST
        final response = await _dio.post(endpoint, data: patientData);
        if (response.statusCode == 200 || response.statusCode == 201) {
          await _db.markAsSynced('patients', patientId);
          return true;
        }
      } else {
        // Existing patient - PUT
        final response = await _dio.put('$endpoint/$patientId', data: patientData);
        if (response.statusCode == 200 || response.statusCode == 201) {
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error syncing patient: $e');
      return false;
    }
  }

  Future<bool> syncScreening(int screeningId) async {
    try {
      final screenings = await _db.query(
        'screenings',
        where: 'id = ?',
        whereArgs: [screeningId],
      );

      if (screenings.isEmpty) return false;

      final screeningData = screenings.first;
      final endpoint = '${AppConstants.apiVersion}/screenings';

      if (screeningData['synced'] == 0) {
        // New screening - POST
        final response = await _dio.post(endpoint, data: screeningData);
        if (response.statusCode == 200 || response.statusCode == 201) {
          await _db.markAsSynced('screenings', screeningId);
          return true;
        }
      } else {
        // Existing screening - PUT
        final response = await _dio.put('$endpoint/$screeningId', data: screeningData);
        if (response.statusCode == 200 || response.statusCode == 201) {
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error syncing screening: $e');
      return false;
    }
  }

  Future<int> getPendingSyncCount() async {
    try {
      final patientCount = await _db.getUnsyncedCount('patients');
      final screeningCount = await _db.getUnsyncedCount('screenings');
      final queueCount = (await _db.getSyncQueue()).length;
      return patientCount + screeningCount + queueCount;
    } catch (e) {
      debugPrint('Error getting pending sync count: $e');
      return 0;
    }
  }

  Future<bool> isConnected() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity is List<ConnectivityResult>) {
        final List<ConnectivityResult> resultList = connectivity as List<ConnectivityResult>;
        return resultList.isNotEmpty && resultList.first != ConnectivityResult.none;
      } else {
        final ConnectivityResult result = connectivity as ConnectivityResult;
        return result != ConnectivityResult.none;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchPatientFromServer(int patientId) async {
    try {
      final response = await _dio.get('${AppConstants.apiVersion}/patients/$patientId');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching patient from server: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchScreeningFromServer(int screeningId) async {
    try {
      final response = await _dio.get('${AppConstants.apiVersion}/screenings/$screeningId');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching screening from server: $e');
      return null;
    }
  }

  void dispose() {
    stopAutoSync();
  }
}
