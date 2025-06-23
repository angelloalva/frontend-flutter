import 'dart:convert';
import 'package:citas_app/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:citas_app/models/especialidad.dart';

class EspecialidadService {
  static const String baseUrl = '${ApiConfig.baseAdminUrl}';

  Future<List<Especialidad>> getEspecialidades(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/especialidades'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Especialidad.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('SESSION_EXPIRED');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<Especialidad> createEspecialidad({
    required String nombre,
    required String descripcion,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/especialidades'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'nombre': nombre, 'descripcion': descripcion}),
    );

    if (response.statusCode == 200) {
      return Especialidad.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('SESSION_EXPIRED');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<Especialidad> updateEspecialidad({
    required String id,
    required String nombre,
    required String descripcion,
    required String token,
  }) async {
    final response = await http.put(
      // Cambia a PUT si tu API lo soporta
      Uri.parse('$baseUrl/api/especialidades/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'nombre': nombre, 'descripcion': descripcion}),
    );

    if (response.statusCode == 200) {
      return Especialidad.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('SESSION_EXPIRED');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<Especialidad> getEspecialidad({
    required String id,
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/especialidades/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Especialidad.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('SESSION_EXPIRED');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> deleteEspecialidad({
    required String id,
    required String token,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/especialidades/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('SESSION_EXPIRED');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  // Método para login (mantenido para consistencia)
  Future<Map<String, dynamic>> login({
    required int documentType,
    required String documentNumber,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'documentType': documentType,
        'documentNumber': documentNumber,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('SESSION_EXPIRED');
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }
}
