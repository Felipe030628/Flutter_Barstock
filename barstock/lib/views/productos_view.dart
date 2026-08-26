import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/global_theme.dart';

class ProductosView extends StatefulWidget {
  const ProductosView({super.key});

  @override
  State<ProductosView> createState() => _ProductosViewState();
}

class _ProductosViewState extends State<ProductosView> {
  List<Producto> _todos = [];
  List<Producto> _filtrados = [];
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
      final lista = await ApiService.listarProductos();
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
    _filtrados = _todos.where((p) => p.nombre.toLowerCase().contains(q)).toList();
  }

  Future<void> _eliminar(Producto p) async {
    final ok = await confirmarEliminar(context, p.nombre);
    if (!ok) return;
    try {
      await ApiService.eliminarProducto(p.id);
      if (!mounted) return;
      setState(() {
        _todos.removeWhere((x) => x.id == p.id);
        _aplicarFiltro();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${p.nombre}" eliminado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $e')),
      );
    }
  }

  Color _colorStock(int stock) {
    if (stock <= 0) return AppColors.danger;
    if (stock <= 5) return AppColors.goldSoft;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: _cargar,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: BuscadorField(
                hint: 'Buscar producto...',
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
                      mensajeVacio: 'No hay productos registrados.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filtrados.length,
                      itemBuilder: (context, i) {
                        final p = _filtrados[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: const GoldBadge(icono: Icons.liquor_rounded, size: 44),
                            title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${p.nomCategoria.isEmpty ? "Sin categoría" : p.nomCategoria} · Vence: ${p.fechaVencimiento.isEmpty ? "-" : p.fechaVencimiento}',
                                style: const TextStyle(color: AppColors.inkMuted, fontSize: 12),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('\$${p.precio.toStringAsFixed(2)}',
                                        style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                                    Text('Stock: ${p.stock}',
                                        style: TextStyle(color: _colorStock(p.stock), fontSize: 12)),
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
