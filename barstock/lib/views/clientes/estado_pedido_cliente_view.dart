import 'dart:async';
import 'package:flutter/material.dart';
import '../../controllers/sesion_cliente_controller.dart';
import '../../models/pedido.dart';
import '../../services/pedido_cliente_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/global_theme.dart';
import '../../widgets/sesion_countdown_widget.dart';
import 'productos_cliente_view.dart';

/// Pantalla de seguimiento: consulta el estado del pedido cada 5 segundos
/// para dar sensación de "tiempo real" sin necesitar websockets en el
/// backend. Si el cliente aún tiene tiempo de sesión, puede volver al
/// catálogo para agregar otro pedido.
class EstadoPedidoClienteView extends StatefulWidget {
  final SesionClienteController sesion;
  final int idPedido;
  const EstadoPedidoClienteView({super.key, required this.sesion, required this.idPedido});

  @override
  State<EstadoPedidoClienteView> createState() => _EstadoPedidoClienteViewState();
}

class _EstadoPedidoClienteViewState extends State<EstadoPedidoClienteView> {
  static const _intervaloConsulta = Duration(seconds: 5);

  PedidoDetalle? _detalle;
  bool _cargando = true;
  String? _error;
  Timer? _poller;

  @override
  void initState() {
    super.initState();
    _consultar();
    _poller = Timer.periodic(_intervaloConsulta, (_) => _consultar(mostrarCarga: false));
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }

  Future<void> _consultar({bool mostrarCarga = true}) async {
    if (mostrarCarga) setState(() => _cargando = true);
    try {
      final d = await PedidoClienteService.consultarEstado(widget.idPedido);
      if (!mounted) return;
      setState(() {
        _detalle = d;
        _error = null;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = mostrarCarga ? e.toString() : _error;
        _cargando = false;
      });
    }
  }

  // Orden de progreso para dibujar la línea de tiempo. Ajusta estos textos
  // a los estados reales que use tu backend si son distintos.
  static const _pasos = ['pendiente', 'preparando', 'listo', 'entregado'];

  int _pasoActual(String estado) {
    final i = _pasos.indexOf(estado.toLowerCase());
    return i == -1 ? 0 : i;
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado':
      case 'entregado':
        return AppColors.success;
      case 'cancelado':
        return AppColors.danger;
      default:
        return AppColors.goldSoft;
    }
  }

  void _hacerOtroPedido() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ProductosClienteView(sesion: widget.sesion)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SesionExpiradaGuard(
      sesion: widget.sesion,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pedido #${widget.idPedido}'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(child: SesionCountdownChip(sesion: widget.sesion)),
            ),
          ],
        ),
        body: (_cargando && _detalle == null) || (_error != null && _detalle == null)
            ? EstadoCarga(
                cargando: _cargando && _detalle == null,
                error: _detalle == null ? _error : null,
                vacio: false,
                onReintentar: () => _consultar(),
              )
            : _contenido(),
      ),
    );
  }

  Widget _contenido() {
    final detalle = _detalle!;
    final estado = detalle.pedido.estado;
    final color = _colorEstado(estado);
    final cancelado = estado.toLowerCase() == 'cancelado';

    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: () => _consultar(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  GoldBadge(
                    icono: cancelado ? Icons.cancel_outlined : Icons.local_bar_rounded,
                    size: 56,
                    color: color,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Mesa ${detalle.pedido.mesa} · ${detalle.pedido.fecha}',
                    style: const TextStyle(color: AppColors.inkMuted, fontSize: 12.5),
                  ),
                  const SizedBox(height: 6),
                  EstadoChip(texto: estado, color: color),
                  const SizedBox(height: 18),
                  if (!cancelado) _lineaDeTiempo(estado),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SectionLabel('Tu pedido'),
          const SizedBox(height: 10),
          ...detalle.detalles.map((d) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(d.nombreProducto),
                  subtitle: Text('${d.cantidad} x \$${d.precioUnitario.toStringAsFixed(2)}'),
                  trailing: Text('\$${d.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                ),
              )),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('\$${detalle.pedido.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, color: AppColors.gold, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: widget.sesion,
            builder: (context, _) {
              if (widget.sesion.expirada) return const SizedBox.shrink();
              return OutlinedButton.icon(
                onPressed: _hacerOtroPedido,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Hacer otro pedido'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _lineaDeTiempo(String estado) {
    final actual = _pasoActual(estado);
    const etiquetas = ['Recibido', 'Preparando', 'Listo', 'Entregado'];
    return Row(
      children: List.generate(etiquetas.length, (i) {
        final activo = i <= actual;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (i > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: activo ? AppColors.gold : AppColors.panelLine,
                      ),
                    ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activo ? AppColors.gold : AppColors.panelLine,
                    ),
                  ),
                  if (i < etiquetas.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i < actual ? AppColors.gold : AppColors.panelLine,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                etiquetas[i],
                style: TextStyle(
                  fontSize: 10.5,
                  color: activo ? AppColors.goldSoft : AppColors.inkMuted,
                  fontWeight: activo ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
