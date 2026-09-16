import 'producto.dart';

/// Representa un producto agregado al carrito del cliente, con la
/// cantidad elegida. Vive solo en memoria hasta que se confirma el pedido.
class ItemCarrito {
  final Producto producto;
  int cantidad;

  ItemCarrito({required this.producto, this.cantidad = 1});

  double get subtotal => producto.precio * cantidad;

  Map<String, dynamic> toJson() => {
        'idProducto': producto.id,
        'cantidad': cantidad,
      };
}
