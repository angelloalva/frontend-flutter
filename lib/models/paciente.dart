class Paciente {
  final String id;
  final String nombres;
  final String apellidos;
  final String celular;
  final String correo;
  final String direccion;
  final String tipoDocumento;
  final String numeroDocumento;
  Paciente({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.celular,
    required this.correo,
    required this.direccion,
    required this.tipoDocumento,
    required this.numeroDocumento,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      celular: json['celular'] ?? '',
      correo: json['correo'] ?? '',
      direccion: json['direccion'] ?? '',
      tipoDocumento: json['tipoDocumento'] ?? '',
      numeroDocumento: json['numeroDocumento'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'celular': celular,
      'correo': correo,
      'direccion': direccion,
      'tipoDocumento': tipoDocumento,
      'numeroDocumento': numeroDocumento,
      
    };
  }
}