import 'package:flutter/material.dart';
import '../models/categoria.dart';
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
  List<Categoria> _categorias = [];

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
      final resultados = await Future.wait([
        ApiService.listarProductos(),
        ApiService.listarCategorias(),
      ]);

      if (!mounted) return;

      setState(() {
        _todos = resultados[0] as List<Producto>;
        _categorias = resultados[1] as List<Categoria>;
        _aplicarFiltro();
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  void _aplicarFiltro() {
    final q = _busqueda.trim().toLowerCase();

    _filtrados = _todos
        .where((p) => p.nombre.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _abrirFormulario() async {
    if (_categorias.isEmpty) {
      try {
        final categorias = await ApiService.listarCategorias();

        if (!mounted) return;

        setState(() {
          _categorias = categorias;
        });
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudieron cargar las categorías: $e')),
        );
        return;
      }
    }

    if (!mounted) return;

    final resultado = await showDialog<bool>(
      context: context,
      builder: (_) => _FormularioProductoDialog(
        categorias: _categorias,
      ),
    );

    if (resultado == true) {
      await _cargar();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto registrado correctamente.'),
        ),
      );
    }
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
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            tooltip: 'Registrar producto',
            onPressed: _abrirFormulario,
            icon: const Icon(Icons.add_box_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.void_,
        onPressed: _abrirFormulario,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo producto'),
      ),
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: _filtrados.length,
                      itemBuilder: (context, i) {
                        final p = _filtrados[i];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: const GoldBadge(
                              icono: Icons.liquor_rounded,
                              size: 44,
                            ),
                            title: Text(
                              p.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${p.nomCategoria.isEmpty ? "Sin categoría" : p.nomCategoria} · Vence: ${p.fechaVencimiento.isEmpty ? "-" : p.fechaVencimiento}',
                                style: const TextStyle(
                                  color: AppColors.inkMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '\$${p.precio.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppColors.gold,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Stock: ${p.stock}',
                                      style: TextStyle(
                                        color: _colorStock(p.stock),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.danger,
                                  ),
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

class _FormularioProductoDialog extends StatefulWidget {
  final List<Categoria> categorias;

  const _FormularioProductoDialog({
    required this.categorias,
  });

  @override
  State<_FormularioProductoDialog> createState() =>
      _FormularioProductoDialogState();
}

class _FormularioProductoDialogState
    extends State<_FormularioProductoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController(text: '0');

  int? _idCategoria;
  DateTime? _fecha;
  bool _guardando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  String _fechaTexto() {
    if (_fecha == null) return '';

    final y = _fecha!.year.toString().padLeft(4, '0');
    final m = _fecha!.month.toString().padLeft(2, '0');
    final d = _fecha!.day.toString().padLeft(2, '0');

    return '$y-$m-$d';
  }

  Future<void> _seleccionarFecha() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (seleccionada != null) {
      setState(() => _fecha = seleccionada);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_idCategoria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una categoría.')),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final precio = double.parse(
        _precioController.text.trim().replaceAll(',', '.'),
      );
      final stock = int.parse(_stockController.text.trim());

      await ApiService.registrarProducto(
        nombre: _nombreController.text,
        precio: precio,
        fechaVencimiento: _fechaTexto(),
        idCategoria: _idCategoria!,
        stockInicial: stock,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar producto'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Escribe el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precioController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: (v) {
                  final valor = double.tryParse(
                    (v ?? '').trim().replaceAll(',', '.'),
                  );

                  if (valor == null || valor <= 0) {
                    return 'Precio inválido';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _idCategoria,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: widget.categorias
                    .map(
                      (c) => DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.nombre),
                      ),
                    )
                    .toList(),
                onChanged: _guardando
                    ? null
                    : (v) => setState(() => _idCategoria = v),
                validator: (v) =>
                    v == null ? 'Selecciona una categoría' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock inicial',
                  prefixIcon: Icon(Icons.inventory_outlined),
                ),
                validator: (v) {
                  final valor = int.tryParse((v ?? '').trim());

                  if (valor == null || valor < 0) {
                    return 'Stock inválido';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(
                  _fecha == null
                      ? 'Fecha de vencimiento (opcional)'
                      : 'Vence: ${_fechaTexto()}',
                ),
                trailing: IconButton(
                  onPressed: _guardando ? null : _seleccionarFecha,
                  icon: const Icon(Icons.edit_calendar_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
