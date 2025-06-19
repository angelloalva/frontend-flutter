class Doctor {
  final String id;
  final String usuarioId;
  final String cmp;
  final String especialidadId;
  final List<String> sedeIds;
  final String? fotoUrl;

  Doctor({
    required this.id,
    required this.usuarioId,
    required this.cmp,
    required this.especialidadId,
    required this.sedeIds,
    this.fotoUrl,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? '',
      usuarioId: (json['usuarioId'] ?? '').toString(), // <-- fuerza a String y nunca null
      cmp: json['cmp'] ?? '',
      especialidadId: json['especialidadId'] ?? '',
      sedeIds: List<String>.from(json['sedeIds'] ?? []),
      fotoUrl: json['fotoUrl'],
    );
  }
}