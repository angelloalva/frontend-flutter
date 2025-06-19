import 'package:citas_app/models/TurnoResponse.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/turno_service.dart';
import '../models/turno.dart';

class TurnoProvider with ChangeNotifier {
  final TurnoService _turnoService = TurnoService();
  bool _isLoading = false;
  String? _error;
  List<Turno> _turnos = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Turno> get turnos => _turnos;
  List<TurnoResponse> _todosLosTurnos = [];
  List<TurnoResponse> get todosLosTurnos => _todosLosTurnos;
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchTodosLosTurnos(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception('No autenticado');
      _todosLosTurnos = await _turnoService.getTurnos(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> crearTurno(Map<String, dynamic> turno, BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception('No se encontró el token de autenticación');
      await _turnoService.crearTurno(turno, token);
      // Aquí podrías actualizar una lista de turnos si la manejas
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTurnosPorDoctor(String doctorId, BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception('No se encontró el token de autenticación');
      _turnos = await _turnoService.obtenerTurnosPorDoctor(doctorId, token);
    } catch (e) {
      if (e.toString().contains('SESSION_EXPIRED')) {
        // Si tienes handleSessionExpired, úsalo aquí
        // await handleSessionExpired(context);
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