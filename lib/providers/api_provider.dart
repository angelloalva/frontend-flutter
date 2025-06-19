import 'dart:convert';
import 'package:citas_app/models/registro.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:citas_app/models/user.dart';
import 'package:citas_app/services/api_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _token;
  String _errorMessage = '';
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get token => _token;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Constructor
  AuthProvider() {
    _checkAuthStatus();
  }

  // Verificar si el usuario ya está autenticado
  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final userData = prefs.getString('user_data');

      if (token != null && userData != null) {
        _token = token;
        _user = User.fromJson(jsonDecode(userData));
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _logger.e('Error checking auth status', error: e);
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Login
  Future<bool> login({
    required int tipoDocumento,
    required String numeroDocumento,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final responseData = await _apiService.login(
        tipoDocumento: tipoDocumento,
        numeroDocumento: numeroDocumento,
        password: password,
      );

      final user = User.fromJson(responseData['user'] ?? {});
      final token = responseData['jwt'] ?? '';

      await _saveUserData(token, user);
      
      _user = user;
      _token = token;
      _status = AuthStatus.authenticated;
      
      _setLoading(false);
      return true;

    } catch (e, stackTrace) {
      _logger.e('Login error', error: e, stackTrace: stackTrace);
      _handleError(e);
      _setLoading(false);
      return false;
    }
  }

  // Register - Crear usuario desde login (solo pacientes)
  Future<void> crearUsuario( Registro usuario) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.crearUsuario(usuario);
      
      _setLoading(false);
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Register error', error: e, stackTrace: stackTrace);
      _handleError(e);
      _setLoading(false);
      throw e; // Re-lanzar el error para que lo maneje la UI
    }
  }
  

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      await prefs.remove('user_id');
      await prefs.remove('user_data');

      _user = null;
      _token = null;
      _status = AuthStatus.unauthenticated;
      
      notifyListeners();
    } catch (e) {
      _logger.e('Logout error', error: e);
    }
  }

  // Métodos privados
  Future<void> _saveUserData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _status = AuthStatus.loading;
    }
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    if (_status == AuthStatus.error) {
      _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  void _handleError(dynamic error) {
    _status = AuthStatus.error;
    
    if (error.toString().contains('401')) {
      _errorMessage = 'Credenciales incorrectas';
    } else if (error.toString().contains('400')) {
      _errorMessage = 'Datos incorrectos o usuario ya existe';
    } else if (error.toString().contains('409')) {
      _errorMessage = 'El usuario ya está registrado';
    } else if (error.toString().contains('404')) {
      _errorMessage = 'Usuario no encontrado';
    } else if (error.toString().contains('XMLHttpRequest')) {
      _errorMessage = 'Error CORS: Verifica la configuración del servidor';
    } else if (error.toString().contains('Connection refused')) {
      _errorMessage = 'Error: El servidor no está disponible';
    } else {
      _errorMessage = 'Error de conexión: ${error.toString()}';
    }
    
    notifyListeners();
  }

  // Método para limpiar mensajes de error manualmente
  void clearError() {
    _clearError();
  }
}