import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/paciente_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PacienteProvider with ChangeNotifier {
  final PacienteService _pacienteService = PacienteService();
  List<User> _pacientes = [];
  bool _isLoading = false;
  String? _error;

  List<User> get pacientes => _pacientes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchPacientes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No autenticado');
      _pacientes = await _pacienteService.obtenerPacientes(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}