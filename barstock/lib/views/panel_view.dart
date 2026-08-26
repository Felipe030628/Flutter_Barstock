import 'package:flutter/material.dart';
import '../models/dashboard.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/global_theme.dart';

class PanelView extends StatefulWidget {
  const PanelView({super.key});

  @override
  State<PanelView> createState() => _PanelViewState();
}

class _PanelViewState extends State<PanelView> {
  Dashboard? _data;
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
      final d = await ApiService.obtenerDashboard();
      setState(() {
        _data = d;
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
      appBar: AppBar(title: const Text('Panel')),
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: _cargar,
        child: (_cargando || _error != null)
            ? EstadoCarga(
                cargando: _cargando,
                error: _error,
                vacio: false,
                onReintentar: _cargar,
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(child: _Kpi(titulo: 'Caja de hoy', valor: '\$${_data!.caja.toStringAsFixed(2)}', icono: Icons.point_of_sale_rounded)),
                      const SizedBox(width: 12),
                      Expanded(child: _Kpi(titulo: 'Stock crítico', valor: '${_data!.critico}', icono: Icons.warning_amber_rounded, color: AppColors.danger)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Kpi(titulo: 'Variedad de productos', valor: '${_data!.variedad}', icono: Icons.category_rounded),
                  const SizedBox(height: 24),
                  const SectionLabel('Productos más solicitados'),
                  const SizedBox(height: 12),
                  if (_data!.topProductos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Sin datos de ventas todavía.', style: TextStyle(color: AppColors.inkMuted)),
                    )
                  else
                    ..._data!.topProductos.map((p) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const GoldBadge(icono: Icons.trending_up_rounded, size: 40),
                            title: Text(p.nombre),
                            subtitle: Text('${p.cantidad} unidades vendidas'),
                            trailing: Text('\$${p.monto.toStringAsFixed(2)}',
                                style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                          ),
                        )),
                  const SizedBox(height: 24),
                  const SectionLabel('Ventas últimos 7 días'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: List.generate(_data!.ventasLabels.length, (i) {
                          final maxVal = _data!.ventasData.isEmpty
                              ? 1.0
                              : _data!.ventasData.reduce((a, b) => a > b ? a : b).clamp(1, double.infinity);
                          final valor = _data!.ventasData[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                SizedBox(width: 40, child: Text(_data!.ventasLabels[i], style: const TextStyle(color: AppColors.inkMuted, fontSize: 12))),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      height: 12,
                                      color: AppColors.panel,
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: (valor / maxVal).clamp(0.03, 1.0),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(colors: [AppColors.goldDeep, AppColors.gold]),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 60,
                                  child: Text('\$${valor.toStringAsFixed(0)}', textAlign: TextAlign.end, style: const TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const _Kpi({required this.titulo, required this.valor, required this.icono, this.color = AppColors.gold});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GoldBadge(icono: icono, size: 40, color: color),
            const SizedBox(height: 12),
            Text(valor, style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(titulo, style: const TextStyle(color: AppColors.inkMuted, fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}
