class TopProducto {
  final String nombre;
  final int cantidad;
  final double monto;

  TopProducto({required this.nombre, required this.cantidad, required this.monto});

  factory TopProducto.fromJson(Map<String, dynamic> json) {
    return TopProducto(
      nombre: json['nombre'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      monto: (json['monto'] ?? 0).toDouble(),
    );
  }
}

class Dashboard {
  final double caja;
  final int critico;
  final int variedad;
  final List<String> ventasLabels;
  final List<double> ventasData;
  final List<String> categoriasLabels;
  final List<double> categoriasData;
  final List<TopProducto> topProductos;

  Dashboard({
    required this.caja,
    required this.critico,
    required this.variedad,
    required this.ventasLabels,
    required this.ventasData,
    required this.categoriasLabels,
    required this.categoriasData,
    required this.topProductos,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    final ventas = json['ventasSemana'] ?? {};
    final categorias = json['categorias'] ?? {};
    return Dashboard(
      caja: (json['caja'] ?? 0).toDouble(),
      critico: json['critico'] ?? 0,
      variedad: json['variedad'] ?? 0,
      ventasLabels: List<String>.from(ventas['labels'] ?? []),
      ventasData: (ventas['data'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
      categoriasLabels: List<String>.from(categorias['labels'] ?? []),
      categoriasData: (categorias['data'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
      topProductos: (json['topProductos'] as List<dynamic>? ?? [])
          .map((e) => TopProducto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
