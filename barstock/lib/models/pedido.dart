class Pedido {
  final int idPedido;
  final String cliente;
  final String mesa;
  final String fecha;
  final String estado;
  final double total;

  Pedido({
    required this.idPedido,
    required this.cliente,
    required this.mesa,
    required this.fecha,
    required this.estado,
    required this.total,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      idPedido: json['idPedido'] ?? 0,
      cliente: json['cliente'] ?? '',
      mesa: json['mesa'] ?? '',
      fecha: json['fecha'] ?? '',
      estado: json['estado'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}

class DetallePedidoItem {
  final int idProducto;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  DetallePedidoItem({
    required this.idProducto,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory DetallePedidoItem.fromJson(Map<String, dynamic> json) {
    return DetallePedidoItem(
      idProducto: json['idProducto'] ?? 0,
      nombreProducto: json['nombreProducto'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      precioUnitario: (json['precioUnitario'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }
}

class PedidoDetalle {
  final Pedido pedido;
  final List<DetallePedidoItem> detalles;

  PedidoDetalle({required this.pedido, required this.detalles});

  factory PedidoDetalle.fromJson(Map<String, dynamic> json) {
    return PedidoDetalle(
      pedido: Pedido.fromJson(json),
      detalles: (json['detalles'] as List<dynamic>? ?? [])
          .map((e) => DetallePedidoItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
