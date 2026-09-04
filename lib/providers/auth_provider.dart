import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
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
      final userId = prefs.getInt('current_user_id');
      _userRole = prefs.getString('user_role');

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
        _errorMessage = 'Invalid credentials';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(User user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = DatabaseHelper();

      // Check if phone number already exists
      final existingUsers = await db.query(
        'users',
        where: 'phone_number = ?',
        whereArgs: [user.phoneNumber],
      );

      if (existingUsers.isNotEmpty) {
        _errorMessage = 'Phone number already registered';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final id = await db.insert('users', user.toMap());
      user = user.copyWith(id: id);

      _currentUser = user;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('current_user_id', user.id!);

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