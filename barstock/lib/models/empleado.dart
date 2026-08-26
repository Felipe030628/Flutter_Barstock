class Empleado {
  final int idUsuarios;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final String direccion;
  final int activo;

  Empleado({
    required this.idUsuarios,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.direccion,
    required this.activo,
  });

  bool get estaActivo => activo == 1;
  String get nombreCompleto => '$nombre $apellido'.trim();

  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      idUsuarios: json['idUsuarios'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      correo: json['correo'] ?? '',
      telefono: json['telefono'] ?? '',
      direccion: json['direccion'] ?? '',
      activo: json['activo'] ?? 0,
    );
  }
}
