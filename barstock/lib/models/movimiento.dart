class Movimiento {
  final int idMovimiento;
  final String fecha;
  final int cantidad;
  final String motivo;
  final int idProducto;
  final String nombreProducto;

  Movimiento({
    required this.idMovimiento,
    required this.fecha,
    required this.cantidad,
    required this.motivo,
    required this.idProducto,
    required this.nombreProducto,
  });

  bool get esEntrada => motivo.toLowerCase().startsWith('entrada');

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      idMovimiento: json['idMovimiento'] ?? 0,
      fecha: json['fecha'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      motivo: json['motivo'] ?? '',
      idProducto: json['idProducto'] ?? 0,
      nombreProducto: json['nombreProducto'] ?? '',
    );
  }
}
