import 'dart:convert';
import 'package:citas_app/models/user.dart';
import 'package:http/http.dart' as http;
import '../models/doctor.dart';

class DoctorService {
  static const String baseUrl = 'http://localhost:8080/api/doctores';

  Future<List<Doctor>> obtenerDoctores(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Doctor.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('SESSION_EXPIRED');
    } else {
      throw Exception('Error al obtener doctores: ${response.body}');
    }
  }
    Future<List<User>> obtenerMisPacientes(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mis-pacientes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener mis pacientes: ${response.body}');
    }
  }
}