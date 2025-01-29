import 'package:flutter/material.dart';

// Widget reutilizable de un botón con bordes redondeados
class RoundedButton extends StatelessWidget {
  final String text; // Texto que mostrará el botón
  final VoidCallback
      onPressed; // Función que se ejecutará cuando se presione el botón

  // Constructor para recibir el texto y la acción del botón
  const RoundedButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFC9863C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(horizontal: 65, vertical: 15),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}
