import 'package:flutter/material.dart';
import 'package:furconnect/config/themes/theme.dart';
import 'package:furconnect/config/routes/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FurConnect',
      routerConfig: router,
      theme: AppTheme.theme,
    );
  }
}
