import 'package:flutter/foundation.dart';
import '../models/carrito_item.dart';
import '../models/producto.dart';

/// Carrito de compras en memoria del cliente actual. Vive mientras dura
/// la sesión (se descarta al confirmar el pedido o al expirar la sesión).
class CarritoController extends ChangeNotifier {
  final Map<int, CarritoItem> _items = {}; // idProducto -> item

  List<CarritoItem> get items => _items.values.toList();

  int get totalUnidades => _items.values.fold(0, (s, i) => s + i.cantidad);

  double get total => _items.values.fold(0.0, (s, i) => s + i.subtotal);

  bool get estaVacio => _items.isEmpty;

  int cantidadDe(Producto p) => _items[p.id]?.cantidad ?? 0;

  void agregar(Producto producto) {
    final actual = _items[producto.id];
    if (actual != null) {
      actual.cantidad += 1;
    } else {
      _items[producto.id] = CarritoItem(producto: producto, cantidad: 1);
    }
    notifyListeners();
  }

  void quitar(Producto producto) {
    final actual = _items[producto.id];
    if (actual == null) return;
    if (actual.cantidad <= 1) {
      _items.remove(producto.id);
    } else {
      actual.cantidad -= 1;
    }
    notifyListeners();
  }

  void eliminar(Producto producto) {
    _items.remove(producto.id);
    notifyListeners();
  }

  void vaciar() {
    _items.clear();
    notifyListeners();
  }
}
