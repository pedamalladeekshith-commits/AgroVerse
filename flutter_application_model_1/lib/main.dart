import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const AgroVersApp());
}

class AgroVersApp extends StatelessWidget {
  const AgroVersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgroVers',
      theme: appTheme(),
      home: const LoginScreen(),
    );
  }
}