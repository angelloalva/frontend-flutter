class RegistroUsuarioRequest {
  final int documentoTipo;
  final String documentoNumero;
  final String nombres;
  final String apellidos;
  final String correo;
  final String celular;
  final String direccion;
  final List<String> roles;

  RegistroUsuarioRequest({
    required this.documentoTipo,
    required this.documentoNumero,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.celular,
    required this.direccion,
    required this.roles,
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
      };
}

class DoctorCreateRequest {
  final String cmp;
  final String especialidadId;
  final List<String> sedeIds;
  final String? fotoUrl;

  DoctorCreateRequest({
    required this.cmp,
    required this.especialidadId,
    required this.sedeIds,
    this.fotoUrl,
  });

  Map<String, dynamic> toJson() => {
        'cmp': cmp,
        'especialidadId': especialidadId,
        'sedeIds': sedeIds,
        'fotoUrl': fotoUrl,
      };
}