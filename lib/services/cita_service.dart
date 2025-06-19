import 'dart:convert';
import 'package:citas_app/models/cita.dart';
import 'package:http/http.dart' as http;

class CitaService {
  static const String baseUrl = 'http://localhost:8080/api/citas';

   Future<void> crearCita(Cita cita,String token) async {
     final jsonData = cita.toJson();
    print('=== DEBUG CITA SERVICE ===');
      print('JSON que se va a enviar: $jsonData');
      print('fechaHora en JSON: ${jsonData['fechaHora']}');
      print('Body completo: ${jsonEncode(jsonData)}');
  print('==========================');
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json' ,'Authorization': 'Bearer $token',},
      
      body: jsonEncode(jsonData),
    );
   
    if (response.statusCode != 201) {
      throw Exception('Error al crear cita: ${response.body}');
    }
  }
   Future<List<Cita>> obtenerCitasPorPaciente(String pacienteId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/paciente/$pacienteId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Cita.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener citas: ${response.body}');
    }
  }
}