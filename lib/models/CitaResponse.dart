class CitaResponse {
  String? id;
  String pacienteId;
  String doctorId;
  final String doctorNombres; // Nuevo campo
  final String doctorApellidos; // Nuevo campo
  String sedeId;
  String sedeNombre; // Nuevo campo opcional
  String especialidadNombre; // Nuevo campo opcional
  DateTime fechaHora;
  String turnoId;
  String estado;
  String? observaciones;

  CitaResponse({
    this.id,
    required this.pacienteId,
    required this.doctorNombres,
    required this.doctorApellidos,
    required this.doctorId,
    required this.sedeId,
    required this.sedeNombre, // Valor por defecto
    required this.especialidadNombre, // Valor por defecto
    required this.fechaHora,
    required this.turnoId,
    required this.estado,
    this.observaciones,
  });
  factory CitaResponse.fromJson(Map<String, dynamic> json) {
    return CitaResponse(
      id: json['_id'] ?? '',
      pacienteId: json['pacienteId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      doctorNombres: json['doctorNombres'] ?? 'Desconocido',
      doctorApellidos: json['doctorApellidos'] ?? '',
      sedeId: json['sedeId'] ?? '',
      sedeNombre: json['sedeNombre'] ?? 'Sin sede',
      especialidadNombre: json['especialidadNombre'] ?? 'Sin especialidad',
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
      'sedeNombre': sedeNombre,
      'especialidadNombre': especialidadNombre,
      'fechaHora': fechaHora.toIso8601String(),
      'turnoId': turnoId,
      'estado': estado,
      'observaciones': observaciones,
    };
  }
}
