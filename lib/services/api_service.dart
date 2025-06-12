import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _baseUrl = 'http://localhost:8080';

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



}