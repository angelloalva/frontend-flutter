import 'dart:convert';
import 'package:citas_app/models/TurnoResponse.dart';
import 'package:http/http.dart' as http;
import '../models/turno.dart';

class TurnoService {
  final String baseUrl = 'http://localhost:8083/api/turnos'; // Cambia por tu URL real

  Future<void> crearTurno(Map<String, dynamic> turno, String token) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(turno),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear turno: ${response.body}');
    }
  }
Future<List<TurnoResponse>> getTurnos(String token) async {
  print('Iniciando petición GET de turnos...');
  print('Token: $token');
  print('URL: $baseUrl');  // Verifica que la URL sea correcta

  final response = await http.get(
    Uri.parse('$baseUrl'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print('Código de respuesta: ${response.statusCode}');
  print('Respuesta: ${response.body}');

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    print('Cantidad de turnos recibidos: ${data.length}');
    for (var turno in data) {
      print('Turno -> DoctorId: ${turno['doctorId']}, SedeId: ${turno['sedeId']}, EspecialidadId: ${turno['especialidadId']}');
    }

    return data.map((json) => TurnoResponse.fromJson(json)).toList();
  } else if (response.statusCode == 401) {
    print('Sesión expirada.');
    throw Exception('SESSION_EXPIRED');
  } else {
    print('Error ${response.statusCode}: ${response.body}');
    throw Exception('Error ${response.statusCode}: ${response.body}');
  }
}
  Future<List<Turno>> obtenerTurnosPorDoctor(String doctorId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/doctor/$doctorId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Turno.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('SESSION_EXPIRED');
    } else {
      throw Exception('Error al obtener turnos: ${response.body}');
    }
  }
}