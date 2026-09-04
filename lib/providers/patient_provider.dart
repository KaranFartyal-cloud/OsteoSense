import 'package:flutter/foundation.dart';
import '../models/patient.dart';
import '../services/database_helper.dart';

class PatientProvider with ChangeNotifier {
  List<Patient> _patients = [];
  Patient? _selectedPatient;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _screeningData = {};

  List<Patient> get patients => _patients;
  Patient? get selectedPatient => _selectedPatient;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get screeningData => _screeningData;

  Future<void> loadPatients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = DatabaseHelper();
      final patientsData = await db.query(
        'patients',
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

  Future<void> searchPatients(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
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
      final id = await db.insert('patients', patient.toMap());
      patient = patient.copyWith(id: id);
      
      _patients.insert(0, patient);
      _selectedPatient = patient;
      
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
      await db.update(
        'patients',
        patient.toMap(),
        where: 'id = ?',
        whereArgs: [patient.id],
      );

      final index = _patients.indexWhere((p) => p.id == patient.id);
      if (index != -1) {
        _patients[index] = patient;
      }

      if (_selectedPatient?.id == patient.id) {
        _selectedPatient = patient;
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
