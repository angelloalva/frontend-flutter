
class User {
  final String id;
  final String nombres;
  final String apellidos;
  final String celular;
  final String correo;
  final String direccion;
  final String tipoDocumento;
  final String numeroDocumento;
  final Set<String> roles;
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
      tipoDocumento :json['tipoDocumento'] ?? 1,
      numeroDocumento: json['numeroDocumento'] ?? '',  
      roles: (json['roles'] as List<dynamic>?)?.cast<String>().toSet() ?? {},
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
      'roles': roles.toList(), // Convertir Set<String> a List<String>v
    };
  }
}