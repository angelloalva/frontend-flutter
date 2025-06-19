// lib/providers/sede_provider.dart
import 'package:citas_app/utils/session_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sede.dart';
import '../services/sede_service.dart';

class SedeProvider with ChangeNotifier {
  final SedeService _sedeService = SedeService();
  List<Sede> _sedes = [];
  bool _isLoading = false;
  String? _error;

  List<Sede> get sedes => _sedes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchSedes(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception('No se encontró el token de autenticación');
      _sedes = await _sedeService.obtenerSedes(token);
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

  Future<void> crearSede(String nombre, String direccion, BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception('No se encontró el token de autenticación');
      final nuevaSede = await _sedeService.crearSede(nombre, direccion, token);
      _sedes.add(nuevaSede);
      notifyListeners();
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

  Future<void> actualizarSede(String id, String nombre, String direccion, BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception('No se encontró el token de autenticación');
      await _sedeService.actualizarSede(id, nombre, direccion, token);
      final index = _sedes.indexWhere((sede) => sede.id == id);
      if (index != -1) {
        _sedes[index] = Sede(
          id: id,
          nombre: nombre.isNotEmpty ? nombre : _sedes[index].nombre,
          direccion: direccion.isNotEmpty ? direccion : _sedes[index].direccion,
        );
        notifyListeners();
      }
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

  Future<void> eliminarSede(String id, BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception('No se encontró el token de autenticación');
      await _sedeService.eliminarSede(id, token);
      _sedes.removeWhere((sede) => sede.id == id);
      notifyListeners();
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}