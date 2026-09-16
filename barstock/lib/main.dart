import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'views/clientes/bienvenida_cliente_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  runApp(const BarstockApp());
}

class BarstockApp extends StatelessWidget {
  const BarstockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barstock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      // El cliente que escanea el QR de su mesa llega directo aquí:
      // solo le pedimos nombre y correo, sin contraseña. El acceso del
      // personal (login con contraseña) queda como un botón discreto
      // dentro de BienvenidaClienteView.
      home: const BienvenidaClienteView(),
    );
  }
}
