class Turno {
  final String id;
  final String especialidadId;
  final String sedeId;
  final String doctorId;
  final List<DiaTurno> diasDisponibles;

  Turno({
    required this.id,
    required this.especialidadId,
    required this.sedeId,
    required this.doctorId,
    required this.diasDisponibles,
  });

  factory Turno.fromJson(Map<String, dynamic> json) {
    return Turno(
      id: json['id'] ?? '',
      especialidadId: json['especialidadId'] ?? '',
      sedeId: json['sedeId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      diasDisponibles: (json['diasDisponibles'] as List<dynamic>? ?? [])
          .map((e) => DiaTurno.fromJson(e))
          .toList(),
    );
  }
}

class DiaTurno {
  final String fecha; // Puedes usar DateTime si prefieres
  final String dia;
  final String horaInicio;
  final String horaFin;
  final List<SlotTurno> slots;

  DiaTurno({
    required this.fecha,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    required this.slots,
  });

  factory DiaTurno.fromJson(Map<String, dynamic> json) {
    return DiaTurno(
      fecha: json['fecha'] ?? '',
      dia: json['dia'] ?? '',
      horaInicio: json['horaInicio'] ?? '',
      horaFin: json['horaFin'] ?? '',
      slots: (json['slots'] as List<dynamic>? ?? [])
          .map((e) => SlotTurno.fromJson(e))
          .toList(),
    );
  }
}

class SlotTurno {
  final String horaInicio;
  final String horaFin;
  final String fechaHoraCompleta;
  final bool ocupado;
  final String? pacienteId;
  final String? citaId;

  SlotTurno({
    required this.horaInicio,
    required this.horaFin,
    required this.fechaHoraCompleta,
    required this.ocupado,
    this.pacienteId,
    this.citaId,
  });

  factory SlotTurno.fromJson(Map<String, dynamic> json) {
    return SlotTurno(
      horaInicio: json['horaInicio'] ?? '',
      horaFin: json['horaFin'] ?? '',
      fechaHoraCompleta: json['fechaHoraCompleta'] ?? '',
      ocupado: json['ocupado'] ?? false,
      pacienteId: json['pacienteId'],
      citaId: json['citaId'],
    );
  }
}