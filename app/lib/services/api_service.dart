import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired or invalid. Attempt refresh.
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the original request
            try {
              final opts = Options(
                method: e.requestOptions.method,
                headers: e.requestOptions.headers,
              );
              final response = await _dio.request(
                e.requestOptions.path,
                options: opts,
                data: e.requestOptions.data,
                queryParameters: e.requestOptions.queryParameters,
              );
              return handler.resolve(response);
            } catch (retryErr) {
              return handler.next(e);
            }
          } else {
            // Refresh failed, user needs to login again.
            await _clearAuth();
          }
        }
        return handler.next(e);
      },
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken == null) return false;

      // Note: Do not use the main _dio instance here to avoid infinite loops if this fails with 401
      final refreshDio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
      final response = await refreshDio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200 && response.data['token'] != null) {
        await prefs.setString('auth_token', response.data['token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove(AppConstants.keyUserId);
    // Ideally, we'd also dispatch an event to log the user out of the UI,
    // but the AuthProvider will handle fetching the current user and reacting to missing tokens.
  }

  // --- Auth Endpoints ---

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'phone': phone,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/auth/register', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // --- Patient Endpoints ---

  Future<List<dynamic>> getPatients() async {
    try {
      final response = await _dio.get('/patients');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createPatient(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/patients', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updatePatient(dynamic id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/patients/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // --- Screening Endpoints ---

  Future<Map<String, dynamic>> createScreening(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/screenings', data: data);
      return response.data; // Server AI response
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // --- Sync ---

  Future<Map<String, dynamic>> syncBatch(Map<String, dynamic> batchData) async {
    try {
      final response = await _dio.post('/sync/batch', data: batchData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return ApiException('Network connection failed. Please check your internet.', statusCode: e.response?.statusCode);
    }
    
    if (e.response != null) {
      final data = e.response?.data;
      String message = 'An error occurred';
      if (data is Map<String, dynamic> && data.containsKey('error')) {
        message = data['error'];
      }
      return ApiException(message, statusCode: e.response?.statusCode, data: data);
    }
    
    return ApiException(e.message ?? 'Unknown error occurred');
  }
}
