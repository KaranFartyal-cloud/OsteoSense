import 'package:flutter/foundation.dart';
import '../models/patient.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class PatientProvider with ChangeNotifier {
  List<Patient> _patients = [];
  Patient? _selectedPatient;
  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, dynamic> _screeningData = {};

  List<Patient> get patients => _patients;
  Patient? get selectedPatient => _selectedPatient;
  int? get selectedPatientId => _selectedPatient?.id;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get screeningData => _screeningData;

  Future<void> loadPatients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      try {
        // Try API first
        final patientsData = await ApiService().getPatients();
        _patients = patientsData.map((data) {
          // Backend might return _id (Mongo), map it to serverId
          final pData = data as Map<String, dynamic>;
          if (pData['_id'] != null) {
            pData['server_id'] = pData['_id'];
          }
          if (pData['fullName'] != null) {
            pData['name'] = pData['fullName'];
          }
          if (pData['createdAt'] != null) {
            pData['created_at'] = pData['createdAt'];
          }
          if (pData['updatedAt'] != null) {
            pData['updated_at'] = pData['updatedAt'];
          }
          pData['synced'] = 1;
          return Patient.fromMap(pData);
        }).toList();

        // Optional: Update local DB cache with fresh data here
        // This would require matching by serverId or localId to avoid duplicates

      } catch (apiError) {
        // Fallback to local DB
        final db = DatabaseHelper();
        final patientsData = await db.query(
          'patients',
          orderBy: 'created_at DESC',
        );
        _patients = patientsData.map((data) => Patient.fromMap(data)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchPatients(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
      final db = DatabaseHelper();
      final patientsData = await db.query(
        'patients',
        where: 'name LIKE ? OR village LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'created_at DESC',
      );

      _patients = patientsData.map((data) => Patient.fromMap(data)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByRiskLevel(String riskLevel) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
      final db = DatabaseHelper();
      final screeningsData = await db.query(
        'screenings',
        where: 'risk_level = ?',
        whereArgs: [riskLevel],
        orderBy: 'screening_date DESC',
      );

      final patientIds = screeningsData.map((s) => s['patient_id'] as int).toSet();
      
      if (patientIds.isEmpty) {
        _patients = [];
      } else {
        final placeholders = List.filled(patientIds.length, '?').join(',');
        final patientsData = await db.query(
          'patients',
          where: 'id IN ($placeholders)',
          whereArgs: patientIds.toList(),
        );
        _patients = patientsData.map((data) => Patient.fromMap(data)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPatient(Patient patient) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = DatabaseHelper();
      
      // Save locally first to get an ID
      final id = await db.insert('patients', patient.toMap());
      var newPatient = patient.copyWith(id: id);
      
      try {
        // Try API sync immediately
        final apiData = {
          'localId': id,
          'fullName': newPatient.name,
          'age': newPatient.age,
          'gender': newPatient.gender,
          'contact': newPatient.contact,
          'village': newPatient.village,
          'address': newPatient.address,
          'occupation': newPatient.occupation,
        };
        
        final response = await ApiService().createPatient(apiData);
        
        // Update local record with server ID and mark synced
        final serverId = response['patient']['_id'];
        newPatient = newPatient.copyWith(serverId: serverId, synced: true);
        
        await db.update(
          'patients',
          {'server_id': serverId, 'synced': 1},
          where: 'id = ?',
          whereArgs: [id],
        );
      } catch (apiError) {
        // Failed to sync immediately, add to sync queue
        await db.addToSyncQueue('patients', id, 'insert', newPatient.toMap());
      }
      
      _patients.insert(0, newPatient);
      _selectedPatient = newPatient;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePatient(Patient patient) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = DatabaseHelper();
      
      // Update local DB first
      await db.update(
        'patients',
        patient.toMap(),
        where: 'id = ?',
        whereArgs: [patient.id],
      );

      var updatedPatient = patient;

      try {
        // Try API sync immediately if we have a serverId
        if (patient.serverId != null) {
          final apiData = {
            'fullName': patient.name,
            'age': patient.age,
            'gender': patient.gender,
            'contact': patient.contact,
            'village': patient.village,
            'address': patient.address,
            'occupation': patient.occupation,
          };
          
          // Call updatePatient API using the mongo _id
          await ApiService().updatePatient(patient.serverId, apiData);
          
          updatedPatient = patient.copyWith(synced: true);
          await db.update(
            'patients',
            {'synced': 1},
            where: 'id = ?',
            whereArgs: [patient.id],
          );
        } else {
           // It was never synced, just add to sync queue as an insert or update
           await db.addToSyncQueue('patients', patient.id!, 'update', patient.toMap());
        }
      } catch (apiError) {
        // Failed to sync immediately, add to sync queue
        await db.addToSyncQueue('patients', patient.id!, 'update', patient.toMap());
      }

      final index = _patients.indexWhere((p) => p.id == patient.id);
      if (index != -1) {
        _patients[index] = updatedPatient;
      }

      if (_selectedPatient?.id == patient.id) {
        _selectedPatient = updatedPatient;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePatient(int patientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = DatabaseHelper();
      await db.delete(
        'patients',
        where: 'id = ?',
        whereArgs: [patientId],
      );

      _patients.removeWhere((p) => p.id == patientId);
      
      if (_selectedPatient?.id == patientId) {
        _selectedPatient = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> selectPatient(Patient patient) async {
    _selectedPatient = patient;
    notifyListeners();
  }

  Future<void> loadPatientById(int patientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = DatabaseHelper();
      final patientsData = await db.query(
        'patients',
        where: 'id = ?',
        whereArgs: [patientId],
      );

      if (patientsData.isNotEmpty) {
        _selectedPatient = Patient.fromMap(patientsData.first);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
