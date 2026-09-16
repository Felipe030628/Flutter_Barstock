import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/producto.dart';
import '../models/mesa.dart';
import '../models/movimiento.dart';
import '../models/pedido.dart';
import '../models/empleado.dart';
import '../models/dashboard.dart';
import '../models/item_carrito.dart';

/// Excepción genérica para errores de red / backend.
class ApiException implements Exception {
  final String mensaje;
  ApiException(this.mensaje);
  @override
  String toString() => mensaje;
}

/// Todas las llamadas al backend Barstock.
class ApiService {
  static Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);
  }

  static Future<dynamic> _getJson(Uri uri) async {
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        throw ApiException('Error del servidor (${res.statusCode})');
      }
      return jsonDecode(utf8.decode(res.bodyBytes));
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('No se pudo conectar con el servidor: $e');
    }
  }

  static Future<bool> _eliminar(Uri uri) async {
    final data = await _getJson(uri);
    if (data is Map && data['success'] == true) return true;
    throw ApiException(data is Map ? (data['error'] ?? 'No se pudo eliminar') : 'No se pudo eliminar');
  }

  // ---------------- Productos ----------------
  static Future<List<Producto>> listarProductos() async {
    final data = await _getJson(_uri('/Producto', {'accion': 'listarJson'}));
    return (data as List).map((e) => Producto.fromJson(e)).toList();
  }

  static Future<bool> eliminarProducto(int id) {
    return _eliminar(_uri('/Producto', {'accion': 'eliminarJson', 'id': '$id'}));
  }

  // ---------------- Movimientos de stock ----------------
  static Future<List<Movimiento>> listarMovimientos() async {
    final data = await _getJson(_uri('/Movimiento', {'accion': 'listarJson'}));
    return (data as List).map((e) => Movimiento.fromJson(e)).toList();
  }

  static Future<bool> eliminarMovimiento(int id) {
    return _eliminar(_uri('/Movimiento', {'accion': 'eliminarJson', 'id': '$id'}));
  }

  // ---------------- Mesas ----------------
  static Future<List<Mesa>> listarMesas() async {
    final data = await _getJson(_uri('/Mesas', {'accion': 'listarJson'}));
    return (data as List).map((e) => Mesa.fromJson(e)).toList();
  }

  static Future<bool> eliminarMesa(int id) {
    return _eliminar(_uri('/Mesas', {'accion': 'eliminarJson', 'id': '$id'}));
  }

  /// Busca una mesa por id reutilizando el listado (no requiere endpoint
  /// nuevo en el backend). Se usa en el flujo de escaneo de QR del cliente.
  static Future<Mesa> obtenerMesa(int idMesa) async {
    final mesas = await listarMesas();
    return mesas.firstWhere(
      (m) => m.idMesa == idMesa,
      orElse: () => throw ApiException('Mesa no encontrada'),
    );
  }

  // ---------------- Pedidos ----------------
  static Future<List<Pedido>> listarPedidos() async {
    final data = await _getJson(_uri('/Pedido', {'accion': 'listarJson'}));
    return (data as List).map((e) => Pedido.fromJson(e)).toList();
  }

  static Future<PedidoDetalle> detallePedido(int id) async {
    final data = await _getJson(_uri('/Pedido', {'accion': 'detalleJson', 'id': '$id'}));
    return PedidoDetalle.fromJson(data);
  }

  static Future<bool> eliminarPedido(int id) {
    return _eliminar(_uri('/Pedido', {'accion': 'eliminarJson', 'id': '$id'}));
  }

  /// Crea un pedido nuevo desde la app de cliente.
  ///
  /// IMPORTANTE: esto requiere que el backend tenga una acción `crearJson`
  /// en el controlador `/Pedido` (hoy solo existen `listarJson`,
  /// `detalleJson` y `eliminarJson`). Contrato esperado:
  ///
  /// POST {baseUrl}/Pedido?accion=crearJson
  /// Body (JSON):
  /// {
  ///   "idMesa": 5,
  ///   "cliente": "Juan Pérez",
  ///   "items": [ { "idProducto": 3, "cantidad": 2 }, ... ]
  /// }
  ///
  /// Respuesta esperada:
  /// { "success": true,  "idPedido": 123 }
  /// { "success": false, "error": "mensaje para mostrar al cliente" }
  ///
  /// El backend debe validar el stock de cada producto y calcular el total;
  /// no confíes en un total calculado en el celular.
  static Future<int> crearPedido({
    required int idMesa,
    required String cliente,
    required List<ItemCarrito> items,
  }) async {
    if (items.isEmpty) {
      throw ApiException('El carrito está vacío');
    }
    try {
      final res = await http
          .post(
            _uri('/Pedido', {'accion': 'crearJson'}),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'idMesa': idMesa,
              'cliente': cliente,
              'items': items
                  .map((i) => {'idProducto': i.producto.id, 'cantidad': i.cantidad})
                  .toList(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        throw ApiException('Error del servidor (${res.statusCode})');
      }
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (data is Map && data['success'] == true && data['idPedido'] != null) {
        return data['idPedido'] is int ? data['idPedido'] : int.parse('${data['idPedido']}');
      }
      throw ApiException(
        data is Map ? (data['error']?.toString() ?? 'No se pudo crear el pedido') : 'No se pudo crear el pedido',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('No se pudo conectar con el servidor: $e');
    }
  }

  // ---------------- Empleados ----------------
  static Future<List<Empleado>> listarEmpleados() async {
    final data = await _getJson(_uri('/UsuariosCont', {'accion': 'listarJson'}));
    return (data as List).map((e) => Empleado.fromJson(e)).toList();
  }

  static Future<bool> eliminarEmpleado(int id) {
    return _eliminar(_uri('/UsuariosCont', {'accion': 'eliminarJson', 'id': '$id'}));
  }

  // ---------------- Dashboard / Panel ----------------
  static Future<Dashboard> obtenerDashboard() async {
    final data = await _getJson(_uri('/DashboardData'));
    return Dashboard.fromJson(data);
  }
}