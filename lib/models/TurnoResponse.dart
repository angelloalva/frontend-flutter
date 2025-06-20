class TurnoResponse {
  final String id;
  final String especialidadId;
  final String sedeId;
  final String doctorId;
  final String doctorNombres;
  final String doctorApellidos;
  final String doctorCmp; // Nuevo campo opcional
  final String sedeNombre;
  final String especialidadNombre;
  final List<DiaTurnoResponse> diasDisponibles;

  TurnoResponse({
    required this.id,
    required this.especialidadId,
    required this.sedeId,
    required this.doctorId,
    required this.doctorNombres,
    required this.doctorApellidos,
    required this.doctorCmp, 
    required this.sedeNombre,
    required this.especialidadNombre,
    required this.diasDisponibles,
  });

  factory TurnoResponse.fromJson(Map<String, dynamic> json) {
    try {
      return TurnoResponse(
        id: json['id'] ?? '',
        especialidadId: json['especialidadId'] ?? '',
        sedeId: json['sedeId'] ?? '',
        doctorId: json['doctorId'] ?? '',
        doctorNombres: json['doctorNombres'] ?? 'Desconocido',
        doctorApellidos: json['doctorApellidos'] ?? '',
        doctorCmp: json['doctorCmp'] ?? '', // Campo opcional
        sedeNombre: json['sedeNombre'] ?? 'Sin sede',
        especialidadNombre: json['especialidadNombre'] ?? 'Sin especialidad',
        diasDisponibles: (json['diasDisponibles'] as List<dynamic>? ?? [])
            .map((e) {
              try {
                return DiaTurnoResponse.fromJson(e);
              } catch (error) {
                print('Error parseando día: $error');
                print('Datos del día problemático: $e');
                return null;
              }
            })
            .where((dia) => dia != null)
            .cast<DiaTurnoResponse>()
            .toList(),
      );
    } catch (e) {
      print('Error en TurnoResponse.fromJson: $e');
      print('JSON problemático: $json');
      rethrow;
    }
  }
}

class DiaTurnoResponse {
  final DateTime fecha;
  final String dia;
  final String horaInicio; // Cambiar de vuelta a String
  final String horaFin;    // Cambiar de vuelta a String
  final List<SlotTurnoResponse> slots;

  DiaTurnoResponse({
    required this.fecha,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    required this.slots,
  });

  factory DiaTurnoResponse.fromJson(Map<String, dynamic> json) {
    try {
      return DiaTurnoResponse(
        fecha: DateTime.parse(json['fecha'] ?? ''),
        dia: json['dia'] ?? '',
        horaInicio: json['horaInicio'] ?? '00:00:00',
        horaFin: json['horaFin'] ?? '00:00:00',
        slots: (json['slots'] as List<dynamic>? ?? [])
            .map((e) {
              try {
                return SlotTurnoResponse.fromJson(e);
              } catch (error) {
                print('Error parseando slot: $error');
                print('Datos del slot problemático: $e');
                return null;
              }
            })
            .where((slot) => slot != null)
            .cast<SlotTurnoResponse>()
            .toList(),
      );
    } catch (e) {
      print('Error en DiaTurnoResponse.fromJson: $e');
      print('JSON problemático: $json');
      rethrow;
    }
  }
}

class SlotTurnoResponse {
  final String horaInicio;    // Cambiar de vuelta a String
  final String horaFin;       // Cambiar de vuelta a String
  final DateTime fechaHoraCompleta;
  final bool ocupado;
  final String? pacienteId;
  final String? citaId;

  SlotTurnoResponse({
    required this.horaInicio,
    required this.horaFin,
    required this.fechaHoraCompleta,
    required this.ocupado,
    this.pacienteId,
    this.citaId,
  });

  factory SlotTurnoResponse.fromJson(Map<String, dynamic> json) {
    try {
      return SlotTurnoResponse(
        horaInicio: json['horaInicio'] ?? '00:00:00',
        horaFin: json['horaFin'] ?? '00:00:00',
        fechaHoraCompleta: DateTime.parse(json['fechaHoraCompleta'] ?? ''),
        ocupado: json['ocupado'] ?? false,
        pacienteId: json['pacienteId'],
        citaId: json['citaId'],
      );
    } catch (e) {
      print('Error en SlotTurnoResponse.fromJson: $e');
      print('JSON problemático: $json');
      rethrow;
    }
  }
}