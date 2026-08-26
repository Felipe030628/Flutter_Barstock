import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/producto.dart';
import '../models/mesa.dart';
import '../models/movimiento.dart';
import '../models/pedido.dart';
import '../models/empleado.dart';
import '../models/dashboard.dart';

/// Excepción genérica para errores de red / backend.
class ApiException implements Exception {
  final String mensaje;
  ApiException(this.mensaje);
  @override
  String toString() => mensaje;
}

/// Todas las llamadas al backend Barstock (solo consulta: listar + eliminar).
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
