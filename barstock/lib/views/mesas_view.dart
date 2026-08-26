import 'package:flutter/material.dart';
import '../models/mesa.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/global_theme.dart';

class MesasView extends StatefulWidget {
  const MesasView({super.key});

  @override
  State<MesasView> createState() => _MesasViewState();
}

class _MesasViewState extends State<MesasView> {
  List<Mesa> _todas = [];
  List<Mesa> _filtradas = [];
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
      final lista = await ApiService.listarMesas();
      setState(() {
        _todas = lista;
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
    _filtradas = _todas.where((m) => m.numeroMesa.toLowerCase().contains(q)).toList();
  }

  Future<void> _eliminar(Mesa m) async {
    final ok = await confirmarEliminar(context, 'Mesa ${m.numeroMesa}');
    if (!ok) return;
    try {
      await ApiService.eliminarMesa(m.idMesa);
      if (!mounted) return;
      setState(() {
        _todas.removeWhere((x) => x.idMesa == m.idMesa);
        _aplicarFiltro();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mesa eliminada')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
    }
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'libre':
        return AppColors.success;
      case 'ocupado':
        return AppColors.danger;
      default:
        return AppColors.goldSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mesas')),
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: _cargar,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: BuscadorField(
                hint: 'Buscar mesa...',
                onChanged: (v) => setState(() {
                  _busqueda = v;
                  _aplicarFiltro();
                }),
              ),
            ),
            Expanded(
              child: (_cargando || _error != null || _filtradas.isEmpty)
                  ? EstadoCarga(
                      cargando: _cargando,
                      error: _error,
                      vacio: _filtradas.isEmpty,
                      onReintentar: _cargar,
                      mensajeVacio: 'No hay mesas registradas.',
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: _filtradas.length,
                      itemBuilder: (context, i) {
                        final m = _filtradas[i];
                        final color = _colorEstado(m.estado);
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const GoldBadge(icono: Icons.table_restaurant_rounded, size: 40),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                                      onPressed: () => _eliminar(m),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text('Mesa ${m.numeroMesa}',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('Capacidad: ${m.capacidad}',
                                    style: const TextStyle(color: AppColors.inkMuted, fontSize: 12)),
                                const SizedBox(height: 8),
                                EstadoChip(texto: m.estado, color: color),
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
