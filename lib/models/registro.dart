class Registro {
  final int documentoTipo;
  final String documentoNumero;
  final String nombres;
  final String apellidos;
  final String correo;
  final String celular;
  final String direccion;
  final List<String> roles;
      final String password;

  Registro({
    required this.documentoTipo,
    required this.documentoNumero,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.celular,
    required this.direccion,
    required this.roles,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'documentoTipo': documentoTipo,
        'documentoNumero': documentoNumero,
        'nombres': nombres,
        'apellidos': apellidos,
        'correo': correo,
        'celular': celular,
        'direccion': direccion,
        'roles': roles,
        'password': password,
      };
}
