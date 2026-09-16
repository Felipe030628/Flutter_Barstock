import 'package:flutter/material.dart';
import '../../controllers/carrito_controller.dart';
import '../../controllers/sesion_cliente_controller.dart';
import '../../models/producto.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/global_theme.dart';
import '../../widgets/sesion_countdown_widget.dart';
import 'carrito_cliente_view.dart';

/// Catálogo que ve el cliente tras identificarse. Agrupa por categoría y
/// permite ir sumando productos a su carrito con un stepper +/-.
class ProductosClienteView extends StatefulWidget {
  final SesionClienteController sesion;
  const ProductosClienteView({super.key, required this.sesion});

  @override
  State<ProductosClienteView> createState() => _ProductosClienteViewState();
}

class _ProductosClienteViewState extends State<ProductosClienteView> {
  final CarritoController _carrito = CarritoController();

  List<Producto> _productos = [];
  bool _cargando = true;
  String? _error;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _carrito.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final lista = await ApiService.listarProductos();
      setState(() {
        _productos = lista.where((p) => p.stock > 0).toList();
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  Map<String, List<Producto>> get _porCategoria {
    final q = _busqueda.toLowerCase();
    final filtrados = _productos.where((p) => p.nombre.toLowerCase().contains(q));
    final mapa = <String, List<Producto>>{};
    for (final p in filtrados) {
      final cat = p.nomCategoria.isEmpty ? 'Otros' : p.nomCategoria;
      mapa.putIfAbsent(cat, () => []).add(p);
    }
    return mapa;
  }

  void _irAlCarrito() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CarritoClienteView(sesion: widget.sesion, carrito: _carrito),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grupos = _porCategoria;
    return SesionExpiradaGuard(
      sesion: widget.sesion,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Mesa ${widget.sesion.mesa}'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(child: SesionCountdownChip(sesion: widget.sesion)),
            ),
          ],
        ),
        body: RefreshIndicator(
          color: AppColors.gold,
          onRefresh: _cargar,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: BuscadorField(
                  hint: 'Buscar producto...',
                  onChanged: (v) => setState(() => _busqueda = v),
                ),
              ),
              Expanded(
                child: (_cargando || _error != null || grupos.isEmpty)
                    ? EstadoCarga(
                        cargando: _cargando,
                        error: _error,
                        vacio: grupos.isEmpty,
                        onReintentar: _cargar,
                        mensajeVacio: 'No hay productos disponibles por ahora.',
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                        children: grupos.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionLabel(entry.key),
                                const SizedBox(height: 10),
                                ...entry.value.map(_tarjetaProducto),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: AnimatedBuilder(
          animation: _carrito,
          builder: (context, _) {
            if (_carrito.estaVacio) return const SizedBox.shrink();
            return FloatingActionButton.extended(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.void_,
              onPressed: _irAlCarrito,
              icon: Badge(
                label: Text('${_carrito.totalUnidades}'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              label: Text('Ver carrito · \$${_carrito.total.toStringAsFixed(2)}'),
            );
          },
        ),
      ),
    );
  }

  Widget _tarjetaProducto(Producto p) {
    return AnimatedBuilder(
      animation: _carrito,
      builder: (context, _) {
        final cantidad = _carrito.cantidadDe(p);
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                GoldBadge(texto: p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : '?', size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text('\$${p.precio.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                if (cantidad == 0)
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.void_),
                    onPressed: () => _carrito.agregar(p),
                    icon: const Icon(Icons.add_rounded),
                  )
                else
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _carrito.quitar(p),
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.inkMuted),
                      ),
                      Text('$cantidad', style: const TextStyle(fontWeight: FontWeight.w700)),
                      IconButton(
                        onPressed: () => _carrito.agregar(p),
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.gold),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
