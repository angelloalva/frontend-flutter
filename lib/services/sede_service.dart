import 'dart:convert';

import 'package:citas_app/models/sede.dart';
import 'package:http/http.dart' as http;

class SedeService {
  static const String baseUrl = 'http://localhost:8080/api/sedes';
  Future<List<Sede>> obtenerSedes(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Sede.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
  throw Exception('SESSION_EXPIRED');
} else {
      throw Exception('Error al obtener sedes: ${response.statusCode}');
    }
  }

  Future<Sede> crearSede(String nombre, String direccion, String token) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nombre': nombre,
        'direccion': direccion,
      }),
    );

    if (response.statusCode == 201) {
     return Sede.fromJson(jsonDecode(response.body));

    }else if (response.statusCode == 401) {
  throw Exception('SESSION_EXPIRED');
}  else {
      final error = jsonDecode(response.body)['mensaje'] ?? 'Error al crear sede';
      throw Exception(error);
    }
  }

  Future<Sede> actualizarSede(String id, String nombre, String direccion, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (nombre.isNotEmpty) 'nombre': nombre,
        if (direccion.isNotEmpty) 'direccion': direccion,
      }),
    );
    
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return Sede.fromJson(responseBody);
      }else if (response.statusCode == 401) {
  throw Exception('SESSION_EXPIRED');
}  else {
        final error = jsonDecode(response.body)['mensaje'] ?? 'Error al actualizar sede';
        throw Exception(error);
      }
    }
  

  Future<void> eliminarSede(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      if (response.statusCode == 401) {
  throw Exception('SESSION_EXPIRED');
}
      final error = jsonDecode(response.body)['mensaje'] ?? 'Error al eliminar sede';
      throw Exception(error);
    }
  }
}

