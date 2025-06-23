import 'package:citas_app/models/registro.dart';
import 'package:citas_app/models/user.dart';
import 'package:citas_app/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _baseUrl = '${ApiConfig.baseAuthUrl}';

  Future<Map<String, dynamic>> login({
    required int tipoDocumento,
    required String numeroDocumento,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Flutter-App/1.0',
      },
      body: json.encode({
        'tipoDocumento': tipoDocumento,
        'numeroDocumento': numeroDocumento,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> crearUsuario(Registro usuario) async {
    final body = usuario.toJson();
    print('Body: $usuario');
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear usuario: ${response.body}');
    }
  }

  Future<User> miPerfil(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/auth/me'),
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
}
