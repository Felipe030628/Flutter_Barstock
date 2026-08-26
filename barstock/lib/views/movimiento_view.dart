import 'package:flutter/material.dart';
import '../models/movimiento.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/global_theme.dart';

class MovimientoView extends StatefulWidget {
  const MovimientoView({super.key});

  @override
  State<MovimientoView> createState() => _MovimientoViewState();
}

class _MovimientoViewState extends State<MovimientoView> {
  List<Movimiento> _todos = [];
  List<Movimiento> _filtrados = [];
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
      final lista = await ApiService.listarMovimientos();
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
        .where((m) => m.nombreProducto.toLowerCase().contains(q) || m.motivo.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _eliminar(Movimiento m) async {
    final ok = await confirmarEliminar(context, '${m.motivo} - ${m.nombreProducto}');
    if (!ok) return;
    try {
      await ApiService.eliminarMovimiento(m.idMovimiento);
      if (!mounted) return;
      setState(() {
        _todos.removeWhere((x) => x.idMovimiento == m.idMovimiento);
        _aplicarFiltro();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Movimiento eliminado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movimientos de stock')),
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: _cargar,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: BuscadorField(
                hint: 'Buscar por producto o motivo...',
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
                      mensajeVacio: 'No hay movimientos registrados.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filtrados.length,
                      itemBuilder: (context, i) {
                        final m = _filtrados[i];
                        final esEntrada = m.esEntrada;
                        final color = esEntrada ? AppColors.success : AppColors.danger;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: GoldBadge(
                              icono: esEntrada ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              color: color,
                              size: 44,
                            ),
                            title: Text(m.nombreProducto, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('${m.motivo} · ${m.fecha}',
                                  style: const TextStyle(color: AppColors.inkMuted, fontSize: 12)),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${esEntrada ? '+' : '-'}${m.cantidad}',
                                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                                  onPressed: () => _eliminar(m),
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
