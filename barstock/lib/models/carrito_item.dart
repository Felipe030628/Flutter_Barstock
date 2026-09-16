import 'producto.dart';

/// Representa un producto agregado al carrito del cliente, junto con
/// la cantidad seleccionada. Vive solo en memoria (no requiere login
/// ni persistencia local) mientras el cliente arma su pedido.
class CarritoItem {
  final Producto producto;
  int cantidad;

  CarritoItem({required this.producto, this.cantidad = 1});

  double get subtotal => producto.precio * cantidad;
}
