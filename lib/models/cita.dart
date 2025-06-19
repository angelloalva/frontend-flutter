class Cita {
  String? id;
  String pacienteId;
  String doctorId;
  final String doctorNombres; // Nuevo campo
  final String doctorApellidos; // Nuevo campo
  String sedeId;
  DateTime fechaHora;
  String turnoId;
  String estado;
  String? observaciones;

  Cita({
    this.id,
    required this.pacienteId,
    required this.doctorNombres,
    required this.doctorApellidos,
    required this.doctorId,
    required this.sedeId,
    required this.fechaHora,
    required this.turnoId,
    required this.estado,
    this.observaciones,
  });
  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['_id'] ?? '',
      pacienteId: json['pacienteId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      doctorNombres: json['doctorNombres'] ?? 'Desconocido',
      doctorApellidos: json['doctorApellidos'] ?? '',
      sedeId: json['sedeId'] ?? '',
      fechaHora: DateTime.parse(json['fechaHora']),
      turnoId: json['turnoId'] ?? '',
      estado: json['estado'] ?? '',
      observaciones: json['observaciones'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'pacienteId': pacienteId,
      'doctorId': doctorId,
      'doctorNombres': doctorNombres,
      'doctorApellidos': doctorApellidos,
      'sedeId': sedeId,
      'fechaHora': fechaHora.toIso8601String(),
      'turnoId': turnoId,
      'estado': estado,
      'observaciones': observaciones,
    };
  }
}
