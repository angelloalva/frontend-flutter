// usuario_provider.dart
import 'package:flutter/material.dart';
import 'package:citas_app/models/user.dart';
import 'package:citas_app/services/usuario_service.dart';

class UsuarioProvider with ChangeNotifier {
  final UsuarioService _usuarioService = UsuarioService();
  User? _usuario;
  bool _isLoading = false;
  String? _error;

  User? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsuario(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _usuario = await _usuarioService.obtenerUsuario(id);
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
      await _usuarioService.actualizarUsuario(id, usuario);
      _usuario = usuario; // Actualiza el estado local
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

  }
  bool get isAdmin => _usuario?.roles.contains('ADMIN') ?? false;

  // Actualiza setUsuario para notificar cambios
  void setUsuario(User usuario) {
    _usuario = usuario;
    notifyListeners();
  }
}