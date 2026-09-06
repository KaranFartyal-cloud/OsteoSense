import 'package:flutter/foundation.dart';
import '../models/screening.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class ScreeningProvider with ChangeNotifier {
  List<Screening> _screenings = [];
  Screening? _currentScreening;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOfflineResult = false;

  // Draft answers from SymptomQuestionnaireScreen — held in memory
  // until ProcessingScreen submits them.
  int? _draftPatientId;
  int _draftPainLevel = 0;
  String _draftStiffnessDuration = 'none';
  bool _draftSwelling = false;
  bool _draftPastInjury = false;
  String _draftPastInjuryDetail = '';
  String? _draftGaitData;

  List<Screening> get screenings => _screenings;
  Screening? get currentScreening => _currentScreening;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOfflineResult => _isOfflineResult;
  int? get draftPatientId => _draftPatientId;
  int get draftPainLevel => _draftPainLevel;
  String get draftStiffnessDuration => _draftStiffnessDuration;
  bool get draftSwelling => _draftSwelling;
  bool get draftPastInjury => _draftPastInjury;
  String get draftPastInjuryDetail => _draftPastInjuryDetail;
  String? get draftGaitData => _draftGaitData;

  set draftGaitData(String? value) {
    _draftGaitData = value;
    notifyListeners();
  }

  Future<void> loadScreenings() async {
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
      if (kDebugMode) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
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
      var finalScreening = screening;
      
      try {
        // Find the patient's server ID to associate the screening
        final patients = await db.query('patients', where: 'id = ?', whereArgs: [screening.patientId]);
        final serverPatientId = patients.isNotEmpty ? patients.first['server_id'] as String? : null;
        
        if (serverPatientId != null) {
          // Parse gait features
          List<double> gaitFeatures = [];
          if (screening.gaitData != null) {
            try {
              final parsed = screening.gaitData!.replaceAll('[', '').replaceAll(']', '').split(',');
              gaitFeatures = parsed.map((e) => double.tryParse(e.trim()) ?? 0.0).toList();
            } catch (_) {}
          }
          
          final apiData = {
            'patientId': serverPatientId,
            'painLevel': screening.painLevel,
            'stiffnessDuration': screening.stiffnessDuration,
            'swelling': screening.swelling,
            'pastInjury': screening.pastInjury,
            'gaitFeatures': gaitFeatures,
          };
          
          final response = await ApiService().createScreening(apiData);
          final serverResult = response['screening'];
          
          // Use server's AI calculation
          finalScreening = screening.copyWith(
            serverId: serverResult['_id'],
            riskLevel: serverResult['riskLevel'],
            confidence: serverResult['confidence']?.toDouble(),
            contributingFactors: serverResult['contributingFactors'] != null 
                ? (serverResult['contributingFactors'] as List).join(',') 
                : '',
            aiReasoning: serverResult['aiReasoning'],
            doctorRecommendations: serverResult['doctorRecommendations'],
            synced: true,
          );
          _isOfflineResult = false;
        } else {
          // We don't have a serverPatientId, we can't sync this screening yet.
          // Fall back to offline flow
          _isOfflineResult = true;
        }
      } catch (apiError) {
        // Fall back to offline calculation that was passed in `screening`
        _isOfflineResult = true;
      }
      
      // Save locally
      final id = await db.insert('screenings', finalScreening.toMap());
      finalScreening = finalScreening.copyWith(id: id);
      
      if (_isOfflineResult) {
        // Add to sync queue for later
        await db.addToSyncQueue('screenings', id, 'insert', finalScreening.toMap());
      }
      
      _screenings.insert(0, finalScreening);
      _currentScreening = finalScreening;
      
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

  /// Store symptom questionnaire answers in-memory so ProcessingScreen can use them.
  void setDraftAnswers({
    required int patientId,
    required int painLevel,
    required String stiffnessDuration,
    required bool swelling,
    required bool pastInjury,
    required String pastInjuryDetail,
  }) {
    _draftPatientId = patientId;
    _draftPainLevel = painLevel;
    _draftStiffnessDuration = stiffnessDuration;
    _draftSwelling = swelling;
    _draftPastInjury = pastInjury;
    _draftPastInjuryDetail = pastInjuryDetail;
    notifyListeners();
  }

  void clearDraft() {
    _draftPatientId = null;
    _draftPainLevel = 0;
    _draftStiffnessDuration = 'none';
    _draftSwelling = false;
    _draftPastInjury = false;
    _draftPastInjuryDetail = '';
    _draftGaitData = null;
  }

  void setDraftGaitData(String data) {
    _draftGaitData = data;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
