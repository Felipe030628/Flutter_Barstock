class Mesa {
  final int idMesa;
  final String numeroMesa;
  final String estado;
  final int capacidad;

  Mesa({
    required this.idMesa,
    required this.numeroMesa,
    required this.estado,
    required this.capacidad,
  });

  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      idMesa: json['idMesa'] ?? 0,
      numeroMesa: json['numero_mesa'] ?? '',
      estado: json['estado'] ?? '',
      capacidad: json['capacidad'] ?? 0,
    );
  }
}
