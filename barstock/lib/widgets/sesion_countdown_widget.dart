import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/sesion_cliente_controller.dart';
import '../theme/app_theme.dart';

/// Chip pequeño que muestra el tiempo restante de la sesión. Cambia a rojo
/// en el último minuto para avisar al cliente.
class SesionCountdownChip extends StatelessWidget {
  final SesionClienteController sesion;
  const SesionCountdownChip({super.key, required this.sesion});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sesion,
      builder: (context, _) {
        final urgente = sesion.tiempoRestante.inSeconds <= 60;
        final color = urgente ? AppColors.danger : AppColors.gold;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                sesion.tiempoRestanteTexto,
                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Envuelve cualquier pantalla del flujo de cliente. Escucha el temporizador
/// de la sesión y, cuando se agota, bloquea la pantalla con un aviso y
/// cierra la app (o intenta hacerlo — en iOS el sistema no siempre lo
/// permite, así que además se deja un botón para salir manualmente).
class SesionExpiradaGuard extends StatefulWidget {
  final SesionClienteController sesion;
  final Widget child;

  const SesionExpiradaGuard({super.key, required this.sesion, required this.child});

  @override
  State<SesionExpiradaGuard> createState() => _SesionExpiradaGuardState();
}

class _SesionExpiradaGuardState extends State<SesionExpiradaGuard> {
  late bool _cerrando = widget.sesion.expirada;

  @override
  void initState() {
    super.initState();
    widget.sesion.addListener(_onCambioSesion);
  }

  @override
  void dispose() {
    widget.sesion.removeListener(_onCambioSesion);
    super.dispose();
  }

  void _onCambioSesion() {
    if (widget.sesion.expirada && !_cerrando) {
      setState(() => _cerrando = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_cerrando)
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.void_.withValues(alpha: 0.96),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hourglass_bottom_rounded, color: AppColors.gold, size: 56),
                      const SizedBox(height: 18),
                      Text(
                        'Tu sesión terminó',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pasaron los 15 minutos para hacer tu pedido.\nEscanea el código QR de la mesa para empezar de nuevo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.inkMuted),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => SystemNavigator.pop(),
                        child: const Text('Salir'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
