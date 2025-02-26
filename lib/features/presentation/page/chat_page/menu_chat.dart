import 'package:flutter/material.dart';

class MenuChat extends StatelessWidget {
  const MenuChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes'),
      ),
      body: Center(
        child: Text(
          'Pantalla de Chat próximamente...',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
