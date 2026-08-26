import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'views/login_view.dart';

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
      home: const LoginView(),
    );
  }
}
