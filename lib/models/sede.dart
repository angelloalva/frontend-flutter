class Sede {
  final String id;
  final String nombre;
  final String direccion;
  
  Sede({required this.id, required this.nombre, required this.direccion});
  
  factory Sede.fromJson(Map<String, dynamic> json) {
    return Sede(
      id: json['id'],
      nombre: json['nombre'],
      direccion: json['direccion'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
    };
  }
}