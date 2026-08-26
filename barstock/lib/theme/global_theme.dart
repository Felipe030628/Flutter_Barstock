import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Barra de búsqueda flotante reutilizada en todas las vistas de consulta.
class BuscadorField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const BuscadorField({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.panelLine),
        boxShadow: [
          BoxShadow(color: AppColors.void_.withValues(alpha: 0.45), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        cursorColor: AppColors.gold,
        style: const TextStyle(color: AppColors.ink, fontSize: 14.5),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.inkMuted),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gold),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

/// Insignia circular de doble anillo, estilo "moneda de barra", usada como
/// icono o inicial en listas, tarjetas y encabezados de toda la app.
class GoldBadge extends StatelessWidget {
  final IconData? icono;
  final String? texto;
  final double size;
  final Color color;

  const GoldBadge({super.key, this.icono, this.texto, this.size = 44, this.color = AppColors.gold});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.14)),
        alignment: Alignment.center,
        child: icono != null
            ? Icon(icono, color: color, size: size * 0.46)
            : Text(
                texto ?? '?',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: size * 0.36),
              ),
      ),
    );
  }
}

/// Etiqueta de sección tipo "carta de cóctel": mayúsculas, espaciada
/// y con una pequeña línea dorada delante.
class SectionLabel extends StatelessWidget {
  final String texto;
  const SectionLabel(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 2, color: AppColors.gold),
        const SizedBox(width: 8),
        Text(
          texto.toUpperCase(),
          style: const TextStyle(
            color: AppColors.goldSoft,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Chip de estado (Libre/Ocupado, Pendiente/Completado, Activo/Inactivo, etc.).
class EstadoChip extends StatelessWidget {
  final String texto;
  final Color color;

  const EstadoChip({super.key, required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.3),
          ),
        ],
      ),
    );
  }
}

/// Estado central de carga / error / vacío, común a todas las listas.
class EstadoCarga extends StatelessWidget {
  final bool cargando;
  final String? error;
  final bool vacio;
  final VoidCallback onReintentar;
  final String mensajeVacio;

  const EstadoCarga({
    super.key,
    required this.cargando,
    required this.error,
    required this.vacio,
    required this.onReintentar,
    this.mensajeVacio = 'No hay datos para mostrar.',
  });

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator(color: AppColors.gold));
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GoldBadge(icono: Icons.error_outline_rounded, size: 64, color: AppColors.danger),
              const SizedBox(height: 16),
              Text(error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.inkMuted)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    if (vacio) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GoldBadge(icono: Icons.inbox_outlined, size: 64),
              const SizedBox(height: 14),
              Text(mensajeVacio, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.inkMuted)),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

/// Diálogo de confirmación de eliminación, consistente en toda la app.
Future<bool> confirmarEliminar(BuildContext context, String nombre) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.panelAlt,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.panelLine),
      ),
      title: const Row(
        children: [
          GoldBadge(icono: Icons.delete_outline_rounded, size: 40, color: AppColors.danger),
          SizedBox(width: 12),
          Expanded(child: Text('Eliminar registro')),
        ],
      ),
      content: Text('¿Seguro que deseas eliminar "$nombre"? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return res ?? false;
}
