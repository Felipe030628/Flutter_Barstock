import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/carrito_item.dart';
import '../models/pedido.dart';
import 'api_service.dart';

class PedidoClienteException implements Exception {
  final String mensaje;
  PedidoClienteException(this.mensaje);
  @override
  String toString() => mensaje;
}

/// Llamadas al backend relacionadas con el pedido que hace el cliente
/// desde su celular (sin iniciar sesión de empleado).
///
/// IMPORTANTE — endpoint pendiente en el backend:
/// `listarPedidos`, `detallePedido` y `eliminarPedido` ya existen en
/// [ApiService] y se reutilizan aquí tal cual. Pero crear un pedido nuevo
/// NO existe todavía en el controlador `/Pedido` de tu backend (.NET), así
/// que hay que agregar una acción `crearJson` que reciba este contrato:
///
/// POST {baseUrl}/Pedido?accion=crearJson
/// Body (JSON):
/// {
///   "mesa": "5",
///   "cliente": "Juan Pérez",
///   "correo": "juan@correo.com",
///   "items": [
///     { "idProducto": 3, "cantidad": 2 },
///     { "idProducto": 7, "cantidad": 1 }
///   ]
/// }
///
/// Respuesta esperada:
/// { "success": true,  "idPedido": 123 }
/// { "success": false, "error": "mensaje para mostrar al cliente" }
///
/// El backend debe validar el stock de cada producto y calcular el total
/// (no confíes en un total que venga del celular).
class PedidoClienteService {
  static Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);
  }

  /// Crea el pedido en el backend y devuelve el id asignado.
  static Future<int> crearPedido({
    required String mesa,
    required String nombreCliente,
    required String correo,
    required List<CarritoItem> items,
  }) async {
    if (items.isEmpty) {
      throw PedidoClienteException('El carrito está vacío');
    }
    try {
      final res = await http
          .post(
            _uri('/Pedido', {'accion': 'crearJson'}),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'mesa': mesa,
              'cliente': nombreCliente,
              'correo': correo,
              'items': items
                  .map((i) => {'idProducto': i.producto.id, 'cantidad': i.cantidad})
                  .toList(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        throw PedidoClienteException('Error del servidor (${res.statusCode})');
      }
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (data is Map && data['success'] == true && data['idPedido'] != null) {
        return data['idPedido'] is int ? data['idPedido'] : int.parse('${data['idPedido']}');
      }
      throw PedidoClienteException(
        data is Map ? (data['error']?.toString() ?? 'No se pudo crear el pedido') : 'No se pudo crear el pedido',
      );
    } on PedidoClienteException {
      rethrow;
    } catch (e) {
      throw PedidoClienteException('No se pudo conectar con el servidor: $e');
    }
  }

  /// Consulta el estado actual del pedido. Reutiliza `/Pedido?accion=detalleJson`,
  /// que ya existe en el backend, así que no requiere ningún cambio adicional.
  static Future<PedidoDetalle> consultarEstado(int idPedido) {
    return ApiService.detallePedido(idPedido);
  }
}
