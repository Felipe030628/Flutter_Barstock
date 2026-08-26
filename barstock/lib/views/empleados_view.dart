import 'package:flutter/material.dart';
import '../models/empleado.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/global_theme.dart';

class EmpleadosView extends StatefulWidget {
  const EmpleadosView({super.key});

  @override
  State<EmpleadosView> createState() => _EmpleadosViewState();
}

class _EmpleadosViewState extends State<EmpleadosView> {
  List<Empleado> _todos = [];
  List<Empleado> _filtrados = [];
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
      final lista = await ApiService.listarEmpleados();
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
        .where((e) => e.nombreCompleto.toLowerCase().contains(q) || e.correo.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _eliminar(Empleado e) async {
    final ok = await confirmarEliminar(context, e.nombreCompleto);
    if (!ok) return;
    try {
      await ApiService.eliminarEmpleado(e.idUsuarios);
      if (!mounted) return;
      setState(() {
        _todos.removeWhere((x) => x.idUsuarios == e.idUsuarios);
        _aplicarFiltro();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Empleado eliminado')));
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $err')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Empleados')),
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: _cargar,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: BuscadorField(
                hint: 'Buscar empleado...',
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
                      mensajeVacio: 'No hay empleados registrados.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filtrados.length,
                      itemBuilder: (context, i) {
                        final e = _filtrados[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: GoldBadge(texto: e.nombre.isNotEmpty ? e.nombre[0].toUpperCase() : '?', size: 44),
                            title: Text(e.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(e.correo, style: const TextStyle(color: AppColors.inkMuted, fontSize: 12)),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                EstadoChip(
                                  texto: e.estaActivo ? 'Activo' : 'Inactivo',
                                  color: e.estaActivo ? AppColors.success : AppColors.danger,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                                  onPressed: () => _eliminar(e),
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
