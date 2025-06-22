class UsuarioRequest {
  final String id;
  final String nombres;
  
  final String tipoDocumento;
  final String numeroDocumento;
  final List<String> roles; // Cambiado de Set<String> a List<String>
  UsuarioRequest({
    required this.id,
    required this.nombres,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.roles,
  });

  factory UsuarioRequest.fromJson(Map<String, dynamic> json) {
    return UsuarioRequest(
      id: json['id'] ?? '',
      nombres: json['nombres'] ?? '',
      tipoDocumento: json['tipoDocumento'] ?? '',
      numeroDocumento: json['numeroDocumento'] ?? '',
      roles: List<String>.from(json['roles'] ?? []), // Cambiado para List<String>
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombres': nombres,
      'tipoDocumento': tipoDocumento,
      'numeroDocumento': numeroDocumento,
      'roles': roles, // Ya es List<String>
    };
  }
}