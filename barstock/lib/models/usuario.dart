/// Usuario autenticado en la app (respuesta de login/registro del backend).
class Usuario {
  final int idUsuarios;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final String direccion;

  Usuario({
    required this.idUsuarios,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.direccion,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuarios: json['idUsuarios'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      correo: json['correo'] ?? '',
      telefono: json['telefono'] ?? '',
      direccion: json['direccion'] ?? '',
    );
  }
}
