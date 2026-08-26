import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/global_theme.dart';
import 'panel_view.dart';
import 'productos_view.dart';
import 'movimiento_view.dart';
import 'mesas_view.dart';
import 'pedidos_view.dart';
import 'empleados_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const _opciones = [
    _Opcion('Panel', 'Ventas y resumen del día', Icons.dashboard_rounded, PanelView()),
    _Opcion('Productos', 'Catálogo e inventario', Icons.liquor_rounded, ProductosView()),
    _Opcion('Movimientos', 'Entradas y salidas de stock', Icons.swap_vert_rounded, MovimientoView()),
    _Opcion('Mesas', 'Estado de la sala', Icons.table_restaurant_rounded, MesasView()),
    _Opcion('Pedidos', 'Comandas y cuentas', Icons.receipt_long_rounded, PedidosView()),
    _Opcion('Empleados', 'Equipo del bar', Icons.people_alt_rounded, EmpleadosView()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _Encabezado()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.98,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _TarjetaOpcion(opcion: _opciones[i]),
                childCount: _opciones.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.panel, AppColors.void_],
        ),
        border: Border(bottom: BorderSide(color: AppColors.panelLine)),
      ),
      child: Row(
        children: [
          const GoldBadge(icono: Icons.local_bar_rounded, size: 56),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Barstock', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                const Text(
                  'Control de barra, mesas y stock en un solo lugar',
                  style: TextStyle(color: AppColors.inkMuted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaOpcion extends StatelessWidget {
  final _Opcion opcion;
  const _TarjetaOpcion({required this.opcion});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => opcion.pagina)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GoldBadge(icono: opcion.icono, size: 44),
              const Spacer(),
              Text(opcion.titulo, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 4),
              Text(opcion.subtitulo, style: const TextStyle(color: AppColors.inkMuted, fontSize: 11.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Opcion {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Widget pagina;
  const _Opcion(this.titulo, this.subtitulo, this.icono, this.pagina);
}
