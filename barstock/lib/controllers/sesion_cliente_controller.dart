import 'dart:async';
import 'package:flutter/foundation.dart';

/// Duración total de la sesión de un cliente para hacer pedidos.
const Duration duracionSesionCliente = Duration(minutes: 15);

/// Maneja los datos de la sesión del cliente (nombre, correo, mesa) y el
/// temporizador de 15 minutos. Cuando el tiempo se agota, notifica a quien
/// esté escuchando (la UI decide qué hacer: mostrar aviso y cerrar la app).
///
/// Se crea una sola instancia justo cuando el cliente completa el formulario
/// de bienvenida (nombre + correo) y se le hace `dispose()` cuando la sesión
/// termina, ya sea por expiración o porque el cliente cierra el flujo.
class SesionClienteController extends ChangeNotifier {
  final String nombre;
  final String correo;
  final String mesa;

  /// Id del pedido en curso (si el cliente ya hizo uno), útil para poder
  /// volver a ver su estado sin perderlo al navegar por el catálogo.
  int? idPedidoActual;

  Timer? _timer;
  Duration _restante = duracionSesionCliente;
  bool _expirada = false;

  SesionClienteController({
    required this.nombre,
    required this.correo,
    required this.mesa,
  }) {
    _iniciarConteo();
  }

  Duration get tiempoRestante => _restante;
  bool get expirada => _expirada;

  /// Texto tipo "14:32" para mostrar en pantalla.
  String get tiempoRestanteTexto {
    final m = _restante.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _restante.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _iniciarConteo() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_restante.inSeconds <= 1) {
        _restante = Duration.zero;
        _expirada = true;
        _timer?.cancel();
        notifyListeners();
        return;
      }
      _restante -= const Duration(seconds: 1);
      notifyListeners();
    });
  }

  /// Extiende la sesión (por ejemplo, si el cliente quiere hacer un pedido
  /// adicional y aún no ha expirado). No se usa automáticamente: solo se
  /// llama explícitamente desde la UI si en el futuro se quiere dar más
  /// tiempo tras confirmar un pedido.
  void reiniciarConteo() {
    if (_expirada) return;
    _restante = duracionSesionCliente;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
