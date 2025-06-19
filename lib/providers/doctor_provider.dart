import 'package:citas_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/doctor.dart';
import '../services/doctor_service.dart';

class DoctorProvider with ChangeNotifier {
  final DoctorService _doctorService = DoctorService();
  List<Doctor> _doctores = [];
  bool _isLoading = false;
  String? _error;

  List<Doctor> get doctores => _doctores;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<User> _misPacientes = [];
  bool _isLoadingPacientes = false;
  String? _errorPacientes;

  List<User> get misPacientes => _misPacientes;
  bool get isLoadingPacientes => _isLoadingPacientes;
  String? get errorPacientes => _errorPacientes;


  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchDoctores() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No autenticado');
      _doctores = await _doctorService.obtenerDoctores(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> fetchMisPacientes() async {
    _isLoadingPacientes = true;
    _errorPacientes = null;
    notifyListeners();
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No autenticado');
      _misPacientes = await _doctorService.obtenerMisPacientes(token);
    } catch (e) {
      _errorPacientes = e.toString();
    } finally {
      _isLoadingPacientes = false;
      notifyListeners();
    }
  }
}