import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/producto.dart';
import '../models/categoria.dart';
import '../models/mesa.dart';
import '../models/movimiento.dart';
import '../models/pedido.dart';
import '../models/empleado.dart';
import '../models/dashboard.dart';
import '../models/item_carrito.dart';

class ApiException implements Exception {
  final String mensaje;
  ApiException(this.mensaje);

  @override
  String toString() => mensaje;
}

class ApiService {
  static Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('${ApiConfig.baseUrl}$path')
        .replace(queryParameters: query);
  }

  static Future<dynamic> _getJson(Uri uri) async {
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        throw ApiException('Error del servidor (${res.statusCode})');
      }

      final texto = utf8.decode(res.bodyBytes);
      if (texto.trim().isEmpty) {
        throw ApiException('El servidor devolvió una respuesta vacía.');
      }

      return jsonDecode(texto);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('No se pudo conectar con el servidor: $e');
    }
  }

  static Future<Map<String, dynamic>> _postJson(
    Uri uri,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      final texto = utf8.decode(res.bodyBytes);

      if (res.statusCode != 200) {
        throw ApiException(
          'Error del servidor (${res.statusCode}): '
          '${texto.isEmpty ? 'sin detalle' : texto}',
        );
      }

      if (texto.trim().isEmpty) {
        throw ApiException('El servidor devolvió una respuesta vacía.');
      }

      final data = jsonDecode(texto);

      if (data is! Map<String, dynamic>) {
        throw ApiException('Respuesta inválida del servidor.');
      }

      return data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('No se pudo conectar con el servidor: $e');
    }
  }

  static Future<bool> _eliminar(Uri uri) async {
    final data = await _getJson(uri);

    if (data is Map && data['success'] == true) {
      return true;
    }

    throw ApiException(
      data is Map
          ? '${data['error'] ?? 'No se pudo eliminar'}'
          : 'No se pudo eliminar',
    );
  }

  // ---------------- Productos ----------------

  static Future<List<Producto>> listarProductos() async {
    final data = await _getJson(
      _uri('/Producto', {'accion': 'listarJson'}),
    );

    if (data is! List) {
      throw ApiException('El servidor no devolvió una lista de productos.');
    }

    return data
        .map((e) => Producto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<List<Categoria>> listarCategorias() async {
    final data = await _getJson(
      _uri('/Producto', {'accion': 'categoriasJson'}),
    );

    if (data is! List) {
      throw ApiException('El servidor no devolvió las categorías.');
    }

    return data
        .map((e) => Categoria.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<int> registrarProducto({
    required String nombre,
    required double precio,
    required String fechaVencimiento,
    required int idCategoria,
    required int stockInicial,
  }) async {
    if (nombre.trim().isEmpty) {
      throw ApiException('Escribe el nombre del producto.');
    }

    if (precio <= 0) {
      throw ApiException('El precio debe ser mayor que cero.');
    }

    if (idCategoria <= 0) {
      throw ApiException('Selecciona una categoría.');
    }

    if (stockInicial < 0) {
      throw ApiException('El stock no puede ser negativo.');
    }

    final data = await _postJson(
      _uri('/Producto', {'accion': 'registrarJson'}),
      {
        'nombre': nombre.trim(),
        'precio': precio,
        'fecha_vencimiento':
            fechaVencimiento.trim().isEmpty ? null : fechaVencimiento.trim(),
        'idCategoria': idCategoria,
        'stock': stockInicial,
      },
    );

    if (data['success'] != true || data['idProducto'] == null) {
      throw ApiException(
        '${data['error'] ?? 'No se pudo registrar el producto.'}',
      );
    }

    return int.tryParse('${data['idProducto']}') ?? 0;
  }

  static Future<bool> eliminarProducto(int id) {
    return _eliminar(
      _uri('/Producto', {'accion': 'eliminarJson', 'id': '$id'}),
    );
  }

  // ---------------- Movimientos ----------------

  static Future<List<Movimiento>> listarMovimientos() async {
    final data = await _getJson(
      _uri('/Movimiento', {'accion': 'listarJson'}),
    );

    return (data as List)
        .map((e) => Movimiento.fromJson(e))
        .toList();
  }

  static Future<bool> eliminarMovimiento(int id) {
    return _eliminar(
      _uri('/Movimiento', {'accion': 'eliminarJson', 'id': '$id'}),
    );
  }

  // ---------------- Mesas ----------------

  static Future<List<Mesa>> listarMesas() async {
    final data = await _getJson(
      _uri('/Mesas', {'accion': 'listarJson'}),
    );

    return (data as List).map((e) => Mesa.fromJson(e)).toList();
  }

  static Future<bool> eliminarMesa(int id) {
    return _eliminar(
      _uri('/Mesas', {'accion': 'eliminarJson', 'id': '$id'}),
    );
  }

  static Future<Mesa> obtenerMesa(int idMesa) async {
    final mesas = await listarMesas();

    return mesas.firstWhere(
      (m) => m.idMesa == idMesa,
      orElse: () => throw ApiException('Mesa no encontrada'),
    );
  }

  // ---------------- Pedidos ----------------

  static Future<List<Pedido>> listarPedidos() async {
    final data = await _getJson(
      _uri('/Pedido', {'accion': 'listarJson'}),
    );

    return (data as List).map((e) => Pedido.fromJson(e)).toList();
  }

  static Future<PedidoDetalle> detallePedido(int id) async {
    final data = await _getJson(
      _uri('/Pedido', {'accion': 'detalleJson', 'id': '$id'}),
    );

    if (data is Map && data['error'] != null) {
      throw ApiException('${data['error']}');
    }

    return PedidoDetalle.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  static Future<bool> eliminarPedido(int id) {
    return _eliminar(
      _uri('/Pedido', {'accion': 'eliminarJson', 'id': '$id'}),
    );
  }

  static Future<int> crearPedido({
    required int idMesa,
    required String cliente,
    required List<ItemCarrito> items,
  }) async {
    if (items.isEmpty) {
      throw ApiException('El carrito está vacío');
    }

    final data = await _postJson(
      _uri('/Pedido', {'accion': 'crearJson'}),
      {
        'idMesa': idMesa,
        'cliente': cliente,
        'items': items
            .map(
              (i) => {
                'idProducto': i.producto.id,
                'cantidad': i.cantidad,
              },
            )
            .toList(),
      },
    );

    if (data['success'] == true && data['idPedido'] != null) {
      return int.tryParse('${data['idPedido']}') ?? 0;
    }

    throw ApiException(
      '${data['error'] ?? 'No se pudo crear el pedido'}',
    );
  }

  // ---------------- Empleados ----------------

  static Future<List<Empleado>> listarEmpleados() async {
    final data = await _getJson(
      _uri('/UsuariosCont', {'accion': 'listarJson'}),
    );

    return (data as List).map((e) => Empleado.fromJson(e)).toList();
  }

  static Future<bool> eliminarEmpleado(int id) {
    return _eliminar(
      _uri('/UsuariosCont', {'accion': 'eliminarJson', 'id': '$id'}),
    );
  }

  // ---------------- Dashboard ----------------

  static Future<Dashboard> obtenerDashboard() async {
    final data = await _getJson(_uri('/DashboardData'));
    return Dashboard.fromJson(data);
  }
}
