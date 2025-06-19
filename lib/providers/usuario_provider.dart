// usuario_provider.dart
import 'package:flutter/material.dart';
import 'package:citas_app/models/user.dart';
import 'package:citas_app/services/usuario_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioProvider with ChangeNotifier {
  final UsuarioService _usuarioService = UsuarioService();
  User? _usuario;
  bool _isLoading = false;
  String? _error;
  List<User> _usuarios = [];
  List<User> get usuarios => _usuarios;
  User? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchUsuarios() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');
    _usuarios = await _usuarioService.obtenerUsuarios(token);
    notifyListeners();
  }

  Future<void> fetchUsuario(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception('No se encontró el token de autenticación');
      _usuario = await _usuarioService.obtenerUsuario(id,token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> actualizarUsuario(String id, User usuario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception('No se encontró el token de autenticación');
      await _usuarioService.actualizarUsuario(id, usuario, token);
      _usuario = usuario; // Actualiza el estado local
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

  }
    Future<void> crearUsuario({
    required Map<String, dynamic> usuario,
    required Map<String, dynamic> doctor,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');
    await UsuarioService().crearUsuario(
      usuario:usuario,
      doctor: doctor,
      token: token,
    );
    // Aquí podrías actualizar una lista de usuarios si la manejas
    notifyListeners();
  }
  bool get isAdmin => _usuario?.roles.contains('ADMIN') ?? false;

  // Actualiza setUsuario para notificar cambios
  void setUsuario(User usuario) {
    _usuario = usuario;
    notifyListeners();
  }
}