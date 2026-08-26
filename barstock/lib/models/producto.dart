class Producto {
  final int id;
  final String nombre;
  final double precio;
  final String fechaVencimiento;
  final int idCategoria;
  final String nomCategoria;
  final int stock;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.fechaVencimiento,
    required this.idCategoria,
    required this.nomCategoria,
    required this.stock,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      precio: (json['precio'] ?? 0).toDouble(),
      fechaVencimiento: json['fecha_vencimiento'] ?? '',
      idCategoria: json['idCategoria'] ?? 0,
      nomCategoria: json['nomCategoria'] ?? '',
      stock: json['stock'] ?? 0,
    );
  }
}
