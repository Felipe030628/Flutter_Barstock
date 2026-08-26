import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/usuario.dart';

/// Excepción de autenticación (credenciales inválidas, cuenta inactiva, etc.).
class AuthException implements Exception {
  final String mensaje;
  AuthException(this.mensaje);
  @override
  String toString() => mensaje;
}

/// Login contra `/UsuariosCont` (accion=loginJson). El registro de usuarios
/// se hace desde la web administrativa, no desde la app.
class AuthService {
  static Uri _uri(String path, Map<String, String> query) {
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);
  }

  /// Inicia sesión con correo y contraseña.
  /// Espera del backend: {"success": true, "usuario": {...}}
  /// o {"success": false, "error": "mensaje"}.
  static Future<Usuario> login({required String correo, required String contrasena}) async {
    try {
      final uri = _uri('/UsuariosCont', {
        'accion': 'loginJson',
        'correo': correo,
        'contrasena': contrasena,
      });
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        throw AuthException('Error del servidor (${res.statusCode})');
      }
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (data is! Map) {
        throw AuthException('Respuesta inesperada del servidor');
      }
      if (data['success'] == true && data['usuario'] != null) {
        return Usuario.fromJson(data['usuario']);
      }
      throw AuthException(data['error']?.toString() ?? 'Correo o contraseña incorrectos');
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('No se pudo conectar con el servidor: $e');
    }
  }
}
