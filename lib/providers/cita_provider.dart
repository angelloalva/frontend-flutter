
import 'package:citas_app/models/CitaResponse.dart';
import 'package:flutter/material.dart';
import 'package:citas_app/services/cita_service.dart';
import 'package:citas_app/models/cita.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CitaProvider with ChangeNotifier {
  final CitaService _citaService = CitaService();

  bool isLoading = false;
  String? error;
  List<CitaResponse> _citas = [];
  List<CitaResponse> get citas => _citas;
    Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> crearCita(Cita cita, BuildContext context) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception('No autenticado');
      await _citaService.crearCita(cita, token);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCitasPorPaciente(String pacienteId, BuildContext context) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
    final token = await _getToken();
      if (token == null) throw Exception('No autenticado');
      _citas = await _citaService.obtenerCitasPorPaciente(pacienteId,token);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
