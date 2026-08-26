import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/global_theme.dart';

class PedidosView extends StatefulWidget {
  const PedidosView({super.key});

  @override
  State<PedidosView> createState() => _PedidosViewState();
}

class _PedidosViewState extends State<PedidosView> {
  List<Pedido> _todos = [];
  List<Pedido> _filtrados = [];
  bool _cargando = true;
  String? _error;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final lista = await ApiService.listarPedidos();
      setState(() {
        _todos = lista;
        _aplicarFiltro();
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  void _aplicarFiltro() {
    final q = _busqueda.toLowerCase();
    _filtrados = _todos
        .where((p) => p.cliente.toLowerCase().contains(q) || p.mesa.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _eliminar(Pedido p) async {
    final ok = await confirmarEliminar(context, 'Pedido #${p.idPedido} (${p.cliente})');
    if (!ok) return;
    try {
      await ApiService.eliminarPedido(p.idPedido);
      if (!mounted) return;
      setState(() {
        _todos.removeWhere((x) => x.idPedido == p.idPedido);
        _aplicarFiltro();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido eliminado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
    }
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado':
        return AppColors.success;
      case 'cancelado':
        return AppColors.danger;
      default:
        return AppColors.goldSoft;
    }
  }

  void _verDetalle(Pedido p) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _DetallePedidoPage(pedido: p)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: _cargar,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: BuscadorField(
                hint: 'Buscar por cliente o mesa...',
                onChanged: (v) => setState(() {
                  _busqueda = v;
                  _aplicarFiltro();
                }),
              ),
            ),
            Expanded(
              child: (_cargando || _error != null || _filtrados.isEmpty)
                  ? EstadoCarga(
                      cargando: _cargando,
                      error: _error,
                      vacio: _filtrados.isEmpty,
                      onReintentar: _cargar,
                      mensajeVacio: 'No hay pedidos registrados.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filtrados.length,
                      itemBuilder: (context, i) {
                        final p = _filtrados[i];
                        final color = _colorEstado(p.estado);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            onTap: () => _verDetalle(p),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: GoldBadge(texto: '#${p.idPedido}', size: 44),
                            title: Text(p.cliente.isEmpty ? 'Sin cliente' : p.cliente,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('Mesa ${p.mesa} · ${p.fecha}',
                                  style: const TextStyle(color: AppColors.inkMuted, fontSize: 12)),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('\$${p.total.toStringAsFixed(2)}',
                                        style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                                    EstadoChip(texto: p.estado, color: color),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                                  onPressed: () => _eliminar(p),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetallePedidoPage extends StatefulWidget {
  final Pedido pedido;
  const _DetallePedidoPage({required this.pedido});

  @override
  State<_DetallePedidoPage> createState() => _DetallePedidoPageState();
}

class _DetallePedidoPageState extends State<_DetallePedidoPage> {
  PedidoDetalle? _detalle;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final d = await ApiService.detallePedido(widget.pedido.idPedido);
      setState(() {
        _detalle = d;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pedido #${widget.pedido.idPedido}')),
      body: (_cargando || _error != null || (_detalle?.detalles.isEmpty ?? true))
          ? EstadoCarga(
              cargando: _cargando,
              error: _error,
              vacio: _detalle?.detalles.isEmpty ?? true,
              onReintentar: _cargar,
              mensajeVacio: 'Este pedido no tiene productos.',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_detalle!.pedido.cliente.isEmpty ? 'Sin cliente' : _detalle!.pedido.cliente,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Mesa ${_detalle!.pedido.mesa} · ${_detalle!.pedido.fecha}',
                            style: const TextStyle(color: AppColors.inkMuted)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Productos', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ..._detalle!.detalles.map((d) => Card(
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
                    Text('\$${_detalle!.pedido.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, color: AppColors.gold, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
    );
  }
}
