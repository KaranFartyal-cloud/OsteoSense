import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _userRole; // 'agent' or 'user'

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;
  String? get userRole => _userRole;

  Future<void> loadCurrentUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      _userRole = prefs.getString('user_role');

      if (token != null) {
        try {
          // Try API first
          final userData = await ApiService().getCurrentUser();
          _currentUser = User.fromMap(userData['data'] ?? userData);
          final userId = _currentUser!.id;
          if (userId != null) await prefs.setInt('current_user_id', userId);
        } catch (e) {
          // Fallback to local DB
          final userId = prefs.getInt('current_user_id');
          if (userId != null) {
            final db = DatabaseHelper();
            final users = await db.query(
              'users',
              where: 'id = ?',
              whereArgs: [userId],
            );
            if (users.isNotEmpty) {
              _currentUser = User.fromMap(users.first);
            }
          }
        }
      } else {
        // No token, check local fallback just in case it's a demo session
        final userId = prefs.getInt('current_user_id');
        if (userId != null) {
          final db = DatabaseHelper();
          final users = await db.query(
            'users',
            where: 'id = ?',
            whereArgs: [userId],
          );
          if (users.isNotEmpty) {
            _currentUser = User.fromMap(users.first);
          }
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String phoneNumber, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Try API Login
      final response = await ApiService().login(phoneNumber, password);
      final token = response['token'];
      final refreshToken = response['refreshToken'];
      final userData = response['user'];

      _currentUser = User.fromMap(userData);
      
      final prefs = await SharedPreferences.getInstance();
      if (token != null) await prefs.setString('auth_token', token);
      if (refreshToken != null) await prefs.setString('refresh_token', refreshToken);
      await prefs.setInt('current_user_id', _currentUser!.id!);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (apiError) {
      // 2. Fallback to Local DB on network failure
      try {
        final db = DatabaseHelper();
        final users = await db.query(
          'users',
          where: 'phone_number = ? AND password = ?',
          whereArgs: [phoneNumber, password],
        );

        if (users.isNotEmpty) {
          _currentUser = User.fromMap(users.first);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('current_user_id', _currentUser!.id!);

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = apiError is ApiException ? apiError.message : 'Invalid credentials (offline)';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } catch (dbError) {
        _errorMessage = apiError is ApiException ? apiError.message : dbError.toString();
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }
  }

  Future<bool> signup(User user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Try API Signup
      final response = await ApiService().register(user.toMap());
      final token = response['token'];
      final refreshToken = response['refreshToken'];
      final userData = response['user'];

      _currentUser = User.fromMap(userData);
      
      final prefs = await SharedPreferences.getInstance();
      if (token != null) await prefs.setString('auth_token', token);
      if (refreshToken != null) await prefs.setString('refresh_token', refreshToken);
      await prefs.setInt('current_user_id', _currentUser!.id!);
      
      // Save locally as well for offline fallback
      final db = DatabaseHelper();
      final existing = await db.query('users', where: 'phone_number = ?', whereArgs: [user.phoneNumber]);
      if (existing.isEmpty) {
        await db.insert('users', _currentUser!.toMap());
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (apiError) {
      // 2. Fallback to Local DB on network failure
      try {
        final db = DatabaseHelper();
        final existingUsers = await db.query(
          'users',
          where: 'phone_number = ?',
          whereArgs: [user.phoneNumber],
        );

        if (existingUsers.isNotEmpty) {
          _errorMessage = 'Phone number already registered locally';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        final id = await db.insert('users', user.toMap());
        _currentUser = user.copyWith(id: id);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('current_user_id', _currentUser!.id!);

        // Note: Ideally queue this signup for sync when online
        
        _isLoading = false;
        notifyListeners();
        return true;
      } catch (dbError) {
        _errorMessage = apiError is ApiException ? apiError.message : dbError.toString();
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }
  }

  /// Quick demo login used by the hackathon build — creates a dummy user
  /// in memory (no DB/backend required) and marks the user authenticated
  /// with the given role, then persists the role/session locally.
  Future<void> demoLogin(String role) async {
    _isLoading = true;
    notifyListeners();

    _userRole = role;

    _currentUser = User(
      id: 1,
      fullName: role == 'agent' ? 'Health Worker' : 'Demo User',
      phoneNumber: '9999999999',
      password: '',
      healthCenterId: role == 'agent' ? 'HC-001' : null,
      location: 'Northeast India',
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('current_user_id', _currentUser!.id!);
      await prefs.setString('user_role', role);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _userRole = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
    await prefs.remove('user_role');
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');

    notifyListeners();
  }

  Future<bool> updateProfile(User updatedUser) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = DatabaseHelper();
      await db.update(
        'users',
        updatedUser.toMap(),
        where: 'id = ?',
        whereArgs: [_currentUser!.id],
      );

      _currentUser = updatedUser;
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setRole(String role) {
    _userRole = role;
    notifyListeners();
  }

  Future<void> saveUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', _userRole ?? 'agent');
  }
}