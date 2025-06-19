import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/especialidad.dart';
import '../services/especialidad_service.dart';
import '../utils/session_utils.dart';

class EspecialidadProvider with ChangeNotifier {
  final EspecialidadService _especialidadService = EspecialidadService();
  List<Especialidad> _especialidades = [];
  bool _isLoading = false;
  String? _error;

  List<Especialidad> get especialidades => _especialidades;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchEspecialidades(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception('No se encontró el token de autenticación');
      _especialidades = await _especialidadService.getEspecialidades(token);
    } catch (e) {
      if (e.toString().contains('SESSION_EXPIRED')) {
        await handleSessionExpired(context);
        return;
      }
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createEspecialidad({
    required BuildContext context,
    required String nombre,
    required String descripcion,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No se encontró el token de autenticación');
      final nueva = await _especialidadService.createEspecialidad(
        nombre: nombre,
        descripcion: descripcion,
        token: token,
      );
      _especialidades.add(nueva);
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('SESSION_EXPIRED')) {
        await handleSessionExpired(context);
        return;
      }
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEspecialidad({
    required BuildContext context,
    required String id,
    required String nombre,
    required String descripcion,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No se encontró el token de autenticación');
      final actualizada = await _especialidadService.updateEspecialidad(
        id: id,
        nombre: nombre,
        descripcion: descripcion,
        token: token,
      );
      final idx = _especialidades.indexWhere((e) => e.id == id);
      if (idx != -1) {
        _especialidades[idx] = actualizada;
        notifyListeners();
      }
    } catch (e) {
      if (e.toString().contains('SESSION_EXPIRED')) {
        await handleSessionExpired(context);
        return;
      }
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
Future<void> getEspecialidad({
    required BuildContext context,
    required String id
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No se encontró el token de autenticación');
      final actualizada = await _especialidadService.getEspecialidad(
        id: id,
        token: token,
      );
      final idx = _especialidades.indexWhere((e) => e.id == id);
      if (idx != -1) {
        _especialidades[idx] = actualizada;
        notifyListeners();
      }
    } catch (e) {
      if (e.toString().contains('SESSION_EXPIRED')) {
        await handleSessionExpired(context);
        return;
      }
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEspecialidad({
    required BuildContext context,
    required String id,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No se encontró el token de autenticación');
      await _especialidadService.deleteEspecialidad(id: id, token: token);
      _especialidades.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('SESSION_EXPIRED')) {
        await handleSessionExpired(context);
        return;
      }
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}