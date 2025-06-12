import 'dart:convert';
import 'package:citas_app/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citas_app/models/especialidad.dart';


class EspecialidadService { 
  static const String baseUrl = 'http://localhost:8080';
Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  void _handleUnauthorized(BuildContext? context) async {
    if (context != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      await prefs.remove('user_id');
      await prefs.remove('user_data');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<List<Especialidad>> getEspecialidades(BuildContext context) async {
    final token = await _getToken();
    if (token == null) {
      _handleUnauthorized(context);
      throw Exception('No se encontró el token de autenticación');
    }

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
      _handleUnauthorized(context);
      throw Exception('Sesión expirada');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<Especialidad> createEspecialidad({
    required String nombre,
    required String descripcion,
    required BuildContext context,
  }) async {
    final token = await _getToken();
    if (token == null) {
      _handleUnauthorized(context);
      throw Exception('No se encontró el token de autenticación');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/especialidades'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
      }),
    );

    if (response.statusCode == 201) {
      return Especialidad.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      _handleUnauthorized(context);
      throw Exception('Sesión expirada');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<Especialidad> updateEspecialidad({
    required String id,
    required String nombre,
    required String descripcion,
    required BuildContext context,
  }) async {
    final token = await _getToken();
    if (token == null) {
      _handleUnauthorized(context);
      throw Exception('No se encontró el token de autenticación');
    }

    final response = await http.put( // Cambia a PUT si tu API lo soporta
      Uri.parse('$baseUrl/api/especialidades/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
      }),
    );

    if (response.statusCode == 200) {
      return Especialidad.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      _handleUnauthorized(context);
      throw Exception('Sesión expirada');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> deleteEspecialidad(String id, BuildContext context) async {
    final token = await _getToken();
    if (token == null) {
      _handleUnauthorized(context);
      throw Exception('No se encontró el token de autenticación');
    }

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
      _handleUnauthorized(context);
      throw Exception('Sesión expirada');
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
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }


}