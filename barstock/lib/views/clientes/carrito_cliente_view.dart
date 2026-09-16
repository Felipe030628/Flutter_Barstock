import 'package:flutter/material.dart';
import '../../controllers/carrito_controller.dart';
import '../../controllers/sesion_cliente_controller.dart';
import '../../services/pedido_cliente_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/global_theme.dart';
import '../../widgets/sesion_countdown_widget.dart';
import 'estado_pedido_cliente_view.dart';

/// Revisión final del carrito antes de enviar el pedido al backend.
class CarritoClienteView extends StatefulWidget {
  final SesionClienteController sesion;
  final CarritoController carrito;
  const CarritoClienteView({super.key, required this.sesion, required this.carrito});

  @override
  State<CarritoClienteView> createState() => _CarritoClienteViewState();
}

class _CarritoClienteViewState extends State<CarritoClienteView> {
  bool _enviando = false;

  Future<void> _confirmarPedido() async {
    if (widget.sesion.expirada) return;
    setState(() => _enviando = true);
    try {
      final idPedido = await PedidoClienteService.crearPedido(
        mesa: widget.sesion.mesa,
        nombreCliente: widget.sesion.nombre,
        correo: widget.sesion.correo,
        items: widget.carrito.items,
      );
      widget.sesion.idPedidoActual = idPedido;
      widget.carrito.vaciar();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EstadoPedidoClienteView(sesion: widget.sesion, idPedido: idPedido),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SesionExpiradaGuard(
      sesion: widget.sesion,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tu pedido'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(child: SesionCountdownChip(sesion: widget.sesion)),
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: widget.carrito,
          builder: (context, _) {
            final items = widget.carrito.items;
            if (items.isEmpty) {
              return const EstadoCarga(
                cargando: false,
                error: null,
                vacio: true,
                onReintentar: _sinAccion,
                mensajeVacio: 'Tu carrito está vacío.\nAgrega productos desde el catálogo.',
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          title: Text(item.producto.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '${item.cantidad} x \$${item.producto.precio.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppColors.inkMuted),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('\$${item.subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: AppColors.danger, size: 20),
                                onPressed: () => widget.carrito.eliminar(item.producto),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('\$${widget.carrito.total.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 20, color: AppColors.gold, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        FilledButton(
                          onPressed: _enviando ? null : _confirmarPedido,
                          child: _enviando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.void_),
                                )
                              : const Text('Confirmar pedido'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

void _sinAccion() {}
