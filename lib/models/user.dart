class User {
  final String id;
  final String nombres;
  final String apellidos;
  final String celular;
  final String correo;
  final String direccion;
  final String tipoDocumento;
  final String numeroDocumento;
  final List<String> roles; // Cambiado de Set<String> a List<String>
  User({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.celular,
    required this.correo,
    required this.direccion,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      celular: json['celular'] ?? '',
      correo: json['correo'] ?? '',
      direccion: json['direccion'] ?? '',
      tipoDocumento: json['tipoDocumento'] ?? '',
      numeroDocumento: json['numeroDocumento'] ?? '',
      roles: List<String>.from(json['roles'] ?? []), // Cambiado para List<String>
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
      'roles': roles, // Ya es List<String>
    };
  }
}