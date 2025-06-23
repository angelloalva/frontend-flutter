import 'dart:convert';
import 'package:citas_app/config/api_config.dart';
import 'package:citas_app/models/paciente.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class PacienteService {
  static const String baseUrl =
      '${ApiConfig.baseAdminUrl}/api/usuarios/pacientes';

  Future<List<Paciente>> obtenerPacientes(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Paciente.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener pacientes: ${response.body}');
    }
  }
}
