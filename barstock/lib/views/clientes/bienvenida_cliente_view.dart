import 'package:flutter/material.dart';
import '../../controllers/sesion_cliente_controller.dart';
import '../../theme/app_theme.dart';
import '../../theme/global_theme.dart';
import '../login_view.dart';
import 'productos_cliente_view.dart';

/// Primera pantalla que ve el cliente al abrir la app (por ejemplo, tras
/// escanear el QR de su mesa). Solo pide nombre y correo — sin contraseña,
/// sin cuenta — y arranca la sesión de 15 minutos para hacer su pedido.
///
/// [mesaInicial] permite prellenar el número de mesa si en el futuro el QR
/// codifica un enlace del tipo `.../mesa/5` y se decodifica antes de llegar
/// aquí (deep link). Por ahora el cliente puede escribirla a mano.
class BienvenidaClienteView extends StatefulWidget {
  final String? mesaInicial;
  const BienvenidaClienteView({super.key, this.mesaInicial});

  @override
  State<BienvenidaClienteView> createState() => _BienvenidaClienteViewState();
}

class _BienvenidaClienteViewState extends State<BienvenidaClienteView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  late final _mesaCtrl = TextEditingController(text: widget.mesaInicial ?? '');

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _mesaCtrl.dispose();
    super.dispose();
  }

  void _continuar() {
    if (!_formKey.currentState!.validate()) return;

    final sesion = SesionClienteController(
      nombre: _nombreCtrl.text.trim(),
      correo: _correoCtrl.text.trim(),
      mesa: _mesaCtrl.text.trim(),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ProductosClienteView(sesion: sesion)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: GoldBadge(icono: Icons.local_bar_rounded, size: 72)),
                  const SizedBox(height: 20),
                  Text(
                    'Bienvenido a Barstock',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Solo necesitamos tu nombre y correo para tomar tu pedido.\n'
                    'Tendrás 15 minutos para completarlo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.inkMuted, fontSize: 13.5),
                  ),
                  const SizedBox(height: 36),
                  TextFormField(
                    controller: _nombreCtrl,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(color: AppColors.ink),
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.gold),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Ingresa tu nombre';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _correoCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.ink),
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      prefixIcon: Icon(Icons.mail_outline_rounded, color: AppColors.gold),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                      if (!v.contains('@') || !v.contains('.')) return 'Correo inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _mesaCtrl,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(color: AppColors.ink),
                    decoration: const InputDecoration(
                      labelText: 'Número de mesa',
                      prefixIcon: Icon(Icons.table_bar_outlined, color: AppColors.gold),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Ingresa el número de tu mesa';
                      return null;
                    },
                    onFieldSubmitted: (_) => _continuar(),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: _continuar,
                    child: const Text('Ver productos'),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginView()),
                      ),
                      child: const Text('Acceso para personal'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
