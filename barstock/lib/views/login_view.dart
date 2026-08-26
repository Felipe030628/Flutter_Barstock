import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/global_theme.dart';
import 'home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();
  bool _ocultarContrasena = true;
  bool _cargando = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _contrasenaCtrl.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      await AuthService.login(
        correo: _correoCtrl.text.trim(),
        contrasena: _contrasenaCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeView()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
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
                    'Barstock',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Inicia sesión para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.inkMuted, fontSize: 13.5),
                  ),
                  const SizedBox(height: 36),
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
                      if (!v.contains('@')) return 'Correo inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contrasenaCtrl,
                    obscureText: _ocultarContrasena,
                    style: const TextStyle(color: AppColors.ink),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.gold),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarContrasena ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.inkMuted,
                        ),
                        onPressed: () => setState(() => _ocultarContrasena = !_ocultarContrasena),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                      return null;
                    },
                    onFieldSubmitted: (_) => _iniciarSesion(),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: _cargando ? null : _iniciarSesion,
                    child: _cargando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.void_),
                          )
                        : const Text('Iniciar sesión'),
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
