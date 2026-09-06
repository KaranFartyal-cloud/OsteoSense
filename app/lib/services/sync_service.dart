import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import '../services/database_helper.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class SyncService {
  static SyncService? _instance;
  final DatabaseHelper _db = DatabaseHelper();
  bool _isSyncing = false;
  StreamSubscription? _connectivitySubscription;

  factory SyncService() {
    _instance ??= SyncService._internal();
    return _instance!;
  }

  SyncService._internal();

  bool get isSyncing => _isSyncing;

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
        result = results;
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
        result = connectivity;
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

      List<Map<String, dynamic>> patients = [];
      List<Map<String, dynamic>> screenings = [];
      List<int> queueIds = [];

      for (var item in syncQueue) {
        try {
          final tableName = item['table_name'] as String;
          final action = item['action'] as String;
          final recordId = item['record_id'] as int;
          final dataStr = item['data'] as String;
          
          final data = jsonDecode(dataStr) as Map<String, dynamic>;
          data['_sync_queue_id'] = item['id'];
          data['_sync_action'] = action;
          data['localId'] = recordId;

          if (tableName == 'patients') {
            patients.add(data);
          } else if (tableName == 'screenings') {
            screenings.add(data);
          }
          queueIds.add(item['id'] as int);
        } catch (e) {
          debugPrint('Error parsing sync item ${item['id']}: $e');
        }
      }

      final batchData = {
        'patients': patients,
        'screenings': screenings,
      };

      try {
        final response = await ApiService().syncBatch(batchData);
        
        // Handle successfully synced patients
        final syncedPatients = response['results']?['patients'] ?? [];
        for (var p in syncedPatients) {
          final localId = p['localId'];
          final serverId = p['serverId'];
          if (localId != null && serverId != null) {
            await _db.update(
              'patients',
              {'server_id': serverId, 'synced': 1},
              where: 'id = ?',
              whereArgs: [localId],
            );
          }
        }

        // Handle successfully synced screenings
        final syncedScreenings = response['results']?['screenings'] ?? [];
        for (var s in syncedScreenings) {
          final localId = s['localId'];
          final serverId = s['serverId'];
          if (localId != null && serverId != null) {
            await _db.update(
              'screenings',
              {'server_id': serverId, 'synced': 1},
              where: 'id = ?',
              whereArgs: [localId],
            );
          }
        }

        // Clear synced items from queue
        for (var qId in queueIds) {
          await _db.removeFromSyncQueue(qId);
        }

        debugPrint('Sync completed successfully');
        _isSyncing = false;
        return true;
      } catch (e) {
        debugPrint('Sync batch API failed: $e');
        
        // Increment retry counts
        for (var item in syncQueue) {
          final retryCount = (item['retry_count'] as int) + 1;
          if (retryCount >= AppConstants.maxRetryCount) {
            await _db.removeFromSyncQueue(item['id'] as int);
          } else {
            await _db.update(
              'sync_queue',
              {'retry_count': retryCount},
              where: 'id = ?',
              whereArgs: [item['id']],
            );
          }
        }
        
        _isSyncing = false;
        return false;
      }
    } catch (e) {
      debugPrint('Sync error: $e');
      _isSyncing = false;
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
        final ConnectivityResult result = connectivity;
        return result != ConnectivityResult.none;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchPatientFromServer(int patientId) async {
    try {
      // Actually fetch via ApiService if we needed to, but we generally just use ApiService.getPatients() 
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchScreeningFromServer(int screeningId) async {
    try {
      return null;
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    stopAutoSync();
  }
}
