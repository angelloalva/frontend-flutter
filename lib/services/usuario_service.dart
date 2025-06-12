// usuario_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citas_app/models/user.dart';


class UsuarioService {
  static const String baseUrl = 'http://localhost:8080/api/usuarios';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<User> obtenerUsuario(String id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No se encontró el token de autenticación');

    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 403) {
      throw Exception('Acceso denegado');
    } else if (response.statusCode == 404) {
      throw Exception('Usuario no encontrado');
    } else {
      throw Exception('Error al obtener el perfil: ${response.statusCode}');
    }
  }

  Future<void> actualizarUsuario(String id, User usuario) async {
    final token = await _getToken();
    if (token == null) throw Exception('No se encontró el token de autenticación');

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(usuario.toJson()),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
     if (responseBody['mensaje'] == 'Actualizado con éxito') {
        return; // Éxito
      } else {
        throw Exception('Respuesta inesperada: ${response.body}');
      }
    } else if (response.statusCode == 403) {
      throw Exception('Acceso denegado');
    } else if (response.statusCode == 404) {
      throw Exception('Usuario no encontrado');
    } else {
      throw Exception('Error al actualizar el perfil: ${response.statusCode}');
    }
  }
}