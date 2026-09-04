import 'package:flutter/foundation.dart';
import '../models/screening.dart';
import '../models/patient.dart';
import '../services/database_helper.dart';

class ScreeningProvider with ChangeNotifier {
  List<Screening> _screenings = [];
  Screening? _currentScreening;
  bool _isLoading = false;
  String? _errorMessage;

  List<Screening> get screenings => _screenings;
  Screening? get currentScreening => _currentScreening;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadScreenings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = DatabaseHelper();
      final screeningsData = await db.query(
        'screenings',
        orderBy: 'screening_date DESC',
      );

      _screenings = screeningsData.map((data) => Screening.fromMap(data)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadScreeningsByPatient(int patientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = DatabaseHelper();
      final screeningsData = await db.query(
        'screenings',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'screening_date DESC',
      );

      _screenings = screeningsData.map((data) => Screening.fromMap(data)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveScreening(Screening screening) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = DatabaseHelper();
      final id = await db.insert('screenings', screening.toMap());
      screening = screening.copyWith(id: id);
      
      _screenings.insert(0, screening);
      _currentScreening = screening;
      
      // Add to sync queue
      await db.addToSyncQueue('screenings', id, 'insert', screening.toMap());
      
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

  Future<bool> updateScreening(Screening screening) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = DatabaseHelper();
      await db.update(
        'screenings',
        screening.toMap(),
        where: 'id = ?',
        whereArgs: [screening.id],
      );

      final index = _screenings.indexWhere((s) => s.id == screening.id);
      if (index != -1) {
        _screenings[index] = screening;
      }

      if (_currentScreening?.id == screening.id) {
        _currentScreening = screening;
      }

      // Add to sync queue
      await db.addToSyncQueue('screenings', screening.id!, 'update', screening.toMap());

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

  Future<bool> deleteScreening(int screeningId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = DatabaseHelper();
      await db.delete(
        'screenings',
        where: 'id = ?',
        whereArgs: [screeningId],
      );

      _screenings.removeWhere((s) => s.id == screeningId);
      
      if (_currentScreening?.id == screeningId) {
        _currentScreening = null;
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

  void setCurrentScreening(Screening screening) {
    _currentScreening = screening;
    notifyListeners();
  }

  void clearCurrentScreening() {
    _currentScreening = null;
    notifyListeners();
  }

  Future<Map<String, int>> getRiskDistribution() async {
    try {
      final db = DatabaseHelper();
      final screeningsData = await db.query('screenings');

      int low = 0;
      int medium = 0;
      int high = 0;

      for (var data in screeningsData) {
        final riskLevel = data['risk_level'] as String?;
        if (riskLevel != null) {
          switch (riskLevel.toLowerCase()) {
            case 'low':
              low++;
              break;
            case 'medium':
              medium++;
              break;
            case 'high':
              high++;
              break;
          }
        }
      }

      return {'low': low, 'medium': medium, 'high': high};
    } catch (e) {
      return {'low': 0, 'medium': 0, 'high': 0};
    }
  }

  Future<List<Map<String, dynamic>>> getScreeningsOverTime() async {
    try {
      final db = DatabaseHelper();
      final screeningsData = await db.query(
        'screenings',
        orderBy: 'screening_date ASC',
      );

      final Map<String, int> dateCount = {};
      
      for (var data in screeningsData) {
        final dateStr = data['screening_date'] as String;
        final date = DateTime.parse(dateStr);
        final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        dateCount[key] = (dateCount[key] ?? 0) + 1;
      }

      return dateCount.entries.map((e) => {
        'date': e.key,
        'count': e.value,
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> getTotalScreenings() async {
    try {
      final db = DatabaseHelper();
      final screeningsData = await db.query('screenings');
      return screeningsData.length;
    } catch (e) {
      return 0;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
