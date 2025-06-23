// usuario_service.dart
import 'dart:convert';
import 'package:citas_app/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citas_app/models/user.dart';

class UsuarioService {
  static const String baseUrl = '${ApiConfig.baseAdminUrl}/api/usuarios';

  Future<void> crearUsuario({
    required Map<String, dynamic> usuario,
    required Map<String, dynamic> doctor,
    required String token,
  }) async {
    final body = {'usuario': usuario, if (doctor != null) 'doctor': doctor};
    print('Body: $body');
    final response = await http.post(
      Uri.parse('$baseUrl'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear usuario: ${response.body}');
    }
  }

  Future<User> obtenerUsuario(String id, String token) async {
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

  Future<void> actualizarUsuario(String id, User usuario, String token) async {
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

  Future<List<User>> obtenerUsuarios(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener usuarios: ${response.body}');
    }
  }
}
